# 6. Short videos, screen recordings, and technical demonstrations

[Previous](05-content-strategy-and-linkedin.md) · [Course home](../README.md) · [Next: search and evergreen discovery](07-seo-and-evergreen-discovery.md)

## Begin with the observable change

A technical video works when the viewer can quickly recognize a problem, see the relevant behavior, and understand the explanation. Expensive equipment cannot rescue an unclear demonstration. For a coding educator, the central asset is often a small example with a visible before-and-after result.

Imagine recording your entire desktop while narrating a twenty-minute debugging session. You know where to look because you built the application. A new viewer sees tiny text, several windows, and no clear reason to continue. The solution is to design the teaching moment before pressing record.

This lesson teaches a repeatable process for planning, recording, editing, packaging, and evaluating short technical videos. It assumes you can explain the underlying concept accurately. It does not require a specific paid editor or camera.

## Decide what one video should accomplish

Choose one teaching objective. “Understand coroutines” is too large. “See why closing the screen ends this request in this example” is workable. You can then choose the evidence: a small application, a visible action, a log change, and a diagram showing scope ownership.

A short social video, a course lesson, and a product trailer have different jobs. The social video should deliver a complete small insight. The course lesson can teach prerequisites and explore variations. The trailer should accurately show what the product contains and who it helps.

Do not use a trailer as the only sample of your teaching. Attractive music and quick cuts do not demonstrate whether a buyer can follow your explanations. Offer at least one representative educational segment when evaluating teaching quality matters to purchase.

A useful brief contains the viewer, their current knowledge, the problem, the demonstration, the takeaway, and the next step. If you cannot state these in a few sentences, narrow the topic before recording.

## Plan a sequence with a real payoff

For a hypothetical 60-second video, you might allocate a few seconds to the problem, show the behavior, explain the mechanism, repeat the useful conclusion, and offer a related resource. The exact duration is a creative choice, not a platform rule.

A storyboard makes the reasoning visible:

| Segment | Picture | Spoken purpose | On-screen support |
| --- | --- | --- | --- |
| Opening | Application and unexpected stop | Name the concrete problem | A short problem label |
| Demonstration | Close the screen and show logs | Point out the observed result | Highlight only the relevant line |
| Explanation | Ownership diagram beside code | Connect lifecycle to scope | Parent and child labels |
| Takeaway | Return to the important lines | State the diagnostic habit | One concise sentence |
| Next step | Sample guide preview | Offer a deeper worked example | A clear destination |

Do not add a hook unrelated to the content just because it sounds dramatic. “This mistake destroys every app” is harder to support than “This request stops when its owning scope ends.” Specificity can be both more credible and more interesting to the right viewer.

## Write for speaking

Spoken language needs shorter sentences and clearer transitions than dense prose. Replace “The propagation characteristics of cancellation are contingent upon hierarchical ownership” with “First, find the scope that owns this work.” Then explain the technical relationship precisely.

Read the script aloud. If you run out of breath or stumble over nested clauses, simplify it. You can keep a few deliberate pauses so the viewer has time to inspect code. Fast editing is useful when it removes dead time, but constant movement can prevent learning.

An illustrative script skeleton is:

> This request stops when I close the screen. Here is the action, and here is the log. The important question is which scope created the work. In this example, the work belongs to a scope whose lifetime ends with the screen. Start your diagnosis by tracing ownership. The sample guide walks through the complete setup and the variations this short clip leaves out.

Before using this skeleton, verify that your actual framework and code behave as described. The script is not a universal statement about all screens, scopes, or lifecycle implementations.

## Record clear audio first

Speech must be easy to understand. Choose a quiet space, reduce nearby fan noise where practical, and position the microphone consistently. Record a short test and listen with headphones before doing the full take. Check for clipping, harsh room echo, low volume, and distracting background sound.

You can begin with equipment you already own. A phone camera and an existing microphone are enough to test whether the format helps your audience. Upgrade when you can identify a recurring limitation that the purchase will solve. A more expensive camera will not fix unreadable code or a wandering explanation.

Keep input levels below clipping and leave headroom. Exact controls differ by recording software. Apply modest processing only if it improves intelligibility. Aggressive noise removal can distort consonants and make technical terms harder to recognize.

If using background music, keep it subordinate to speech and verify you have the rights to use it. Silence is often a good choice for a short debugging demonstration.

## Frame code for the actual viewing surface

A full desktop contains far more information than a phone can display comfortably. Increase editor font size, hide irrelevant panels, and crop around the active region. Use a clean demonstration project. Remove private tokens, notifications, customer identifiers, and unrelated personal windows before recording.

A vertical composition can stack a result, code, and a simple diagram, but do not make all three equally dense. Choose one primary focus at a time. A wider composition may work better for side-by-side code comparisons. Pick based on readability, then preview the actual result on a phone.

As production starting points, you can test a 1080×1920 vertical canvas or a 1920×1080 landscape canvas at 30 frames per second. These are editorial choices, not claims about preferred distribution or current upload limits. Check the destination's requirements when exporting.

Highlight a few relevant lines instead of zooming randomly. Cursor movement should guide attention. If the viewer needs to see a terminal result, hold it long enough to read. Avoid flashing code that the narration expects them to understand immediately.

## Record in small, repairable sections

Prepare the environment so the demo produces a consistent result. Reset application state, use reliable sample data, and rehearse the relevant interactions. Capture a clean version of the result separately if the explanation requires several takes.

Record the narration and screen together when spontaneous explanation is useful. Record separately when you need precise timing or want to replace a sentence without rerunning the demo. Neither method is universally better. Choose the one that lets you preserve accuracy and understandable pacing.

When you make a mistake, pause and restart the sentence. You can remove the bad section later. Constantly restarting the entire video turns a small task into a large one. Keep a simple take log if you record many versions.

Do not fake application behavior to strengthen a claim. You can edit out loading delays if the edit does not misrepresent performance or omit an important step. If a demonstration uses a mock service or simplified code, say so where that context affects interpretation.

## Edit for comprehension

First remove mistakes, unrelated setup, and long pauses. Then make the sequence easier to follow. Add highlights, concise labels, and transitions only when they serve the explanation. Decorative effects increase editing time and may compete with the code.

Use captions and manually inspect technical terms, code identifiers, negations, and numbers. An automatic caption that changes “not cancelled” to “cancelled” reverses the lesson. Make sure the text is readable against the background and does not cover the exact output you are discussing.

LinkedIn's current help page describes caption options and advises keeping key material away from interface-covered edges. It also explains that creators do not directly place uploads into the immersive feed. See [R2](../SOURCES.md#r2-linkedin-video). Do not promise a particular feed placement.

Avoid treating captions as a complete accessibility solution. Spoken descriptions of visual changes and an accompanying text explanation help people who cannot easily inspect the screen. A written code sample can make the demonstration easier to revisit.

## Package the post honestly

The thumbnail or opening frame should communicate the topic without requiring tiny text. A useful label might be “Trace cancellation ownership.” The accompanying post can state the setup, the lesson, and where to find the complete example.

Use one relevant call to action. If the video teaches a concept, invite the viewer to inspect the sample lab or share a related debugging situation. If it demonstrates the product, explain what the buyer receives. Asking people to like, follow, comment, subscribe, and buy at once creates competing actions.

Do not assume that a short video must withhold the answer. Deliver one useful insight and explain why a longer resource exists. Buyers can value structure, exercises, and a coherent sequence even when you publish strong free explanations.

## Evaluate retention without optimizing away the learning

If your platform provides viewing and retention information, look for places where viewers leave. A steep early drop could indicate a weak opening, irrelevant audience, unclear first frame, or an auto-play exposure that never reflected genuine interest. A later drop might align with a confusing explanation or simply the point at which viewers received their answer.

Compare videos with similar topics and intended audiences. A long and a short video naturally produce different completion patterns. Repeated viewing may reflect interest or confusion. Metrics suggest questions; they do not explain motives by themselves.

Track relevant visits and responses alongside viewing metrics. A video that generates fewer views but several thoughtful questions from intended buyers may be commercially useful. Avoid cutting every necessary explanation just to improve completion percentage.

## Build an efficient recording routine

Maintain a reusable project layout, a caption style, a recording checklist, and a folder of original demonstration assets. Reuse the setup so each new video does not become a design project. Batch recordings only after the examples are ready.

For a weekly routine, prepare one reliable demo, record several short sections, edit a complete explanation, inspect the export on a phone, and publish with a coherent text description. Keep a note of what took the most time. The next improvement should remove the real bottleneck: unclear script, fragile demo, audio repair, or excessive editing.

## Optional application: create one useful short

Produce a 45–90 second demonstration as a creative constraint, not a platform optimum. Show one behavior, explain its cause, and give the viewer a usable takeaway. Include accurate captions and a related written explanation. Review sound, code readability, privacy, claims, and destination links before publishing.

A successful first exercise is a video that a relevant developer can understand and accurately summarize. Reach is a later observation. Your first responsibility is a clear teaching experience.
