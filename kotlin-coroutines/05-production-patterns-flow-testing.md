# 05 — Production patterns, Flow, testing, and design

This final part turns the earlier mechanics into code you can maintain. The goal is not “put coroutines everywhere”; it is explicit ownership, cancellation, error behavior, and execution policy.

## Layering pattern: suspend below, launch at the lifecycle edge

Repositories and use cases usually expose suspending functions (or `Flow`). The layer that owns a lifecycle launches them.

```kotlin
class UserRepository(private val api: UserApi) {
    suspend fun getUser(id: String): User = api.getUser(id)
}

class UserViewModel(private val repository: UserRepository) : ViewModel() {
    private val _state = MutableStateFlow<UserUiState>(UserUiState.Loading)
    val state: StateFlow<UserUiState> = _state

    fun load(id: String) {
        viewModelScope.launch {
            _state.value = UserUiState.Loading
            _state.value = try {
                UserUiState.Ready(repository.getUser(id))
            } catch (e: IOException) {
                UserUiState.Error("Could not load user")
            }
        }
    }
}
```

This lets the ViewModel cancellation stop the request, preserves testability, and keeps UI policy out of the repository. Avoid a repository silently launching `GlobalScope` work: it severs these guarantees.

## Flow: a stream, not a coroutine replacement

`Flow<T>` represents an asynchronous sequence of values. A suspend function produces one eventual result; a flow can produce zero, one, or many values over time.

```kotlin
fun observeTemperature(): Flow<Int> = flow {
    while (currentCoroutineContext().isActive) {
        emit(sensor.read())
        delay(1_000)
    }
}
```

Most flows are **cold**: defining one does not start work; each collector starts its own collection.

```kotlin
observeTemperature().collect { value ->
    println(value)
}
```

Use operators to transform streams declaratively:

```kotlin
val names: Flow<String> = users
    .filter { it.isActive }
    .map { it.displayName }
    .distinctUntilChanged()
```

`StateFlow` is a hot, state-holder flow with a current value; it is a strong default for observable UI state. `SharedFlow` is a hot broadcast stream, useful for events when you have intentionally designed their delivery semantics. Hot streams require a deliberate ownership/lifetime strategy.

## Flow cancellation and collection

`collect` is suspending and collection obeys the collecting coroutine’s cancellation. In Android UI code, collect according to visible lifecycle rather than merely creating a forever collector. Framework lifecycle APIs provide patterns such as `repeatOnLifecycle` for this purpose.

Avoid catching cancellation in a Flow with a broad `.catch` and emitting an error as though cancellation were a business failure. Flow operators participate in the same cooperative cancellation model covered in part 4.

## Backpressure and latest-value work

If producers outpace consumers, define what must happen to old values. Useful tools include:

| Tool | Intent |
|---|---|
| `buffer()` | allow producer and consumer to overlap up to a bounded buffer |
| `conflate()` | keep only the newest value when consumer is slow |
| `collectLatest` | cancel prior handling when a newer value arrives |
| `debounce()` | wait for an input pause, e.g. search typing |

```kotlin
searchQueries
    .debounce(300)
    .distinctUntilChanged()
    .collectLatest { query ->
        // A new query cancels this old search.
        showResults(repository.search(query))
    }
```

`collectLatest` is ideal for superseded work, but wrong for work that must always complete (for example, charging a payment).

## Callback bridges

Use `suspendCancellableCoroutine` to adapt a one-shot callback API, and unregister/cancel the underlying request when the coroutine is cancelled.

```kotlin
suspend fun legacyFetch(id: String): User = suspendCancellableCoroutine { continuation ->
    val request = legacyClient.fetch(id,
        onSuccess = { user -> continuation.resume(user) {} },
        onFailure = { error -> continuation.resumeWithException(error) }
    )
    continuation.invokeOnCancellation { request.cancel() }
}
```

For repeated callbacks, use `callbackFlow` and `awaitClose` to remove listeners. The essential rule is symmetrical resource management: register on collection; unregister on cancellation/close.

## Testing coroutine code

Use `kotlinx-coroutines-test` and `runTest`. It provides virtual time for `delay`, avoids real waits, and reports uncompleted child work.

```kotlin
@Test
fun `refresh exposes loaded state`() = runTest {
    val dispatcher = StandardTestDispatcher(testScheduler)
    val repository = FakeRepository(dispatcher)
    val viewModel = UserViewModel(repository)

    viewModel.load("42")
    advanceUntilIdle()

    assertEquals(UserUiState.Ready(FakeRepository.user), viewModel.state.value)
}
```

Inject dispatchers (or a dispatcher provider) into code that performs blocking/CPU context shifts. Do not use real `Thread.sleep` in coroutine tests. When testing Flow, collect only the values needed and cancel the collection; test tools such as Turbine can make stream assertions ergonomic.

## A review checklist

When reviewing coroutine code, ask:

1. Which real owner cancels this work?
2. Does the API expose `suspend`/`Flow` rather than secretly choosing a scope?
3. Is concurrency necessary, safe, and structured?
4. Does a blocking call run off a sensitive thread on the right dispatcher?
5. What happens when a child fails—should it cancel siblings or be supervised?
6. Does error handling rethrow `CancellationException`?
7. Are Flow collection, callback registration, and cleanup tied to lifecycle?
8. Can a test control time and dispatchers deterministically?

## Final mental model

Coroutines are not “background threads with nicer syntax.” They are structured tasks. Suspension makes waiting efficient; contexts decide scheduling; jobs define lifetime; scopes establish ownership; and cancellation/failure rules keep concurrent work tractable. If you decide those four things—owner, result, dispatcher, failure policy—your coroutine code will be clear and resilient.

