# Lesson 1 — Visual storytelling and the video production pipeline

A technical video is an argument made in time. It asks a viewer to pay attention, shows an idea or a result, and leaves them with something they understand or can do. The graphics, narration and editing are the means by which that argument becomes clear.

This lesson starts before installing a video framework. You will take a small developer topic from an idea to a timed plan, understand what the basic video settings mean, and make a simple browser-based animatic. We will use database indexes as a recurring example because they let us show a genuine technical idea without inventing performance numbers. The same planning process applies to a product launch or an application demonstration.

You do not need to be an experienced designer or video editor. You do need a text editor and a web browser for the optional code example. Later lessons introduce React, Remotion and HyperFrames in detail. Here, HTML and JavaScript are just a way to see how a sequence of planned visuals can become something that changes over time.

## 1. What problem does a video solve?

Imagine you built an application called QueryLens. It displays database query information in a readable interface. You could post a sentence saying, “I made a query viewer.” That tells people the project exists, but it does not show what using it feels like or why they might care.

A video can make that information visible. It can show a confusing query result, then the application presenting the same information in a more understandable way. It can bring attention to one important control while a short narration explains its use. It can establish a sequence of cause and effect. Those are advantages of the medium: movement reveals change, a screen recording shows behavior, and sound can add context while the viewer looks at the image.

A video also has a constraint that text does not have in the same way. A reader can skim a paragraph or go back easily. A video advances at the editor's chosen speed. If three labels appear while the narrator introduces a new idea, the viewer must divide their attention or pause. A technically correct video can therefore fail as teaching if it gives the audience insufficient time to understand what is on screen.

The first design question is not “What effects should I add?” It is “What change in understanding should happen between the start and the end?” Write that change as a simple sentence:

> A developer who has heard of an index will understand that an index offers an alternate path for finding rows, while recognizing that the database may still choose a scan.

That sentence gives you a decision rule. A dramatic animated database tunnel might look attractive, but if it makes finding the explanation harder, it works against the goal. A simple diagram that shows two possible paths may be a better choice.

### Different types of developer video

| Type | Primary viewer question | Useful proof | Common risk |
| --- | --- | --- | --- |
| Explainer | “How does this idea work?” | A concrete example and a clear diagram | Oversimplifying until the explanation becomes false |
| Tutorial | “How do I do this?” | Steps performed in a real environment | Skipping prerequisites or hiding an error |
| Demo | “What does this product do?” | Real interaction with real interface behavior | Showing mockups as if they were current features |
| Launch video | “What is this, and why should I care?” | A believable outcome and a memorable presentation | Claims that go beyond available evidence |
| Commentary | “What is your perspective?” | Reasoning, examples and disclosed uncertainty | Turning an opinion into an unsupported fact |

A single clip can combine categories, but one primary purpose makes editing easier. If a launch video turns into a detailed tutorial, the essential product message may arrive too late. If an explanation becomes a product advertisement, the viewer may not learn the idea promised in the opening.

## 2. The smallest useful creative brief

A brief is a short set of constraints. It is not bureaucratic paperwork. Its purpose is to make important decisions early enough that a script, storyboard and agent prompt all point in the same direction.

A useful brief answers these questions:

1. **Audience:** Who is watching, and what can you reasonably assume they know?
2. **Objective:** What should they understand, feel or do afterward?
3. **Core message:** What single idea carries that objective?
4. **Evidence:** What example, demonstration or source makes the message credible?
5. **Format:** What approximate duration and aspect ratio suit the planned destination?
6. **Action:** Is there a useful next step, such as reading a post or trying a product?
7. **Constraints:** What footage, access, budget, privacy boundaries and deadline are real?

For the database-index example:

```text
Audience: Developers who know what a database table and row are.
Objective: Understand why an index can help locate matching rows.
Message: An index is an additional data structure that offers a search path.
Evidence: A simplified example of finding one user by email.
Format: Approximately 20 seconds, vertical 9:16.
Action: Read a longer post about indexes and tradeoffs.
Constraints: No numerical speed claim; no real customer data; captions readable
on a phone. A sequential scan can still be the optimizer's better choice.
```

Notice the distinction between an objective and a message. “Understand why an index can help” describes the desired change in the viewer. “An index offers a search path” is the idea you use to cause that change. The evidence shows that idea operating on a specific example. Without evidence, the message risks being only a slogan.

An AI agent can draft a brief, but it cannot know whether your interface truly does something unless it can inspect the relevant project or you provide reliable information. Treat facts and access claims as inputs to verify. If there is no evidence for a claim, either gather evidence, qualify the claim, or remove it.

## 3. From message to story: hook, development and payoff

Even a 20-second video benefits from a structure. A practical structure is:

- **Hook:** Give the viewer a reason to care about the specific problem.
- **Development:** Show the relevant situation or mechanism.
- **Payoff:** Reveal the useful insight or result.
- **Optional next step:** Point the viewer to a relevant action.

A hook is not necessarily a startling claim. “Your database is slow because you forgot this one trick” is tempting but misleading: database performance has many causes. A more honest hook is “How does a database find one row among many?” It creates a question the rest of the video can answer without promising a universal result.

Consider this draft:

```text
0–4 s: How does a database find one row among many?
4–9 s: One option is to inspect rows until matching values are found.
9–16 s: An index provides another structure the database may search.
16–20 s: The optimizer chooses a plan; an index is not always best.
```

The opening frames a problem. The middle introduces two options. The ending prevents a common misconception. The timeline is a starting estimate, not proof that the script fits. Read it aloud at a natural speed and allow time for visual comprehension. If it does not fit, remove or simplify a concept rather than artificially speeding up the narration.

### A note on technical analogies

An index is often compared to an index in a book. This can be useful: both provide a way to locate relevant material without starting at the beginning. But the mapping is imperfect. Real databases support different index structures, may store pointers or row identifiers differently, and can use an index in many ways. A book index does not explain query optimization, selectivity, write overhead or covering indexes.

For a short video, show the analogy and explicitly avoid implying it is a literal description of every database implementation. A later detailed lesson or linked post can discuss the omitted mechanisms. Simplification is not the same as inventing a rule.

## 4. Write a script for the ear and the eye

A script for video has at least two tracks: what is heard and what is seen. They should complement one another. If narration says, “The index points to a matching row,” a graphic can show a search path connecting an index entry to a highlighted row. The viewer hears the relationship and sees an example at the same time.

They do not need to read a paragraph that exactly repeats every spoken word. Reading and listening both consume language-processing attention. Short labels, captions, simple shapes and sequential reveals usually give the viewer less to juggle than multiple blocks of prose.

Here is a complete draft script with approximate timing. The timing is illustrative; actual delivery determines the final cut.

| Time | Narration | Visual | Purpose |
| --- | --- | --- | --- |
| 0–4 s | “How does a database find one user among many?” | A table of rows, one search field | Establish the question |
| 4–8 s | “It can inspect the rows to find a match.” | A highlight moves through several rows | Make scanning concrete |
| 8–15 s | “An index can offer another search path.” | A small index diagram leads toward one row | Introduce the new mechanism |
| 15–20 s | “The database chooses a plan for the query.” | Both paths remain visible; one is selected | Avoid implying an index is always used |

A production version should be checked against the database engine and scenario you intend to discuss. In particular, do not claim a specific complexity or speedup without explaining assumptions and having appropriate evidence. This short script is conceptual rather than a benchmark.

### Make each shot answer a question

A shot is a continuous visual segment. An animated sequence can contain several shots even when all visuals are made in one framework. Ask what each shot contributes:

- The table shows the thing being searched.
- The moving highlight makes a scan visible over time.
- The index diagram introduces an alternate structure.
- The two-path view explains that a database has a choice.

If an element has no clear function, remove it temporarily. A decorative animated cloud behind a diagram may establish style, but if it competes with a small label it harms the explanation. Decoration can return after the informational layer is readable.

## 5. Storyboard, shot list and animatic

These three artifacts are related but different.

A **storyboard** depicts the important moments. It might be a set of rough still images, each with a note describing the intended action. The images can be boxes and labels; they do not need to be polished illustrations. The purpose is to evaluate the visual explanation before investing in final graphics.

A **shot list** describes what must be created or captured. For the example above, that might include a static table, a row highlight animation, an index diagram, a search field, a recorded voiceover and captions. A shot list is useful for identifying missing assets and deciding which pieces should be real screen recordings versus designed graphics.

An **animatic** puts rough storyboard images in time, often with temporary narration or a timing track. It answers a question still images cannot: “Does this sequence give the viewer enough time?” A good animatic can use plain rectangles, basic fonts and a temporary voice. Its roughness helps you change the structure without feeling that you are throwing away polished work.

An example shot list:

```text
Shot 01 — Question
  Duration: roughly 4 seconds
  Source: designed graphic, not a live database recording
  Elements: question, table outline, search field
  Motion: title enters; table appears after title settles

Shot 02 — Scan
  Duration: roughly 4 seconds
  Source: reusable table graphic
  Elements: rows, one matching email address
  Motion: highlight travels through example rows
  Accuracy: simplified illustration; not a trace of an actual query plan

Shot 03 — Index path
  Duration: roughly 7 seconds
  Source: designed index and arrow
  Elements: index card, table, highlighted match
  Motion: emphasize index entry, then reveal connection

Shot 04 — Choice
  Duration: roughly 5 seconds
  Source: reuse both earlier diagrams
  Elements: scan path, index path, “plan” label
  Motion: hold long enough to read; end on a stable frame
```

This description makes the production requirement reviewable. “Make it cool” is not a requirement you can objectively inspect. “The index arrow appears after the narration names the index, then holds on the matching row” is an observable behavior.

## 6. Video fundamentals: frames, duration and resolution

A digital video presents a series of images called **frames**. Playing them in order creates apparent motion. Frame rate is measured in frames per second, usually abbreviated FPS. At 30 FPS, one frame lasts approximately 1/30 of a second, or 33.3 milliseconds. A ten-second sequence at a constant 30 FPS contains 300 frames.

```text
frame count = duration in seconds × frames per second
```

For 20 seconds at 30 FPS:

```text
20 × 30 = 600 frames
```

If frames are indexed starting at zero, the first is frame 0 and the last is frame 599. Frame 600 would be the start of the next second after the 20-second duration. This indexing detail matters later when code decides when a scene appears or disappears.

**Resolution** describes the width and height of a frame in pixels. A vertical 1080 × 1920 frame has 1080 pixels across and 1920 pixels down. Its aspect ratio is 1080:1920, simplified to 9:16. A 1920 × 1080 frame is 16:9 and horizontal.

An aspect ratio describes shape, not quality. Both 540 × 960 and 1080 × 1920 are 9:16, but the latter has four times as many pixels because each dimension is doubled. More pixels can improve detail, but they also increase the amount of data to render, process and encode.

You cannot automatically make a horizontal design work vertically by shrinking it. A wide paragraph may become unreadable when reduced to fit a narrow frame. A thoughtful vertical layout may need a new hierarchy, a closer crop or fewer words. Plan your main destination first, then redesign additional versions where necessary.

**Pixel dimensions are not the same as perceived readability.** A title can have many pixels but still look tiny when a phone displays the full frame. Review at the physical size and viewing distance your audience is likely to use.

## 7. Codec, container and compression

After frames are generated, the video needs to be stored and played. A **codec** specifies how video or audio is encoded and decoded. H.264 is an example of a video codec. AAC is an example of an audio codec. A **container**, such as MP4 or MOV, holds streams and metadata together. An MP4 file may contain H.264 video and AAC audio, but the filename extension alone does not fully describe what is inside.

**Compression** reduces the amount of data needed to store or transmit the video. Lossy compression discards some information. Stronger compression may produce blockiness, banding in gradients, blurred text, or motion artifacts. Increasing bitrate often helps, but the right setting depends on content and the destination. Tiny text and fine line art can be especially sensitive.

A practical workflow is to keep an editable source project and, when useful, a high-quality master. Export delivery versions according to the requirements of the platform you are using. Repeatedly exporting an already compressed copy can compound artifacts, so prefer returning to the source or a suitable master when you make revisions. Do not assume a particular upload setting will stay current; consult the destination's present specifications.

The renderer's preview and final export are related but not identical experiences. A preview may drop frames when an effect is expensive, or it may use different resolution or settings. A rendered video is evaluated frame by frame and encoded for playback; resource loading, fonts, timing and codecs can still cause differences. Always watch the actual output file, including its beginning and end.

### A small calculation

A 20-second video at 30 FPS has 600 frames. Suppose a render averages 0.2 seconds of computation per frame in a simplified, sequential thought experiment. Capturing frames alone would take about 120 seconds. In practice, parallel work, decoding, effects, hardware and encoding change the result, so this is an estimate, not a performance promise. The point is conceptual: a 20-second video can take longer than 20 seconds to render because the computer must compute and encode every frame.

## 8. Try a browser-based animatic

The following file is a small, complete animatic. It uses plain HTML, CSS and JavaScript. Save it as `animatic.html`, then open it in a current browser. It is a planning preview, not a Remotion or HyperFrames project, and it does not export a video. A later lesson replaces the real-time clock with frame-driven rendering.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Index explainer animatic</title>
  <style>
    body { margin: 0; background: #111827; color: white; font-family: system-ui; }
    main { width: min(90vw, 405px); aspect-ratio: 9 / 16; margin: 2rem auto;
      background: #172554; display: grid; place-items: center; padding: 1rem;
      box-sizing: border-box; }
    .scene { text-align: center; max-width: 20rem; }
    .eyebrow { color: #67e8f9; text-transform: uppercase; letter-spacing: .1em; }
    h1 { font-size: 2rem; line-height: 1.1; }
    p { font-size: 1.1rem; line-height: 1.4; }
    button { font: inherit; padding: .7rem 1rem; }
    footer { text-align: center; }
  </style>
</head>
<body>
  <main><section class="scene" aria-live="polite">
    <div class="eyebrow" id="label"></div>
    <h1 id="title"></h1><p id="detail"></p>
  </section></main>
  <footer><button id="restart" type="button">Restart</button>
    <p id="clock"></p></footer>
  <script>
    const scenes = [
      { start: 0, label: "Question", title: "Find one user", detail: "How can a database locate a matching row?" },
      { start: 4, label: "Scan", title: "Inspect rows", detail: "A scan can examine rows to find a match." },
      { start: 8, label: "Index", title: "Another path", detail: "An index can offer a different way to search." },
      { start: 15, label: "Plan", title: "Choose a path", detail: "The database chooses a plan for the query." }
    ];
    const duration = 20;
    let startedAt = performance.now();
    const label = document.querySelector('#label');
    const title = document.querySelector('#title');
    const detail = document.querySelector('#detail');
    const clock = document.querySelector('#clock');
    function draw(now) {
      const time = Math.min((now - startedAt) / 1000, duration);
      const scene = [...scenes].reverse().find(item => time >= item.start);
      label.textContent = scene.label;
      title.textContent = scene.title;
      detail.textContent = scene.detail;
      clock.textContent = `${time.toFixed(1)} / ${duration} seconds`;
      requestAnimationFrame(draw);
    }
    document.querySelector('#restart').addEventListener('click', () => {
      startedAt = performance.now();
    });
    requestAnimationFrame(draw);
  </script>
</body>
</html>
```

The `scenes` array is the shot plan in data form. Each object has a start time and text to display. When the browser draws, the code calculates elapsed seconds and searches backward for the last scene whose start time has been reached. At 9 seconds, for example, the scene beginning at 8 seconds is selected. The `duration` variable stops the displayed time at 20 seconds. The restart button resets the start time.

The page uses `aspect-ratio: 9 / 16` so that its preview has the intended vertical shape. The content uses `textContent`, which inserts text rather than interpreting it as HTML. There is no audio or animation beyond changing the displayed scene; that is intentional. The goal is to test timing and message before adding polish.

`requestAnimationFrame` follows the browser's real-time display loop. It is appropriate for this simple interactive preview, but it does not guarantee that an offline renderer can ask for any frame and receive the correct output. For production compositions, use the timing mechanism required by the chosen framework, as later lessons explain. This limitation is an example of why “it moves in a browser” and “it renders deterministically as video” are different requirements.

To adjust the plan, change a scene's `start` value or its text. Keep starts in ascending order. Read the corresponding narration aloud while the page runs and notice where you need more time. A real project might use still frames and temporary audio instead of this HTML page; the decision-making process is the same.

## 9. Where AI helps, and where you need to direct it

AI can help create variants of the hook, restructure the narration, propose visual metaphors, write a shot list or produce code for an animatic. It can also make confident mistakes: a visually convincing database animation may teach the wrong mechanism, and an invented statistic may sound plausible. Quality control therefore belongs in the workflow, not just at the final export.

Give an agent four kinds of information:

1. **Intent:** audience, message and desired outcome.
2. **Evidence:** approved claims, source documents, real product behavior and uncertain areas.
3. **Constraints:** duration, aspect ratio, available assets, privacy and budget.
4. **Checks:** what to inspect and how to report gaps.

Compare two requests:

```text
Weak: Make a cool AI video about databases.

Stronger: Plan a 20-second vertical explainer for developers who know tables
and rows but have not studied indexes. Explain that an index can provide
another search path and that the optimizer may choose a scan. Create a four-shot
storyboard and narration; use no numerical performance claims. Identify what
must be verified, then create a simple local HTML animatic with editable text.
```

The stronger prompt does not prescribe every visual choice. It constrains what must be true and leaves room for creative choices that can be reviewed. It also separates planning from producing a final video, making it cheaper to revise the story.

### Claude Code prompt

```text
Read the brief below and create storyboard.md plus a simple HTML animatic in
this folder. The audience knows tables and rows. The goal is to explain that
an index can provide an alternate search path; the database may choose a scan.
Target 20 seconds and 9:16. Do not invent speed claims or imply the illustration
is a real query trace. Use local assets only. Explain the purpose of each scene,
mark any assumptions, and tell me how to alter timing and copy. Review the
result for readable text and leave a list of anything you could not verify.
```

### Codex prompt

```text
In this project, create a four-scene storyboard and a self-contained browser
animatic for a 20-second 9:16 database-index explainer. Use a simple index
metaphor, but state its limits. Keep text editable and scene timing in one data
structure. Do not use customer data, paid services, or numerical speed claims.
Inspect the result where the environment permits, describe the checks you ran,
and explain how to change the duration and order of scenes.
```

The prompts deliberately request observable deliverables and an honest report of checks. They do not guarantee that every environment can open a browser or inspect visual output. If an agent reports a limitation, perform the missing review yourself or use a tool that can display the result.

## 10. Production workflow and asset decisions

Once the plan is understandable, production can proceed in small passes:

1. **Brief and source check:** settle the audience and verify claims.
2. **Script:** write narration and concise on-screen copy.
3. **Storyboard:** choose what the audience sees at each beat.
4. **Animatic:** check duration and sequence with rough visuals and temporary audio.
5. **Assets:** collect or create permitted screenshots, screen recordings, graphics, voice and music.
6. **Composition:** arrange elements and animate important changes.
7. **Sound and captions:** synchronize narration, effects and corrected captions.
8. **Review:** check representative frames, then watch the complete export.
9. **Delivery:** export suitable versions and retain source and asset information.

These stages are not a rigid waterfall. If the animatic reveals an unclear explanation, revise the script. If the recording exposes an awkward interface interaction, revise the storyboard. The point of the ordering is to find expensive mistakes early, while a rough plan is still easy to change.

### Which technique makes each asset?

A real application demonstration needs an honest representation of actual product behavior. A screen recording is often the clearest proof. An animated diagram needs precise labels and positions, so code, vector graphics or a design tool can be appropriate. A cinematic atmospheric background might be generated from an image or video model, licensed from a stock provider, or filmed. A voice can be recorded or synthesized if the chosen use complies with consent and licensing requirements.

The techniques can coexist. For example, a screen recording can sit inside a code-animated device frame over a generated background. The final assembly may be performed in Remotion, HyperFrames or a conventional editor. Whichever approach you choose, keep a list of where assets came from, their permitted uses and any required attribution. Do not upload private company material to external tools without authorization.

## 11. Common problems and their causes

### The hook is exciting but unrelated to the lesson

A hook creates an expectation. If the viewer is promised a “secret database trick” and receives a general definition, the video feels disconnected. Rewrite the hook to describe the question the video actually answers.

### Every scene introduces a new concept

In 20 seconds, the audience may not have time to understand indexes, B-trees, query plans, selectivity, write amplification and caching. Choose one primary idea and connect to deeper material elsewhere. You can still mention a critical caveat briefly, such as “the optimizer chooses a plan.”

### The narration and visual contradict each other

If the narrator says “the database may scan” while the animation always shows a direct index lookup, the visual can accidentally teach a stronger and false rule. Design the visual to reflect the qualified claim, or label the example clearly.

### There is no time to read

A title appearing for a quarter second may be legible in a screenshot and unreadable during playback. Test it at real speed. Shorten the text, increase the hold, or reduce competing motion. Do not rely solely on a frame-by-frame inspection.

### A polished export is treated as evidence

A beautiful generated screen or chart is not proof that a product works or that a performance result is real. Record actual behavior and use measured data when making factual claims. Label mockups, simulations and illustrative examples.

### The plan never reaches production

Planning can become excessive. Once the core message, approximate timing and major visual beats are clear, create a rough animatic. Use the result to decide the next change. The plan is a working tool, not a permanent contract.

## 12. A complete example production brief

The following combines the decisions made throughout the lesson. You can adapt it to your own developer content.

```text
Working title: How an index helps find a row
Audience: Developers comfortable with tables and basic SELECT queries
Primary takeaway: An index can provide an alternate search path, but the
optimizer chooses a plan based on the query and available information.
Format: 20 seconds, 9:16, captions, phone-readable labels
Tone: Clear, curious, restrained; no claim of universal speedup

0–4 s: Show a table and the question “Find one user?”
4–8 s: Highlight rows in sequence; label this a simplified scan.
8–15 s: Reveal an index card and a path to a matching row.
15–20 s: Show both choices and the label “The database chooses a plan.”

Narration: Record a natural read, then adjust timing around the recording.
Assets: Original vector shapes; no company data; local placeholder fonts.
Review: Verify the technical wording, captions, text size and final audio.
Next step: Link to a longer explanation of index tradeoffs.
```

The output of this lesson is a plan that can be understood and changed. It is not yet a complete final video, and it does not need an AI-generated cinematic scene to be useful. The next lesson takes one of the still frames from this plan and develops the visual hierarchy, typography, spacing and color that make it readable before animation begins.

## References

- [Remotion documentation](https://www.remotion.dev/docs/) for frame-based video production.
- [HyperFrames introduction](https://hyperframes.app/docs/1-startup/1-introduction) for HTML-based compositions.
- [MDN: HTML video element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/video) for browser video fundamentals.
- [MDN: Video codecs](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Formats/Video_codecs) for codec and container concepts.

## 13. From storyboard to a useful first edit

A storyboard shows what each important moment might look like. An **animatic** puts those moments in time, usually using still images, simple placeholder shapes, and temporary narration. Its purpose is to reveal timing and storytelling problems while the cost of changing them is still low. If your storyboard has four cards for a 20-second video, placing each card on screen for exactly five seconds produces a rough first sequence. It is a starting point, but it may not match the amount of information in each beat or the pace of a recorded sentence.

For the database example, begin by reading the script aloud at a natural pace and recording it on your phone or computer. You do not need a polished microphone setup for this draft. Listen for pauses, unclear phrases, and sentences that take longer to say than expected. A line that looks short on the page can still be difficult to speak if it contains several unfamiliar terms. Mark approximate points where you say “table,” “index,” and “row.” These marks give the editor useful cues, not rigid rules that require every visual to change on the exact syllable.

Place the table visual on screen before or as you introduce the search. When the narration turns to the index, reveal a simple labeled block or arrow. Keep the final row visible after it is found. If the voiceover finishes before the viewer has understood the result, extend the hold or shorten an earlier phrase. If the viewer sees the answer long before the narration reaches it, consider moving the reveal later. The right choice depends on whether showing the result early builds anticipation or makes the narration feel late.

An animatic can be created in an ordinary editor, a slideshow exported as video, or a simple code-based composition. The medium is less important than its ability to show approximate durations and play alongside audio. Clearly mark placeholder visuals so nobody mistakes a temporary mockup for the final product. Keep the project editable: changing a line of narration should not require rebuilding an elaborate effect.

### A concrete review pass

Watch the draft three times, giving each pass a different purpose:

1. **Story pass:** Can a viewer identify the question, follow the change, and understand the final point? Ignore visual polish. Write down the first moment of confusion.
2. **Timing pass:** Is there enough time to read each label? Does the spoken explanation finish before the visual disappears? Check the transition into and out of the final hold.
3. **Accuracy pass:** Is the scan labeled as a simplified illustration? Does the conclusion allow for the fact that query optimizers may choose different plans? Remove any invented numeric performance claim.

A reviewer may report, “The middle feels slow.” Translate that observation into a testable hypothesis. Perhaps the index graphic is visible for four seconds before anything changes, or the voiceover repeats what the caption already says. Try shortening the redundant part and compare the two versions. Conversely, a reviewer may say, “I missed the index.” That could mean the visual appeared too briefly, the label was too small, or the transition occurred while the viewer was reading another caption. Pause at the relevant time and inspect the actual frame before deciding which fix to make.

### Keep a small decision record

A simple edit note is enough to preserve the reason for a revision:

```text
Version: animatic-02
Change: Extend the final result hold by 0.8 seconds.
Reason: The row label appeared just as the narration ended.
Tradeoff: Shortened the opening question by 0.8 seconds.
Verify: The opening remains readable on a phone; the final scene ends cleanly.
```

This record helps when an AI agent makes changes because it separates the requested outcome from the implementation. If a later edit restores the earlier problem, you can explain why the hold existed. It also prevents an agent from optimizing only for a shorter duration while removing the time required to understand the visual.

Here is a prompt for either Claude Code or Codex after the animatic exists:

```text
Review the existing 20-second animatic and its script. Identify the time range
of each scene, where narration cues occur, and any moments where a label appears
or disappears before the corresponding phrase is understandable. Propose a
small timing table with exact changes and reasons. Preserve the accurate
wording about the optimizer; do not invent benchmark results. If you cannot
inspect the audio or rendered video in this environment, state that limitation
and base observations only on the files you can actually inspect.
```

The final sentence matters. A trustworthy review distinguishes evidence from assumptions. A code inspection can establish that a card is scheduled for a particular interval, but it cannot by itself establish that the recorded narration sounds natural or that a viewer can read the text on a phone. Those questions require listening to and watching the actual output.
