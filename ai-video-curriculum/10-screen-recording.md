# Lesson 10 — Screen recordings and real product demonstrations

A screen recording lets a viewer see what your software actually does. That makes it one of the most valuable assets in a developer's video toolkit. It also creates an editorial challenge: a real interface contains far more information than a viewer can understand in a few seconds. The cursor moves, menus open, text changes, and the user has to understand why each action matters.

In this lesson, you will learn to plan, record and edit a truthful product demonstration. We will use a fictional application called QueryLens as a running example: a developer pastes a SQL query into a panel, selects an “Analyze” button, and receives an illustrative explanation. Your own application may have different features; the techniques apply as long as the video accurately represents what your software really does.

The goal is a 30-second vertical walkthrough suitable for a social feed: a clear opening, a sequence of meaningful actions, an understandable outcome, and a call to action appropriate to the product's current state. We will also build a small Remotion composition that combines a real local recording with editable callouts. No model generation service is necessary to follow the lesson.

## 1. The problem: a recording is not yet a demonstration

Imagine recording yourself using an application for thirty seconds. You open the browser, resize a window, search for the right test account, click a control, wait for loading, correct a typo, scroll, then explain the result. Every action is real, but the viewer has to discover which ones matter.

A product demonstration is an edited explanation of a workflow. It has a job: help the audience connect an action with its result and understand why the result is useful. This involves three related but distinct tasks:

1. **Capture:** record what the application actually shows.
2. **Select:** choose the portions that communicate the workflow.
3. **Explain:** direct attention to the action and its meaning through framing, narration, timing and graphics.

Editing is not automatically deceptive. Removing a long pause or zooming toward a control can make a true action easier to see. However, editing can become misleading if it hides a material limitation, presents staged data as a real result, changes the apparent order of actions, or implies an automation happened instantly when it did not. The lesson will show how to improve clarity while preserving context.

## 2. Start with the viewer's question

For a developer product video, the viewer may want to know:

- What problem does this address?
- What do I actually do in the product?
- What comes back?
- Why would the result help me?
- Is this a working feature, prototype, or conceptual example?

A screen full of controls cannot answer all of those at once. Choose one coherent task and use the recording to demonstrate it. A concise promise might be:

> “See how QueryLens turns an example SQL query into an explanation you can inspect.”

That wording describes a workflow. It does not claim that every query is correctly optimized or that results will be faster. In your own video, replace the fictional product and behavior with what your software demonstrably supports.

### Demo, explainer and advertisement

A **demo** shows behavior. An **explainer** teaches a concept, possibly without a product. An **advertisement** persuades the viewer to take an action. One video can contain elements of all three, but a viewer should not confuse a conceptual animation with actual product footage.

For example, an animated database icon may help explain what an index does, while a screen recording shows the application's actual analysis panel. Label a mockup as a mockup when the distinction matters. Your audience's trust is a long-term asset, especially when you build products in public.

## 3. Plan a 30-second story

A simple structure is hook, context, action, result and close. These are functions in a story, not mandatory exact timestamps. Use the actual narration and footage to set the final timing.

| Approximate time | Viewer needs to understand | Possible visual |
| --- | --- | --- |
| 0–3 s | What is the useful idea? | Short headline over a clean product frame |
| 3–7 s | What is the starting point? | Show the query input and a brief label |
| 7–15 s | What does the user do? | Paste an example query and select Analyze |
| 15–24 s | What happens? | Show the actual result and highlight one meaningful part |
| 24–30 s | What should the viewer remember or do next? | Summarize the benefit and show an accurate CTA |

The structure provides a starting point. If the result needs more time to read, shorten the opening or use a longer video. A fast edit that prevents the viewer from seeing the result defeats the purpose of a demo.

### Write the voiceover alongside the visuals

A sample script:

> “Wondering what your SQL query is doing? In this example, I paste a query into QueryLens and select Analyze. The app displays an explanation next to the query, so I can inspect the result without leaving the workflow. This is a demo using sample data.”

Notice what the script does and does not say. It names the action and the visible output. It does not invent benchmark numbers or imply that the fictional product has features you have not implemented. In a real project, verify each sentence against the recorded behavior.

Read the script aloud while watching a rough cut. A narration sentence that requires six seconds cannot be made understandable merely by squeezing it into three seconds. You can shorten the sentence, extend the shot, or split the thought into two shots.

## 4. Convert the story into a shot list

A *shot list* describes what to capture or assemble. It differs from the script: the script tells you what the viewer hears, while the shot list identifies the visual evidence needed.

```text
Shot 01 — Hook
Duration target: 0:00–0:03
Visual: Product frame with editable headline.
Purpose: Introduce the problem.
Source: Static layout around a real approved app image.

Shot 02 — Input
Duration target: 0:03–0:07
Visual: Real input panel with a short example SQL query.
Purpose: Establish the starting state.
Source: Screen recording, first take.

Shot 03 — Action
Duration target: 0:07–0:15
Visual: Cursor selects Analyze; loading is visible if material.
Purpose: Show the operation the user initiates.
Source: Screen recording, second take if needed.

Shot 04 — Result
Duration target: 0:15–0:24
Visual: Actual explanation panel; one section highlighted.
Purpose: Show the output rather than merely describe it.
Source: Screen recording, result hold.

Shot 05 — Close
Duration target: 0:24–0:30
Visual: Calm product frame and accurate call to action.
Purpose: Give the viewer the next step.
Source: Editable graphics and product recording.
```

Record more than the minimum at the beginning and end of each action. Editors often call this extra material *handles*. If you intend a three-second excerpt, recording a few quiet seconds around it makes transitions and timing adjustments easier.

## 5. Prepare a demonstration environment

A prepared environment makes the capture easier to understand and reduces accidental exposure of private information. It also lets you repeat the same action across multiple takes.

### 5.1 Use a separate, clearly identified demo dataset

Create sample users, sample projects, and sample queries that are safe to show. Prefer invented names and domains reserved for examples, such as `example.com`, rather than using real customer data. Use a dedicated test or demo account where possible.

Think beyond visible table contents. Sensitive material can also appear in:

- Browser tabs, bookmarks, address bars, account avatars and autofill.
- Notifications, chat popups and calendar reminders.
- File paths, project names, commit messages and terminal output.
- URLs containing tokens, query parameters or internal hostnames.
- Browser developer tools, console logs or network panels.
- Previously used search queries and generated model prompts.

A crop or blur may reduce visibility in the final video, but it should not be your first privacy control. Start with an environment that does not contain secrets. Blurs can fail, move out of alignment, or remain recoverable in source footage. Keep raw recordings protected and delete unnecessary takes according to your own retention requirements.

### 5.2 Prepare a repeatable application state

Write down the initial state: which page is open, which data is loaded, whether a panel is expanded, and what result should appear. Then establish a reset procedure. For example:

```text
Starting state:
- Demo account signed in.
- Example project “Sample Shop” selected.
- Query panel empty.
- No notifications visible.

Action:
- Paste the prepared query.
- Select Analyze once.
- Wait until the result has fully loaded.
- Move the pointer away and hold for five seconds.

Reset:
- Clear the query and result using the application's normal controls.
- Return to the starting page.
```

This record is not automation code. It is a repeatable capture plan. If your application cannot reset easily, a test database snapshot or seeded demo environment may help; ensure any reset action is appropriate for the environment before running it.

### 5.3 Make the demo truthful

Synthetic data is fine when it is presented as sample data. A precomputed response can be appropriate for a prototype if it is labeled as simulated or staged where that distinction affects understanding. Avoid using edited footage to imply a live integration, speed, outcome, or capability that is not actually present.

For instance, if analysis normally takes twenty seconds and you cut out fifteen seconds, you can use a visible transition or mention that the wait was shortened. You do not have to show every second of loading, but do not leave an impression that the operation is instantaneous if speed is a material selling point.

## 6. Choose recording dimensions deliberately

A video frame is a rectangle. Its **resolution** is the number of pixels across and down; its **aspect ratio** is the shape of that rectangle. A 1920 × 1080 screen recording is 16:9 landscape. A 1080 × 1920 vertical output is 9:16. Putting one inside the other requires a decision: fit the entire landscape screen into a narrow vertical canvas, or crop and reframe a portion of it.

### Fit versus fill

- **Fit:** scale the whole source until it fits inside the destination. Nothing is cropped, but the interface may become very small and there may be empty space.
- **Fill:** scale until the destination is covered. The video fills the frame, but some edges are cropped.
- **Reframe:** choose and animate a crop around the relevant UI area, potentially changing it between actions.

There is no automatic best answer. A full-screen overview can establish context; a tighter crop can then show a specific control. Keep enough context for the viewer to understand where they are.

### Example of crop math

Suppose a 1920 × 1080 source is placed in a 1080 × 1920 vertical frame with a `cover` operation. The scale factor needed to cover the destination is:

```text
max(destination width / source width, destination height / source height)
= max(1080 / 1920, 1920 / 1080)
≈ 1.778
```

The scaled source is roughly 3413 × 1920. Only 1080 pixels of its width fit in the vertical destination. The result is a narrow slice of the original landscape recording. This calculation explains why a simple `object-fit: cover` can accidentally hide most of a desktop interface.

A more useful design may place the full landscape screen in a framed area of the vertical canvas, then cut to a tighter view for key controls. Alternatively, record the app in a narrower browser window or responsive layout if that is a genuine supported view. Do not change the interface in a way that suggests a real layout or feature that does not exist.

### Capture resolution and display scaling

Higher resolution can give you more room to crop, but it also creates larger files and can make UI elements small if the application isn't scaled appropriately. Increase the application's zoom or use an appropriate window size so important text is legible. Check that browser zoom does not alter the workflow being demonstrated. A good starting point is to capture a clean, readable window and test the intended crop before recording the whole session.

## 7. Prepare the visual workspace

Before recording:

1. Turn off or silence notifications using your operating system's supported controls.
2. Close unrelated tabs, windows and overlays; check the taskbar and menu bar.
3. Set the browser and application to a clean state with readable text.
4. Use a neutral pointer size and contrasting cursor if that improves visibility.
5. Decide whether to capture a single window, a region or the full display.
6. Confirm whether system audio or microphone audio is being recorded.
7. Make a short test clip and listen to it.

Window capture limits the recorded area but may exclude menus or dialogs that appear outside the captured window, depending on the tool and platform. Full-screen capture catches those dialogs but may also capture unrelated information. Test your actual setup; tool behavior is not universal.

If narration will be recorded separately, recording the screen silently often makes retakes easier. You can then pace the voice around the final edit. If the demonstration depends on live sound or a spoken interaction, capture the necessary source audio and check the recording permissions and levels.

## 8. Record for the edit, not for real-time speed

A good take usually feels slower to the person recording than a normal interaction. The viewer needs time to locate the control and connect the action with the outcome.

A useful rhythm is **arrive → pause → act → hold**:

1. Move the cursor toward the target.
2. Pause briefly so the viewer can see where it landed.
3. Click or type the action.
4. Hold on the result after it appears.

The pause does not need to be long. Its purpose is to create a clear edit point and give attention time to settle. If you immediately move the cursor away, the viewer may miss what you selected. If you move continuously while speaking, the viewer may follow the cursor rather than the important result.

### Cursor behavior

Move with intention. Large, circular movements can be distracting. Avoid repeatedly circling a control unless the gesture itself is meaningful. After an action, move the pointer to an unobtrusive area or leave it still if it would otherwise cover the result.

A post-production cursor effect can add a ring or highlight, but it should align with the real action. If you animate a fake cursor, label the reconstruction when appropriate and do not misrepresent the exact interaction. Be especially careful with a cursor that appears to click a button that was not actually clicked in the source.

### Typing and paste operations

Recording every keystroke can feel slow; instantly pasting a large block can be hard to follow. Possible compromises include using a short query, showing the completed input for a moment, or cutting from an empty field to the completed example with a clear transition. If the precise input matters, keep it readable long enough for the audience to understand it. Captions and narration should explain the action without requiring the viewer to read every character in a brief shot.

### Capture multiple takes

Record the entire workflow once for context, then capture individual actions again if needed. Keep a short note of the best take and any problems. For example:

```text
Take 01: complete workflow; pointer covers result at the end.
Take 02: clean input and button click; notification visible in upper right.
Take 03: clean result hold; use this section.
```

Discard a take with private information from public deliverables; do not assume that a tight crop makes raw footage safe to share.

## 9. Understand frame rate, variable frame rate and synchronization

**Frame rate** is the number of displayed frames per second. A 30 fps project has a new frame approximately every 1/30 second. A 60 fps capture can preserve smoother pointer movement, but it generates more data and does not automatically improve a 30 fps export. Choose settings that your computer can record reliably and that your editor can handle.

Some screen recorders produce **variable frame rate** footage: the time between captured frames can change. This can save resources when the screen is static, but some editing pipelines handle variable timing less predictably than constant-frame-rate media. Symptoms can include audio drift or mismatched cuts. Before converting, inspect the original in your chosen editor; modern tools vary in their support.

FFmpeg's `ffprobe` can inspect a file. Given an installed FFmpeg package and a file named `screen-recording.mp4`, run:

```bash
ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,r_frame_rate,avg_frame_rate,duration \
  -of default=noprint_wrappers=1 screen-recording.mp4
```

This displays the reported dimensions, rates and duration. Differences between rate fields can be a clue, but they are not by themselves a complete proof of variable-frame-rate behavior. Use a media inspector or frame-timestamp analysis when you need certainty.

If your workflow has a confirmed compatibility problem, you can make a constant-rate editing copy. This example intentionally produces 30 fps and re-encodes video:

```bash
ffmpeg -i screen-recording.mp4 \
  -vf fps=30 -c:v libx264 -crf 18 -preset medium \
  -c:a aac -b:a 192k screen-recording-cfr.mp4
```

`-vf fps=30` resamples the video timeline to 30 frames per second, potentially duplicating or dropping frames. `libx264` re-encodes the video; `-crf 18` is a quality-oriented setting, not lossless preservation. The audio is encoded as AAC. Keep your original, inspect the new file, and adjust settings for your environment. If your recording has no audio, FFmpeg will generally create an output without an audio stream. Always use an output filename different from the input.

## 10. Edit the action around cause and effect

The most important unit of a product demo is often a causal pair: **the user does something → the application responds**. If you cut too aggressively between them, the viewer may not understand what produced the result. If you hold too long on an unchanging screen, attention can drift.

A practical edit for an Analyze action:

1. Show the button and relevant input together.
2. Let the viewer see the pointer arrive.
3. Show the click.
4. Include enough loading context to preserve the nature of the operation.
5. Reveal the actual result.
6. Hold the result while narration explains it.

If a long wait is not central to the story, shorten it transparently. A cut, dissolve, or small “loading shortened” note can communicate the passage of time. The right choice depends on whether timing is a material claim. If the video advertises speed, use measured timings and provide the conditions instead of editing the wait away.

### Establish, then emphasize

A close crop is easier to understand after an overview. Start by showing where a panel exists in the app, then move closer to the key control or result. This mirrors a helpful human explanation: “Here is the page; now look at this part.”

Avoid using a zoom as a substitute for legible source material. If the interface text is too small or blurry at capture time, enlarging it later also enlarges the blur. Record at an appropriate size and test your final crop early.

## 11. Crop and reframe without hiding meaning

Suppose the Analyze button is at the right of a wide interface. A vertical crop centered on the button may remove the query input. The viewer then sees a click but not what was analyzed. Solve this by choosing one of three patterns:

- Show an overview first, then cut to the button.
- Use a wider framed screen with a callout pointing to the button.
- Show the input and result in separate crops with a clear transition and narration.

The visual can change, but the relationship must remain understandable. Check that labels, units, warnings and relevant state indicators are not cut away. A crop should guide attention, not remove information necessary to judge the result.

### Animated reframing

You can animate a crop from input to result, similar to a camera move. Begin and end on stable compositions. Move slowly enough that the viewer can follow, and avoid moving while the viewer is trying to read a dense paragraph. If there is an actual change in the interface, timing the reframe to follow that change helps the audience see cause and effect.

A cut is sometimes clearer than a moving zoom. The viewer does not need every pixel of the journey between two UI regions. Use motion when it helps preserve spatial context; use a cut when the transition itself would be distracting.

## 12. Highlight a control without distorting the screen

A highlight is an overlay that directs attention. Common choices include:

- A thin outline around the relevant control.
- A translucent spotlight or dimmed surrounding area.
- A short arrow or connector with a label.
- A cursor halo at the moment of selection.
- A freeze or brief hold on an important result.

Each has a cost. A thick opaque box can cover neighboring content; a pulsing effect can distract from the result; an arrow can point at the wrong item after a layout shift. Start with the least intrusive treatment that makes the action clear.

### Why timing matters

Suppose a highlight appears two seconds before a button is clicked. The viewer may think the button was already activated. If it appears after the screen has changed, the viewer may not know which action caused the result. Synchronize it to the actual source footage and inspect the frame before, during and after the action.

### Coordinate systems

An overlay needs a position. If the source video is scaled or cropped, coordinates measured in source pixels must be transformed into composition pixels. A simple scale-and-offset mapping is:

```text
output_x = source_x × scale + offset_x
output_y = source_y × scale + offset_y
```

Here `scale` is the factor applied to the source, and the offsets are the position of the scaled source inside the output frame. If the video is cropped, those offsets may be negative. This model assumes uniform scaling without rotation or perspective. Once you add those transforms, use the full transform or anchor the overlay inside the same transformed container as the video.

A practical lesson follows: put the recording and the overlay in a shared container when they should move together. If you animate the video separately, the overlay may drift away from its target.

## 13. Add motion graphics without burying the product

Motion graphics can explain what the recording alone cannot. A headline may identify the problem. A callout can name the action. A small diagram can explain a backend concept. A progress marker can orient the viewer. The recording remains the evidence of product behavior.

A good visual hierarchy might be:

1. **Primary:** the product action or result.
2. **Secondary:** a short explanatory callout.
3. **Supporting:** background texture or brand decoration.
4. **Accessibility layer:** accurate captions positioned where they do not hide essential UI.

If the background is the most visually active element, the viewer's eye may go to the wrong place. Reduce its contrast, movement or saturation. If the callout covers the control, move the callout and use a connecting line instead.

### Combining real footage with generated surroundings

A generated texture or abstract scene can sit behind a real device frame. For example, a recorded browser window may appear over a subdued generated gradient or server-room image. The viewer sees the authentic application in the foreground; the surrounding imagery sets the mood.

Keep the distinction clear. Do not generate a fictional interface and imply it is actual footage. When using a mockup to illustrate an unfinished feature, label the concept or prototype appropriately. Ensure generated backdrops do not contain misleading logos, product claims or accidental text.

## 14. Runnable Remotion example: recorded interface plus callout

This example assumes a working Remotion project created in Lesson 5. It composes a real local screen recording into a vertical video and places editable text above and below it. It does **not** alter the recorded interface or simulate a click.

Place a short, sanitized recording at `public/demo.mp4`. Use a recording you made or have permission to use. The example uses a 30 fps, 15-second composition; ensure your source contains enough footage or adjust the duration in the registered composition.

Create `src/ProductDemo.tsx`:

```tsx
import React from 'react';
import {
  AbsoluteFill,
  interpolate,
  OffthreadVideo,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';

export const ProductDemo: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  // Bring the callout in during the second second of the composition.
  const calloutOpacity = interpolate(frame, [fps, fps * 1.5], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: '#07111F',
        color: '#F3F7FA',
        fontFamily: 'Arial, sans-serif',
        padding: 64,
        display: 'flex',
        flexDirection: 'column',
        gap: 40,
      }}
    >
      <div>
        <div style={{color: '#35D7C0', fontSize: 30}}>PRODUCT WALKTHROUGH</div>
        <h1 style={{fontSize: 74, lineHeight: 1.05, margin: '18px 0 0'}}>
          Explore a query
        </h1>
      </div>

      <div
        style={{
          width: '100%',
          aspectRatio: '16 / 9',
          overflow: 'hidden',
          borderRadius: 24,
          border: '3px solid #38536B',
          backgroundColor: '#000',
        }}
      >
        <OffthreadVideo
          src={staticFile('demo.mp4')}
          muted
          style={{width: '100%', height: '100%', objectFit: 'contain'}}
        />
      </div>

      <div
        style={{
          opacity: calloutOpacity,
          fontSize: 42,
          lineHeight: 1.25,
          padding: 28,
          borderRadius: 18,
          backgroundColor: '#102B3B',
        }}
      >
        Start with an example query, then inspect the app's response.
      </div>
    </AbsoluteFill>
  );
};
```

Add the following **fragment** inside the JSX returned by your existing registered root component:

```tsx
<Composition
  id="ProductDemo"
  component={ProductDemo}
  durationInFrames={450}
  fps={30}
  width={1080}
  height={1920}
/>
```

Import `Composition` from `remotion` and `ProductDemo` from its file in that root. Your project should already call `registerRoot` once; do not create a second root just for this scene.

### What each part does

`AbsoluteFill` creates a full-frame container. The outer style establishes the background, text color, padding and vertical arrangement. The header is editable code, not part of the screen recording.

The nested `div` creates a 16:9 frame. `OffthreadVideo` displays the local file through `staticFile`, which resolves files inside `public`. `objectFit: 'contain'` preserves the whole source frame within that container; if your source is not 16:9, blank space may appear. This is intentional: we are choosing to preserve context rather than cropping. `muted` prevents accidental audio from the source. Add separately approved narration or sound through your project's supported audio workflow.

`useCurrentFrame()` returns the current frame within this composition. At 30 fps, `fps` is 30. The opacity interpolation maps frame 30 to zero and frame 45 to one. That means the callout fades in over half a second, starting one second into the video. The clamp options keep opacity at zero before that interval and one afterward.

The registration sets 450 frames at 30 fps, which equals 15 seconds. The example does not guarantee the callout matches a specific click in your recording. Scrub through the source and change the frame interval to correspond to the actual action. If the recording starts with setup you don't want, edit the source or use an appropriate supported media timing feature from the documentation for your installed version.

### Test the design on a phone

The 16:9 screen is relatively small inside a 9:16 canvas. It may establish context but be too small for detailed text. Render a still or short draft and inspect it at the size it will appear on a phone. If the viewer cannot read the result, create a separate close-up with an appropriate crop, or design the application window so the important area is larger at capture time. Do not assume a high-resolution export makes small interface text readable.

### Add a timed highlight carefully

If you add an outline over a control, first determine its position relative to the displayed recording. Put the recording and outline inside the same positioned container. Test the beginning, middle and end of any animation. If the source layout changes, the outline may no longer point at the correct control. For moving content, manual keyframes or tracking may be needed, and the final alignment must be inspected.

## 15. A small runnable timing helper

When planning annotations, it is useful to convert between seconds and frames. Save the following as `timing.js` and run it with `node timing.js`:

```js
const fps = 30;

function secondsToFrame(seconds) {
  return Math.round(seconds * fps);
}

function frameToSeconds(frame) {
  return frame / fps;
}

const actionTime = 7.2;
const actionFrame = secondsToFrame(actionTime);

console.log(`Action at ${actionTime}s ≈ frame ${actionFrame}`);
console.log(`Frame ${actionFrame} = ${frameToSeconds(actionFrame)}s`);
```

The output is approximately:

```text
Action at 7.2s ≈ frame 216
Frame 216 = 7.2s
```

This helper assumes a constant project frame rate and rounds to the nearest whole frame. If you use 29.97 fps, a variable-frame-rate source, or footage with offsets, the conversion requires more care. It is a planning tool, not a substitute for scrubbing the actual composition.

You can use the result as the starting point for a callout or a cut. For a half-second fade at 30 fps, use 15 frames. Verify the alignment visually, because the action may begin between frames or your source may have been trimmed.

## 16. HyperFrames workflow for the same demonstration

HyperFrames can also combine a real recording with editable titles and callouts. The conceptual workflow is:

1. Create a project using the current documented quickstart.
2. Put the sanitized recording in the project assets.
3. Add the recording as a timed media clip according to the installed version's HTML schema.
4. Add separate foreground elements for the title and callout.
5. Animate the callout with the supported seekable timing model.
6. Run `npx hyperframes lint`, preview the timeline, render the MP4, and inspect the result.

Consult the [HyperFrames quickstart](https://hyperframes.app/docs/1-startup/2-quickstart) and [HTML schema](https://hyperframes.app/docs/6-reference/html-schema) for version-specific attributes and timeline registration. A browser animation that looks correct while running in real time is not automatically suitable for seek-based rendering. Use the framework's supported patterns and check a rendered export.

If you already have an editable Remotion composition, you can render it and use the resulting file as a clip in another editor or HyperFrames project. The tradeoff is that the internal title and callout are baked into pixels in the exported clip. Keep the original source project so you can revise them later.

## 17. Build a 30-second walkthrough step by step

Let's assemble the entire QueryLens example. Substitute your own actual interface and results.

### Step 1: define the promise

Write one sentence: “This video shows a developer submitting a sample query and inspecting the explanation.” If the product does not provide an explanation, change the promise. The statement should be testable against the recording.

### Step 2: prepare the environment

Use a demo account, an invented project and a sample query. Hide notifications, remove unrelated browser tabs and ensure the browser does not expose tokens. Set the window dimensions so the relevant panel is readable. Record the starting and reset state.

### Step 3: capture an overview

Record the app at a scale that shows the relationship between the query input, action button and result panel. Hold the initial state for several seconds. This footage establishes context and gives you edit handles.

### Step 4: capture the action

Perform the query submission slowly. Pause before clicking. If a loading state appears, allow it to complete. Hold the result. Record another take if the cursor blocks the result or an unrelated notification appears.

### Step 5: capture details

If the result text would be too small in a full-frame view, record a closer view at a larger browser zoom or crop from a sufficiently high-resolution source. Check that zooming does not rearrange the application into a misleading or unsupported state. Include the relevant title or context so the detail remains understandable.

### Step 6: build a rough edit

Arrange the best sections in the hook–input–action–result–close sequence. Use temporary text cards or narration. At this point, do not spend an hour polishing a background. Check that someone unfamiliar with the app can follow the causal sequence.

### Step 7: add voice and graphics

Record or add approved narration. Add a small number of editable labels and highlights. If you use a generated background, keep it behind the real recording and low enough in contrast that it does not compete. Place captions away from essential controls and verify each word.

### Step 8: review truthfulness and readability

Watch the rough cut without narration: is the action visible? Then listen without looking: does the explanation make sense? Finally, watch with both on a phone-sized display. These are practical review passes, not a requirement that the video be fully understandable in every possible context.

Check whether cuts conceal significant delays, whether the result shown belongs to the input, whether any mockups are identified when relevant, and whether the CTA reflects the product's availability.

### Step 9: export and inspect

Render a draft using your chosen tool. Watch the exported file from beginning to end with audio. Check for clipped text, black frames, stretched screen footage, mismatched audio and unintentional sensitive details. Keep the original capture and the editable project separately from the final export.

## 18. Work with Claude Code and Codex

The agent's job is to help you build and inspect the project. The human still supplies product context, confirms that the recording is safe to use, and judges whether the video is accurate. Give the agent local files and explicit scope; do not assume it can see private services or should upload anything.

### Claude Code: create a storyboard from actual product behavior

```text
I have a sanitized screen recording of my app at public/demo.mp4.
The actual workflow is: paste a sample SQL query, select Analyze, and
read a generated explanation. Create a 30-second vertical storyboard
that shows the input, action, and result. Use sample data and avoid
claims about performance. Identify where a viewer needs a close-up,
where context must remain visible, and where a caption could cover UI.
Do not upload the recording or use a paid service.
```

### Codex: implement the composition

```text
Inspect this existing Remotion project and use public/demo.mp4 as a
local, muted screen-recording asset. Build a 1080x1920 product-demo
composition with a concise title, a framed overview of the recording,
and editable callout text. Do not fabricate interface interactions.
Make the callout timing easy to change. Render a draft if the environment
supports it, inspect frames around the main action, and report any parts
that you could not verify. Do not upload the recording or add paid APIs.
```

### A focused visual revision

```text
At 00:12 the callout covers the result panel. Move the callout into the
empty area below the recording and keep the panel fully visible. The
headline should stay readable on a phone. Render and inspect the same
moment again, and report the final placement and any remaining clipping.
```

A useful request describes the observed defect, where it occurs, what must stay true, and how to verify the change. “Make it better” can start a conversation, but it gives the agent little objective direction. If you want visual exploration, ask for two alternatives with specific differences rather than pretending there is one automatically correct style.

### Ask for explanations, not just files

For learning, add:

```text
Explain the file structure, how the recording is scaled, how frame timing
maps to seconds, and exactly which values control the callout. Identify any
assumptions and distinguish a tested render from code you could not run.
```

This turns generated code into an opportunity to understand the project. Read the implementation and check the export. Agent confidence is not evidence that a video was rendered or inspected.

## 19. Troubleshooting common problems

### The interface is unreadable on a phone

Likely causes include a full desktop screen squeezed into a narrow canvas, small source text, a busy background, or too short a hold. Use an overview followed by a close-up; increase application zoom when recording; reduce surrounding decorations; allow the result to remain visible longer. Check a real phone-size render, not only a large desktop preview.

### The highlight points to the wrong place

Check whether the source was cropped, scaled, moved, or changed by responsive layout. An overlay with fixed output coordinates may not track a video that animates independently. Put both inside a shared transformed container or calculate the mapping carefully. Inspect the precise frame of the click.

### The cursor disappears or is hard to see

Some recording modes or applications capture the cursor differently. Perform a short test before recording the full workflow. If the cursor is present but low contrast, change the pointer setting or use a subtle correctly timed halo. Do not imply a fake action with a replacement cursor.

### The recording looks stretched

Verify the source and container aspect ratios. `width: 100%` and `height: 100%` without an appropriate `object-fit` can distort the image. Use `contain` to preserve the full frame, or `cover` when a deliberate crop is acceptable. Check circles and text for distortion.

### The audio drifts

Inspect source timing and the editor's support for the recording format. Variable frame rate, an incorrect project frame rate, or an audio offset can contribute. Try a tested constant-frame-rate intermediate only if needed, then verify the entire duration. Do not assume a single setting fixes every synchronization problem.

### A private notification appears

The best fix is to recapture in a clean environment. If recapture is impossible, evaluate whether the raw source can be safely handled and whether a robust edit truly removes the information. A visual blur is not a guarantee that sensitive content is irrecoverable, especially if source files are shared.

### The video feels too fast

Identify the specific action the viewer cannot follow. Hold the result longer, shorten narration, remove a decorative transition, or split the workflow into separate videos. Slowing every clip uniformly can make the piece feel sluggish without addressing the confusing point.

## 20. Export, archive and publish thoughtfully

For each project, keep the source recording, editable project, approved audio, captions, asset-rights notes and final export organized. A simple structure:

```text
querylens-demo/
  brief.md
  storyboard.md
  assets/
    demo.mp4
    narration.wav
  src/
    ProductDemo.tsx
  exports/
    querylens-demo-draft.mp4
    querylens-demo-final.mp4
  asset-manifest.md
```

This is an illustrative layout; your actual framework may use `public/` for assets and a different source structure. Avoid committing large raw recordings or secrets to a public Git repository by accident. Decide whether large files belong in a separate storage system and include a clear setup note for collaborators.

Before publishing, verify current platform recommendations for aspect ratio, duration, captions and format. They can change. A correct export for one platform may be cropped or overlaid differently elsewhere, so inspect each version. Accessibility and clarity matter more than assuming a particular format guarantees reach.

## 21. Optional application: your own product

Pick one feature from an application you have built. Write a one-sentence promise and a five-shot outline. Set up safe sample data. Capture an overview and one clean action–result sequence. Build a short vertical edit with one title and one callout. Add narration and manually checked captions if useful. Review the export on a phone and make one targeted revision based on an observed problem.

If your app is still a prototype, say so where it matters. Showing a real, limited feature clearly is more useful to your audience than implying a polished capability that does not yet exist.

## Further reading

- [Remotion API reference](https://www.remotion.dev/docs/api) for media, sequencing and frame APIs.
- [Remotion captions documentation](https://www.remotion.dev/docs/captions/displaying) for displaying timed captions.
- [HyperFrames quickstart](https://hyperframes.app/docs/1-startup/2-quickstart) and [CLI](https://hyperframes.app/docs/5-packages/cli) for current project and rendering commands.
- [FFmpeg documentation](https://ffmpeg.org/documentation.html) for media inspection, conversion and filters.
