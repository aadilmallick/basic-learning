# Articles and YouTube scripts

# 9 Writing that attracts the right developer

Publish article A on your own site first, with a clear title and working resource CTA. Share a platform-native introduction on LinkedIn. Republish or adapt where you have rights and the publication’s rules permit it; do not assume identical copies on many sites improve discovery.

Add screenshots only from the real reference project. Replace a screenshot caption with a factual description if the implementation changes.

## Article A ready-to-adapt copy

Title: Your AI prototype works once Now test the next ten inputs

> A prototype can be convincing while leaving important questions unanswered.
>
> The interface renders. The assistant returns a paragraph. The demo input produces a useful result. You can show the screen to someone and explain what the feature is supposed to do.
>
> The next question is whether you understand what happens when the input changes.
>
> Consider a small application that turns rough client notes into a project brief. A normal input might describe a dog groomer who needs a five-page website and a way to request appointments. The application can organize the information into something useful.
>
> Now remove most of the detail. The note says only, “I need a website for my business.”
>
> What should the application do?
>
> It could invent a deadline, a list of pages, and a customer login. The output would look complete. It would also give the developer commitments the client never made.
>
> For this workflow, a useful response preserves missing information and asks questions. That behavior needs to be part of the specification.
>
> Start with a small output contract. Separate information supplied by the user from assumptions and open questions. Keep the result in draft state until a person reviews it.
>
> Then create examples before changing the prompt.
>
> Use a normal input, an incomplete input, a contradictory input, and a failure condition. Add a note that says both “no accounts needed” and “customers must sign in.” Decide what should happen when the model times out. Decide what happens if someone presses the generate button repeatedly.
>
> These examples are not a complete assurance program. They are a way to replace a vague feeling with inspectable behavior.
>
> The important distinction is between output structure and output meaning.
>
> A response may contain every required field and still make an unsupported claim. A schema check can help reject malformed data. It cannot independently establish that the client actually requested every requirement.
>
> That means the interface matters as well as the model call. An editable draft, visible uncertainty, and an explicit review step can be more useful than another instruction to “be accurate.”
>
> Make one change for one observed problem. Perhaps you separate assumptions from requirements. Perhaps you invalidate approval when the draft changes. Perhaps you limit recovery attempts after a timeout.
>
> Run the same examples again. Keep the earlier results. Record what changed and where the new version still fails.
>
> Be careful with the conclusion. Passing a small teaching set does not prove the application is safe for every user or input. It does show that you have started defining the behavior you intend to support.
>
> AI coding assistants can help implement these changes. You still need to inspect the diff and compare the behavior against the specification. A confident summary of the change is not a substitute for running the relevant check.
>
> If you want a small next step, choose one uncertain behavior in your own prototype. Write the expected result, create the smallest input that exposes it, and test the current version before editing anything.
>
> That gives you a concrete engineering task. “Make it more reliable” does not.
>
> I put the same process into an AI App Shipping Checklist for JavaScript developers. It covers the request path, validation, uncertainty, recovery, usage boundaries, and handoff. Get it from the resource link on this page.
>
> If you want to practice on a guided project, the checklist page also explains the next free workshop. The session ends with an optional invitation to my paid project lab.

Add a factual author bio and links to relevant work. Do not add a student result or numerical improvement until you have permission and evidence.

## Article B ready-to-adapt copy

Title: What to review before accepting AI generated code

> The coding assistant says it implemented the feature. Before accepting the change, I want to know three things: what changed, what behavior that change creates, and how I can check it.
>
> Start with the original request. If the request says “add an editable draft,” the acceptance criteria should explain what editing means. Does the exported document reflect the edit? Does changing a previously approved draft require another review? Are unknown fields still visibly unknown?
>
> Without those details, the assistant can produce something that looks finished while you and the software disagree about the task.
>
> Inspect the diff in small pieces.
>
> Name each changed file and its role. If a new dependency appears, ask what problem requires it. If a server operation moves into browser code, inspect the implications rather than assuming the move is harmless.
>
> Follow one request through the system. The user submits notes. The application validates the request. A server calls the model. The response is checked. The interface displays a draft. A person edits and reviews it.
>
> That trace gives you places to ask useful questions. What happens if the input is too long? If the response is malformed? If the request times out? If two requests finish in a different order?
>
> You do not need to answer every possible question before making a training prototype. You do need to know which behavior is implemented, which is untested, and which is outside the stated scope.
>
> Next, inspect the check that supposedly proves the change works.
>
> A test that merely repeats the implementation’s assumptions may miss the actual user problem. For an editable brief, checking that a text box exists is weaker than checking that an edited requirement appears in the exported draft.
>
> Use one normal case and at least one revealing edge case. Add a regression check for the bug you just fixed. Run the existing relevant checks so the correction does not quietly break earlier behavior.
>
> Finally, explain the change without reading the assistant’s summary.
>
> If you cannot describe the request path or the reason for an important condition, slow down and investigate. You are responsible for the application you choose to ship.
>
> A useful assistant can make implementation faster while leaving these responsibilities with you.
>
> Try this on your next small change: write the acceptance criteria first, inspect the diff, run the behavior check, and explain the result. Keep a note of what remains uncertain.
>
> My free AI App Shipping Checklist gives you a reusable version of that review. The project lab applies the same method to a six-week AI application sprint with scoped feedback.

## Why these articles belong in the funnel

Both help the same developer who would benefit from the paid sprint. The examples demonstrate your teaching method. The resource CTA asks for a small next step. The membership invitation appears only after the reader understands the problem and your approach.

Measure resource visits and qualified replies by article. A technical article that produces a handful of appropriate learners may be more useful than a broadly popular tool list.

# 10 YouTube production and the first two scripts

Use a screen-first format with your voice and optional camera. Keep code readable at normal viewing size, enlarge the relevant area, hide secrets and private notifications, and show the finished behavior early.

Record one main take, then capture closeups of the actual changes. Edit pauses and repetition. Add captions and a written summary. Use your existing equipment before buying new tools.

YouTube describes discovery as depending on viewer personalization and how people choose and continue watching. Treat the opening and explanation quality as things to inspect, not a guaranteed algorithm trick. [YouTube discovery guidance](https://support.google.com/youtube/answer/11914225?hl=en)

## YT01 The prototype works until the client changes the brief

Suggested title: I tested an AI app beyond the demo input

Thumbnail text: THE SECOND INPUT

Visual: the same draft screen beside the incomplete input that exposes the problem. Do not invent a red error or fake score.

Target length: 8 to 12 minutes including the live demonstration. The narration below is the script; the screen work and explanation pauses supply the remaining time.

> This app turns rough client notes into a draft brief. Here is the normal input, and here is the result. Now I am going to remove most of the information.
>
> The interesting question is what the application should do with what it does not know.
>
> Before running it, I want to write the expected behavior. The app should preserve uncertainty, ask useful questions, and keep the brief unapproved. It should not silently decide what the client bought.
>
> I am using fictional notes throughout this example. We do not need real client data to learn the mechanism.
>
> Here is the request path. The interface submits the notes to a server endpoint. The model returns a response. We check its structure before showing an editable draft. A person reviews it before export.
>
> Notice that each boundary has a different job. A server boundary keeps provider access under our control. A schema check helps with response shape. Human review and explicit uncertainty help with a different problem: a plausible statement that the client never supplied.
>
> Let us run the incomplete input. I will compare the actual behavior with the expectation rather than decide afterward that whatever happened is acceptable.
>
> [Run C02 and describe exactly what appears. If it already behaves correctly, explain the relevant implementation. Do not manufacture a failure.]
>
> Now let us use a contradiction. The notes say there should be no login, but they also say every customer must sign in. The useful behavior is to expose that conflict.
>
> [Run C03. Show the observed output and the corresponding result-sheet entry.]
>
> I am going to make one small change based on the issue we actually observed. I want to keep assumptions separate from stated requirements. I will ask the coding assistant for a bounded change, inspect the diff, and run the same examples again.
>
> [Show the real change, or use a clearly labeled prepared teaching branch. Explain each relevant file.]
>
> This is the point where a test set becomes useful. We can compare the same cases before and after. We can also discover that fixing one case made another worse.
>
> A small set does not prove the app is reliable in general. It makes this particular behavior easier to inspect.
>
> Here is the next thing I would do: add one example from a different kind of brief, then document the remaining limitations. I would also verify timeout behavior before sharing the app.
>
> If you have an AI prototype, choose one unknown behavior and write the expected result before changing the prompt. That is a useful task you can do today.
>
> The free AI App Shipping Checklist is linked below and from my channel profile. It includes the questions used in this walkthrough. If you want a guided project with feedback, the resource page explains the next workshop and the paid lab.

Description opening:

> A practical walkthrough for JavaScript developers moving beyond a single successful AI demo. We inspect incomplete and conflicting inputs, separate response structure from meaning, and compare a small change against the same cases.
>
> Free checklist: [resource link]
>
> Workshop details: [workshop link]
>
> The demonstration uses synthetic inputs. This is a training example, not a security certification or a guarantee for every deployment.

## YT02 Review the change before accepting it

Suggested title: How I review AI generated code before merging it

Thumbnail text: CHECK THE DIFF

> I asked an assistant to make this draft editable. Before accepting the change, I want to check whether the behavior matches the request.
>
> A text box appearing on the screen is only part of the result. If I change a requirement, does the export change? If I edit an approved draft, should it still be approved?
>
> I am going to write those checks first.
>
> [Show the two acceptance criteria.]
>
> Here is the diff. I will identify the role of each changed file and follow one edit through the application.
>
> [Trace the interface update, state, approval behavior, and export.]
>
> The assistant’s explanation is useful context, but I need to inspect the actual behavior. Here is the normal edit. Here is the case that changes an already approved draft.
>
> [Run the checks. Describe the result accurately.]
>
> If the behavior fails, I want the smallest correction that addresses it. I will avoid asking the assistant to rewrite the whole application while I am still trying to understand one state transition.
>
> [Show the real correction or a labeled teaching version.]
>
> Now I will rerun the same checks and the relevant earlier ones. The goal is to understand what changed and whether the original problem was fixed.
>
> Finally, I want to explain the result in my own words. The draft can be edited. Export uses the current content. A material edit requires review again. These are product decisions we made explicit.
>
> This review method works beyond this example: define the behavior, inspect the diff, run a revealing check, and explain the result.
>
> The free checklist below gives you the same process. The AI App Shipping Lab applies it across a full project, including evaluation, failure handling, deployment, and handoff. See the workshop page if that matches what you need.

## The next six videos

Use these after the first two and adapt them to actual questions:

1. “A valid JSON response can still be wrong” with the unsupported-requirement example.
2. “What happens when your AI request times out” with the recovery path.
3. “The smallest useful evaluation set for an AI feature” with the results sheet.
4. “Keep assumptions out of the client scope” with editable uncertainty.
5. “What I put in an AI app handoff” with the real README.
6. “A browser extension for the same workflow” as the later adjacent project.

For each, show the behavior first, teach one mechanism, demonstrate a check, and use the resource or workshop CTA. Do not create six new applications to make six videos.
