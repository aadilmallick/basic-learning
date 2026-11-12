# 03 — Structured concurrency, `launch`, `async`, and results

Structured concurrency makes coroutines behave like a task tree instead of untracked background activity. A parent owns child work: it normally waits for children; cancelling it cancels them; and a normal child failure propagates upward.

```kotlin
runBlocking {                    // parent
    launch {                     // child
        launch { refreshA() }    // grandchild
        launch { refreshB() }    // grandchild
    }
}
```

This ownership tree is what prevents leaks, makes cancellation predictable, and lets a request/screen reliably know when its work has finished.

## `launch`: concurrent work with no result

`launch` starts a coroutine and returns a `Job`.

```kotlin
val saveJob: Job = launch {
    saveDraft()
}

saveJob.join()   // suspend until it is complete
saveJob.cancel() // request cancellation
```

Use it when completing the action is the point, rather than obtaining a value: update state, send telemetry, refresh a cache, or run independent child work. “Fire and forget” should mean “the scope still owns it,” not “nobody can track it.”

## `async`: concurrent work that computes a value

`async` starts a coroutine and returns `Deferred<T>`, a future-like handle to a value.

```kotlin
val profile: Deferred<Profile> = async { api.loadProfile() }
val value: Profile = profile.await() // suspends, rather than blocks
```

Use it when tasks are independent, can genuinely overlap, and you need their results.

```kotlin
suspend fun loadScreen(): Screen = coroutineScope {
    val profile = async { api.loadProfile() }
    val notifications = async { api.loadNotifications() }

    Screen(
        profile = profile.await(),
        notifications = notifications.await()
    )
}
```

Both requests begin before either `await`. If they each take 300 ms, this can approach 300 ms rather than 600 ms—subject to connection, server, and CPU limits.

## A direct call versus `async`

```kotlin
// Sequential: B begins after A completes.
val a = fetchA()
val b = fetchB()

// Concurrent: both child coroutines are created before awaiting either.
val aDeferred = async { fetchA() }
val bDeferred = async { fetchB() }
val a = aDeferred.await()
val b = bDeferred.await()
```

Do not reach for `async` by default. It adds scheduling, failure, and cancellation relationships. Use it only when concurrency is safe and useful. For dependent work, sequential code is clearer and correct:

```kotlin
val account = api.loadAccount(id)
val invoices = api.loadInvoices(account.id) // depends on account
```

## `coroutineScope` is the usual concurrent-operation boundary

Without an explicit nested scope, a suspend function cannot call `async` unless it was given a scope receiver—which often tempts unstructured designs. Prefer this pattern:

```kotlin
suspend fun buildDashboard(): Dashboard = coroutineScope {
    val user = async { repository.user() }
    val activity = async { repository.activity() }
    Dashboard(user.await(), activity.await())
}
```

The function does not return until all children complete. If the caller cancels it, both requests are cancelled. Failure behavior is covered next.

## Lazy `async`: uncommon but useful

By default, `async` starts immediately. `CoroutineStart.LAZY` defers start until `start()` or first `await()`.

```kotlin
val token = async(start = CoroutineStart.LAZY) { refreshToken() }
if (needsToken) token.await()
```

This can avoid unnecessary work, but it often makes timing harder to see. Prefer ordinary immediate `async` unless laziness is intentional. Lazy children still participate in structured completion; if never started/awaited, a parent waiting for children can wait indefinitely.

## `join` versus `await`

| Handle | Wait operation | Produces |
|---|---|---|
| `Job` from `launch` | `join()` | completion only |
| `Deferred<T>` from `async` | `await()` | the `T`, or throws its failure |

Both operations suspend the caller instead of blocking a thread.

## Anti-pattern: returning `Deferred` from ordinary service APIs

Usually, expose a suspend function:

```kotlin
// Preferred: caller decides scope, timing, and concurrency.
suspend fun loadUser(id: String): User = api.user(id)
```

Instead of:

```kotlin
// Often problematic: API secretly chooses scope/lifetime.
fun loadUser(id: String): Deferred<User> = GlobalScope.async { api.user(id) }
```

The caller can compose the first version inside its own `coroutineScope`; it retains cancellation and error ownership.

## Key takeaways

1. `launch` returns `Job`: use it for owned work without a required value.
2. `async` returns `Deferred<T>`: use it for concurrent work whose result you need.
3. `await`/`join` suspend; they do not block.
4. Make concurrent work a structured child of the operation that needs it.

