# Learn Redis with Node.js

> [@First Principles Coding Coach](plugin://gpt-0dbcc877a99734ed25e7e95afab64010@workspace-shared-with-me) Teach me redis from beginning to advanced, in the context of the normal redis language and also using redis with nodeJS servers

<details><summary>2 previous messages</summary>

> I’m using the First Principles Coding Coach skill to build a step-by-step Redis course, pairing Redis commands with Node.js server examples.
>
> <details><summary>Ran a command, searched the web</summary>
>
> - Ran `Get-Content -LiteralPath 'C:/Users/amallick.ENGINEERS/.codex/plugins/cache/workspace-shared-with-me/gpt-0dbcc877a99734ed25e7e95afab64010/0.3.1+bundle.053dd2c6e205b232cb2c9fb1f93d9a9b/skills/instructions/SKILL.md'`
>
> Searched the web for `site.redis.io docs node redis connect set EX quit close ...`
>
> Searched the web for `https://redis.io/docs/latest/commands/set/`
>
> </details>
</details>

We’ll learn Redis through its native commands and the equivalent Node.js code, building from simple storage to reliable server applications.

I’ll assume basic JavaScript familiarity. I’ll explain the networking, asynchronous code, and database concepts as they become necessary. We’ll work through this in lessons so each advanced topic has a clear foundation.

## 1. What problem does Redis solve?

Imagine a Node.js server that reads a product from a database:

```text
Browser → Node.js server → Database
```

If thousands of requests ask for the same product, the server may repeat the same database work thousands of times.

One solution is to keep a temporary copy in a JavaScript `Map`:

```js
const products = new Map();

products.set("product:42", {
  name: "Keyboard",
  price: 80
});
```

This works within that Node.js process. But suppose your application runs on three servers:

- Each server has its own `Map`.
- Updating one server’s copy does not update the others.
- Restarting a process loses its copy.

Redis provides a separate service that all those servers can access:

```text
Node.js server A ─┐
Node.js server B ─┼──→ Redis
Node.js server C ─┘
```

**Redis is a database built around fast operations on data held primarily in memory.** It supports persistence to disk, so “in memory” does not automatically mean “temporary.” It also provides useful data structures and operations beyond storing cached values. [Redis overview](https://redis.io/about/)

Common applications include cached database results, sessions, counters, leaderboards, rate limits, and messaging.

## 2. What is the “Redis language”?

Redis normally uses **commands**, rather than a general-purpose programming language.

For example:

```redis
SET greeting "Hello"
GET greeting
```

You can send those commands through:

- **`redis-cli`**: an interactive terminal client.
- **A Node.js client library**: JavaScript methods that send Redis commands.

Both talk to the same Redis server.

| Redis command | Node.js equivalent |
|---|---|
| `SET greeting "Hello"` | `await client.set("greeting", "Hello")` |
| `GET greeting` | `await client.get("greeting")` |
| `DEL greeting` | `await client.del("greeting")` |
| `INCR visits` | `await client.incr("visits")` |

Later, Redis also supports server-side programming, including Lua scripts. First, we need to understand the commands those programs coordinate.

## 3. Keys, values, and data types

A **key** identifies a stored value.

```redis
SET user:42:name "Amina"
```

Here:

- `SET` is the command.
- `user:42:name` is the key.
- `"Amina"` is the value.

The colons are a naming convention. Redis does not interpret this key as nested folders or a JavaScript object.

Read it:

```redis
GET user:42:name
```

Result:

```text
"Amina"
```

Overwrite it:

```redis
SET user:42:name "Sam"
```

Now `GET user:42:name` returns `"Sam"`.

`SET` creates or replaces a string value. Redis strings can contain text, serialized JSON, or other bytes. [SET documentation](https://redis.io/docs/latest/commands/set/)

Redis also has structured value types:

| Type | What it represents | Example use |
|---|---|---|
| String | A sequence of bytes | Cached JSON, a counter |
| Hash | Field–value pairs | User profile fields |
| List | An ordered sequence | Recent activity |
| Set | Unique members | Users who liked a post |
| Sorted set | Unique members with scores | A leaderboard |
| Stream | An append-only sequence of entries | Events processed by workers |

**The data type determines which operations Redis can perform on the value.** We’ll learn each through a practical problem. [Redis data types](https://redis.io/docs/latest/develop/data-types/)

## 4. Run Redis locally

If you have Docker Desktop installed and running, use this terminal command:

```powershell
docker run -d --name redis-learning -p 127.0.0.1:6379:6379 redis:8
```

This starts a Redis container and makes its port available locally at `localhost:6379`.

Open its command-line client:

```powershell
docker exec -it redis-learning redis-cli
```

Inside `redis-cli`, enter:

```redis
PING
```

Expected response:

```text
PONG
```

Your terminal is now a client communicating with the Redis server. This follows the official [Redis Docker setup](https://redis.io/docs/latest/operate/oss_and_stack/install/install-stack/docker/).

## 5. Your first useful commands

Enter these commands individually in `redis-cli`:

```redis
SET lesson:message "Hello Redis"
GET lesson:message
EXISTS lesson:message
DEL lesson:message
GET lesson:message
```

Expected results:

```text
OK
"Hello Redis"
(integer) 1
(integer) 1
(nil)
```

The results mean:

- `SET` stored the value.
- `GET` retrieved it.
- `EXISTS` found the key.
- `DEL` removed one key.
- The final `GET` found no value.

**A missing value is different from an empty string.** In Node.js, an ordinary missing `GET` result is `null`.

### Expiration: let Redis remove a value automatically

Suppose you want a value to live for 60 seconds:

```redis
SET lesson:temporary "Hello" EX 60
TTL lesson:temporary
```

`EX 60` sets an expiration in seconds. `TTL` reports how many seconds remain:

| Result | Meaning |
|---|---|
| Zero or positive number | Remaining lifetime in seconds |
| `-1` | The key exists without expiration |
| `-2` | The key does not exist |

After expiration, `GET lesson:temporary` returns no value. Reading the key does **not** restart its timer. [TTL documentation](https://redis.io/docs/latest/commands/ttl/)

One common mistake: a normal `SET` overwrite removes an existing expiration unless you explicitly preserve or replace it. [SET expiration behavior](https://redis.io/docs/latest/commands/set/)

## 6. Use the same commands from Node.js

Create a learning folder, then run:

```powershell
npm init -y
npm install redis@5
```

Create a file named `basics.mjs`:

```js
import { createClient } from "redis";

const client = createClient({
  url: "redis://localhost:6379"
});

client.on("error", (error) => {
  console.error("Redis connection error:", error);
});

await client.connect();

try {
  await client.set("lesson:message", "Hello from Node.js");

  const message = await client.get("lesson:message");
  console.log(message);

  await client.set("lesson:temporary", "Expires soon", {
    EX: 60
  });

  const remainingSeconds = await client.ttl("lesson:temporary");
  console.log("Remaining seconds:", remainingSeconds);

  await client.del("lesson:message");

  const deletedMessage = await client.get("lesson:message");
  console.log(deletedMessage);
} finally {
  await client.close();
}
```

Run it:

```powershell
node basics.mjs
```

Typical output:

```text
Hello from Node.js
Remaining seconds: 60
null
```

### What the JavaScript means

`createClient()` constructs the client object. `connect()` establishes its connection to Redis.

Redis commands involve network communication, so the methods return **Promises**. `await` pauses this asynchronous flow until the result is available; it does not block the entire Node.js process while waiting for the network.

The option object:

```js
{ EX: 60 }
```

expresses the same expiration as this Redis command:

```redis
SET lesson:temporary "Expires soon" EX 60
```

The error listener handles client error events. `finally` closes the connection when this short script finishes. In a long-running server, you ordinarily connect during startup, reuse the client across requests, and close it during shutdown. [Node.js connection guide](https://redis.io/docs/latest/develop/clients/nodejs/connect/), [node-redis lifecycle documentation](https://github.com/redis/node-redis)

## 7. Store a JavaScript object

Redis string commands do not automatically store JavaScript objects as structured objects.

For a whole object, serialize it:

```js
const product = {
  id: 42,
  name: "Keyboard",
  price: 80
};

await client.set(
  "product:42",
  JSON.stringify(product),
  { EX: 60 }
);
```

Read and deserialize it:

```js
const cached = await client.get("product:42");

if (cached !== null) {
  const product = JSON.parse(cached);
  console.log(product.name);
}
```

These are fragments to place inside the connected script’s `try` block.

The conversion is:

```text
JavaScript object
    → JSON.stringify()
Redis string
    → JSON.parse()
JavaScript object
```

Redis sees this value as a string. A hash is another option when you want Redis to manipulate individual fields.

## 8. Why Redis operations matter: a shared counter

Suppose two Node.js servers increment a counter by reading and rewriting it.

```text
Server A reads 10
Server B reads 10
Server A writes 11
Server B writes 11
```

Two increments occurred, but the final value is only `11`.

Instead, send one command:

```redis
INCR lesson:visits
```

Or, inside your connected Node.js script:

```js
const visits = await client.incr("lesson:visits");
console.log(visits);
```

`INCR` performs the increment atomically: another command cannot interleave between its internal read and update. A missing counter starts from zero, so its first increment returns `1`. [INCR documentation](https://redis.io/docs/latest/commands/incr/)

**One atomic command does not make an entire sequence of commands atomic.** That distinction becomes essential when we build rate limits, transactions, and distributed coordination.

We’ll build on these foundations with data structures and a real Node.js caching endpoint, then progress into concurrency, messaging, persistence, replication, clustering, and production failure handling. The next lesson is **choosing Redis data structures and modeling application data**, using native commands beside their Node.js equivalents.

> continue

## Lesson 2: Choose the right Redis data type

Redis is most useful when you pick a data type that matches the operations your application needs. A product’s fields, a queue of jobs, and a leaderboard all have different access patterns, so they benefit from different Redis structures.

### Hashes: fields in one record

A Redis hash stores named fields under one key. It works well when you want to read or update individual fields of a record.

```redis
HSET user:42 name "Amina" plan "pro" login_count 3
HGET user:42 name
HGETALL user:42
HINCRBY user:42 login_count 1
```

The corresponding Node.js commands are:

```js
await client.hSet("user:42", {
  name: "Amina",
  plan: "pro",
  login_count: 3
});

const name = await client.hGet("user:42", "name");
const user = await client.hGetAll("user:42");
const loginCount = await client.hIncrBy("user:42", "login_count", 1);
```

Redis hash fields and values are strings. The Node.js client returns values as strings too, so convert fields such as `login_count` to numbers when your application needs numeric behavior.

Use a hash when you want to update fields independently. Use a serialized JSON string when you usually read and write the entire object together. With JSON, the application serializes and parses the value; with a hash, Redis can update one field directly.

### Sets: unique membership

A Redis set stores unique members without a meaningful order. This makes it a natural fit for questions such as “Has this user liked the post?” or “Which users belong to this group?”

```redis
SADD post:99:likers user:42 user:77
SISMEMBER post:99:likers user:42
SCARD post:99:likers
SREM post:99:likers user:42
```

In Node.js:

```js
await client.sAdd("post:99:likers", ["user:42", "user:77"]);

const hasLiked = await client.sIsMember("post:99:likers", "user:42");
const likeCount = await client.sCard("post:99:likers");

await client.sRem("post:99:likers", "user:42");
```

Adding an existing member again does not create a duplicate. If you need ranked ordering, use a sorted set instead.

### Lists: ordered sequences

A Redis list is an ordered sequence of values. A basic task queue can add jobs at one end and remove them from the other.

```redis
LPUSH jobs "email:123"
LPUSH jobs "email:124"
RPOP jobs
```

In Node.js:

```js
await client.lPush("jobs", ["email:123", "email:124"]);

const job = await client.rPop("jobs");
```

Lists can work for simple queues, but they do not provide all the delivery and recovery features of a message system. For reliable work distribution, Redis Streams may be a better fit.

### Sorted sets: scores and rankings

A sorted set associates each unique member with a numeric score and keeps members ordered by score. This supports leaderboards and ranking queries.

```redis
ZADD leaderboard 1250 user:42 980 user:77
ZREVRANGE leaderboard 0 9 WITHSCORES
ZINCRBY leaderboard 25 user:77
```

In Node.js:

```js
await client.zAdd("leaderboard", [
  { score: 1250, value: "user:42" },
  { score: 980, value: "user:77" }
]);

const topPlayers = await client.zRangeWithScores(
  "leaderboard",
  0,
  9,
  { REV: true }
);

await client.zIncrBy("leaderboard", 25, "user:77");
```

This example uses one-based human ranking in the idea, but Redis range indexes are **zero-based**: `0` is the first result. The `REV` option returns the highest scores first.

### A quick selection guide

| Need | Redis type to consider |
|---|---|
| One value, cached JSON, or a counter | String |
| A record with independently updated fields | Hash |
| Unique membership checks | Set |
| Ordered items, such as a simple queue | List |
| Ranking by score | Sorted set |
| Event log or worker queue with acknowledgements | Stream |

The type alone does not decide whether the design is correct. Also consider how the application reads and updates the data, how large it can grow, and what should happen when Redis is unavailable.

### Key names and cleanup

Keep names consistent and readable:

```text
user:42
post:99:likers
leaderboard:weekly:2026-11
```

Redis treats these as ordinary key strings; the colons simply make the names easier for people to scan. For temporary or derived data, set an expiration where appropriate:

```redis
EXPIRE user:42 3600
```

For a cache entry, prefer setting the value and expiration together so another command cannot run between those steps:

```redis
SET product:42 '{"name":"Keyboard"}' EX 60
```

In Node.js:

```js
await client.set(
  "product:42",
  JSON.stringify({ name: "Keyboard" }),
  { EX: 60 }
);
```

### Next: a cache in a Node.js server

We’ve seen the types individually. The next step is combining them with a real request flow: check Redis for a cached product, query the primary database on a miss, then cache the result with an expiration. That will introduce cache misses, stale data, and the right place to reuse a Redis client in a server.

> continue

## Lesson 3: Build a cache around a Node.js endpoint

A cache keeps a copy of data that the server can retrieve quickly. The primary database remains the source of truth; Redis holds a copy that can be discarded and rebuilt.

The request flow is:

```text
Request product
       │
       ▼
  Check Redis
   ╱       ╲
 found     missing
  │           │
  ▼           ▼
 return    Read database
              │
              ▼
         Save in Redis
              │
              ▼
          Return product
```

This pattern is called **cache-aside**: your application checks the cache first and fetches from the database when needed.

### A small Express example

Install the packages:

```powershell
npm install express redis
```

Here’s a runnable example that uses an in-memory object as a stand-in for a database. It demonstrates the cache flow; in a real application, replace `findProductInDatabase` with a query to your database.

```js
import express from "express";
import { createClient } from "redis";

const app = express();
const redis = createClient({
  url: process.env.REDIS_URL ?? "redis://localhost:6379"
});

redis.on("error", (error) => {
  console.error("Redis error:", error);
});

// Stand-in for a primary database.
const products = new Map([
  ["42", { id: "42", name: "Keyboard", price: 80 }]
]);

async function findProductInDatabase(id) {
  return products.get(id) ?? null;
}

app.get("/products/:id", async (request, response, next) => {
  const cacheKey = `product:${request.params.id}`;

  try {
    const cachedJson = await redis.get(cacheKey);

    if (cachedJson !== null) {
      return response.json({
        source: "cache",
        product: JSON.parse(cachedJson)
      });
    }

    const product = await findProductInDatabase(request.params.id);

    if (product === null) {
      return response.status(404).json({ error: "Product not found" });
    }

    await redis.set(cacheKey, JSON.stringify(product), { EX: 60 });

    return response.json({
      source: "database",
      product
    });
  } catch (error) {
    return next(error);
  }
});

await redis.connect();

const server = app.listen(3000, () => {
  console.log("Server listening on http://localhost:3000");
});

async function shutdown() {
  server.close();
  await redis.close();
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
```

Save it as `server.mjs` and run:

```powershell
node server.mjs
```

Request the same product twice:

```powershell
curl http://localhost:3000/products/42
curl http://localhost:3000/products/42
```

The first response should report `"source":"database"` and the second `"source":"cache"`. The cache entry expires after 60 seconds, so a later request will fetch from the database again.

### What happens on a cache miss?

On the first request, `GET product:42` returns `null`. The handler queries the database, serializes the result with `JSON.stringify`, and stores it with a 60-second expiration.

On a later request, Redis returns the JSON string. `JSON.parse` turns it back into a JavaScript object, so the database query is skipped.

The expiration limits how long the cached copy can remain unchanged. This is a simple way to limit stale data, but it doesn’t guarantee that the cache matches the database at every moment.

### Keep one Redis client per server process

A Redis client holds a network connection and manages its use. Create and connect it during server startup, then reuse it across incoming requests. Creating a new client for every request adds unnecessary connection work and makes error handling harder.

`await redis.connect()` happens before the server starts accepting requests. If Redis is required for the application to start, this also means a failed connection prevents startup. Whether that’s the right choice depends on how your application behaves when Redis is unavailable.

### Update the cache when database data changes

Suppose a product is updated in the database. The cached copy could now be stale. A straightforward approach is to delete its cache key after a successful database update:

```js
await updateProductInDatabase(id, changes);
await redis.del(`product:${id}`);
```

The next request will miss the cache and load fresh data from the database. This is called **cache invalidation**.

The order matters: update the database first, then delete the cache key. If the database update fails, you don’t want to invalidate a useful cache entry for a change that never happened. In systems where updates and requests overlap, more advanced patterns may be needed to control races and stale reads.

### Handle Redis failures deliberately

A cache is often an optimization, so an application may be able to serve requests from the database if Redis is down. But that choice has tradeoffs:

- If you continue without Redis, database load may rise sharply.
- If you fail requests when Redis is unavailable, your service depends on Redis uptime.
- If you silently ignore Redis errors, you may miss an outage until performance degrades.

Choose based on the role Redis plays. For a disposable product cache, falling back to the database may make sense. For sessions or other required state, treating Redis as optional could lose important behavior.

Also avoid logging sensitive cached values or returning internal Redis errors to clients. Log enough to diagnose the problem, and send a suitable server response.

### Expiration is part of the cache design

A short expiration means cached values refresh more often, which can increase database reads. A long expiration reduces reads but allows stale values to live longer.

The right duration depends on how quickly data changes and how much staleness the application can tolerate. Some applications use a fixed expiration; others also delete affected keys as part of database updates.

Redis supports setting a key and its expiration in one `SET` command:

```redis
SET product:42 '{"id":"42","name":"Keyboard","price":80}' EX 60
```

That avoids a gap between writing the value and applying an expiration. [Redis `SET` command](https://redis.io/docs/latest/commands/set/)

### Next: counters and rate limits

A cache served two requests using `GET` and `SET`. The next lesson will use `INCR` and expiration to count requests safely, and examine why a sequence of individually safe commands can still have a race condition.

> continue

## Lesson 4: Counters and rate limits

A rate limit caps how often a client can perform an action. For example, an API might allow each user 100 requests per minute.

The basic idea is to count requests in Redis and reject requests after the count exceeds the limit.

### Count requests in a time window

A simple fixed-window counter uses one key per user and time window. This example gives each user 10 requests per minute.

```js
const LIMIT = 10;
const WINDOW_SECONDS = 60;

async function allowRequest(userId) {
  const window = Math.floor(Date.now() / 1000 / WINDOW_SECONDS);
  const key = `rate-limit:${userId}:${window}`;

  const count = await redis.incr(key);

  if (count === 1) {
    await redis.expire(key, WINDOW_SECONDS);
  }

  return count <= LIMIT;
}
```

Use it in an Express route:

```js
app.get("/reports", async (request, response, next) => {
  try {
    const allowed = await allowRequest(request.user.id);

    if (!allowed) {
      return response.status(429).json({
        error: "Too many requests"
      });
    }

    return response.json({ report: "..." });
  } catch (error) {
    next(error);
  }
});
```

The key includes a time window number, so requests from the same user in different minutes increment different counters. `INCR` is atomic: if multiple server instances increment the same key concurrently, Redis applies each increment as one indivisible operation. A new key starts at 1. [Redis `INCR` command](https://redis.io/docs/latest/commands/incr/)

### Why expiration matters

Without expiration, every user-window counter would remain in Redis forever. The expiration lets Redis clean up old windows automatically:

```redis
INCR rate-limit:user-42:window-123
EXPIRE rate-limit:user-42:window-123 60
```

The code sets the expiration only when the count is `1`, which identifies the first increment for that key. Expiration keeps the key from accumulating forever. [Redis `EXPIRE` command](https://redis.io/docs/latest/commands/expire/)

### A subtle race condition

`INCR` and `EXPIRE` are separate commands. If the Node.js process crashes after `INCR` returns `1` but before `EXPIRE` runs, the counter could remain forever.

We need both steps to happen together. A Redis transaction can group the commands:

```js
async function allowRequest(userId) {
  const window = Math.floor(Date.now() / 1000 / WINDOW_SECONDS);
  const key = `rate-limit:${userId}:${window}`;

  const results = await redis
    .multi()
    .incr(key)
    .expire(key, WINDOW_SECONDS)
    .exec();

  const count = results[0];
  return count <= LIMIT;
}
```

In Redis, `MULTI` queues commands and `EXEC` runs them as a group. Other clients’ commands won’t run between those queued operations. However, Redis transactions do **not** roll back earlier commands if a later command fails. They provide isolation, not database-style rollback. See the [Redis transaction documentation](https://redis.io/docs/latest/develop/using-commands/transactions/).

### Fixed-window behavior

A fixed-window limit is straightforward, but it has a boundary effect. A user may make 10 requests just before the minute changes and 10 more just after, resulting in 20 requests within a short span.

For many internal tools, this is acceptable. For stricter limits, use a sliding-window or token-bucket design. These need more state and careful atomic updates, often implemented with a Lua script.

### Key design and privacy

Rate-limit keys should use a stable identifier, such as an authenticated user ID. For unauthenticated traffic, IP addresses are sometimes used, but shared networks and proxies can make them poor identity signals.

Avoid storing unnecessary personal data in keys. Use the smallest identifier needed, and set an expiration on counters.

### Summary

- `INCR` gives you a concurrency-safe counter.
- Expiration prevents old counter keys from accumulating.
- A separate increment and expiration can leave a permanent key if the process crashes between them.
- `MULTI`/`EXEC` groups those commands so they run without another client interleaving commands.
- Fixed windows are simple but permit bursts around window boundaries.

Next, we’ll explore Redis lists and streams for queues, including what happens when a worker crashes while processing a job.

> continue

<details><summary>2 previous messages</summary>

> I’ll continue with Redis queues, starting with the difference between a simple list and a stream, then show how a Node.js worker reads and acknowledges jobs.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/develop/data-types/streams node.js XREADGROUP XACK consumer group ...`
>
> </details>
</details>

## Lesson 5: Queues with lists and streams

A queue lets one part of your application hand work to another. For example, an HTTP server can enqueue an email job, and a separate worker can send it later.

Redis lists and streams can both hold work, but they handle worker crashes differently.

### Lists: a simple queue

A list can act as a first-in, first-out queue:

```redis
LPUSH jobs "email:123"
RPOP jobs
```

`LPUSH` adds a job to the left; `RPOP` removes one from the right. Together, they preserve the order jobs were added.

In Node.js:

```js
await redis.lPush("jobs", JSON.stringify({
  type: "send-email",
  userId: "123"
}));

const jobJson = await redis.rPop("jobs");
```

This is fine for learning or simple, disposable work. There’s a catch: once `RPOP` removes the job, a worker crash can lose it before processing finishes.

A list can reduce that risk by moving a job to a separate processing list in one Redis operation:

```redis
BLMOVE jobs processing RIGHT LEFT 0
```

`BLMOVE` waits for a job, removes it from `jobs`, and moves it to `processing`. After finishing, the worker removes it from `processing`:

```redis
LREM processing 1 "email:123"
```

A recovery process can look for jobs left in `processing` and return them to `jobs`. That recovery logic is yours to build. `BLMOVE` is the current command for this pattern; it replaces the deprecated `BRPOPLPUSH`. [Redis `BLMOVE` documentation](https://redis.io/docs/latest/commands/blmove/), [Redis job queue pattern](https://redis.io/docs/latest/develop/use-cases/job-queue/)

### Streams: a log with worker tracking

A Redis Stream stores entries in an ordered log. Unlike a list pop, reading through a **consumer group** tracks which worker received each entry and whether it acknowledged processing.

Create a stream entry from `redis-cli`:

```redis
XADD jobs:email * type send-email userId 123
```

The `*` asks Redis to generate an entry ID. Create a consumer group:

```redis
XGROUP CREATE jobs:email email-workers $ MKSTREAM
```

`$` starts the group at the end of the stream, so it receives new entries. `MKSTREAM` creates the stream if it does not exist.

A group shares new work across its consumers. A second group on that same stream can independently receive its own copy of every entry, which is useful when separate systems need to process the same events.

### Produce and consume from Node.js

Use a producer to append a job:

```js
const streamKey = "jobs:email";

const entryId = await redis.xAdd(streamKey, "*", {
  type: "send-email",
  userId: "123"
});

console.log("Queued:", entryId);
```

After creating the group once with `XGROUP CREATE`, a worker can read entries assigned to it:

```js
const streamKey = "jobs:email";
const group = "email-workers";
const consumer = "worker-a";

const result = await redis.xReadGroup(
  group,
  consumer,
  [{ key: streamKey, id: ">" }],
  { COUNT: 10, BLOCK: 5000 }
);

for (const stream of result ?? []) {
  for (const entry of stream.messages) {
    try {
      const { type, userId } = entry.message;

      if (type === "send-email") {
        await sendEmailToUser(userId);
      }

      await redis.xAck(streamKey, group, entry.id);
    } catch (error) {
      console.error("Job failed:", entry.id, error);
      // Leave it unacknowledged so recovery logic can retry it.
    }
  }
}
```

Here, `>` means “give me entries this group has not delivered to a consumer yet.” `BLOCK` lets the worker wait for new work instead of repeatedly polling. After successful processing, `XACK` acknowledges the entry.

**Create the group once during setup**, before starting workers. If your application starts several worker processes at once, handle the case where another process created the group first.

### What if the worker crashes?

If a worker reads an entry and crashes before acknowledging it, the entry stays **pending** in the group. Another consumer can claim sufficiently idle pending entries with `XAUTOCLAIM` and retry them.

This provides **at-least-once delivery**: the job can be delivered again after a failure. It does not guarantee that a job runs only once. For example, a worker might send an email successfully, then crash before acknowledging the entry. A retry could send the email again.

Design the handler to be **idempotent**: processing the same job twice should not repeat an unwanted effect. For a payment or order update, that often means tracking a unique job or transaction ID and checking whether it was already applied.

A stream also keeps entries after acknowledgement. Acknowledgement removes the entry from the group’s pending list; it does not delete it from the stream. Set a retention policy so the stream does not grow forever. Monitor pending entries and recover stuck work as part of a production worker. [Redis Streams with Node.js](https://redis.io/docs/latest/develop/use-cases/streaming/nodejs/)

### Choosing between the two

| Use a list when… | Use a stream when… |
|---|---|
| Work is simple and losing an in-flight item is acceptable | You want consumer groups to track deliveries and acknowledgements |
| You can build and maintain your own recovery list | You need to inspect pending work and recover stalled entries |
| One queue is enough | Multiple independent groups need to process the same events |

For a production worker queue where recovery matters, streams are usually the easier starting point. They still require careful handling of retries, duplicate processing, retention, and poison-pill jobs that fail every time.

Next, we’ll look at **Redis transactions and atomicity**: what Redis guarantees when commands run together, where those guarantees stop, and when to use a Lua script.

> continue

<details><summary>2 previous messages</summary>

> Next is atomicity: what Redis means when it says an operation is atomic, how `MULTI`/`EXEC` behaves, and when a Lua script is a better fit.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/develop/using-commands/transactions Redis MULTI EXEC atomic no rollback WATCH ...`
>
> </details>
</details>

## Lesson 6: Redis transactions and atomic operations

Redis processes commands one at a time. A single command such as `INCR` runs atomically: other clients cannot interrupt it halfway through.

But a sequence of commands from Node.js can interleave with commands from other clients. If several commands must act as one unit, you need a transaction, a script, or a single command that already does the work.

### `MULTI` and `EXEC`: run commands together

In `redis-cli`:

```redis
MULTI
INCR page:views
EXPIRE page:views 86400
EXEC
```

`MULTI` queues commands; `EXEC` runs the queued commands together. Another client’s commands won’t run in the middle of that transaction.

Node.js uses a chained API:

```js
const results = await redis
  .multi()
  .incr("page:views")
  .expire("page:views", 86400)
  .exec();

console.log(results);
```

This is useful when several commands should run together. `MULTI`/`EXEC` does **not** roll back earlier successful commands if a later command returns an error. It gives you isolation from other clients, rather than the rollback behavior some people expect from SQL transactions. [Redis transaction documentation](https://redis.io/docs/latest/develop/using-commands/transactions/), [node-redis transactions](https://redis.io/docs/latest/develop/clients/nodejs/transpipe/)

If you only need to increment a counter, use the single atomic command:

```js
const views = await redis.incr("page:views");
```

Redis commands often already combine the operation you need. Prefer one command when it expresses the logic clearly.

### `WATCH`: update only if nothing changed

Sometimes the application must read a value, decide what to do, then write a new value. Consider inventory that must never fall below zero.

A plain read and write can fail under concurrency:

```text
Client A reads stock = 1
Client B reads stock = 1
Client A writes stock = 0
Client B writes stock = 0
```

Both clients believe they claimed the last item.

`WATCH` provides optimistic locking: watch the key, read it, and ask Redis to run the transaction only if the watched key has not changed.

```redis
WATCH inventory:keyboard
GET inventory:keyboard
MULTI
DECR inventory:keyboard
EXEC
```

If another client changes that key between `WATCH` and `EXEC`, Redis aborts the transaction. The application can retry its read-and-decide process. `WATCH` does not automatically retry for you. [Redis transactions](https://redis.io/docs/latest/develop/using-commands/transactions/)

### Lua scripts: check and update in one server operation

For a reservation, the check and decrement belong together. A Lua script can perform both while Redis blocks other commands for the duration of the script:

```lua
local stock = tonumber(redis.call("GET", KEYS[1]) or "0")

if stock > 0 then
  redis.call("DECR", KEYS[1])
  return 1
end

return 0
```

Call it from Node.js with the key passed separately:

```js
const reserveOne = `
  local stock = tonumber(redis.call("GET", KEYS[1]) or "0")

  if stock > 0 then
    redis.call("DECR", KEYS[1])
    return 1
  end

  return 0
`;

const reserved = await redis.eval(reserveOne, {
  keys: ["inventory:keyboard"],
  arguments: []
});

if (reserved === 1) {
  console.log("Reserved one keyboard");
} else {
  console.log("Out of stock");
}
```

`KEYS[1]` is the first key supplied through the `keys` array. Scripts receive keys and ordinary arguments separately. That makes the script reusable with different inventory keys.

A Lua script runs atomically, so no other client can change the inventory between the check and decrement. Keep scripts short: while a script runs, Redis cannot serve other commands. [Redis Lua scripting](https://redis.io/docs/latest/develop/interact/programmability/eval-intro/)

### Which tool should you use?

| Need | Prefer |
|---|---|
| One built-in operation, such as incrementing | A single Redis command |
| Several known commands that should not interleave | `MULTI` / `EXEC` |
| Read a value, then write only if nobody changed it | `WATCH` with retry logic |
| Conditional logic that must happen atomically near the data | A short Lua script |

Transactions and scripts do not make every application workflow atomic. If Redis updates stock and another database records the order, Redis cannot automatically commit or undo the database change. That larger workflow needs application-level failure handling and a design for retries or reconciliation.

### A practical rule

Start with the simplest Redis command that fits. Use a transaction when a fixed group of commands must run together. Use `WATCH` when you want optimistic retry behavior. Use a short Lua script when a conditional check-and-update needs to be atomic.

Next, we’ll cover **persistence and durability**: what happens to Redis data when the server restarts, and how snapshotting and the append-only file affect recovery.

> continue

<details><summary>2 previous messages</summary>

> Next is what Redis keeps when it restarts: snapshots, the append-only file, and how to choose settings based on how much data loss your application can tolerate.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/operate/oss_and_stack/management/persistence Redis RDB AOF fsync every second ...`
>
> </details>
</details>

## Lesson 7: Persistence and durability

Redis keeps its working data in memory, but it can also save data to disk so it can rebuild its dataset after a restart. **Persistence is a setting of the Redis server; it isn’t something your Node.js client turns on for an individual key.** Redis offers snapshots (RDB), a write log (AOF), both together, or no persistence. [Redis persistence documentation](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/)

### RDB: periodic snapshots

An RDB file is a snapshot of the dataset at a point in time. Redis can create snapshots on a schedule or when requested.

Think of it like a photograph: compact and useful for backups, but changes made after the last snapshot might be lost if the server fails before another one is saved.

RDB can also help Redis restart quickly with a large dataset. Creating snapshots uses system resources, so the cost depends on dataset size and workload.

### AOF: record writes for replay

The Append Only File records write operations. After a restart, Redis replays those operations to rebuild the dataset.

The `appendfsync` setting controls how often Redis asks the operating system to flush AOF data to disk:

| Setting | Tradeoff |
|---|---|
| `always` | Stronger write durability, with more disk work per write |
| `everysec` | A balance between performance and durability; recent writes may still be lost if the server or machine fails |
| `no` | Redis leaves flushing largely to the operating system |

AOF files can take more space than snapshots, so Redis can rewrite them into a more compact representation. Since Redis 7, AOF uses a multi-part file structure. [Persistence options and tradeoffs](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/)

### Using both

RDB and AOF solve related but different problems:

- RDB gives you compact snapshots that are handy for backups and recovery.
- AOF can record changes more frequently, depending on the flush policy.
- When both are enabled, Redis uses AOF to rebuild data at startup because it usually reflects more recent writes.

The right choice depends on what happens if recent data is lost. A disposable cache may not need persistence because the application can refill it. A job stream or session store may need stronger recovery settings.

Persistence still doesn’t make Redis equivalent to a transactional relational database for every workload. Know which writes could be lost under your configuration, and keep backups that you can restore.

### Check persistence status

From `redis-cli`, inspect the server’s persistence information:

```redis
INFO persistence
```

This reports status fields for snapshotting and AOF activity. In a managed Redis service, persistence options and defaults may be configured through that provider rather than a local `redis.conf`.

In Node.js, the application generally issues the same reads and writes regardless of whether persistence is enabled:

```js
await redis.set("session:42", JSON.stringify({ userId: "42" }));
```

The server’s configuration determines how that write is saved. It’s useful to keep the distinction clear: **the client sends commands; the server decides how to persist them.**

### Persistence is different from replication

A disk file helps Redis recover after a restart. A replica is another Redis server that receives data from a primary and may help with availability.

Replication can reduce some risks, but it is not a substitute for backups. Depending on timing and failure behavior, a replica may not have the latest acknowledged writes. For production systems, think separately about:

- **Persistence:** Can Redis rebuild data after restart?
- **Backups:** Can you restore an earlier copy after deletion or corruption?
- **Replication and failover:** Can the service keep operating when a node fails?

### A note about the local Docker setup

The earlier example started Redis in a container without mounting a host directory for its data. That setup is fine for learning, but deleting the container can delete its stored files too. For data you want to keep across container replacement, Redis needs both persistence configured and storage that survives container removal. [Redis Docker persistence setup](https://redis.io/docs/latest/operate/oss_and_stack/install/install-stack/docker/)

The next lesson is **replication and high availability**: how replicas follow a primary, how failover works, and why a primary-replica setup doesn’t remove every risk of data loss.

> contineu

<details><summary>2 previous messages</summary>

> Continuing with replication and high availability: we’ll separate copying data to replicas from automatically promoting a replacement when the primary fails.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/operate/oss_and_stack/management/replication Redis replication asynchronous ...`
>
> </details>
</details>

## Lesson 8: Replication, Sentinel, and Cluster

Persistence saves data to disk so Redis can recover after a restart. **Replication keeps copies of data on other Redis servers.** It can help with read scaling and recovery if a server fails, but it doesn’t guarantee every acknowledged write is safely copied.

### Replicas copy from a primary

A primary accepts writes and sends them to one or more replicas. By default, replication is asynchronous: Redis can acknowledge a write before a replica has received it. If the primary fails at that moment, a recent write may be missing from the replica. [Redis replication](https://redis.io/docs/latest/operate/oss_and_stack/management/replication/)

Replication can also help spread read traffic, though replica reads may be slightly behind writes to the primary. Your application needs to tolerate that if it reads from replicas.

```text
                  ┌── Replica 1 (copy)
Application ──→ Primary
                  └── Replica 2 (copy)
```

### Sentinel: monitor and fail over

For a non-clustered Redis setup, **Sentinel** monitors primary and replica servers. If it determines the primary is unavailable, Sentinel can promote a replica and inform clients about the new primary address.

Sentinel is separate from Redis data servers. A robust setup uses at least three Sentinels on independently failing machines so they can agree on a failover. [Redis Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/)

```text
Redis application ──→ current primary
                           │
                      replica copy
                           ▲
                   Sentinel monitors
```

Your Node.js app must also discover the current primary through Sentinel and reconnect appropriately. A client that keeps trying only the old primary won’t benefit from failover. This is usually configured in the Redis client connection settings, and the exact setup depends on your deployment and client version.

### Cluster: split data across nodes

Replication copies data. **Sharding splits data** so different nodes store different portions of it. Redis Cluster combines sharding with replication for availability.

```text
Key slots 0–5,000  → Shard A (primary + replica)
Key slots 5k–10k   → Shard B (primary + replica)
Key slots 10k–16k  → Shard C (primary + replica)
```

A single key lives on one shard. This lets the dataset grow beyond one server’s capacity, but it changes how multi-key operations work. In Cluster, keys used together in one transaction or script generally need to map to the same shard. Hash tags in key names can deliberately place related keys together, for example:

```text
cart:{user42}:items
cart:{user42}:total
```

The `{user42}` part is the hash tag used to co-locate those keys. [Redis Cluster scaling](https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/)

Cluster is not simply “Sentinel with more servers.” Sentinel monitors a primary-replica group; Cluster partitions data across multiple primary shards, each with its own replicas. Cluster adds capacity, but also adds constraints to key design and multi-key operations.

### What `WAIT` does—and doesn’t—guarantee

After a write, Redis provides `WAIT` to ask how many replicas have acknowledged receiving previous writes from that connection:

```redis
SET order:123 status:paid
WAIT 1 1000
```

This can reduce the chance of losing a recent write after failure, but it does not turn Redis into a strongly consistent system. Acknowledged writes can still be lost under some failover and persistence scenarios. Treat it as an additional safeguard, not a guarantee of zero data loss. [Redis replication and `WAIT`](https://redis.io/docs/latest/operate/oss_and_stack/management/replication/)

### Which setup fits?

| Need | Consider |
|---|---|
| A local cache or learning setup | One Redis server |
| Failover for one Redis dataset | Primary, replicas, and Sentinel |
| More capacity by distributing keys | Redis Cluster |
| Recovery after restart | Persistence, configured separately |
| Recovery from accidental deletion | Backups, configured separately |

A production design often combines these mechanisms: persistence for restart recovery, replicas and failover for availability, and backups for disaster recovery. The appropriate combination depends on acceptable downtime and data loss.

Next, we’ll look at **key expiration, eviction, and memory limits**—what happens when Redis runs out of memory and how to keep caches bounded.

> continue

<details><summary>2 previous messages</summary>

> Next is memory management: how expiration differs from eviction, what Redis does at its memory limit, and how to choose a policy for a cache.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/develop/reference/eviction Redis maxmemory eviction policies allkeys-lru volatile-ttl ...`
>
> </details>
</details>

## Lesson 9: Expiration, eviction, and memory limits

Redis holds its working dataset in memory, so you need a plan for what happens when data ages out or the server approaches its memory limit.

Two mechanisms can remove keys:

- **Expiration** removes a key after its time-to-live (TTL) runs out.
- **Eviction** removes keys to make room when Redis reaches its configured memory limit.

A key can expire even when Redis has plenty of free memory. A key can also be evicted before its TTL runs out if memory pressure requires it.

### Set a memory limit and eviction policy

Redis uses `maxmemory` to set a limit for its dataset. When writes push usage over that limit, Redis follows the configured `maxmemory-policy`.

You can inspect memory and eviction activity with:

```redis
INFO memory
INFO stats
```

Useful fields include memory usage and `evicted_keys`. `MEMORY USAGE` estimates the RAM used by one key and its value:

```redis
MEMORY USAGE product:42
```

The estimate includes Redis’s overhead for storing the key, not just the value’s text length. [Redis key eviction](https://redis.io/docs/latest/reference/eviction/), [MEMORY USAGE](https://redis.io/docs/latest/commands/memory-usage/)

### Common eviction policies

| Policy | What Redis may remove |
|---|---|
| `noeviction` | Removes nothing; writes that need more memory fail |
| `allkeys-lru` | Least recently used keys, from the whole dataset |
| `allkeys-lfu` | Least frequently used keys, from the whole dataset |
| `volatile-lru` | Least recently used keys that have a TTL |
| `volatile-ttl` | Keys with a TTL that expires soonest |

For a cache where any entry can be rebuilt, `allkeys-lru` is a common starting point: any key may be evicted, and less recently used keys are preferred. If some keys must never be evicted, separate them from the cache where practical, or use a policy that limits eviction to keys with expiration times.

A subtlety: `volatile-*` policies only consider keys that have a TTL. If none do, Redis behaves like `noeviction`, so writes can fail. [Redis eviction policies](https://redis.io/docs/latest/reference/eviction/)

### Cache entries should have a deliberate lifetime

When you cache data, set an expiration as part of the write:

```js
await redis.set(
  "product:42",
  JSON.stringify(product),
  { EX: 300 }
);
```

This entry can expire after five minutes. The TTL controls how long the cached copy remains valid; it doesn’t reserve memory or guarantee that Redis keeps the key for the full five minutes. An eviction policy can remove it earlier.

Expiration is useful for stale data and cleanup. Eviction is a safety mechanism for memory pressure. They solve different problems, so a cache often uses both.

### What if Redis reaches its limit?

With `noeviction`, Redis rejects commands that need to add data when it cannot make room. Reads and some updates that do not grow memory can still work.

In a cache-aside endpoint, a failed cache write should not necessarily fail the request. The application may still return the database result while reporting the cache error. Decide this explicitly: if Redis stores required application state, continuing without a successful write could be unsafe.

### Node.js inspection

You can query a particular key’s size from Node.js:

```js
const bytes = await redis.memoryUsage("product:42");
console.log("Approximate bytes:", bytes);
```

For server-wide monitoring, `INFO memory` and `INFO stats` return text sections with metrics:

```js
const memoryInfo = await redis.info("memory");
const statsInfo = await redis.info("stats");

console.log(memoryInfo);
console.log(statsInfo);
```

For production dashboards, parse and collect the metrics you need rather than logging the full response on every request. Watch memory usage and eviction counts together: rising evictions can mean the cache is underprovisioned, entries are too large, or the chosen policy is removing useful keys.

### A practical cache configuration

For a Redis instance dedicated to disposable cache data, a common shape is:

```text
maxmemory <planned limit>
maxmemory-policy allkeys-lru
```

Leave room for Redis overhead and the operating system; don’t assume the configured dataset limit equals all RAM usage. If Redis also stores sessions, queues, or other state that must not disappear unexpectedly, a single cache eviction policy can have unwanted effects. Separate workloads when possible, or choose and monitor the policy carefully.

Next, we’ll cover **performance and operational habits**: pipelining, avoiding expensive commands on large datasets, and inspecting Redis behavior without disrupting a live server.

> continue

<details><summary>2 previous messages</summary>

> Continuing with performance and operations: how to reduce network round trips, scan large keyspaces safely, and find slow commands.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/develop/using-commands/pipelining Redis pipelining ...`
>
> </details>
</details>

## Lesson 10: Performance and safe operations

Redis commands often do very little work once they reach the server. In a Node.js application, time spent sending commands and waiting for replies can matter more than the command itself. Three useful habits are batching independent work, avoiding full-keyspace commands on busy servers, and checking slow operations before optimizing blindly.

### Batch independent commands

Without batching, each `await` waits for a Redis round trip:

```js
const name = await redis.get("user:42:name");
const plan = await redis.get("user:42:plan");
const region = await redis.get("user:42:region");
```

If the reads are independent, run them together:

```js
const [name, plan, region] = await Promise.all([
  redis.get("user:42:name"),
  redis.get("user:42:plan"),
  redis.get("user:42:region")
]);
```

Or use a pipeline to send multiple commands as a batch:

```js
const results = await redis
  .multi()
  .get("user:42:name")
  .get("user:42:plan")
  .get("user:42:region")
  .execAsPipeline();
```

**Pipelining reduces round trips; it does not make a group of commands atomic.** By contrast, `MULTI`/`EXEC` executes commands as an isolated transaction. Choose based on whether you need batching, transaction behavior, or both. Keep pipeline batches to a reasonable size because Redis must hold the replies until the client reads them. [Redis pipelining](https://redis.io/docs/latest/develop/using-commands/pipelining/), [node-redis pipelines and transactions](https://redis.io/docs/latest/develop/clients/nodejs/transpipe/)

### Don’t fetch every key with `KEYS`

This is convenient during local development:

```redis
KEYS user:*
```

But `KEYS` checks the whole keyspace before returning matches. On a large, busy server, that can delay other work. Use it for debugging small datasets, not as a routine application query. [Redis `KEYS` documentation](https://redis.io/docs/latest/commands/keys/)

For incremental inspection, use `SCAN`:

```redis
SCAN 0 MATCH user:* COUNT 100
```

Redis returns a cursor and a batch of matching keys. Continue with the returned cursor until Redis returns `0`. The `COUNT` value is a hint about work per call, not a guaranteed number of results.

In Node.js:

```js
for await (const key of redis.scanIterator({
  MATCH: "user:*",
  COUNT: 100
})) {
  console.log(key);
}
```

`SCAN` is intended for incremental iteration, so it can still return duplicates while the keyspace changes. Treat it as an administrative or batch-processing tool, not as a substitute for a direct lookup when you already know the key.

### Check command cost and slow operations

Redis documents the time complexity of commands. Constant-time operations such as `GET` are generally predictable; commands that process every element in a large collection can take longer as that collection grows.

From `redis-cli`, inspect recent slow commands:

```redis
SLOWLOG GET 10
```

You can also enable Redis’s latency monitor with a threshold appropriate to your service:

```redis
CONFIG SET latency-monitor-threshold 100
LATENCY LATEST
```

That threshold records latency events above 100 milliseconds. On managed services, you may need to use their dashboard or configuration controls instead. [Diagnosing Redis latency](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency/), [Latency monitor](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency-monitor/)

When users report slow responses, measure the whole request path too. Delay can come from network distance, Node.js work, the database, or waiting in the application—not just Redis command execution.

### A practical checklist

- Batch independent Redis calls when round trips are adding delay.
- Check whether a pipeline or transaction is appropriate; they provide different guarantees.
- Avoid `KEYS` against a large production keyspace; use `SCAN` for incremental inspection.
- Read command complexity when using operations over lists, sets, hashes, or sorted sets.
- Inspect `SLOWLOG` and latency metrics before changing code.
- Keep large pipelines and server-side scripts bounded so they don’t monopolize memory or Redis execution time.

Next, we’ll cover **Redis key design and data modeling**: naming keys, choosing between strings and hashes, and structuring data so common application queries stay direct and predictable.

> continue

## Lesson 11: Key design and data modeling

Redis does not have tables that automatically organize related keys. Your application chooses the key names and decides which values belong together. Good key design makes common reads and updates simple, while avoiding expensive searches across the whole database.

### Name keys consistently

A common pattern is:

```text
<entity>:<id>:<attribute>
```

Examples:

```text
user:42
user:42:preferences
order:918
product:42
```

Colons are a convention for readability; Redis treats each full name as one key. Consistent prefixes make keys easier to understand when inspecting the database.

In Node.js, centralize key construction so different parts of the app use the same names:

```js
const userKey = (userId) => `user:${userId}`;
const userPreferencesKey = (userId) => `user:${userId}:preferences`;
```

### Choose a representation based on access patterns

Suppose a user record has a name, plan, and login count.

**One JSON string** is convenient when your application usually reads or writes the whole object:

```js
await redis.set(
  "user:42",
  JSON.stringify({
    name: "Amina",
    plan: "pro",
    loginCount: 3
  })
);

const json = await redis.get("user:42");
const user = json === null ? null : JSON.parse(json);
```

Redis treats the serialized object as a string. Updating one field means your application reads the string, parses it, changes the object, and writes it back.

**A hash** is useful when you want to access or update fields individually:

```js
await redis.hSet("user:42", {
  name: "Amina",
  plan: "pro",
  loginCount: "3"
});

const plan = await redis.hGet("user:42", "plan");
await redis.hIncrBy("user:42", "loginCount", 1);
```

The fields and values in a Redis hash are strings. Pick the form that matches your read and update patterns; neither one is automatically the right choice for every object.

### Model direct lookups directly

If the application needs to find a product by its ID, use the ID in the key:

```text
product:42
```

Then the lookup is direct:

```js
const productJson = await redis.get("product:42");
```

Avoid designs that require listing every key and searching through them to find one product. Redis can scan keys, but that is not a replacement for an index designed around the query you need.

If users need to look up an order by both order ID and user ID, store a direct key or index for the query your application actually performs. For example:

```text
order:918
user:42:orders
```

The order record can be stored under its ID, while a set or list can track the user’s order IDs. This duplicates a relationship, so updates that create or delete an order must keep both pieces consistent.

### Plan multi-key operations in Cluster

In Redis Cluster, keys are distributed across shards. Operations that require multiple keys together—such as some transactions and scripts—need those keys on the same shard.

Hash tags let you intentionally co-locate related keys:

```text
cart:{user42}:items
cart:{user42}:total
```

Both keys share `{user42}`, so Redis Cluster hashes them to the same slot. Use tags only when related keys truly need to be operated on together; placing too many keys under one tag can concentrate traffic on one shard. [Redis Cluster scaling](https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/)

### Avoid giant values and unbounded collections

A key can hold a large string or a collection with many members. That may seem convenient at first, but large values can make reads, writes, memory use, and deletion more expensive.

Think about growth explicitly:

- Does a list grow forever?
- Does a stream need a retention limit?
- Can a hash accumulate arbitrary fields?
- Can one set become extremely large?
- Should old records expire or be archived elsewhere?

For collections, use range or iteration commands when you only need part of the data. Avoid asking Redis to return an enormous collection in one response.

### Separate data by purpose

If the same Redis deployment stores cache entries, sessions, and job streams, their needs may differ:

- Cache entries can often expire and be evicted.
- Sessions may need predictable expiration and access controls.
- Job streams need retention and consumer recovery.

Make the purpose visible in the key prefix:

```text
cache:product:42
session:abc123
jobs:email
```

Prefixes make inspection easier, but they do not isolate memory or eviction behavior. When workloads have very different durability or memory requirements, separate Redis databases or instances may be more appropriate.

### Summary

A useful Redis model starts with the application’s actual queries:

1. Name keys consistently.
2. Use direct keys for direct lookups.
3. Choose strings, hashes, lists, sets, sorted sets, or streams based on the operations you need.
4. Plan collection growth, expiration, and retention.
5. In Cluster, co-locate keys only when multi-key operations require it.

Next, we’ll build a **small Node.js Redis service** that combines a cache, a counter, and a worker stream, and discuss how to organize the client code cleanly.

> continue

<details><summary>1 previous message</summary>

> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/develop/clients/nodejs xGroupCreate MKSTREAM node redis stream ...`
>
> </details>
</details>

## Lesson 12: Connect the pieces in a small Node.js service

We’ve covered caching, counters, streams, and worker groups. Here’s how they fit together in a small service:

- An HTTP endpoint checks Redis for a cached product.
- Another endpoint places an order by adding an event to a Redis Stream.
- A worker reads order events and acknowledges them after processing.

The examples use `express` and the `redis` npm package (node-redis). Install them with:

```powershell
npm install express redis
```

Run a Redis server locally, then set `REDIS_URL` if it isn’t available at `redis://localhost:6379`.

### HTTP server: cache a read and enqueue a job

Save this as `server.mjs`:

```js
import express from "express";
import { createClient } from "redis";

const app = express();
app.use(express.json());

const redis = createClient({
  url: process.env.REDIS_URL ?? "redis://localhost:6379"
});

redis.on("error", (error) => {
  console.error("Redis error:", error);
});

// Stand-in data source. Replace with your database.
const products = new Map([
  ["42", { id: "42", name: "Keyboard", price: 80 }]
]);

app.get("/products/:id", async (request, response, next) => {
  const id = request.params.id;
  const key = `cache:product:${id}`;

  try {
    const cached = await redis.get(key);

    if (cached !== null) {
      return response.json({
        source: "cache",
        product: JSON.parse(cached)
      });
    }

    const product = products.get(id);

    if (!product) {
      return response.status(404).json({ error: "Product not found" });
    }

    await redis.set(key, JSON.stringify(product), { EX: 60 });

    return response.json({
      source: "database",
      product
    });
  } catch (error) {
    next(error);
  }
});

app.post("/orders", async (request, response, next) => {
  const { orderId, userId } = request.body;

  if (!orderId || !userId) {
    return response.status(400).json({
      error: "orderId and userId are required"
    });
  }

  try {
    const eventId = await redis.xAdd("stream:orders", "*", {
      type: "order.created",
      orderId,
      userId
    });

    return response.status(202).json({ queued: true, eventId });
  } catch (error) {
    next(error);
  }
});

app.use((error, request, response, next) => {
  console.error(error);
  response.status(500).json({ error: "Internal server error" });
});

await redis.connect();

const server = app.listen(3000, () => {
  console.log("Listening on http://localhost:3000");
});

async function shutdown() {
  server.close();
  await redis.close();
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
```

Try the cache endpoint twice:

```powershell
curl http://localhost:3000/products/42
```

The first response should say `"source":"database"`; the second should say `"source":"cache"`. The cached value expires after 60 seconds.

Now enqueue an order event:

```powershell
curl -X POST http://localhost:3000/orders `
  -H "Content-Type: application/json" `
  -d '{"orderId":"o-123","userId":"42"}'
```

The endpoint returns `202 Accepted` after Redis stores the event. A worker can process it separately, so the HTTP request doesn’t need to wait for the order workflow to finish.

### Worker: read, process, acknowledge

Save this as `worker.mjs`:

```js
import { createClient } from "redis";

const redis = createClient({
  url: process.env.REDIS_URL ?? "redis://localhost:6379"
});

redis.on("error", (error) => {
  console.error("Redis error:", error);
});

const stream = "stream:orders";
const group = "order-workers";
const consumer = `worker-${process.pid}`;

await redis.connect();

try {
  await redis.xGroupCreate(stream, group, "$", {
    MKSTREAM: true
  });
} catch (error) {
  // Multiple workers may start together; one can create the group first.
  if (!String(error).includes("BUSYGROUP")) {
    throw error;
  }
}

async function processOrder(orderId, userId) {
  console.log(`Processing order ${orderId} for user ${userId}`);
  // Replace this with application work, such as a database update.
}

async function runWorker() {
  while (true) {
    const batches = await redis.xReadGroup(
      group,
      consumer,
      [{ key: stream, id: ">" }],
      { COUNT: 10, BLOCK: 5000 }
    );

    for (const batch of batches ?? []) {
      for (const entry of batch.messages) {
        try {
          if (entry.message.type === "order.created") {
            await processOrder(
              entry.message.orderId,
              entry.message.userId
            );
          }

          await redis.xAck(stream, group, entry.id);
        } catch (error) {
          console.error("Could not process event:", entry.id, error);
          // Leave it pending so recovery logic can retry it.
        }
      }
    }
  }
}

await runWorker();
```

Run the server and worker in separate terminals:

```powershell
node server.mjs
```

```powershell
node worker.mjs
```

The worker creates the consumer group once. The special stream ID `>` tells Redis to deliver entries that have not yet been delivered to a consumer in this group. `XACK` clears an entry from the group’s pending list after processing. [Redis Streams with Node.js](https://redis.io/docs/latest/develop/use-cases/streaming/nodejs/)

### What this small example leaves for production

A worker can crash after doing its work but before acknowledging the event. Redis may deliver that event again, so the processing should be **idempotent**—safe to repeat. Also add recovery for stuck pending entries using `XAUTOCLAIM`, and choose a retention policy so the stream doesn’t grow without bound.

The HTTP server and worker each connect to Redis once and reuse their client. A blocking stream read can occupy its connection while it waits; if the worker also needs to issue other Redis commands concurrently, give that blocking read a dedicated duplicated connection. [Node-redis streaming guide](https://redis.io/docs/latest/develop/use-cases/streaming/nodejs/)

This example ties together the basics. Next, we can go deeper into **production hardening**: authentication and ACLs, TLS, timeouts and retries, graceful shutdown, and handling Redis outages in Node.js.

> continue

<details><summary>2 previous messages</summary>

> I’ll continue with production hardening: securing Redis connections, limiting what application credentials can do, and making Node.js behavior during outages predictable.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/operate/oss_and_stack/management/security Redis security ACL TLS bind protected mode ...`
>
> </details>
</details>

## Lesson 13: Secure and reliable Redis connections

A production Redis setup needs more than a working connection string. Protect the connection, limit the application account’s permissions, and decide what your Node.js server should do during an outage.

### Protect the connection

For a local learning server, `redis://localhost:6379` is fine. For a remote production service, use TLS and keep credentials outside your source code, such as in environment variables or a secrets manager.

```js
import { createClient } from "redis";

const redis = createClient({
  url: process.env.REDIS_URL,
  socket: {
    connectTimeout: 5000
  }
});

redis.on("error", (error) => {
  console.error("Redis client error:", error);
});

redis.on("reconnecting", () => {
  console.warn("Redis reconnecting");
});

await redis.connect();
```

A TLS connection URL uses the `rediss://` scheme. Managed Redis providers often supply the URL and TLS requirements. Check their connection instructions rather than guessing at certificate settings. Node-redis reconnects automatically after unexpected disconnects, and its production guide covers timeouts and command reliability. [Node-redis connection guide](https://redis.io/docs/latest/develop/clients/nodejs/connect/), [Production usage](https://redis.io/docs/latest/develop/clients/nodejs/produsage/)

Always attach an `error` listener. Also avoid printing connection URLs or credentials in logs.

### Give the application only the access it needs

Redis ACLs let you create named users with restricted commands and key patterns. For example, a cache-only application might need to read, write, and delete keys under `cache:*`:

```redis
ACL SETUSER cache-app reset on >replace-with-a-secret ~cache:* +get +set +del +ping
```

This user can run the listed commands on matching keys. It won’t have permission to manage unrelated keys or run every Redis command. This is only a cache example; a worker that uses streams needs additional permissions. Design the ACL around the actual commands and key prefixes your service uses. [Redis ACL documentation](https://redis.io/docs/latest/operate/oss_and_stack/management/security/acl/)

Avoid exposing Redis directly to the public internet. Restrict network access to the application hosts, use authentication and TLS for remote connections, and keep administrative credentials separate from application credentials. Redis’s security guidance discusses protected mode and access controls. [Redis security](https://redis.io/docs/latest/manual/security/)

### Decide what to do when Redis is unavailable

The right behavior depends on what Redis stores:

- **Disposable cache:** You may fall back to the primary database if Redis fails.
- **Session data or job queue:** Continuing as though the write succeeded could lose important behavior.
- **Rate-limit counter:** Failing open keeps requests flowing but permits more traffic; failing closed enforces the limit but can block legitimate users.

Make that choice for each operation. Don’t silently treat every Redis failure as a cache miss—an outage could then shift a large volume of traffic onto the database.

A cache read can use a deliberate fallback:

```js
async function getCachedProduct(id) {
  try {
    const cached = await redis.get(`cache:product:${id}`);
    return cached === null ? null : JSON.parse(cached);
  } catch (error) {
    console.warn("Cache unavailable; using database", error.message);
    return null;
  }
}
```

The caller can query the database when this returns `null`. For a required write, such as adding a job to a stream, return an error if Redis did not confirm the write.

### Be careful retrying writes

A network failure can happen after Redis processed a command but before Node.js received the reply. The application may not know whether the write happened.

This matters for non-idempotent commands such as `INCR`: retrying can increment twice. Node-redis queues commands during a reconnect by default, so consider whether delayed or repeated execution fits each write. Options such as disabling the offline queue change that behavior; they don’t make the operation exactly-once. [Node-redis production usage](https://redis.io/docs/latest/develop/clients/nodejs/produsage/)

For workflows where duplicate effects matter, use an idempotency key or a conditional operation designed for that workflow. A retry policy should be bounded, use delays, and distinguish transient network errors from permanent errors such as invalid credentials or a wrong data type. [Node-redis error handling](https://redis.io/docs/latest/develop/clients/nodejs/error-handling/)

### Keep health checks meaningful

`redis.isOpen` means the socket is open. `redis.isReady` means the client is ready to send commands. They answer different questions, and neither alone proves the whole application can serve a request successfully.

A health endpoint can check Redis with `PING`, but decide whether Redis is essential to the service before marking the entire app unhealthy. If Redis only holds rebuildable cache data, the app might still serve requests from its database.

Next, we’ll move into **advanced patterns**: idempotency, distributed locks, and coordination between multiple Node.js server instances.

> continue

<details><summary>2 previous messages</summary>

> Next are advanced coordination patterns: preventing duplicate work with idempotency keys, and using Redis locks carefully when several Node.js servers share a resource.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/develop/clients/patterns/distributed-locks Redis SET NX PX compare token unlock ...`
>
> </details>
</details>

## Lesson 14: Idempotency and distributed locks

Multiple Node.js processes can handle requests or jobs at the same time. Two patterns help coordinate that work:

- **Idempotency:** repeating the same operation has the same effect as doing it once.
- **A lock:** only one worker at a time is allowed to enter a critical section.

They solve different problems. Idempotency makes retries safe; a lock coordinates concurrent work.

### Make a Redis-only update idempotent

Suppose an event should award a user 10 points, but the event might be delivered more than once. A simple `INCRBY` would award points each time. Store a marker for the event and increment the score only if that marker is new.

Do both steps in one Lua script:

```lua
local firstTime = redis.call("SET", KEYS[1], "1", "NX", "EX", ARGV[2])

if not firstTime then
  return 0
end

redis.call("INCRBY", KEYS[2], ARGV[1])
return 1
```

Call it from Node.js:

```js
const awardPoints = `
  local firstTime = redis.call("SET", KEYS[1], "1", "NX", "EX", ARGV[2])

  if not firstTime then
    return 0
  end

  redis.call("INCRBY", KEYS[2], ARGV[1])
  return 1
`;

const applied = await redis.eval(awardPoints, {
  keys: [
    "processed-event:{user42}:event9001",
    "score:{user42}"
  ],
  arguments: ["10", "2592000"]
});

console.log(applied === 1 ? "Points awarded" : "Event already handled");
```

The first key records that the event was processed; the second holds the score. The marker expires after 30 days. The shared `{user42}` hash tag keeps both keys on the same Redis Cluster shard, which is required for a script that changes both keys. Redis scripts execute atomically. [Redis Lua scripting](https://redis.io/docs/latest/develop/interact/programmability/eval-intro/)

This protects the Redis score update from duplicate events during that retention period. It doesn’t make a separate database update or external API call part of the same atomic operation. For those, use the external system’s idempotency support or a database constraint and transaction.

### Acquire a lock with a unique token and a timeout

For a task where occasional overlap is acceptable, a single Redis instance can provide a simple lock:

```js
import { randomUUID } from "node:crypto";

const lockKey = "lock:report:daily";
const token = randomUUID();

const acquired = await redis.set(lockKey, token, {
  NX: true,
  PX: 30_000
});

if (acquired !== "OK") {
  console.log("Another worker has the lock");
  return;
}

try {
  await generateDailyReport();
} finally {
  const releaseLock = `
    if redis.call("GET", KEYS[1]) == ARGV[1] then
      return redis.call("DEL", KEYS[1])
    end
    return 0
  `;

  await redis.eval(releaseLock, {
    keys: [lockKey],
    arguments: [token]
  });
}
```

`NX` means “set only if the key doesn’t exist”; `PX` sets an expiration in milliseconds. The unique token matters when releasing: if this worker’s lock expired and another worker acquired the key, the old worker must not delete the new worker’s lock. [Redis `SET` and locking pattern](https://redis.io/docs/latest/commands/set/)

The lock also expires automatically if a worker crashes. Choose a timeout longer than the usual task duration, while recognizing that no fixed timeout guarantees the work will always finish before the lock expires.

### Know the lock’s limits

If a worker pauses long enough for its lock to expire, another worker can acquire the lock while the first worker is still running. Both may then perform the task. A lock alone can’t prevent that stale worker from continuing.

For operations where overlap could cause serious harm, use a stronger safeguard such as a **fencing token** checked by the system being updated, or enforce the rule with a database transaction or uniqueness constraint. Redis’s distributed lock guidance also distinguishes a simple single-instance lock from the Redlock algorithm for multiple independent Redis instances. [Redis distributed locks](https://redis.io/docs/latest/manual/patterns/distributed-locks/)

Use a lock to reduce unwanted overlap. Use idempotency or a constraint at the point of the actual side effect to make retries safe.

Next, we’ll cover **Pub/Sub and event delivery**: how Redis can broadcast live updates, and when a stream is a better fit because consumers need replay or recovery.

> continue

<details><summary>2 previous messages</summary>

> Next is Redis Pub/Sub: how to broadcast live notifications, why subscribers can miss messages, and when a stream is the better tool.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/develop/pubsub Redis Pub/Sub delivery at most once disconnected subscriber ...`
>
> </details>
</details>

## Lesson 15: Redis Pub/Sub for live updates

Pub/Sub lets one part of your application broadcast a message to clients that are subscribed at that moment. It’s useful for events such as “refresh this dashboard” or “a user is typing.”

It behaves like a live announcement: **if a subscriber is disconnected when the message is published, it misses the message.** Redis Pub/Sub is at-most-once delivery; it does not store messages for replay or track acknowledgements. [Redis Pub/Sub](https://redis.io/docs/latest/develop/pubsub/)

### Publish from Node.js

Use a regular Redis client to publish:

```js
await redis.publish(
  "notifications:user:42",
  JSON.stringify({
    type: "report.ready",
    reportId: "report-81"
  })
);
```

The result is the number of subscribers Redis delivered the message to. Zero means no client was listening at that moment.

### Subscribe with a separate client

A node-redis client used for subscriptions is dedicated to Pub/Sub; use a separate connection for ordinary commands:

```js
const subscriber = redis.duplicate();

subscriber.on("error", (error) => {
  console.error("Subscriber error:", error);
});

await subscriber.connect();

await subscriber.subscribe(
  "notifications:user:42",
  (message, channel) => {
    try {
      const event = JSON.parse(message);
      console.log("Received", event.type, "on", channel);
    } catch (error) {
      console.error("Invalid notification:", error);
    }
  }
);
```

A subscription is useful while that connection is open. After reconnecting, make sure the application subscribes again. Node-redis’s Pub/Sub guide shows the same separate-connection pattern with `client.duplicate()`. [Redis Pub/Sub with Node.js](https://redis.io/docs/latest/develop/use-cases/pub-sub/nodejs/)

### When to use Pub/Sub—and when to use Streams

| Pub/Sub | Streams |
|---|---|
| Broadcast live updates to connected listeners | Store events for later reading |
| Messages are discarded after delivery | Entries remain until trimmed or deleted |
| No acknowledgements or consumer tracking | Consumer groups track pending work and acknowledgements |
| Good for transient notifications | Better when replay or worker recovery matters |

For example, a service can save a report in its primary database and then publish a notification to update a live dashboard. If the dashboard is disconnected, it can fetch the report when it reconnects. The durable report remains in the database; Pub/Sub is just the fast nudge.

If missing a message would lose important work, publish it to a Redis Stream or another durable queue instead. [Redis streaming overview](https://redis.io/docs/latest/develop/use-cases/streaming/)

Next, we’ll look at **Redis keyspace notifications**—a related feature that can publish events when keys expire or change, and why those events should usually be treated as hints rather than a durable event log.

> continue

<details><summary>2 previous messages</summary>

> Next is keyspace notifications: Redis can publish events when keys expire or change, but they inherit Pub/Sub’s delivery limits.
>
> <details><summary>Searched the web</summary>
>
> Searched the web for `site:redis.io/docs/latest/develop/pubsub/keyspace-notifications keyspace notifications configuration Ex expired ...`
>
> </details>
</details>

## Lesson 16: Keyspace notifications

Redis can publish notifications when keys are changed, expired, or evicted. This feature is called **keyspace notifications**. It can help with monitoring or trigger a best-effort reaction, such as refreshing a dashboard after a cache key changes.

Notifications are disabled by default. Enable only the events you need. For example, in `redis-cli`:

```redis
CONFIG SET notify-keyspace-events Ex
```

Here, `E` enables key-event channels and `x` selects expiration events. Then subscribe to expiration events for database 0:

```redis
SUBSCRIBE __keyevent@0__:expired
```

When a key expires, Redis publishes the key name as the message. Keyspace notifications use Pub/Sub, so a disconnected subscriber misses events. Also, an expiration notification is sent when Redis actually deletes the key; that may be later than the moment its TTL reaches zero. Don’t use these notifications as a precise timer or a durable record of changes. [Redis keyspace notifications](https://redis.io/docs/latest/develop/pubsub/keyspace-notifications/)

### Subscribe from Node.js

Use a dedicated connection for the subscription:

```js
const subscriber = redis.duplicate();

subscriber.on("error", (error) => {
  console.error("Notification subscriber error:", error);
});

await subscriber.connect();

await subscriber.subscribe(
  "__keyevent@0__:expired",
  (key) => {
    console.log("Redis expired this key:", key);
  }
);
```

The regular `redis` client remains available for `GET`, `SET`, and other commands. A subscribed client is dedicated to Pub/Sub while the subscription is active. [Node.js Pub/Sub guide](https://redis.io/docs/latest/develop/use-cases/pub-sub/nodejs/)

### Keyspace versus key-event channels

Redis can publish two kinds of channel for an operation. For a `DEL` of `mykey` in database 0, the notifications are conceptually:

```text
Channel: __keyspace@0__:mykey   Message: del
Channel: __keyevent@0__:del    Message: mykey
```

Use a **keyspace** channel when you care about events affecting a particular key. Use a **key-event** channel when you care about a particular event type across keys.

### When this feature fits

Keyspace notifications can be useful for:

- Observing key expirations during development.
- Updating a non-critical dashboard when values change.
- Best-effort cache coordination between processes.

They are a poor fit when missing an event would lose work or leave important state inconsistent. For that, record the event durably—in a Redis Stream or your primary database—and let consumers recover from it later.

Next, we can put the Redis pieces together by working through a **debugging scenario**: a slow endpoint, a cache that appears stale, and a worker queue with pending jobs.
