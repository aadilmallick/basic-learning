# Lesson 5 — Your first Remotion video

A video made with Remotion is a React application whose output can be evaluated at a specific frame. You describe a scene with components, tell Remotion how long the composition lasts, and calculate visual properties from time. Remotion can then show an interactive preview or render the frames into a video file.

This lesson builds a ten-second vertical explainer about database indexes. It starts with a single moving title, adds scenes with local timelines, and finishes with a reproducible render. By the end, you should be able to read the generated files and make changes yourself, even when Claude Code or Codex helped create them.

**Prerequisites:** basic JavaScript, React components, JSX, object-style CSS, and the idea of a frame and frame rate. If these are unfamiliar, revisit the web and animation lessons first. No experience with video editing or Remotion is assumed.

**Version note:** The examples use the APIs documented in Remotion's official documentation available when the curriculum was prepared. Tool setup, media APIs and licensing can change. Verify the [current getting-started documentation](https://www.remotion.dev/docs/) and [license terms](https://www.remotion.dev/docs/license/) before installing or commercial deployment. Local examples are educational; service availability and charges depend on your environment.

## 1. The problem a video framework solves

Imagine writing a function that draws a card with a heading, arrow, and three rectangles. It is natural to use HTML and CSS for the layout and React to reuse the card. But a web page and a video operate differently. A page usually reacts to input and runs continuously in a browser. A video is a sequence of finished pictures, displayed one after another, with optional sound.

One simple approach is to create a screenshot manually, move an object slightly, create another screenshot, and repeat hundreds of times. That gives control but is painfully slow and difficult to revise. Another is to animate a page with CSS, play it, and record the screen. That can work, but a recording can drop frames, depend on machine speed, or be hard to reproduce exactly.

Remotion makes time an explicit input. Instead of asking “what does this page look like right now according to the operating-system clock?”, your composition can answer “what should the image look like at frame 42?” Remotion renders the sequence of answers and combines them with media. This makes particular frames easy to inspect, reproduce, and generate without manually drawing every image.

Remotion is not itself an image-generation model. Claude or Codex can write the React code; generative image or video services can create optional source assets; Remotion arranges and renders the result. A beautiful design still needs a readable layout, clear hierarchy, effective pacing, suitable audio, and human review.

## 2. Frames, seconds, and the composition

A **frame** is one picture in a video. **Frames per second**, or FPS, is the number of pictures displayed for each second. At 30 FPS, three seconds contains `3 × 30 = 90` frames. Frames use zero-based indexing, so those 90 frames are numbered 0 through 89. Frame 90 is the start of the next three-second segment, not the final frame of the previous one.

A **composition** joins the component that draws the picture with the video's metadata:

- Width and height in pixels determine the canvas and aspect ratio.
- FPS determines the relationship between frame numbers and seconds.
- Duration in frames determines how many images are in the finished video.
- A component describes what each frame contains.

For a 10-second video at 30 FPS, the duration is 300 frames, numbered 0–299. A 1080-by-1920 canvas is portrait, with a 9:16 ratio. These values are choices rather than requirements; a smaller draft resolution can speed feedback if your project and renderer permit it. Text and positioning should scale intentionally when you change dimensions.

A useful equation is `seconds = frame / fps`. At frame 45 and 30 FPS, the video is 1.5 seconds from the beginning. Conversely, `frame = seconds × fps`. If a narration cue occurs 2.5 seconds in, the corresponding boundary is frame 75 at 30 FPS. In production, align the actual audio after hearing it: a script alone does not guarantee a particular speaking speed.

## 3. Set up a project and understand its files

The documented project creation workflow uses `create-video`. Review the command and packages before running them, especially in a work environment:

```bash
npx create-video@latest
```

Follow the prompts to create a project; choose a minimal TypeScript template if offered. The interactive prompts and resulting filenames may change, so use the latest [getting-started guide](https://www.remotion.dev/docs/) as the authority. Enter the created folder and follow its README to install dependencies and start Studio. Many generated projects expose an npm script such as `npm run dev`; check the generated `package.json` rather than assuming the name.

When generating a project, the wizard may offer official agent skills. Existing Remotion projects can install the official guidance with:

```bash
npx remotion skills add
```

Read the skills and understand the commands an agent wants to run. A package installation or network call can change your project or incur a cost. No generative service is necessary for this lesson.

A minimal Remotion project typically has:

| Part | Role |
| --- | --- |
| Entry file such as `src/index.ts` | Calls `registerRoot` to tell Remotion which component holds composition registrations. |
| Root file such as `src/Root.tsx` | Declares one or more `<Composition>` entries and their metadata. |
| Scene component files | Define the images drawn at each frame. |
| `public/` | Holds local assets that can be referenced via `staticFile()`. |
| `package.json` and lockfile | Declare versions, scripts and dependency resolution. |

The exact scaffold varies. The sample below states every relevant file explicitly so you can adapt it to your template instead of guessing where a piece belongs. Keep the scaffold's existing package configuration; don't add duplicate root registrations if one already exists.

### Register the root

```tsx
// src/index.ts
import { registerRoot } from 'remotion';
import { RemotionRoot } from './Root';

registerRoot(RemotionRoot);
```

`registerRoot` receives a React component. It does not render a video immediately; it makes the set of compositions discoverable to Studio and the renderer. `RemotionRoot` is a normal named export from the next file. If your template already has an entry file, update that file rather than creating an unused second entry point.

### Declare the video

```tsx
// src/Root.tsx
import { Composition } from 'remotion';
import { IndexExplainer } from './IndexExplainer';

export const RemotionRoot = () => {
  return (
    <Composition
      id="IndexExplainer"
      component={IndexExplainer}
      durationInFrames={300}
      fps={30}
      width={1080}
      height={1920}
    />
  );
};
```

The `id` is a stable name used in Studio and on the command line. `component` names the React component to evaluate. The other props define the video, not the appearance of the visible text. A composition is 300 frames long, and at 30 FPS that yields ten seconds. If you changed only `fps` to 60, the same 300 frames would last five seconds, so update timing deliberately.

## 4. Your first observable frame

Start with the smallest scene that shows Remotion's fundamental idea:

```tsx
// src/IndexExplainer.tsx
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from 'remotion';

export const IndexExplainer = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const seconds = frame / fps;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: '#0b1020',
        color: '#ffffff',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontFamily: 'Arial, sans-serif',
        fontSize: 80,
      }}
    >
      Frame {frame} · {seconds.toFixed(2)} seconds
    </AbsoluteFill>
  );
};
```

`useCurrentFrame()` returns the current frame number **within the enclosing sequence**; at the root it is the composition frame. `useVideoConfig()` returns metadata such as `fps`, width, height and duration. `AbsoluteFill` fills its parent with an absolutely positioned element; the style object controls its appearance and flex alignment. `toFixed(2)` formats the displayed time and does not change playback speed.

Open Studio using the script in your scaffold. Select `IndexExplainer`. Move the playhead: the number changes because the component is reevaluated for the requested frame. Try frame 0, frame 30 and frame 60. The displayed seconds should be approximately 0, 1 and 2. If you see an empty list, check that `registerRoot` points to the root file and that Studio is using the same entry point. This is more useful than changing CSS before knowing whether the component is registered.

A React component in an ordinary app often reads state updated by user events. A video component can be simpler: derive a visual value from the frame. This is not a ban on every React feature, but effects, timers, network requests, and mutable state need care because rendering can request frames out of order or in parallel. Prefer values derived directly from the frame and stable inputs.

## 5. Interpolation: map one range into another

Suppose a title should fade from invisible to visible during its first second. At 30 FPS, map frames 0 through 30 to opacity values 0 through 1. You could calculate this yourself, but Remotion provides `interpolate()`:

```tsx
import { AbsoluteFill, interpolate, useCurrentFrame } from 'remotion';

export const FadeTitle = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{ backgroundColor: '#0b1020', justifyContent: 'center' }}>
      <h1 style={{ color: 'white', textAlign: 'center', opacity }}>
        Find data faster
      </h1>
    </AbsoluteFill>
  );
};
```

The input is the current `frame`; `[0, 30]` specifies the input range, and `[0, 1]` gives the matching output range. At frame 15, the linear result is 0.5. The clamp options keep the output at the edge values before and after the range. This matters for positions, scales and other properties where values outside the intended range can cause a visible error. Opacity is generally constrained by the browser, but explicitly clamping makes the intended behavior clear.

This example is a component, not a new entry point. To see it by itself, temporarily use it as the component for the registered composition or place it inside `IndexExplainer`. Keep imports together at the top of the file. The sequence component in the completed example later will provide the contextual timing.

### Express a duration in seconds

Hard-coding 30 frames assumes 30 FPS. If you want an animation to remain one second long when FPS changes, calculate its endpoint:

```tsx
const { fps } = useVideoConfig();
const opacity = interpolate(frame, [0, fps], [0, 1], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});
```

This maps one second's worth of frames to opacity. A fixed frame count is also valid if the creative intention is explicitly tied to frames. The important point is to know which assumption your code makes.

### Move and fade together

A title can also slide into place as it appears. Use the same frame for both properties but give them different output ranges:

```tsx
const opacity = interpolate(frame, [0, 24], [0, 1], {
  extrapolateLeft: 'clamp', extrapolateRight: 'clamp',
});
const translateY = interpolate(frame, [0, 24], [60, 0], {
  extrapolateLeft: 'clamp', extrapolateRight: 'clamp',
});
// In JSX: style={{opacity, transform: `translateY(${translateY}px)`}}
```

Here the title starts 60 pixels below its resting place and reaches that position after 24 frames. At 30 FPS, the entrance takes 0.8 seconds. The transform string uses a CSS pixel value; `opacity` is unitless. The fragment assumes `frame` is already defined with `useCurrentFrame()` inside a component.

The motion will be linear: the change is evenly distributed over time. A linear fade can feel mechanical, especially when a large object stops abruptly. Easing changes the rate of progress. Use it because it supports the feeling or meaning of a movement, not because every object needs to bounce.

## 6. Spring motion and timing

`spring()` calculates a physics-inspired progress value based on a frame number and FPS. It is useful for an entrance that accelerates and settles. A simple component can use its result as the interpolation input:

```tsx
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from 'remotion';

export const SpringTitle = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({
    frame,
    fps,
    config: { damping: 18 },
  });
  const y = interpolate(progress, [0, 1], [70, 0]);

  return (
    <AbsoluteFill style={{ backgroundColor: '#101626', justifyContent: 'center' }}>
      <div style={{ color: 'white', textAlign: 'center', transform: `translateY(${y}px)` }}>
        <h1>Indexes change the search</h1>
      </div>
    </AbsoluteFill>
  );
};
```

The parameters tell Remotion which frame to evaluate and the frame rate. Damping influences how quickly the motion settles; other configuration values influence its behavior. A spring may overshoot its end value, so a property such as opacity may need explicit clamping when used with spring progress. The motion does not create a persistent object that ticks forward; it can be evaluated for an arbitrary frame. See the [spring reference](https://www.remotion.dev/docs/spring) for the exact configuration supported by your version.

There is no universal correct damping number. Watch the result in context. If the title bounces while the narrator is explaining a subtle database distinction, the motion may attract attention away from the content. If a transition is so slow that the viewer must wait to read the message, it hurts pacing. Motion is useful when it directs the eye toward a meaningful change.

## 7. Sequencing: one video, multiple local clocks

A short explainer often needs several scenes. You could write one huge component with many conditions on the root frame. But as the project grows, understanding which animation belongs to which scene becomes hard. `<Sequence>` lets you place a component in a range of the parent timeline.

```tsx
import { Sequence } from 'remotion';

export const TimelineExample = () => (
  <>
    <Sequence from={0} durationInFrames={90}>
      <Intro />
    </Sequence>
    <Sequence from={90} durationInFrames={120}>
      <Diagram />
    </Sequence>
    <Sequence from={210} durationInFrames={90}>
      <Outro />
    </Sequence>
  </>
);
```

`Intro`, `Diagram` and `Outro` are placeholders for components defined elsewhere; the complete project below provides real ones. The first sequence covers composition frames 0–89. The second begins at frame 90 and covers 90–209. The third covers 210–299. The durations add to 300 frames, exactly ten seconds at 30 FPS.

Inside `Diagram`, `useCurrentFrame()` starts at 0 when its sequence starts at composition frame 90. Therefore local diagram frame 15 is composition frame 105. This local clock means a reusable scene can animate from 0 without knowing where the editor puts it. If you move the scene later, the local animation can remain unchanged. Nested sequences add further offsets; when debugging, identify whether a number represents parent time or the child's local time.

A sequence also controls when its children are shown. Two sequences can overlap if their `from` and `durationInFrames` ranges overlap; their visual stacking depends on DOM order and CSS, so a true crossfade requires appropriate opacity and layering. Merely overlapping two opaque, full-frame scenes often causes the later scene to cover the earlier one. Audio can also overlap; check for unintended doubled sound.

### Consecutive scenes with Series

When scenes are strictly one after another, `Series` can reduce manual arithmetic:

```tsx
import { Series } from 'remotion';

export const SequentialExample = () => (
  <Series>
    <Series.Sequence durationInFrames={90}><Intro /></Series.Sequence>
    <Series.Sequence durationInFrames={120}><Diagram /></Series.Sequence>
    <Series.Sequence durationInFrames={90}><Outro /></Series.Sequence>
  </Series>
);
```

Again, the scene names stand for components. `Series.Sequence` uses earlier durations to determine placement. If the first scene changes from 90 to 100 frames, the second moves automatically. Remember to update the composition's total duration if the overall length changes. Use explicit `Sequence` positions when independent tracks and overlaps are clearer; use `Series` when sequential order is the central idea. See [Sequence](https://www.remotion.dev/docs/sequence) and [Series](https://www.remotion.dev/docs/series).

## 8. Complete ten-second explainer

Now replace `src/IndexExplainer.tsx` with the following self-contained example. It needs no external image, font or audio file. It is designed for the `Root.tsx` shown earlier. The diagram is a conceptual visualization of a lookup; it does not claim that every database uses exactly this physical layout or guarantees a particular speedup.

```tsx
// src/IndexExplainer.tsx
import { AbsoluteFill, interpolate, Sequence, spring, useCurrentFrame, useVideoConfig } from 'remotion';

const colors = {
  background: '#0b1020',
  panel: '#19233a',
  text: '#f5f7ff',
  muted: '#b7c5df',
  accent: '#65e6ce',
};

const titleStyle: React.CSSProperties = {
  color: colors.text,
  fontFamily: 'Arial, sans-serif',
  fontSize: 92,
  lineHeight: 1.08,
  fontWeight: 700,
  margin: 0,
  textAlign: 'center',
};

const containerStyle: React.CSSProperties = {
  backgroundColor: colors.background,
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  justifyContent: 'center',
  padding: 90,
  boxSizing: 'border-box',
};

const Intro = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame, fps, config: { damping: 20 } });
  const y = interpolate(progress, [0, 1], [70, 0]);
  const opacity = interpolate(frame, [0, 18], [0, 1], {
    extrapolateLeft: 'clamp', extrapolateRight: 'clamp',
  });
  return (
    <AbsoluteFill style={containerStyle}>
      <div style={{ transform: `translateY(${y}px)`, opacity }}>
        <h1 style={titleStyle}>How do indexes help find data?</h1>
      </div>
    </AbsoluteFill>
  );
};

const Diagram = () => {
  const frame = useCurrentFrame();
  const rows = ['A–F', 'G–M', 'N–Z'];
  const reveal = interpolate(frame, [5, 25], [0, 1], {
    extrapolateLeft: 'clamp', extrapolateRight: 'clamp',
  });
  const highlight = frame >= 55;
  return (
    <AbsoluteFill style={containerStyle}>
      <h2 style={{ ...titleStyle, fontSize: 74, marginBottom: 60 }}>
        Use an index to narrow the search
      </h2>
      <div style={{ width: '100%', opacity: reveal }}>
        {rows.map((label, index) => (
          <div key={label} style={{
            backgroundColor: highlight && index === 1 ? colors.accent : colors.panel,
            color: highlight && index === 1 ? colors.background : colors.text,
            borderRadius: 24, marginBottom: 24, padding: 32,
            fontFamily: 'Arial, sans-serif', fontSize: 64, fontWeight: 700,
            textAlign: 'center',
          }}>
            {label}
          </div>
        ))}
      </div>
      <p style={{ color: colors.muted, fontFamily: 'Arial, sans-serif', fontSize: 46, textAlign: 'center', marginTop: 40 }}>
        A simplified lookup illustration
      </p>
    </AbsoluteFill>
  );
};

const Outro = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 18], [0, 1], {
    extrapolateLeft: 'clamp', extrapolateRight: 'clamp',
  });
  return (
    <AbsoluteFill style={containerStyle}>
      <h2 style={{ ...titleStyle, opacity }}>
        Better access paths can reduce work
      </h2>
    </AbsoluteFill>
  );
};

export const IndexExplainer = () => (
  <AbsoluteFill style={{ backgroundColor: colors.background }}>
    <Sequence from={0} durationInFrames={90}><Intro /></Sequence>
    <Sequence from={90} durationInFrames={120}><Diagram /></Sequence>
    <Sequence from={210} durationInFrames={90}><Outro /></Sequence>
  </AbsoluteFill>
);
```

Depending on your TypeScript configuration, `React.CSSProperties` may require `import type { CSSProperties } from 'react'` and then `CSSProperties` instead. The default React type setup in many templates supplies the namespace, but the explicit type import is the portable choice. No component uses a remote font or a random value; a machine-specific Arial substitute can still look different, so for exact typography use a licensed local font and follow Remotion's current font-loading guidance.

Let's trace the result. Composition frames 0–89 show `Intro`, with the first 18 frames fading in. The spring also moves the title upward from a 70-pixel offset. At composition frame 90, `Diagram` starts at local frame 0. Its list fades in between local frames 5 and 25, corresponding to composition frames 95–115. At local frame 55, or composition frame 145, the middle range changes color. The highlighting is intentionally a hard change so you can see how a condition controls appearance. Frames 210–299 show the outro, which starts with its own local fade.

The `rows.map()` call creates three visual cards from data. Each card has a stable `key`, the label. `index === 1` selects the middle row in the array, not a real database page. The color and background ternaries select styles based on `highlight`. The spread `{ ...titleStyle, fontSize: 74 }` copies shared title styles and overrides just the font size. `boxSizing: 'border-box'` makes the 90-pixel padding part of the available full-frame dimensions, avoiding unintended overflow.

Scrub to frames 0, 18, 89, 90, 115, 145, 209, 210, 228 and 299. At each scene boundary, check that there is no unwanted black flash, clipping or overlap. Check whether text fits with your actual font and whether the narration you eventually add leaves enough time to read. The sample has cuts, not crossfades. That is a creative decision you can change once the basic timeline is correct.

### How to modify it

To make the middle scene last one second longer, add 30 frames to its duration at 30 FPS, move the outro from frame 210 to frame 240, and increase the composition duration from 300 to 330. The outro keeps the same local animation because its own frame zero moves with its `Sequence`. If you forget to extend the root composition, its end will be cut off. If you extend the root without moving the outro, the second scene and outro will overlap.

To slow only the first fade, replace its endpoint 18 with 30; this makes the fade one second long at 30 FPS, while the scene duration remains three seconds. The spring and opacity durations are independent, so check whether they now feel synchronized. You could also calculate the fade endpoint from `fps` if you want the same time after changing frame rate.

## 9. Bringing in images, video, fonts and audio

The sample is asset-free to make the first render easy to reproduce. A production video might need a logo, screen recording, narration and a generated background. Put appropriately licensed files in `public/` and use Remotion's supported media APIs. For a local image, the documented pattern is:

```tsx
import { Img, staticFile } from 'remotion';

export const Logo = () => (
  <Img src={staticFile('logo.png')} style={{ width: 240 }} />
);
```

Place `logo.png` at `public/logo.png`. `staticFile()` creates the correct asset URL for Remotion rather than assuming a path relative to the component. `Img` is intended to coordinate image loading for rendering. This is a separate component; add it to a scene if you have that file and permission to use it. If it is missing, you should expect a load failure rather than a working example.

For video and audio, API choices differ by Remotion version and intended rendering environment. The current official [video and audio documentation](https://www.remotion.dev/docs/) describes supported media packages, trimming, looping and volume. Select components compatible with your installed versions and keep all Remotion package versions aligned. A screen recording can become a timed layer while text remains crisp and editable above it. Do not assume a video clip has the correct length or aspect ratio: inspect the original metadata and decide whether to crop, letterbox or reframe.

Record narration or use an authorized generated voice. Place the source audio deliberately on the timeline, listen to the export, and align text changes to actual speech. A transcription is not automatically a good caption track: correct words, punctuation, timing and readability. Avoid putting captions where a platform's buttons or account information will obscure them. See [Remotion captions](https://www.remotion.dev/docs/captions/displaying) for its current caption format and components.

Fonts require the same care as other dependencies. The layout can change when a font is unavailable or a network resource has not finished loading. Use a properly licensed font and Remotion's documented font-loading method; check render output rather than assuming your local preview and another machine will use the same glyph metrics. If you defer rendering while async work finishes, use the version-appropriate delay-render API and handle errors so the render does not wait indefinitely.

## 10. Preview, render, inspect, revise

Studio is for iterating: select a composition, scrub frames, play the draft and inspect how layout responds. A successful preview is not proof that the final encoded file is correct. A render uses the composition ID, entry point, output path, and current project configuration to capture and encode frames. A common CLI shape is:

```bash
npx remotion render src/index.ts IndexExplainer out/index-explainer.mp4
```

Use the entry point and composition ID from your own project; consult the current [render CLI reference](https://www.remotion.dev/docs/cli/render) for options and licensing requirements. Running the CLI may download a browser or other dependencies depending on your environment. Don't assume a particular command succeeds on every machine; read the error and project's README. If rendering with an agent, authorize the environment and do not provide unrelated files or secrets.

Review the actual MP4 with sound, not just a few stills. First confirm dimensions and duration. Then inspect the beginning, each scene transition, the last frame, and representative mid-animation frames. Watch at normal speed on a desktop and at phone size. Check text wraps, contrast, unwanted overlap, audio timing, and whether the final message remains long enough to read. A render can be technically successful and still be visually ineffective.

For a more targeted review, render or capture still frames using the documented Remotion CLI options and compare them after a change. Explicit timestamps make revision requests clear: “At frame 145, the highlighted row covers the explanatory label” gives an agent evidence and a location. The specific frame may change if the FPS or scene start changes, so also mention the scene and intended behavior.

## 11. Common problems and how to reason about them

**Nothing appears in Studio.** Check the entry point, root registration, exports, composition ID, and whether the development server is displaying a compilation error. An unregistered component cannot be selected even if its code is correct.

**Everything is static.** Confirm that the property changes with `useCurrentFrame()` inside the composition and that the calculated value is actually used in the style. A CSS animation that relies on wall time may not render consistently; use a frame-driven value or a documented compatible integration.

**A scene starts halfway through its animation.** Check whether the calculation uses the composition frame or the local frame within its `Sequence`. A child that expects local time should call `useCurrentFrame()` within that sequence, or the parent should pass an explicitly adjusted value.

**Animation goes beyond the intended endpoint.** Interpolation may extrapolate outside its input range. Clamp where appropriate. A spring can overshoot, which may be useful for position but unsuitable for opacity or an exact numerical value.

**A scene is cut short or disappears.** Compare `from + durationInFrames` with the composition duration. Remember that the last valid frame is one less than the duration. Ensure the underlying asset is present and loaded.

**Preview and export differ.** Investigate wall-clock animation, network assets, fonts, randomness, unsupported media, asynchronous loading and browser differences. Replace hidden state with a deterministic function of frame and stable inputs. Inspect the exported file to determine whether the discrepancy is in visual capture, encoding or playback.

**The render is slow.** Large output dimensions, complex effects, long videos and media decoding increase work. Start with short scenes, simplify effects, use an appropriate preview setup, and measure before optimizing. A faster render that changes the creative result or causes missing assets is not an improvement.

**Text is unreadable on a phone.** The canvas may be 1080 pixels wide, but viewers can see it scaled to a much smaller display. Shorten text, strengthen hierarchy, increase effective size, reduce clutter and hold important content longer. Check the actual output at the expected viewing size.

## 12. Directing Claude Code and Codex

The agents need a task with an objective, constraints and a verification loop. Give them an existing project folder rather than assuming they know its contents. An agent can make a useful first draft, but you should review both code and the actual exported video. Explain that external paid services and uploads require an explicit decision.

### Claude Code example

With the official Remotion plugin installed, its documentation describes `/remotion:remotion-create` as a creation skill. Check the installed plugin version and available commands first. In your project, try:

```text
/remotion:remotion-create Build a 10-second 1080x1920 Remotion explainer
about database indexes at 30 fps. Use three scenes: question, simplified
lookup illustration, and takeaway. Use React components and frame-driven
animations. Keep claims qualitative and label the diagram as simplified.
Use local CSS shapes only; do not call paid models or upload files.
Explain the composition metadata, each scene's local frame, and how to
change the timing. Render a draft and inspect the beginning, every scene
boundary, and final frame. Report the output location and any issues.
```

This prompt specifies the audience-facing claim and instructs the agent to inspect evidence. “Make it look professional” alone leaves most choices undefined. It is still reasonable to tell the agent your desired visual style; the goal is enough specificity to judge whether it achieved your intention.

### Codex example

Remotion's official Codex integration and agent skills may be available differently across installations. In an existing project, install or enable the official skills using the current documentation and then ask:

```text
Use the installed Remotion guidance to implement the three-scene 10-second
index explainer in this repository. First inspect the entry point and existing
composition registrations. Keep the first version asset-free, editable and
fully frame-driven. Explain how useCurrentFrame changes inside a Sequence.
Run the project's available checks, render a draft, inspect representative
frames, and fix any clipping. Do not install paid services or publish anything.
List changed files and provide exact local render instructions.
```

The request to inspect first prevents the agent from assuming a file structure. The local-frame explanation turns generated code into a lesson. The instruction to render and inspect produces evidence rather than only a claim that the code looks plausible.

### A precise iteration request

```text
In the diagram scene, keep the cards visible throughout. The highlight
currently changes abruptly at local frame 55. Animate its background change
across 12 frames, preserve contrast for the text, and do not change the scene
length. Render the affected scene and inspect frames before, during, and after
the change. Explain the interpolation and report any limitations.
```

If the agent introduces a new dependency or an unverified API, ask it to point to the current official documentation and explain why it is needed. A code diff, rendered stills and actual playback are better evidence than a confident description.

## 13. Moving toward a real developer video

A good next step is to replace the conceptual index diagram with a topic you can explain accurately in 20–30 seconds. For example, you might show a before-and-after workflow from one of your own applications. Write the message first, then make a storyboard with a start time, visual and narration for each beat. Record or generate an authorized voiceover; design captions after the narration timing is known. Retain the source files and asset licenses so you can update the video later.

When precise UI or code is the subject, use a genuine screen capture or editable React/SVG overlay for the important details. A generative video model can supply atmosphere, but it may distort text or invent interface elements. Keep a clean boundary between real product behavior and illustrative graphics. A visually rich backdrop is only useful if viewers can still read and understand the foreground.

At this point you have the basic Remotion workflow: register a composition, derive motion from the current frame, arrange scenes using local timelines, add appropriate assets, render, and inspect. The next lesson uses HTML and GSAP timelines in HyperFrames, where the framework seeks a timeline to each requested time instead of asking React for values by frame.

### Further reading

- [The core idea and composition metadata](https://www.remotion.dev/docs/idea)
- [Interpolation](https://www.remotion.dev/docs/interpolate), [spring](https://www.remotion.dev/docs/spring), [Sequence](https://www.remotion.dev/docs/sequence), and [Series](https://www.remotion.dev/docs/series)
- [Agent skills](https://www.remotion.dev/docs/ai/skills), [Claude Code plugin](https://www.remotion.dev/docs/ai/claude-code-plugin), and [Codex plugin](https://www.remotion.dev/docs/ai/codex-plugin)
- [License and pricing](https://www.remotion.dev/docs/license/pricing)
