# Complete voice-agent curriculum

Audience: a developer with basic programming who wants practical depth in both Python and TypeScript. No prior audio, WebRTC, or async-stream expertise is assumed. Read sequentially; prerequisite introductions occur before their use. Practice is optional, with no quiz gates.

The twelve chapter files are the finished lesson content, not an outline to be filled later. The textbook assembles the same canonical lessons into a continuous volume with a preface, part introductions, navigation, references, and full source listings.

## Lesson 01 — What a voice agent actually does

Full lesson: [01-systems-and-landscape.md](chapters/01-systems-and-landscape.md)

Prerequisites: basic functions, arrays/lists, strings, and command-line execution.

Outcome: Choose a cascade, native session, or managed platform using explicit requirements; map every stage and trust boundary.

Companion: latency. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Write a one-page architecture choice for a developer support assistant.

## Lesson 02 — From air pressure to browser audio

Full lesson: [02-audio-and-browser-media.md](chapters/02-audio-and-browser-media.md)

Prerequisites: lessons 1–1; the chapter locally introduces any new practical prerequisite.

Outcome: Calculate PCM sample and byte counts; distinguish codec, container, and sample rate; manage browser capture and playback.

Companion: pcm. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Compare a valid WAV header and its extracted PCM payload.

## Lesson 03 — Streams, transports, and resource ownership

Full lesson: [03-streams-transports-and-lifecycle.md](chapters/03-streams-transports-and-lifecycle.md)

Prerequisites: lessons 1–2; the chapter locally introduces any new practical prerequisite.

Outcome: Use asynchronous producers and consumers in both languages; bound queues; own cancellation, events, and resources.

Companion: interrupt. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Add a delayed stale response to the queue exercise.

## Lesson 04 — Build a speech-to-text, reasoning, and text-to-speech pipeline

Full lesson: [04-building-a-cascaded-agent.md](chapters/04-building-a-cascaded-agent.md)

Prerequisites: lessons 1–3; the chapter locally introduces any new practical prerequisite.

Outcome: Run a whole-file STT → reasoning → TTS turn; inspect each intermediate result; design incremental streaming safely.

Companion: latency. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Run the same permitted speech fixture with both synthesis adapters.

## Lesson 05 — A native OpenAI Realtime web application

Full lesson: [05-openai-realtime-web-app.md](chapters/05-openai-realtime-web-app.md)

Prerequisites: lessons 1–4; the chapter locally introduces any new practical prerequisite.

Outcome: Understand and run a browser Realtime GA connection with either backend; protect the permanent key and clean up media.

Companion: ux, interrupt. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Test denied permission and End while a prompt is pending.

## Lesson 06 — Gemini Live and explicit PCM streaming

Full lesson: [06-gemini-live-and-pcm-streaming.md](chapters/06-gemini-live-and-pcm-streaming.md)

Prerequisites: lessons 1–5; the chapter locally introduces any new practical prerequisite.

Outcome: Understand a bidirectional Live file turn in both languages; pace PCM, decode events, and plan browser transport and resumption.

Companion: pcm, interrupt. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Extend the file-turn adapter with a bounded browser bridge after verifying the current protocol.

## Lesson 07 — Cartesia, ElevenLabs, and managed agent platforms

Full lesson: [07-cartesia-elevenlabs-and-managed-agents.md](chapters/07-cartesia-elevenlabs-and-managed-agents.md)

Prerequisites: lessons 1–6; the chapter locally introduces any new practical prerequisite.

Outcome: Use interchangeable synthesis adapters; evaluate voice and chunking; understand hosted-agent authorization and UI responsibilities.

Companion: latency, cost. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Run a paired pronunciation and first-audio comparison.

## Lesson 08 — Open models, Fish Speech, and self-hosting

Full lesson: [08-open-models-and-self-hosting.md](chapters/08-open-models-and-self-hosting.md)

Prerequisites: lessons 1–7; the chapter locally introduces any new practical prerequisite.

Outcome: Assess Fish, Whisper, Kokoro, and adjacent models; distinguish artifact licenses; plan inference workers and capacity.

Companion: cost. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Pilot one model worker and record cold, warm, and concurrent behavior.

## Lesson 09 — Turn-taking, interruption, and what the user heard

Full lesson: [09-turn-taking-and-interruptions.md](chapters/09-turn-taking-and-interruptions.md)

Prerequisites: lessons 1–8; the chapter locally introduces any new practical prerequisite.

Outcome: Tune endpointing; distinguish backchannels and interruption; reject stale audio and reconcile heard history.

Companion: endpoint, interrupt. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Compare a mid-sentence pause with a short direct question.

## Lesson 10 — Tools, grounding, memory, and trustworthy actions

Full lesson: [10-tools-grounding-and-memory.md](chapters/10-tools-grounding-and-memory.md)

Prerequisites: lessons 1–9; the chapter locally introduces any new practical prerequisite.

Outcome: Validate tools, ground answers, bind proposals to users, enforce idempotency, and separate memory from business state.

Companion: transaction. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Upgrade the in-memory ledger to a durable transactional test database.

## Lesson 11 — Design a voice experience people can control

Full lesson: [11-web-ux-accessibility-and-conversation.md](chapters/11-web-ux-accessibility-and-conversation.md)

Prerequisites: lessons 1–10; the chapter locally introduces any new practical prerequisite.

Outcome: Design permission, listening, waiting, speaking, repair, text fallback, accessibility, and multilingual interaction.

Companion: ux. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Implement a real text route sharing the same proposal state.

## Lesson 12 — Evaluate, operate, and extend the complete system

Full lesson: [12-evaluation-economics-and-production.md](chapters/12-evaluation-economics-and-production.md)

Prerequisites: lessons 1–11; the chapter locally introduces any new practical prerequisite.

Outcome: Design evaluation fixtures, compute percentiles and cost, deploy long-lived sessions, and extend the capstone with evidence.

Companion: evaluation, cost. These experiments isolate selected concepts; they are not provider benchmarks.

Optional application: Complete the guided Harbor capstone and publish an evidence-backed release record.

## Coverage and execution map

| Family | Lessons | Complete source / evidence |
| --- | --- | --- |
| Cascade and component adapters | 1, 4, 7 | Both `providers` files; credentials required, not live-executed |
| OpenAI native browser | 2, 3, 5, 9 | Shared web client and both local relay servers |
| Gemini native audio | 2, 3, 6 | Both file-turn examples; paid calls not executed |
| Open models and Fish | 8 | Optional local-model recipes and official Fish deployment references; no inference executed |
| Turn logic and trusted actions | 3, 9, 10 | Both core implementations; deterministic tests and labs |
| UX, evaluation, economics | 11, 12 | UX, percentile, and cost experiments; browser checks |

Provider material is a researched snapshot, not a claim that every account can access every model. Follow `examples/README.md` and the verification report.
