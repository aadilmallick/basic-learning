# 02 — Context, dispatchers, and scopes

Every coroutine has a `CoroutineContext`: an immutable collection of elements that describes its execution and lifetime. Context is inherited from parent to child, and elements can be added or replaced using `+`.

```kotlin
launch(Dispatchers.IO + CoroutineName("invoice-import")) {
    // Inherits the parent Job unless a different one is explicitly supplied.
}
```

## The context elements that matter most

| Element | Job |
|---|---|
| `Job` | lifecycle, parent/child relationship, cancellation, completion |
| `CoroutineDispatcher` | schedules execution on a thread/pool |
| `CoroutineName` | useful diagnostic label |
| `CoroutineExceptionHandler` | last-resort handler for eligible uncaught failures |

The context is not a thread. The dispatcher is a scheduling policy; it may use a pool, and a coroutine can resume on another thread in that pool after suspension.

## Dispatchers: decide based on work, not function names

```kotlin
withContext(Dispatchers.Default) {
    // CPU-bound: image transform, parsing, expensive calculation
}

withContext(Dispatchers.IO) {
    // Blocking I/O: JDBC, blocking filesystem API, legacy HTTP client
}
```

| Dispatcher | Suitable work |
|---|---|
| `Dispatchers.Default` | CPU-bound tasks; sized around available CPU resources |
| `Dispatchers.IO` | Blocking I/O; designed to tolerate more blocking tasks |
| `Dispatchers.Main` | UI state and rendering work (Android/UI platforms) |
| `Dispatchers.Unconfined` | specialized behavior; rarely appropriate in production |

`withContext` changes context for a *block* and returns its result. It is not a fire-and-forget builder.

```kotlin
suspend fun decodeAndShow(bytes: ByteArray) {
    val image = withContext(Dispatchers.Default) { decode(bytes) }
    // The caller's dispatcher is restored here.
    show(image)
}
```

Dispatching is a performance and correctness concern. On Android, blocking `Main` freezes the UI. On a server, blocking a scarce request/compute thread harms throughput. Conversely, moving a tiny non-blocking operation between dispatchers for no reason is needless complexity.

## `CoroutineScope`: ownership, not merely a place to launch

A `CoroutineScope` carries a context and defines the lifetime to which coroutines belong. In good application design, scopes correspond to real owners:

- an Android `ViewModel` (`viewModelScope`);
- a UI lifecycle (`lifecycleScope`);
- a server request;
- a command-line program;
- a test.

```kotlin
class ProfileViewModel : ViewModel() {
    fun refresh() {
        viewModelScope.launch {
            state.value = State.Loading
            state.value = try {
                State.Ready(repository.load())
            } catch (e: IOException) {
                State.Error(e.message ?: "Network error")
            }
        }
    }
}
```

When that ViewModel is cleared, `viewModelScope` is cancelled and the work stops cooperatively. That is the desired default: the owner has disappeared, so its work no longer consumes resources or updates stale UI.

## Important scopes and scope builders

### `runBlocking`

Bridges ordinary blocking code to coroutines by blocking its current thread until the block and its children finish.

```kotlin
fun main() = runBlocking {
    println(loadGreeting())
}
```

Use it in a small CLI entry point or legacy boundary, and in limited test scenarios. Do not use it in UI callbacks, server handlers, or inside a suspend function: it can block a thread unnecessarily and can deadlock constrained dispatchers.

### `coroutineScope`

Creates a child structured scope and **suspends** the caller until all children finish. It does not block a thread.

```kotlin
suspend fun refreshAll() = coroutineScope {
    launch { refreshProfile() }
    launch { refreshTasks() }
}
```

Use it to say: “these child tasks comprise this operation; it succeeds only when they all finish.”

### `supervisorScope`

Like `coroutineScope`, except a child failure does not automatically cancel its siblings. Part 4 explains the failure semantics and when to use it.

## Avoid detached ownership

`GlobalScope.launch` makes a top-level coroutine with no ordinary lifecycle owner. It is nearly always a mistake in application code:

```kotlin
// Avoid: caller cannot naturally await, cancel, or receive failures from this work.
GlobalScope.launch { repository.sync() }
```

Prefer a suspend function at the lower layer and launch it where a real lifecycle is owned:

```kotlin
class Repository {
    suspend fun sync() { /* ... */ }
}

class SyncViewModel(private val repository: Repository) : ViewModel() {
    fun sync() = viewModelScope.launch { repository.sync() }
}
```

## Context inheritance and explicit dependencies

Children inherit their parent's context by default. Library/domain code should usually avoid hard-coding a dispatcher; the application boundary supplies it. When a component legitimately needs a dispatcher, inject it so behavior is testable:

```kotlin
class ReportRepository(private val io: CoroutineDispatcher) {
    suspend fun load(): Report = withContext(io) { blockingClient.fetchReport() }
}
```

This is preferable to burying `Dispatchers.IO` everywhere, because a test can provide a test dispatcher and production wiring can make the policy explicit.

## Key takeaways

1. Context combines lifetime (`Job`) and scheduling (`Dispatcher`) concerns.
2. A dispatcher is not a permanently assigned thread.
3. Tie work to a real owner; use `runBlocking` only at blocking boundaries.
4. `withContext` is the focused tool for switching context and returning a result.

