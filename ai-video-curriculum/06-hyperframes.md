# Lesson 6 — Your first HyperFrames video

In the previous lesson, Remotion used React components and the current frame to calculate each image. This lesson introduces a different approach: HyperFrames describes a video as an HTML composition and drives a seekable animation timeline to the moment being rendered. Both approaches can create precise motion graphics. Understanding both helps you choose an implementation for the work, instead of assuming every AI video must use the same tool.

You will build a short vertical product teaser using HTML, CSS and GSAP. You will learn how a composition, clip, track, timeline and renderer relate; how to preview, lint and render; and how to direct Claude Code or Codex without losing control of the resulting source code.

**Prerequisites:** basic HTML tags and attributes, CSS selectors and positioning, and JavaScript variables and function calls. The examples explain the unfamiliar parts. Knowing Remotion is helpful for comparison but not required.

**Version note:** HyperFrames is evolving. The examples follow the [official quickstart](https://hyperframes.app/docs/1-startup/2-quickstart) and [HTML schema](https://hyperframes.app/docs/6-reference/html-schema) available when this curriculum was written. Check them again before installing or using an API in production. Agent skills and hosted tools can have different installation, authorization and billing rules from the local open-source framework.

## 1. What HyperFrames is solving

A web designer can already make a heading move with CSS or a JavaScript animation library. That is convenient because web technology has a rich set of layout, typography, image and graphics tools. But if you simply play the page and record it, the capture depends on real time. A browser can pause, the machine can slow down, and the recording may miss a moment. It is difficult to ask the animation for exactly the image at 3.5 seconds without reproducing the previous 3.5 seconds first.

HyperFrames adds a video-oriented structure around HTML. You describe composition dimensions, arrange timed elements, supply a seekable timeline, and let the renderer control the time. For a requested output frame, the renderer seeks the timeline to the corresponding timestamp, captures the browser view, and continues through the video. It then encodes the frames with the audio as appropriate. This allows offline rendering to take longer than playback while still producing a consistent frame sequence.

Think of a seekable animation as a score: a conductor can point to a bar and determine which notes belong there. The analogy has a limit: browser code must actually support arbitrary seeking. A live timer, unseeded random number or external request can introduce information that is not determined by the requested timestamp. We must design the scene so the requested time and stable inputs are enough to describe the visible result.

HyperFrames is a framework and toolchain; it is not itself a text-to-video model. An AI coding agent can author the HTML and animation, and generated images, video clips or voiceovers can be used as assets, but a composition can be created entirely from editable CSS and text without calling any model.

## 2. The four layers of a composition

Start by separating four concerns:

1. **Composition:** the canvas, its dimensions and the overall timeline. For a portrait video we can choose 1080 by 1920 pixels.
2. **Clips:** items present during a defined interval, such as a title, graphic, image, video or audio file.
3. **Tracks:** placement in the timeline and layering. According to the schema, higher track indices appear in front, and clips on the same track must not overlap.
4. **Animation:** changes to visible properties such as position or opacity while an element is present. GSAP is one supported animation system.

A clip's existence is different from its appearance. A title with `data-start="0"` and `data-duration="3"` is scheduled for that three-second interval. Those attributes alone don't make it fade in. A separate timeline animation must change opacity if a fade is desired. Conversely, animating an element's opacity does not necessarily schedule its presence correctly; the element still needs the appropriate clip metadata.

A useful production analogy is a stage. The composition is the stage and the overall performance. A clip is a performer scheduled to be on stage during a time interval. A track helps organize and layer performers. The animation specifies how a performer moves while present. The analogy stops short of describing exact browser behavior, but it keeps scheduling distinct from styling and motion.

## 3. Set up a local project

As documented in the current [quickstart](https://hyperframes.app/docs/1-startup/2-quickstart), the local workflow requires a supported Node.js installation, npm or another supported package manager, and FFmpeg. The quickstart currently specifies Node.js 22 or later. Run:

```bash
node --version
npm --version
ffmpeg -version
```

If a command is unavailable or the version is too old, use the installation guidance for your operating system and the current HyperFrames requirements. On Windows, also check whether you are running commands in PowerShell, Command Prompt, or WSL: each environment may have a different `PATH` and a different Node or FFmpeg installation. Installing a program in Windows does not automatically imply that WSL can find the same executable, or vice versa.

Review commands before running them. `npx` may download and execute packages. Your machine or organization may have restrictions on network access and package installation. You do not need a paid image or video generation service to create the example in this lesson.

Create a project in a directory you control:

```bash
npx hyperframes init my-video
cd my-video
```

The initializer may prompt for an example or media. The current documentation also describes a noninteractive blank example:

```bash
npx hyperframes init my-video --non-interactive --example blank
```

Choose one initialization approach; don't run both against the same target unless you understand the effects. The exact project contents and available templates may change. A typical scaffold includes an `index.html` root composition, metadata, a `compositions/` folder for reusable sub-compositions and an `assets/` folder for media. The initializer may also install agent guidance. Read the generated files to see what your installed version actually created.

### Preview, lint and render

From inside the created project directory:

```bash
npx hyperframes preview
```

This starts the local preview and, according to the quickstart, opens the composition in Studio. Save changes and inspect the result as the preview reloads. Stop the local server using your terminal's interrupt command when done.

Run the structural checker:

```bash
npx hyperframes lint
```

Lint checks common schema and project issues. It cannot judge whether a title is compelling, whether a claim is true, or whether a person can read a caption at phone size. A clean lint report is a useful technical checkpoint, not an artistic approval.

Then render a file:

```bash
npx hyperframes render --output output.mp4
```

Consult the current [CLI reference](https://hyperframes.app/docs/5-packages/cli) for FPS, quality, output, diagnostics and other flags available in your version. Rendered output should be opened and watched. A terminal reporting success proves that a file was produced; it does not prove the timing, audio, color or composition are right.

## 4. Build the smallest working composition

The following example follows the same structure as the official quickstart. In a newly scaffolded project, preserve any required wrapper or metadata from your installed template; replace or adapt the root composition content in `index.html` as appropriate. The example loads GSAP from a CDN, so the initial render needs access to that URL. For reliable offline or reproducible builds, use a permitted local or version-pinned dependency according to the current project guidance.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>First HyperFrames composition</title>
  <style>
    html, body { margin: 0; }
    #root {
      position: relative;
      overflow: hidden;
      background: #0b1020;
      font-family: Arial, sans-serif;
    }
    #title {
      position: absolute;
      left: 10%;
      right: 10%;
      top: 42%;
      margin: 0;
      color: #f5f7ff;
      font-size: 96px;
      text-align: center;
    }
  </style>
</head>
<body>
  <div id="root" data-composition-id="first-video"
       data-start="0" data-width="1080" data-height="1920">
    <h1 id="title" class="clip" data-start="0"
        data-duration="5" data-track-index="0">
      Make a clear idea move
    </h1>
    <script src="https://cdn.jsdelivr.net/npm/gsap@3/dist/gsap.min.js"></script>
    <script>
      const timeline = gsap.timeline({ paused: true });
      timeline.from('#title', { opacity: 0, y: 80, duration: 1 }, 0);
      window.__timelines = window.__timelines || {};
      window.__timelines['first-video'] = timeline;
    </script>
  </div>
</body>
</html>
```

The `<!doctype html>`, `<head>` and `<body>` are ordinary HTML document structure. The root `<div>` is the composition. The `data-width` and `data-height` attributes define the canvas. The `data-composition-id` is a unique identifier that must match the key used to register its timeline. The root's `data-start="0"` identifies its start position; the schema's current rules determine how root and nested composition timing are handled.

The `<h1>` is both an ordinary heading and a timed element. `id="title"` gives JavaScript and CSS an exact target. `class="clip"` tells HyperFrames to manage the visible HTML element as a timed clip. Its `data-start="0"` and `data-duration="5"` specify a five-second interval, in seconds. `data-track-index="0"` places it on a track. The CSS gives it a position, size and color; it is not a separate video-rendering syntax.

The external script loads GSAP. `gsap.timeline({ paused: true })` creates a timeline that does not run independently as soon as the page loads. The framework can seek this timeline to the timestamp needed for a frame. `timeline.from('#title', ...)` describes an animation from the specified initial values toward the element's normal CSS values. `opacity: 0` begins invisible; `y: 80` starts it 80 pixels lower; `duration: 1` lasts one second; and the final `0` places the animation at timeline time zero.

Finally, `window.__timelines['first-video'] = timeline` registers the timeline under the same identifier as the composition. If the names differ, the framework cannot reliably associate the animation with the intended composition. The `window.__timelines || {}` line follows the quickstart's defensive initialization; the framework normally initializes this object as described in its schema.

When this runs successfully, the title fades and moves into place during the first second and remains visible for its scheduled clip interval. Verify the actual duration and final frame in Studio and the rendered file. If your version's blank template supplies different timing conventions, the current schema and scaffold are authoritative.

## 5. Attributes are data that HyperFrames interprets

HTML lets authors store custom values in attributes beginning with `data-`. On an ordinary web page those values do nothing until JavaScript reads them. HyperFrames reads specific attributes to construct and manage a video timeline.

| Attribute | Example | Meaning in this composition |
| --- | --- | --- |
| `data-composition-id` | `first-video` | Names a composition and its registered timeline. |
| `data-width`, `data-height` | `1080`, `1920` | Set composition dimensions. |
| `data-start` | `2.5` | Places a clip at a time measured in seconds, subject to the current relative-timing rules. |
| `data-duration` | `3` | Makes a timed primitive clip last three seconds. |
| `data-track-index` | `1` | Selects a timeline track and influences visual layering. |
| `id` | `title` | Uniquely identifies an element for targeting or supported timing references. |

These attributes do not all apply equally to every element. For example, the schema treats visible HTML/image clips, video clips, audio clips and nested compositions differently. At the time of writing, visible HTML elements and images use `class="clip"`; the schema says video and audio elements are managed directly and should not receive that class. Follow the current [schema reference](https://hyperframes.app/docs/6-reference/html-schema) for the actual element you are authoring, rather than applying a rule for one clip type to all of them.

The same reference distinguishes a composition's timeline-derived duration from a primitive clip's `data-duration`. Do not assume adding a duration attribute to a composition is equivalent to setting the duration of an image or heading. A correctly registered finite timeline, and the framework's handling of timed elements, determine the final composition timing under its current rules. Inspect the resulting duration rather than guessing.

### Track order is not scene order

A track is a lane in the timeline. A clip on track 2 is generally drawn above a clip on track 1; it is not automatically the third scene. A background can occupy a low track for the full video while titles occupy higher tracks at different times. Two clips occupying the same track at overlapping times violate the documented track rule, even if their screen positions do not intersect. For an intentional visual overlap, assign different tracks and check the resulting layer order.

CSS also has stacking contexts, transforms and `z-index`. Avoid adding unnecessary stacking rules until you understand the framework's track behavior. If an overlay disappears behind a video, inspect both the track placement and any CSS stacking context; moving an element in the DOM is not always the whole explanation.

## 6. Read GSAP animation as a timeline of changes

GSAP is a JavaScript animation library. A **tween** is a change between values across a duration. A **timeline** arranges tweens in time. For example:

```js
const timeline = gsap.timeline({ paused: true });
timeline.from('#headline', { opacity: 0, y: 40, duration: 0.6 }, 0);
timeline.from('#card', { opacity: 0, scale: 0.94, duration: 0.5 }, 0.4);
```

This is a teaching fragment. It assumes GSAP is loaded and elements with IDs `headline` and `card` exist. The headline begins at 0 seconds and reaches its normal values at 0.6 seconds. The card begins at 0.4 seconds and finishes at 0.9 seconds. The tweens overlap for 0.2 seconds; staggering produces a sense that one visual leads the viewer to another. It is not necessarily the correct pacing for every video. A long heading may need a longer hold after the entrance so viewers have time to read.

The difference between `from`, `to`, and `fromTo` is about how the starting and ending values are chosen. With `from`, the specified values describe the start and GSAP returns to the element's baseline values. With `to`, the current values serve as the start and the supplied values as the destination. `fromTo` explicitly states both. Consult the current GSAP and HyperFrames documentation when combining tweens; conflicting animations on the same property can have subtle initialization and ordering behavior.

### Translate motion into a visual story

Suppose a new product helps a developer inspect query plans. One visual idea is a card sliding into view followed by a small highlight around the slow query. The card's movement communicates “here is the context.” The highlight communicates “look here next.” If every label, background and button also moves, the viewer has too many simultaneous signals. Use motion to reveal relationships and preserve a quiet interval for reading.

### Ease and velocity

An ease changes how progress is distributed over an animation. With linear motion, equal time intervals produce equal distance changes. An ease-out usually moves more quickly at the beginning and slows toward the end. That can make an entrance feel more deliberate than an object stopping abruptly. A spring-like ease may overshoot; use it for playful emphasis only if it suits the subject and doesn't interfere with legibility. GSAP's documented easing names and behavior depend on its version, so use a known installed version and verify the result.

### Why pause the timeline?

A real-time page might create an autoplaying animation and leave the browser to tick. A video renderer needs to ask for time 2.3 seconds, then perhaps time 0.5 seconds, without waiting for both intervals in sequence. Creating a paused, seekable timeline and registering it lets the framework control when it is evaluated. Manually calling `play()` on the master timeline can compete with the renderer's clock. Likewise, `setTimeout`, `requestAnimationFrame`, `Date.now()` and unseeded randomness can introduce wall-clock dependence. Use the documented seek protocol and deterministic inputs instead.

## 7. A complete three-beat vertical teaser

The next example is an original, asset-free composition for a fictional app named QueryLens. It uses a background, a title, a mock interface and a closing message. The interface is an illustration, not a claim about a real product. Its purpose is to show how clips and tweens fit together.

Replace the earlier example in the scaffold's composition file, or create a new project for it. This is a complete HTML document for a typical scaffold, but preserve any project-specific conventions that your installed release requires. You will need access to the GSAP CDN shown below or an approved local equivalent. After saving, run lint and inspect the composition in preview; runtime details can change between versions.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>QueryLens teaser</title>
  <style>
    * { box-sizing: border-box; }
    html, body { margin: 0; }
    #root {
      position: relative;
      width: 1080px;
      height: 1920px;
      overflow: hidden;
      background: #0b1020;
      color: #f7fbff;
      font-family: Arial, sans-serif;
    }
    .scene {
      position: absolute;
      inset: 0;
      padding: 120px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
    }
    .headline { margin: 0; font-size: 100px; line-height: 1.08; }
    .subhead { margin-top: 40px; color: #b7c7df; font-size: 48px; line-height: 1.3; }
    .card {
      width: 100%;
      padding: 55px;
      border: 3px solid #3e5274;
      border-radius: 36px;
      background: #1a2941;
      text-align: left;
      box-shadow: 0 30px 80px #0007;
    }
    .bar { height: 25px; margin: 26px 0; border-radius: 20px; background: #647899; }
    .bar.accent { width: 62%; background: #65e6ce; }
    .small { color: #b7c7df; font-size: 40px; }
  </style>
</head>
<body>
  <div id="root" data-composition-id="querylens-teaser"
       data-start="0" data-width="1080" data-height="1920">

    <section id="intro" class="clip scene" data-start="0"
             data-duration="3" data-track-index="0">
      <h1 class="headline">Understand your queries</h1>
      <p class="subhead">A fictional product teaser</p>
    </section>

    <section id="demo" class="clip scene" data-start="3"
             data-duration="4" data-track-index="0">
      <div class="card">
        <div class="small">QUERY OVERVIEW</div>
        <div class="bar"></div>
        <div class="bar accent"></div>
        <div class="bar" style="width: 80%"></div>
      </div>
      <p class="subhead">See the next thing to investigate</p>
    </section>

    <section id="outro" class="clip scene" data-start="7"
             data-duration="3" data-track-index="0">
      <h2 class="headline">Meet QueryLens</h2>
      <p class="subhead">A concept, made with code</p>
    </section>

    <script src="https://cdn.jsdelivr.net/npm/gsap@3/dist/gsap.min.js"></script>
    <script>
      const timeline = gsap.timeline({ paused: true });
      timeline.from('#intro .headline', { opacity: 0, y: 70, duration: 0.8 }, 0);
      timeline.from('#intro .subhead', { opacity: 0, y: 35, duration: 0.6 }, 0.25);
      timeline.from('#demo .card', { opacity: 0, y: 90, duration: 0.8 }, 3);
      timeline.from('#demo .subhead', { opacity: 0, y: 35, duration: 0.6 }, 3.35);
      timeline.from('#outro .headline', { opacity: 0, y: 60, duration: 0.8 }, 7);
      timeline.from('#outro .subhead', { opacity: 0, y: 30, duration: 0.6 }, 7.3);
      window.__timelines = window.__timelines || {};
      window.__timelines['querylens-teaser'] = timeline;
    </script>
  </div>
</body>
</html>
```

The three sections occupy the same track because their time ranges do not overlap: intro starts at 0 and lasts 3 seconds; demo starts at 3 and lasts 4 seconds; outro starts at 7 and lasts 3 seconds. Their combined intended interval is ten seconds. Each section occupies the same full-frame rectangle, so scheduling one at a time produces cuts between scenes. The GSAP animations target children within the appropriate section and start at the section's corresponding composition time.

The CSS `.scene` class is ordinary styling, while `clip` is the framework's timing marker. Each section has both because it needs both kinds of behavior. `.card` creates a rounded panel and `.bar` creates simple shapes. The accent bar is not a chart with measured data; it is a visual placeholder. In a real video, label data clearly and avoid implying accuracy through a decorative bar.

`timeline.from('#demo .card', ..., 3)` starts the card's tween at three seconds of the composition's timeline. `#demo .card` means the element with class `card` inside the element with ID `demo`. Because the demo clip also starts at three seconds, its entrance is visible when the scene begins. If you move the clip to four seconds without moving the tween, its animation may already have advanced or finished by the time the clip appears. Keep clip timing and tween positions aligned; there is no automatic guarantee that a hard-coded tween time will follow a changed clip start.

Review seconds 0, 0.4, 2.9, 3.0, 3.4, 6.9, 7.0 and near 10. These cover entrances and boundaries. If the final duration reported by your installed version is not ten seconds, inspect the current timeline and clip-duration rules and ensure the intended length is explicit using the supported method. Do not silently accept a truncated video.

### Turn the demo into a real product video

Replace the decorative bars with a permitted screenshot or screen capture of your own product. Crop the interface so the viewer understands the relevant action. Use a readable label instead of tiny, nonfunctional controls. Establish the real claim you want to demonstrate, such as “inspect a query plan in one place,” only if the actual product supports it. Add a short narration after timing the visuals. Make sure any customer records, private endpoints or credentials have been removed before uploading or publishing.

You can keep the same timing architecture: intro at 0–3 seconds, product evidence at 3–7, takeaway at 7–10. Adjust those numbers to match actual spoken words and the complexity of the UI. A fixed ten-second schedule is an educational constraint, not a rule for a good explainer.

## 8. Working with images, footage and sound

HTML becomes especially useful when it can combine live text with assets. The following snippets illustrate schema concepts; they require real files at the specified paths and the surrounding composition and registered timeline. They are not standalone complete documents.

### A timed image

```html
<img id="product-image" class="clip"
     data-start="2" data-duration="4" data-track-index="1"
     src="./assets/product.png" alt="Product interface" />
```

Put an authorized `product.png` inside `assets/`. The image is scheduled from second 2 for four seconds. `class="clip"` identifies it as a timed visible element; an image has no intrinsic video duration, so the duration must be stated. CSS controls its position, dimensions and crop. A missing file will not magically be generated by this markup. Use alt text that accurately describes the image in contexts where it is exposed; the video itself still needs accessible captions and appropriate descriptions.

### A timed video clip

```html
<video id="product-demo" data-start="2" data-duration="4"
       data-track-index="1" data-media-start="1"
       src="./assets/demo.mp4"></video>
```

Here `data-media-start="1"` trims the source so the composition starts one second into `demo.mp4`; `data-start="2"` is the placement on the composition timeline. These are different clocks. The current schema says video elements are managed directly rather than receiving `class="clip"`. If the source ends before the requested duration, current documented behavior may freeze the final frame; always inspect the output and check your version's media handling. Audio from the source must be planned deliberately, especially if narration is added separately.

The schema warns against animating a video element's width, height, top or left directly with GSAP because browser video rendering can stop updating. Animate a suitable wrapper instead, following the current guide. Treat this as a specific media behavior rather than a general ban on all animated HTML properties.

### A narration track

```html
<audio id="narration" data-start="0" data-duration="10"
       data-track-index="3" data-volume="1"
       src="./assets/narration.mp3"></audio>
```

Audio is invisible, so it does not need the visible clip class. Place an actual authorized file at the path, verify its duration, and listen to the exported mix. `data-volume` is a relative control, not an assertion that the audio meets a particular loudness standard. If narration is quiet and music is loud, lower the music and adjust the source or mix appropriately. Overlapping sound from a source video and a separate narration or music file can become confusing or clipped; listen to the final file on more than one device.

The framework owns media playback and seeking. Avoid manually calling `video.play()`, `video.pause()` or assigning `audio.currentTime` as a way to synchronize the composition. Such calls compete with the rendering clock. Use the timing attributes and the current media documentation instead.

## 9. Captions and readability

A caption system connects spoken words to timing information. Transcription answers “what words were spoken?” Alignment estimates “when was each word spoken?” Neither automatically guarantees that a caption is correct or comfortable to read. Review the transcript, proper names, technical terms, punctuation and actual timing against the recording.

For a short explainer, group words into readable phrases instead of displaying an entire paragraph. Put captions where they do not cover the important interface element and where platform controls are unlikely to obscure them. Platforms change their overlay layouts, so inspect a test export on the intended surface rather than memorizing one universal safe-area measurement. Keep enough contrast against both bright and dark backgrounds, using a subtle backing where necessary.

HyperFrames has caption-related composition conventions and tooling; these can change. Consult the [schema](https://hyperframes.app/docs/6-reference/html-schema) and current CLI documentation before asking an agent to generate captions. If the agent uses an external transcription service, understand where the audio goes and whether that upload is permitted. An automated caption draft is a starting point; you remain responsible for correction.

## 10. Determinism: why seeking must produce the same scene

Imagine that your video is rendered on four workers, each drawing a different set of frames. Worker one may render second 0, while worker two starts at second 5. If the appearance at second 5 depends on a random number generated during second 1, the second worker cannot infer the correct result without reproducing hidden history. Similarly, if a counter increments once per animation tick, a slower machine may perform a different number of increments than a faster one.

A deterministic animation has a stable answer for a given time and fixed inputs. A GSAP timeline that can be sought to a time provides a controlled mechanism for many common transitions. This does not make every external resource deterministic: a remote image may change, a font may fail to load, generated assets may be replaced, and a script can still depend on wall time. Pin dependencies where suitable, keep approved source assets locally, and record versions. If procedural visual variation is needed, use a documented seeded approach or precompute the values and keep them stable.

A diagnostic pattern is to seek the same frame twice after visiting different points in the video. If the two results differ, investigate mutable state, timers, random numbers, media loading and external resources. Also render a short section more than once and compare relevant frames visually. Minor encoding differences are possible; comparing decoded frames or lossless stills can be more useful than comparing compressed MP4 bytes.

## 11. A practical workflow for fixing problems

**The preview is blank.** Start with the terminal. Is the server running from the project directory? Is there a parsing error in the HTML or JavaScript? Does the root have a composition ID, width and height? Is GSAP actually loaded? A blocked CDN may cause `gsap is not defined`. The quickest fix is to identify the first failure, not to rewrite all animation code.

**The element is present but does not animate.** Verify that the selector matches an existing element, the timeline is paused and registered under the exact composition ID, and the tween occurs while the clip is scheduled. Inspect whether the property is also set by another animation. If the animation happened before the clip appeared, change the schedule or the tween time.

**A visual appears for the wrong duration.** Inspect `data-start`, `data-duration`, the track index, and whether you applied attributes to a primitive clip or a composition. Check whether the total composition duration is inferred from its timeline or other current schema rules. Avoid fixing a duration mismatch by adding arbitrary extra elements without understanding the contract.

**Two elements unexpectedly cover one another.** Check the timeline overlap and track order. If both must coexist, give them compatible tracks. Then inspect CSS stacking contexts and opacity. A fully opaque, full-frame section can hide all content behind it even if both clips are technically active.

**The video displays a frozen or blank source clip.** Check the path, codec support, source duration, trim offset, media loading and errors. Verify whether the browser can decode the source and whether the asset was authorized and copied to the project. If you animate a video element's geometry directly, move that animation to a wrapper as recommended by the schema.

**The final render differs from preview.** Check for network dependencies, font loading, nondeterministic timers, browser differences and unsupported CSS. Ensure the same source files and versions were used. Inspect the rendered MP4 itself, not just the file's existence.

**The result is technically correct but dull.** First inspect the static composition: hierarchy, contrast, spacing and the clarity of the message. Then review the pacing and the reason for each animation. More particles and transitions do not automatically improve comprehension. A two-second hold with legible copy can be more effective than continuous movement.

## 12. Use Claude Code as a collaborator

The [HyperFrames quickstart](https://hyperframes.app/docs/1-startup/2-quickstart) documents installing its agent skills with:

```bash
npx skills add heygen-com/hyperframes
```

It describes `/hyperframes`, `/hyperframes-cli`, and `/gsap` as Claude Code skills after installation. Actual availability depends on your agent environment and installed version; inspect the current instructions. Read third-party skills and proposed commands before allowing them to modify files or use services.

Start Claude Code in the intended project and provide a specific brief:

```text
Using /hyperframes, create a 10-second 9:16 teaser for a fictional
query-inspection app named QueryLens. Use a dark background, one mint accent,
large readable type, and a simple editable HTML mockup rather than images.
Structure the scenes as a question, a product concept, and a closing message.
Do not claim measured speed improvements. Do not use paid APIs or upload files.

First inspect the scaffold and explain the timing plan. Then implement a
paused registered GSAP timeline using the current HyperFrames conventions.
Run lint, render an MP4, and inspect stills at the opening, both scene
boundaries, and the end. Explain each data attribute and how I can change
the scene lengths. Report anything you could not verify.
```

Notice the structure. The objective describes the desired video. The visual constraints make design review possible. The source constraint keeps the interface editable. The factual constraint stops invented performance numbers from appearing. The verification requirement distinguishes “wrote files” from “checked the result.” You can ask for a storyboard before implementation if the creative direction needs agreement.

After the first render, iterate with an observable instruction:

```text
At 3 seconds the product card appears too low and the caption overlaps it.
Move the card up, keep the caption below with at least 60 pixels of separation,
and slow the entrance to 0.8 seconds. Keep the existing scene duration. Render
again and inspect the beginning, midpoint and end of that animation. Explain
which CSS and timeline values changed.
```

Pixel measurements should be interpreted at the composition's actual resolution; a value that works on a 1080-pixel-wide canvas may need scaling for another size. The agent should show or report evidence from the actual render, not merely assert that the overlap is resolved.

## 13. Use Codex as a collaborator

Codex can use installed project guidance and read or edit the local repository when your environment permits it. Skill discovery and invocation syntax vary among Codex interfaces, so follow the current interface rather than assuming that a Claude slash command works unchanged. Start it in the same project folder and try:

```text
Inspect this HyperFrames project and use any installed HyperFrames guidance.
Create a 10-second portrait teaser for an imaginary database tool. Keep all
text editable; use only local placeholder graphics and no paid services.

Explain the distinction between data-start, data-duration, track index and
GSAP tween time. Register a paused timeline whose key matches the composition
ID. Run the available lint command, preview or render, inspect frames around
each scene boundary, and report changed files, commands and remaining issues.
Before changing project dependencies, explain why they are needed.
```

Ask the agent to teach the code after implementing it: “Walk me through the root element, one scheduled scene, and one tween. Explain what happens at 3.0 seconds and how the answer changes if the scene moves to 4.0 seconds.” This forces the explanation to connect the abstract timeline to your actual source file.

### Reviewing an agent's work

Read the file and locate the composition ID, dimensions, clip schedule, track assignments and timeline registration. Check the tween selectors against actual element IDs or classes. Compare claimed durations to the clip intervals. Review any network URLs and generated media before publishing. Run lint, but also examine representative frames and watch the actual MP4. If the agent could not render because a dependency or browser was unavailable, treat the file as unverified rather than accepting a fictional success report.

## 14. Choosing HyperFrames or Remotion for a project

Both frameworks render video from browser-based visual content, but the authoring model is different. Remotion commonly uses React and frame-derived values; HyperFrames commonly uses HTML, CSS and a seekable timeline. An existing React component library or strongly typed data-driven template may make Remotion attractive. A team comfortable with HTML and GSAP or a project based on existing web animation may prefer HyperFrames. The choice also depends on editor needs, skills, version compatibility and license terms.

You can render a Remotion clip and use the result as a media asset in HyperFrames, or translate an appropriate composition into native HTML and GSAP. A rendered clip has a simple boundary but its interior text and graphics are baked into pixels. A translation can retain editability but requires checking whether every behavior and asset was reproduced accurately. Hosted integrations and conversions have documented limitations; see the current [migration guidance](https://github.com/heygen-com/hyperframes/blob/main/skills/remotion-to-hyperframes/SKILL.md). You do not need both tools for every video.

Consider a 30-second LinkedIn product demonstration. If the focus is a real screen recording with three animated captions, HyperFrames plus a simple timeline may be enough. If you need hundreds of parameterized versions generated from structured data and have React components already, Remotion may be a better fit. If you need a cinematic, fictional background, generate or license that footage separately and compose it with accurate UI and text. These are starting judgments, not universal rules; prototype and inspect the result.

## 15. An end-to-end production checklist

Before building, define the viewer, message, duration, aspect ratio and delivery format. Gather an accurate script and write a brief visual plan. Choose assets you have permission to use, record their origin, and avoid sending private material to services without approval. Decide which elements must remain editable and which can be rendered as footage.

During construction, lay out a static frame first. Schedule each element as a clip, assign tracks, and make sure no prohibited overlaps exist. Register a finite, paused timeline with the correct composition ID. Add movement that helps the viewer understand the story. Keep motion synchronized to the clip's scheduled visibility and avoid depending on wall-clock timers.

Before delivery, run lint and fix structural errors. Review the preview, then render and watch the actual MP4. Inspect scene starts and ends, readable text, layer order, audio synchronization and the final frame. Check the export on a small screen and with sound muted as well as enabled. Verify the dimensions and duration and keep the project source, dependency versions and permitted assets so you can reproduce or revise the result.

Once you can build and inspect this example, the next useful step is not another animation trick. Choose a real story, show the viewer something accurate, and use the framework as a means of controlling timing and clarity. The following lesson explores the boundaries between Remotion and HyperFrames in more depth, including rendered-media handoffs and the tradeoff between portability and editability.

### Further reading

- [HyperFrames quickstart](https://hyperframes.app/docs/1-startup/2-quickstart)
- [HTML schema](https://hyperframes.app/docs/6-reference/html-schema) and [CLI reference](https://hyperframes.app/docs/5-packages/cli)
- [Rendering guide](https://hyperframes.app/docs/3-guides/4-rendering) and [common mistakes](https://hyperframes.app/docs/3-guides/6-common-mistakes)
- [Official project repository](https://github.com/heygen-com/hyperframes) and [Remotion migration guidance](https://github.com/heygen-com/hyperframes/blob/main/skills/remotion-to-hyperframes/SKILL.md)
