# 01 — Execution, threads, and suspension

## The problem coroutines solve

A **thread** is an operating-system execution resource. It has a stack, scheduling overhead, and a finite supply. If a thread calls a blocking API, it cannot do anything else until that API returns.

```kotlin
Thread.sleep(1_000) // The current thread is unusable for one second.
```

Applications often spend much of their time waiting for I/O: a network response, database query, timer, or user input. Giving every waiting task its own thread does not scale well.

A **coroutine** is a task managed by Kotlin and `kotlinx.coroutines`. At a suspension point it can save its state, release its underlying thread, and later resume. One pool of threads can therefore serve many waiting coroutines.

```kotlin
import kotlinx.coroutines.*

fun main() = runBlocking {
    launch {
        println("start: ${Thread.currentThread().name}")
        delay(1_000)              // suspends this coroutine; does not block the thread
        println("finish: ${Thread.currentThread().name}")
    }
    println("parent continues immediately")
}
```

The exact thread name is not the lesson. A coroutine can resume on a different eligible thread after a suspension. The lesson is that `delay` frees the thread while the coroutine waits; `Thread.sleep` does not.

## Concurrency is not parallelism

**Concurrency** means tasks make progress during overlapping time periods. **Parallelism** means tasks literally execute simultaneously on separate cores/threads. Coroutines make concurrency cheap; parallel CPU execution still needs available threads and cores.

```kotlin
suspend fun fetchBothSequentially(): Pair<String, String> {
    val a = fetchA() // begins and completes first
    val b = fetchB() // only then begins
    return a to b
}
```

The fact that `fetchA` is `suspend` does *not* make this concurrent. Direct calls remain sequential. You will create concurrent children with `launch` or `async` in part 3.

## What `suspend` means

`suspend` marks a function that may suspend the coroutine calling it:

```kotlin
suspend fun loadGreeting(): String {
    delay(300)
    return "Hello"
}
```

It can be invoked only from another suspend function or a coroutine body:

```kotlin
suspend fun welcome(): String = loadGreeting()

fun main() = runBlocking {
    println(loadGreeting())
}
```

It does **not** mean any of these:

- runs on a background thread;
- runs concurrently;
- is automatically non-blocking;
- creates a new coroutine.

It is a capability in the function signature: “this call may pause the caller.” A suspending function can execute ordinary synchronous code before or after it suspends.

## What the compiler does conceptually

Kotlin compiles a suspend function into a state machine. At a possible suspension point, it retains the local state and a continuation—roughly, “what to do next.” If the operation is not ready, it returns control to the dispatcher. When ready, the continuation is scheduled to resume.

You should not code against generated continuations in normal application code. The useful consequence is: **locals survive suspension, but the thread is not reserved.**

```kotlin
suspend fun example(): Int {
    val subtotal = 40
    delay(10)
    return subtotal + 2 // `subtotal` is still available after resumption
}
```

Suspension only occurs at suspension points. A long CPU loop with no suspension does not voluntarily yield and may monopolize its thread.

## Blocking vs suspending APIs

| Need | Prefer | Why |
|---|---|---|
| Wait for a timer | `delay` | suspends rather than blocks |
| Wait for a coroutine result | `await`, `join` | suspends rather than blocks |
| Switch around a blocking SDK / JDBC / file API | `withContext(Dispatchers.IO)` | limits blocking work to the I/O dispatcher |
| Wait in a CLI/test entry point | `runBlocking` | intentionally bridges to blocking code |

```kotlin
suspend fun readLegacyFile(path: String): String = withContext(Dispatchers.IO) {
    java.io.File(path).readText() // blocking API, deliberately isolated
}
```

Do not put every suspend function on `Dispatchers.IO`. A well-designed suspending HTTP or database library already waits without blocking; switching dispatchers around it adds overhead and can obscure ownership.

## First principles exercise

For each line, predict whether it blocks a thread, suspends a coroutine, or neither:

```kotlin
Thread.sleep(50)
delay(50)
println("done")
```

Answer: `sleep` blocks; `delay` suspends; `println` does neither (though real output may have its own I/O cost). The vocabulary is important because “async” is often incorrectly used for all three.

## Key takeaways

1. Threads are execution resources; coroutines are tasks that use them.
2. Suspension frees a thread; blocking does not.
3. `suspend` permits pausing; it does not choose a thread or create concurrency.
4. Direct suspend calls are sequential unless you explicitly introduce concurrent child work.

