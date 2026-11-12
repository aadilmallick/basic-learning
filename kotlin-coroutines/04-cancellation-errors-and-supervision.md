# 04 — Cancellation, errors, and supervision

## Cancellation is cooperative

`job.cancel()` requests cancellation. Kotlin cannot safely kill arbitrary code at an arbitrary instruction, so a coroutine must reach a cancellation check or suspension point.

Most coroutine primitives cooperate automatically: `delay`, `yield`, `await`, channel operations, and many library suspend APIs. CPU-heavy loops must cooperate explicitly.

```kotlin
suspend fun calculate(items: List<Item>): Result {
    var total = 0L
    for (item in items) {
        coroutineContext.ensureActive() // throws CancellationException if cancelled
        total += expensiveCalculation(item)
    }
    return Result(total)
}
```

For loops where `ensureActive` is awkward, `yield()` gives other work an opportunity to run and checks cancellation. For callback-style loops, `isActive` can be useful, but make sure the loop actually exits.

## Never swallow `CancellationException`

Cancellation is represented by `CancellationException`. Broad error handling that catches it and continues breaks cancellation:

```kotlin
try {
    repository.load()
} catch (e: Exception) {
    showError(e) // Wrong: this also catches cancellation.
}
```

Instead, rethrow it:

```kotlin
try {
    repository.load()
} catch (e: CancellationException) {
    throw e
} catch (e: Exception) {
    showError(e)
}
```

Often the cleanest design is to catch only the expected domain/I/O failures, not `Exception`.

## Normal structured failure: failure is contagious

In a `coroutineScope`, a non-cancellation exception from a child cancels its parent and siblings.

```kotlin
suspend fun loadPage() = coroutineScope {
    launch { loadMainContent() }
    launch {
        delay(50)
        error("recommendations service failed")
    }
    launch { loadSomethingSlow() } // cancelled after sibling failure
}
```

This behavior is correct when children form one all-or-nothing operation: an incomplete database transaction or a page that cannot work without authentication should fail as a unit.

With `async`, the exception is observed by `await()`, but do not infer it is isolated. In an ordinary structured parent, a failed async child still cancels the scope. Catch at the correct scope boundary or choose supervision.

## `supervisorScope`: independent children

Use `supervisorScope` only when individual failures are acceptable and you deliberately handle each outcome.

```kotlin
suspend fun loadDashboard(): Dashboard = supervisorScope {
    val account = async { api.account() }
    val recommendations = async { api.recommendations() }

    Dashboard(
        account = account.await(), // essential: page still requires this
        recommendations = runCatching { recommendations.await() }
            .getOrElse { emptyList() }
    )
}
```

A supervisor stops sibling-to-sibling failure propagation; it does not make errors vanish. You must `await` and handle an `async` failure, or provide appropriate reporting for a `launch` child.

`SupervisorJob()` applies the same supervision relationship to a long-lived scope, such as a component where independently launched jobs should not take each other down. It is not a replacement for deciding what error behavior each operation needs.

## Exception handling: where it belongs

Treat exceptions at a boundary that can make a product decision:

- repository maps transport exceptions to domain errors when useful;
- ViewModel/controller maps domain results/errors to UI/API response;
- application root logs unexpected uncaught failures.

`CoroutineExceptionHandler` is a last-resort reporter for uncaught exceptions in root `launch` coroutines. It is not a `try/catch` replacement and it does not recover an `async` result you intend to await.

```kotlin
val handler = CoroutineExceptionHandler { _, throwable ->
    logger.error("Unexpected background failure", throwable)
}

scope.launch(handler) { backgroundMaintenance() }
```

## Cleanup and `finally`

`finally` runs during cancellation, so use it to release resources.

```kotlin
try {
    connection.open()
    process(connection)
} finally {
    connection.close()
}
```

The coroutine is already cancelled inside `finally`. A suspend cleanup action therefore needs `withContext(NonCancellable)` sparingly, with a bounded timeout if possible:

```kotlin
finally {
    withContext(NonCancellable) {
        withTimeout(2_000) { auditClient.flush() }
    }
}
```

Do not use `NonCancellable` to keep ordinary abandoned work running; reserve it for essential, short cleanup.

## Timeouts

`withTimeout` cancels its block if the deadline expires; `withTimeoutOrNull` turns expiry into `null`.

```kotlin
val cachedOrFresh = withTimeoutOrNull(500) { api.fetch() } ?: cache.read()
```

Timeout is cancellation. Ensure code in the timed block follows the same cancellation rules.

## Key takeaways

1. Cancellation is a request and must be cooperatively observed.
2. Never turn cancellation into an ordinary error and continue.
3. Default structured concurrency is all-or-nothing; use supervision only for intentionally independent work.
4. Handle errors where you can make a meaningful recovery decision.

