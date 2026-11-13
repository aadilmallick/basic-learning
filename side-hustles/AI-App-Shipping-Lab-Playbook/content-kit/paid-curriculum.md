# Paid curriculum production plan

# 5 The exact paid curriculum to produce

Create six modules with three lessons each. Record explanations in short segments and use written notes for details that change. Target roughly 10 to 20 minutes per recorded lesson, with exercises taking longer. These durations are production budgets, not required viewing lengths.

The first cohort can be taught live while you improve the materials. Before taking payment, have the reference project, the whole roadmap, week one, and the stated delivery dates ready. Tell buyers which lessons are live and which recordings already exist.

## Module one Specify the behavior

Lesson 1 is “Define done before asking AI to code.” Explain the user, input, output, uncertainty, and acceptance criteria. Demonstrate the difference between “make an AI assistant” and a bounded brief-drafting workflow. Assignment: write the one-page project specification below. Acceptance: another learner can tell what is in and out of scope.

Lesson 2 is “Map the interface and server boundary.” Draw the request moving from the interface to a server endpoint, then to the model, back through validation, and into a draft. Use the mock path first. Assignment: implement or modify the mock and trace one request. Acceptance: the learner explains where credentials, validation, and approval belong.

Lesson 3 is “Create examples before implementation.” Work through C01, C02, and C03. Explain why missing information and contradiction are different problems. Assignment: add two original cases with expected behavior. Acceptance: expectations are written before observing the model response.

## Module two Direct the coding assistant

Lesson 4 is “Give the assistant a small contract.” Show a request that supplies the existing file boundary, required behavior, non-goals, and tests. Assignment: ask for one small change and inspect the diff. Acceptance: the learner can explain every changed file.

Lesson 5 is “Review a diff instead of approving a story.” Demonstrate how a plausible explanation can accompany a wrong change. Compare actual behavior against the acceptance criteria. Assignment: find an intentionally seeded bug in a teaching branch. Acceptance: explain the bug, produce a minimal correction, and show the relevant check.

Lesson 6 is “Make the output editable and unapproved.” Build the draft editor and approval state. Assignment: edit one requirement and verify the exported result. Acceptance: changed content does not retain an inappropriate approval state.

## Module three Treat model output as data

Lesson 7 is “Validate shape and meaning separately.” Show a structurally valid response with an unsupported requirement. Assignment: distinguish schema checks from semantic review in three examples. Acceptance: the learner identifies both kinds of failure.

Lesson 8 is “Represent uncertainty explicitly.” Demonstrate unknown fields and open questions. Assignment: prevent a missing budget or deadline from becoming an invented commitment. Acceptance: the interface visibly distinguishes provided information, assumptions, and questions.

Lesson 9 is “Handle failure without endless generation.” Work through malformed output and timeout behavior. Assignment: add bounded recovery and a useful message. Acceptance: retries are limited and a user can recover without seeing secrets or internal traces.

## Module four Evaluate the same workflow

Lesson 10 is “Build a small repeatable evaluation.” Record results for the ten cases using a fixed rubric. Assignment: evaluate a baseline version. Acceptance: results include inputs, version, expected behavior, and observed behavior.

Lesson 11 is “Change one thing and compare.” Modify a prompt, validation rule, or interface behavior to address a known failure. Assignment: rerun the same cases and describe tradeoffs. Acceptance: no claim of improvement without comparable observations.

Lesson 12 is “Exercise untrusted and sensitive input.” Use synthetic examples and distinguish a demonstration from a security guarantee. Assignment: document where content is trusted, stored, sent, and logged. Acceptance: no private data or credentials appear in the teaching artifacts.

## Module five Prepare a controlled deployment

Lesson 13 is “Protect the request boundary.” Review server-side configuration, input size, usage controls, and duplicate actions. Assignment: demonstrate the configured boundary. Acceptance: the reference app behaves as documented when the limit is reached.

Lesson 14 is “Make errors observable without exposing content.” Choose a few useful operational events and redact unnecessary information. Assignment: diagnose a simulated failure from a safe event trail. Acceptance: the learner can identify the failing stage.

Lesson 15 is “Deploy and verify from scratch.” Use one supported training deployment. Assignment: run the setup and verification checklist from a fresh environment. Acceptance: the README is sufficient for another person to reproduce the training app.

## Module six Demonstrate independent ability

Lesson 16 is “Extend the workflow without copying.” Give each learner a small variation, such as a different brief type or export format. Assignment: implement it with the same boundaries. Acceptance: explain the new behavior and its checks.

Lesson 17 is “Write the handoff and limitations.” Produce setup notes, supported inputs, known failures, data handling, cost controls, and maintenance notes. Assignment: a one-page handoff. Acceptance: a reader understands what the app can and cannot do.

Lesson 18 is “Demo defend and revise.” Each member demonstrates the app, handles a failure, explains a tradeoff, and receives feedback. Assignment: revise one issue and record a short final explanation. Acceptance: meet the rubric rather than merely watch every lesson.

## The exact first lesson text

Use this as the written lesson and the basis of your first recording:

> Before we ask an assistant to generate code, we need a way to decide whether the code did the job.
>
> Our application takes rough client notes and produces a draft brief. That sounds simple until we inspect an incomplete note. If the client did not specify a deadline, what should appear in the deadline field?
>
> A fluent model may fill the gap with something plausible. For this workflow, that is a failure. The correct behavior is to preserve the uncertainty and ask a question.
>
> Write the user first: a developer organizing an initial client conversation. Write the input: rough notes supplied with permission, or synthetic notes in this course. Write the output: a draft the developer can edit. Write the boundary: the application does not approve scope, give a binding quote, or send anything to the client automatically.
>
> Now create three examples. The first contains enough detail for a useful draft. The second contains almost no detail. The third contains a contradiction. For each, write what a useful response should do before you run a model.
>
> Notice that a test expectation does not have to prescribe the exact sentence. It can require that the response identify the contradiction, leave an unknown field empty, or remain unapproved.
>
> This is the first part of engineering an AI feature: deciding which behavior you will accept, what evidence you will inspect, and what remains a human decision.
>
> Your assignment is to write the specification below and add one example of your own. Do not implement a larger app yet. If you cannot state the intended behavior, more generated code will make the uncertainty harder to see.

## The assignment template

Complete these sentences: “The user is… The user is trying to… The input is… The output is… Information the app must not invent includes… A human must review… The workflow deliberately excludes… A normal case is… A missing-information case is… A contradiction case is… I will know the first version works when…”

Submit one page and your four cases. A reviewer should ask a clarifying question rather than silently complete the learner’s product decisions.

## The completion rubric

Score functionality, evaluation evidence, safe boundaries, explanation, and handoff from 0 to 2 each. Propose an 8 out of 10 completion threshold, with critical unresolved data or credential issues requiring correction.

A learner can revise. Completion is your educational assessment, not a professional certification. The final artifact should make the value of the membership visible without promising a job or income.
