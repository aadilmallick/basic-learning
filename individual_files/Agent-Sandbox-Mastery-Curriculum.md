# Complete curriculum: Agent Sandbox Mastery

**Outcome:** independently design and implement an authorized browser/computer-use agent in Python or TypeScript, understand each machine and session boundary, select a sandbox platform, preserve supported authentication state, orchestrate with LangGraph or Strands, and recover tasks using verified effects.

**Prior knowledge:** functions, variables, objects/dictionaries, and basic exception handling. Async, browser contexts, remote protocols, state machines, encryption envelopes, and recovery are taught locally before use. Follow one language first; compare the other after understanding the behavior.

**Format:** six fully authored chapters, thirty-six guided study sessions, a continuous textbook, complete source, seven interactive experiments, synthetic fixtures, deployment recipes, and an evidence report. A session is a suggested stopping point within a substantial chapter, not a separate empty lesson outline. Each chapter meets the documented conservative length proxy of at least 5,000 whitespace words. Length is evidence of scope, not a claim of teaching quality or exact model-token count.

| Session | Read in chapter | Ability and worked treatment | Evidence or application |
| --- | --- | --- | --- |
| 1 | 1: task and agent loop | Distinguish a model proposal from an executed tool effect | Trace the report task |
| 2 | 1: controller/worker/target | Locate processes, authority, and network boundaries | Component ownership table |
| 3 | 1: isolation and state | Separate context, container, VM, disk, session, and workflow | Lifecycle laboratory |
| 4 | 1: local setup and async | Install bindings; await dependent operations | Deterministic demo instructions |
| 5 | 1: cleanup and budgets | Bound operations and whole runs | Budget unit checks |
| 6 | 1: failure timeline | Identify uncertain effects and safe recovery | Worked crash timeline |
| 7 | 2: integration contract | Model create/readiness/execute/release | Fixed-command smoke contract |
| 8 | 2: Daytona | Use stable Python/TS clients and computer-use boundaries | Both provider recipes |
| 9 | 2: Boat | Handle generated requests, readiness, and retained state | Both provider recipes |
| 10 | 2: Maritime | Distinguish agent boxes, ephemeral tasks, and desktops | Both native SDK recipes |
| 11 | 2: Vercel | Use current Python/TS APIs and persistence semantics | Both provider recipes |
| 12 | 2: images, ports, costs | Prepare environments; measure occupancy and retention | Cost laboratory |
| 13 | 3: contexts and locators | Implement a known authenticated browser workflow | Local demo in both languages |
| 14 | 3: storage mechanisms | Distinguish cookies, origin storage, session storage, and profiles | Origin laboratory |
| 15 | 3: state capture and transfer | Export after login; restore and verify identity | Context-transfer implementation |
| 16 | 3: remote connections | Select Playwright protocol or CDP; own resources correctly | Connection fragments and failure diagnosis |
| 17 | 3: secrets and envelopes | Keep passwords separate; encrypt and scope exported state | Python/Node interoperability tests |
| 18 | 3: lifecycle and reauth | Handle expiry, revocation, rotation, revisions, and leases | Encryption/tamper laboratory |
| 19 | 4: observation/driver | Define an image and action contract | Actual Playwright driver |
| 20 | 4: geometry | Derive normalized, crop, scale, and display mappings | Geometry laboratory and invariants |
| 21 | 4: model boundary | Call a vision endpoint and validate returned JSON | Python/TS Ollama loops |
| 22 | 4: desktop | Drive a disposable desktop through Python and TS bridge | Full desktop framework entrypoints |
| 23 | 4: freshness and policy | Handle stale images, focus, prompt injection, and takeover | Action validation laboratory |
| 24 | 4: evaluation | Separate planner, driver, and task quality | Failure and measurement examples |
| 25 | 5: graph fundamentals | Define nodes, state, updates, edges, and verification | Graph trace and diagram |
| 26 | 5: Python LangGraph | Implement observe/plan/act/verify | Complete graph_agent.py |
| 27 | 5: TypeScript LangGraph | Use state annotations and bounded routing | Complete graph_agent.ts |
| 28 | 5: interruption and replay | Pause before effects; resume intentionally | Synthetic approval graph |
| 29 | 5: Strands | Register tools in both languages; understand nested vision | Complete Strands browser/desktop workers |
| 30 | 5: orchestration design | Scope tools, histories, concurrency, events, and recovery | Workflow replay laboratory |
| 31 | 6: placement and packaging | Run the whole agent process in its sandbox | Two worker services and Docker recipes |
| 32 | 6: durable tasks | Separate task, operation, lease, session revision | State-machine and schema design |
| 33 | 6: effects and recovery | Reconcile lost responses and avoid duplicate work | Idempotency fixture and lab |
| 34 | 6: production boundaries | Apply tenant, network, secret, queue, and artifact contracts | Concrete design walkthrough |
| 35 | 6: real use cases | Reports, code/test agents, desktop export, persistent assistants | Four developed application cases |
| 36 | 6: verification/release | Gather layered evidence and promote a tested artifact | Verification report and run commands |

## Suggested pace

Study one session at a time. Read the motivating example and trace the intermediate states before running code. Use the complete source rather than typing fragments into an unrelated project. Stop at a natural subsection when attention falls; the curriculum does not require a fixed calendar or quiz before continuing.

For a Python-first path, use Python examples in sessions 4, 13, 21, 26, and 29. For a TypeScript-first path, use the corresponding TypeScript files. Both paths should read the browser/session and recovery chapters because those concepts do not depend on language choice.

## Capstone acceptance criteria

The included local capstone is implemented as Harbor Reports plus deterministic browser clients and worker services. Its acceptance checks are authenticated login, state transfer to a fresh context, report preparation, independent result indication, and cleanup. Fixture HTTP checks passed; end-to-end Chromium execution was blocked in the authoring host.

To extend it to a cloud agent, choose a provider, validate a compatible SDK and image, run the fixed-command smoke test, deploy the deterministic worker, then enable a real model. Require a task deadline, correct tenant/account, bounded actions, result verification, and observed resource cleanup before calling your integration complete.

To extend it to a consequential workflow, add durable task/operation records, a session lease, protected state revisions, explicit effect authorization where required, and reconciliation after a lost response. These production integrations are taught and specified; no database, queue, cloud account, or real target deployment is falsely claimed as installed.

Optional application work is included in the teaching narrative. No active-recall gate, mandatory quiz, or future scheduled task is imposed.
