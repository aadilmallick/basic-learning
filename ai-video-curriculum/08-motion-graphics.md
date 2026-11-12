# Lesson 8 — Designing and Building Motion Graphics

## The outcome

A motion graphic turns information into a visual event. A word appears as it is spoken. A cursor highlights a real control. A diagram shows a lookup traveling through an index. A screen recording moves into a frame, then the important result stays visible long enough to understand.

In this lesson you will build a vocabulary for those effects and learn why they work. We will move from a static frame to timed text, reveals, interface callouts, animated diagrams and reusable components. Along the way, you will see complete small code examples, conceptual fragments where project setup is assumed, and prompts for both Claude Code and Codex. The goal is not to memorize effects. It is to connect a visual choice to the information a viewer needs at that moment.

We assume you know the basics of frames, interpolation, React and HTML from earlier lessons. The examples use Remotion for the larger runnable composition because its current frame makes the math visible. The principles transfer to HyperFrames, which uses HTML and a seekable timeline. Check the current documentation for the version installed in your project; framework APIs and templates change.

## 1. What makes an animated graphic useful?

Consider a video explaining database indexes. The narration says: “An index helps the database narrow where it looks.” The screen contains a large table, a decorative spinning globe, a blinking title, five moving arrows and a pulsating chart. Which motion should a viewer follow? The viewer has only a limited amount of attention, and all six elements compete for it.

Now change the scene. Show a simple list of records. Highlight a small index card. Animate one line from the index card to a highlighted region of the records. Keep everything else still. The motion has a job: it reveals the relationship between the index and the region being searched. When the motion finishes, the viewer has a stable frame to inspect.

This does not mean decoration is forbidden. A background can carry subtle motion and color without becoming a second explanation. The question is whether it competes with the main action. If someone watches with sound off or on a phone, can they identify the main point in a few seconds? If not, try removing motion before adding more.

Motion communicates through change. An entrance tells us that a new idea has arrived. A change in position can show direction or sequence. A scale increase can direct attention. A reveal can expose information in an order. A long hold provides time to read. The same visual movement can be expressive or confusing depending on timing and context.

### Four layers of a typical scene

Think of a scene as four layers with different jobs:

1. **Background:** establishes a visual atmosphere and separates the subject from the frame edge.
2. **Primary subject:** the UI, chart, title, illustration or footage carrying the point.
3. **Attention cue:** a highlight, pointer, underline or motion that shows where to look.
4. **Supporting information:** captions, labels, source information or a short explanation.

A scene can use more or fewer layers, but naming them makes hierarchy explicit. A common error is giving the background and primary subject equally strong motion. Try pausing your animation at several frames: the scene should still have an obvious subject as a still image.

## 2. Start with a style frame

A **style frame** is a still representation of the intended look. It answers questions that a moving draft can conceal: Is the headline readable? Is there enough contrast? Is the card aligned? Does the visual match the audience and topic? Can the most important information fit without overlap?

For a developer explainer, start with a 1080×1920 vertical canvas. This is a working size, not a guarantee of a platform's current display behavior. Assume the actual player may place interface elements over the edges and verify the final target. Choose a dark background, one primary typeface, one accent color, and a single focal card. Add a concise heading such as “Find less. Query faster.” if it accurately reflects the explanation, and a diagram labeled “Index” and “Records.” Avoid presenting the phrase as a measured speed claim.

Set the type hierarchy by role, not by random sizes. A headline might be 96 pixels in a 1080-pixel-wide design, a supporting line 44 pixels, and diagram labels 36 pixels. Those are starting design values, not universal minimums. What matters is how the final image looks on a phone after downscaling and any platform cropping. Check the actual render at its intended display size.

### A simple static HTML style frame

Save this as `style-frame.html` and open it in a modern browser. The page is standalone; it uses only system fonts and does not call a network service.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Index explainer style frame</title>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      background: #080d17;
      font-family: system-ui, sans-serif;
    }
    .canvas {
      width: min(90vw, 405px);
      aspect-ratio: 9 / 16;
      padding: 9%;
      color: #f8fafc;
      background: radial-gradient(circle at 80% 15%, #17485a, #101827 45%);
      display: flex;
      flex-direction: column;
      justify-content: center;
      gap: 2rem;
      overflow: hidden;
    }
    h1 { margin: 0; font-size: clamp(1.8rem, 6vw, 3.2rem); line-height: 1.05; }
    .card { padding: 1.2rem; border: 1px solid #3b5266; border-radius: 1rem; background: #162538; }
    .accent { color: #5eead4; }
    .arrow { color: #5eead4; font-size: 2rem; }
    p { margin: .5rem 0 0; line-height: 1.4; color: #cbd5e1; }
  </style>
</head>
<body>
  <main class="canvas">
    <h1>Find the right <span class="accent">records</span>.</h1>
    <section class="card" aria-label="Database index illustration">
      <strong>Index</strong>
      <div class="arrow" aria-hidden="true">↓</div>
      <strong>Matching records</strong>
      <p>A simplified visual of a lookup path.</p>
    </section>
  </main>
</body>
</html>
```

The `.canvas` uses `aspect-ratio: 9 / 16` to maintain the portrait shape while being previewable in a browser. It is not itself a video renderer. `overflow: hidden` keeps content inside the frame, though clipping should still be inspected rather than used to hide mistakes. The `radial-gradient` adds a soft area of color behind the content. `clamp()` limits the headline font size while allowing it to respond to the browser width.

In a real rendering composition, decide which dimensions are fixed in pixels and how the preview scales the whole canvas. A responsive browser example and a fixed-resolution video composition use related CSS but are not automatically equivalent. Test both the browser display and the final exported video.

## 3. Plan timing as a sequence of readable states

Before writing animation code, identify what the scene should look like at important times. For a five-second title scene at 30 FPS, a reasonable plan is:

| Time | Frame | Viewer sees | Purpose |
| --- | ---: | --- | --- |
| 0.0 s | 0 | Background and empty title area | Establish the scene |
| 0.0–0.6 s | 0–18 | Title enters | Direct attention to the topic |
| 0.6–1.0 s | 18–30 | Title holds | Give time to read |
| 1.0–1.6 s | 30–48 | Diagram appears | Introduce supporting information |
| 1.6–4.4 s | 48–132 | Diagram holds | Give time to follow narration |
| 4.4–5.0 s | 132–150 | Scene exits or cuts | Prepare the next scene |

A five-second composition at 30 FPS contains frames 0 through 149. The table's 150 marks the end boundary, not a displayed extra frame. The exact timing should be adjusted to the actual narration and reading speed. These values are useful because they make a creative instruction testable: “the title finishes entering by frame 18” is precise enough to inspect.

A hold is an active design choice. If text is moving during its entire appearance, a viewer must read and track movement at the same time. Motion can introduce the information, then settle. A deliberate hold also gives voiceover space to complete a sentence before the next visual arrives.

## 4. The basic motion equation

Most two-dimensional motion graphics begin with a value changing over time. A basic linear interpolation from a starting value `a` to an ending value `b` uses progress `p` between zero and one:

```text
value = a + (b - a) × p
```

If a card moves from 80 pixels below its destination to its destination, `a = 80` and `b = 0`. At `p = 0`, its vertical translation is 80. At `p = 0.5`, it is 40. At `p = 1`, it is 0. The same progress can control opacity from zero to one.

Linear motion is predictable, but it starts and stops abruptly. An easing function remaps progress. One simple ease-out curve is:

```js
function easeOutCubic(progress) {
  const clamped = Math.max(0, Math.min(1, progress));
  return 1 - Math.pow(1 - clamped, 3);
}

console.log(easeOutCubic(0));   // 0
console.log(easeOutCubic(0.5)); // 0.875
console.log(easeOutCubic(1));   // 1
```

At halfway through time, an ease-out cubic has already completed 87.5% of the distance, then slows toward the destination. This makes an entrance feel decisive without stopping as sharply as linear movement. There is no rule that this easing is always appropriate. A steady scanning line or camera move may need linear motion; an energetic label might suit a spring. If every element uses a strong bounce, the visual style can become noisy.

Clamping matters. Without it, a mathematical mapping may continue beyond the intended endpoint. A fading title might become more than fully opaque mathematically or keep traveling off screen after its entrance. Renderers handle out-of-range values differently, so define intended behavior explicitly.

## 5. A complete Remotion scene: title, diagram and callout

This example assumes an existing Remotion project with React and Remotion installed, such as a project created by Remotion's current starter. Replace or adapt the project's root according to its existing setup. The composition has no external assets or network dependencies. The code demonstrates a reusable reveal component and a complete registered video.

```tsx
// src/IndexScene.tsx
import React from "react";
import {
  AbsoluteFill,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

type RevealProps = {
  start: number;
  duration: number;
  children: React.ReactNode;
};

const Reveal: React.FC<RevealProps> = ({ start, duration, children }) => {
  const frame = useCurrentFrame();
  const raw = interpolate(frame, [start, start + duration], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const progress = 1 - Math.pow(1 - raw, 3);

  return (
    <div
      style={{
        opacity: progress,
        transform: `translateY(${(1 - progress) * 45}px)`,
      }}
    >
      {children}
    </div>
  );
};

export const IndexScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const lineProgress = interpolate(frame, [fps * 2, fps * 2.7], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        background: "radial-gradient(circle at 80% 10%, #164e63, #0f172a 50%)",
        color: "#f8fafc",
        fontFamily: "Arial, sans-serif",
        padding: 90,
        justifyContent: "center",
        gap: 60,
      }}
    >
      <Reveal start={0} duration={fps * 0.6}>
        <h1 style={{ fontSize: 96, lineHeight: 1.05, margin: 0 }}>
          Find the right <span style={{ color: "#5eead4" }}>records.</span>
        </h1>
      </Reveal>

      <Reveal start={fps} duration={fps * 0.6}>
        <div style={{
          padding: 56,
          border: "3px solid #35546a",
          borderRadius: 32,
          backgroundColor: "#162538",
          fontSize: 48,
          fontWeight: 700,
        }}>
          <div>Index</div>
          <div style={{ height: 100, display: "flex", alignItems: "center" }}>
            <div style={{
              width: 8,
              height: `${lineProgress * 100}%`,
              backgroundColor: "#5eead4",
              borderRadius: 4,
              transformOrigin: "top",
            }} />
          </div>
          <div>Matching records</div>
          <p style={{ fontSize: 34, lineHeight: 1.35, fontWeight: 400, color: "#cbd5e1" }}>
            A simplified lookup path
          </p>
        </div>
      </Reveal>
    </AbsoluteFill>
  );
};
```

```tsx
// src/Root.tsx
import React from "react";
import { Composition } from "remotion";
import { IndexScene } from "./IndexScene";

export const RemotionRoot: React.FC = () => (
  <Composition
    id="IndexScene"
    component={IndexScene}
    durationInFrames={150}
    fps={30}
    width={1080}
    height={1920}
  />
);
```

```tsx
// src/index.tsx — use this only if your project does not already register a root.
import { registerRoot } from "remotion";
import { RemotionRoot } from "./Root";

registerRoot(RemotionRoot);
```

Use the project's configured Studio command to preview. If its entry point is `src/index.tsx`, a common direct render form is:

```bash
npx remotion render src/index.tsx IndexScene out/index-scene.mp4
```

Confirm the exact CLI syntax with the installed Remotion version. A starter project may already define an entry point or a script; do not register the root twice. See the [rendering guide](https://www.remotion.dev/docs/render) if your project structure differs.

### Read the code slowly

`Reveal` accepts `start`, `duration` and `children`. The first two are frame counts, while `children` is the content wrapped by the component. Calling `useCurrentFrame()` inside the component obtains the current frame of its composition or relevant sequence context. `interpolate()` converts the frame range to progress between zero and one; the two clamp settings prevent the progress from continuing outside that range.

The next line converts linear progress to the cubic ease-out described earlier. When `progress` is zero, the wrapper is transparent and translated 45 pixels down. When it is one, the wrapper is fully visible and at its original position. The transform changes only the wrapper's visual position; it does not reflow other items in the layout. That makes the card's movement easier to reason about, but it also means you should check that it does not overlap neighboring elements while moving.

The title starts at frame zero and takes 0.6 seconds. The diagram starts one second into the composition. The connecting line begins at two seconds and grows until 2.7 seconds. Its parent has a fixed height of 100 pixels, so setting the inner bar's percentage height changes its visible length. At the final state the line reaches 100% of its container; at frame 60, it starts at zero. This is a deliberately simple cue, not a claim about the exact internal structure of a particular database index.

Notice the animation has a hierarchy. The title arrives first, the card follows, then the line draws attention to the relationship. Everything else stays still. You can change one beat at a time and rerender, which makes the result easier to debug than a scene where every property is driven by a different unrelated effect.

### A more honest diagram

The label “Matching records” simplifies a real query. An index can locate candidate rows or support other access strategies, and an optimizer may choose a different plan depending on the database and query. Keep this distinction clear in explanatory content. If the video discusses a specific database, validate the example with its real execution plan rather than animating a generic diagram as a guaranteed behavior.

## 6. Kinetic typography: making words move with meaning

Kinetic typography is animated text. The effect is useful when it makes a message easier to process: a key word arrives on an emphasized syllable; a sentence appears in readable groups; a word changes color when the speaker contrasts two ideas. It becomes less useful when every letter moves independently for no reason.

There are several scales of animation:

- **Whole block:** the entire heading fades or slides in. This is easy to read and easy to maintain.
- **Line by line:** each phrase enters as a unit. This can match spoken clauses.
- **Word by word:** each word is highlighted or revealed at a specific time. It can reinforce narration but requires accurate timing.
- **Character by character:** letters animate separately. This can create a distinctive title but increases visual noise and can interfere with reading.

Begin with block-level motion. Add finer timing only if it helps the story. A line like “Make the slow query visible” could reveal “slow query” first and then “visible” when the narration arrives. A complex sentence does not need every letter to fly in from a different direction.

### A small word-highlight fragment

The following is a component fragment for an existing Remotion project. It deliberately uses fixed frame ranges for a short illustrative phrase. Real captions should be based on verified timing data and support variable line wrapping.

```tsx
import React from "react";
import { useCurrentFrame } from "remotion";

export const TimedPhrase: React.FC = () => {
  const frame = useCurrentFrame();
  const words = [
    { text: "Build", start: 0, end: 15 },
    { text: "better", start: 15, end: 30 },
    { text: "tools", start: 30, end: 48 },
  ];

  return (
    <div style={{ fontSize: 72, fontWeight: 700, color: "#f8fafc" }}>
      {words.map((word) => (
        <span
          key={word.text}
          style={{
            color: frame >= word.start && frame < word.end ? "#5eead4" : "#f8fafc",
            marginRight: 18,
          }}
        >
          {word.text}
        </span>
      ))}
    </div>
  );
};
```

At 30 FPS, the first word is highlighted from frame 0 up to but not including frame 15; the second covers frames 15–29; the third covers frames 30–47. The half-open comparison `frame < word.end` prevents two adjacent ranges from both being active at the exact boundary. In production, use a stable unique identifier for each word rather than the word text as a key, because repeated words would otherwise share a key. This short example avoids repeated words to keep the mechanism visible.

If the phrase is spoken more slowly, these numbers must change. Do not claim that a transcript is synchronized just because word timestamps were generated automatically. Listen to the voice, inspect the timestamps and correct recognition or alignment errors. Also ensure the text retains adequate contrast when not highlighted. Captions should be readable even if the viewer cannot distinguish the accent color.

## 7. Reveals and masks

A reveal changes how much of an element is visible. A common title treatment places text inside a container that hides overflow; the text starts below the container, then moves upward into view. The visible window stays still while its content moves.

```html
<!-- Static structure for a masked title; animation setup is separate. -->
<div class="reveal-window">
  <div class="reveal-content">Make the invisible visible.</div>
</div>
```

```css
.reveal-window {
  overflow: hidden;
  padding-bottom: 0.12em; /* Allow descenders a little space. */
}
.reveal-content {
  transform: translateY(100%);
}
```

To animate this in a video, drive the `translateY` value from the composition's frame or seekable timeline rather than relying on an independent wall-clock CSS animation. At the beginning, the content sits below the window; at the end, it sits at `translateY(0)`. Padding and line-height matter: if the mask is too tight, letters such as “g” and “y” can be clipped after the animation ends.

A mask can also reveal a UI panel from left to right. But the effect must support the content: if the UI has important small labels, a sweeping mask can make them impossible to read until the reveal finishes. Hold the final state long enough for inspection. Check whether shadows extend outside the clipped container; a shadow that suddenly disappears at the mask boundary can look like a rendering bug.

In HyperFrames, implement this as a seekable GSAP animation inside the scaffold's registered timeline. The specific clip metadata, timeline registration and duration rules belong to the current [HyperFrames GSAP guide](https://hyperframes.app/docs/3-guides/3-gsap-animation). A generic browser CSS animation with `animation-play-state: running` is not proof that the video renderer can seek the animation reproducibly.

## 8. Lower thirds and callouts

A lower third is a compact identifier or supporting fact usually positioned in the lower portion of the frame. It might show a presenter's name and role or identify an application feature. In vertical videos, the bottom of the screen may also contain captions or platform controls, so the traditional placement must be adapted. Reserve distinct regions for captions and callouts and inspect them in the actual target display.

A useful lower third has three design decisions:

1. **Information:** what must the viewer learn? A name and a role may be enough.
2. **Timing:** when should it appear, and how long must it remain readable?
3. **Placement:** where can it sit without covering the active UI or captions?

The entrance should lead the eye without requiring the viewer to follow it across the entire canvas. For example, a card could move 30 pixels upward and fade in over 0.4 seconds, remain for 2.5 seconds, then fade away. If a long title wraps, the card should expand or use a planned maximum length rather than clipping the text.

Callouts differ from lower thirds because they refer to a specific thing in the scene. A callout label may read “Filter by date” while a line connects it to the real control. If the screen recording is cropped or zoomed, the target's location changes. The callout should follow the coordinate system of the screen recording, not an unrelated page coordinate. Otherwise the line may point at the wrong control after the layout changes.

For a truthful demonstration, point to a control that exists in the captured UI and name its behavior accurately. If a screen is a conceptual mockup, label it as such where viewers might otherwise infer that it is a released feature. Animation should clarify the product, not imply a capability the product lacks.

## 9. Animated interfaces and cursor movement

A polished UI demo often combines three kinds of media: a real screen capture, an overlay indicating where to look, and a background that frames the recording. A common sequence is:

1. Show the app in context.
2. Zoom gently toward the relevant section.
3. Move the cursor to the control.
4. Indicate the click with a small ring or short scale change.
5. Hold on the resulting state.
6. Add a short label explaining why the result matters.

The viewer needs to see both cause and effect. If the recording jumps immediately from “before” to “after,” the audience may not know which control caused the change. Conversely, showing every intermediate cursor movement and loading delay can make a short video feel slow. Edit out irrelevant pauses, but preserve the meaningful action and result.

### Coordinate systems in a UI callout

Assume a screenshot is 1200×800 pixels and is displayed at 600×400 inside the video. A button at source coordinate `(900, 200)` maps to `(450, 100)` within the displayed screenshot, before adding the screenshot's position on the canvas. This is a scale factor of 0.5 in both directions. If the screenshot is cropped, first subtract the crop's top-left source coordinate, then apply the scale factor, then add the displayed image's position.

```js
// Pure JavaScript coordinate conversion for a uniformly scaled crop.
function mapPoint({ x, y }, crop, displayed) {
  const localX = x - crop.left;
  const localY = y - crop.top;
  return {
    x: displayed.left + localX * (displayed.width / crop.width),
    y: displayed.top + localY * (displayed.height / crop.height),
  };
}

console.log(mapPoint(
  { x: 900, y: 200 },
  { left: 0, top: 0, width: 1200, height: 800 },
  { left: 100, top: 300, width: 600, height: 400 },
));
// { x: 550, y: 400 }
```

The output is in the video canvas's coordinate system. This function assumes an axis-aligned crop and direct scaling. Rotation, perspective, nonuniform transformations and CSS `object-fit` cropping require additional calculations. It also assumes the source UI does not change between frames. When the interface moves, the target must be tracked or updated; a fixed coordinate is no longer enough.

A cursor path can use the same interpolation principles as a card. Define a start and end, choose the travel time, and ease the movement. Avoid simulating a click before the cursor reaches the control. If a real capture already shows a cursor, decide whether to use that cursor or replace it; two simultaneous cursors are distracting. Never present a fabricated cursor action as a real recording without making the nature of the demonstration clear.

## 10. Diagrams and animated data

An animated diagram explains a relationship over time. Consider the stages of a request: client, API and database. A simple diagram can reveal a request line from client to API, hold, then reveal a second line from API to database. This tells a sequence more clearly than making every box pulse simultaneously.

A useful animated chart has an additional constraint: its movement must preserve the meaning of the data. A bar chart whose axes or baseline change during an animation can create a false impression. The bars might grow from zero to their final values, but the scale and labels should be clear. If the data is fabricated for demonstration, label it as illustrative rather than implying a benchmark or real measurement.

### A small, self-contained SVG diagram

Save this file as `diagram.html` and open it in a browser. It is static so you can study the structure before connecting it to a video timeline.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Request path</title>
  <style>
    body { margin: 0; background: #0f172a; color: white; font-family: sans-serif; }
    svg { display: block; width: min(90vw, 900px); margin: 5rem auto; }
    .node { fill: #1e293b; stroke: #5eead4; stroke-width: 3; }
    text { fill: #f8fafc; font-size: 24px; text-anchor: middle; }
    .link { stroke: #5eead4; stroke-width: 5; fill: none; }
  </style>
</head>
<body>
  <svg viewBox="0 0 900 300" role="img" aria-labelledby="title desc">
    <title id="title">Simplified request path</title>
    <desc id="desc">A client sends a request through an API to a database.</desc>
    <rect class="node" x="30" y="90" width="200" height="110" rx="18" />
    <rect class="node" x="350" y="90" width="200" height="110" rx="18" />
    <rect class="node" x="670" y="90" width="200" height="110" rx="18" />
    <path class="link" d="M 230 145 H 350" />
    <path class="link" d="M 550 145 H 670" />
    <text x="130" y="153">Client</text>
    <text x="450" y="153">API</text>
    <text x="770" y="153">Database</text>
  </svg>
</body>
</html>
```

`viewBox` gives the SVG its own coordinate system. Each rectangle has a position, width, height and corner radius. The paths draw horizontal lines between the boxes. Because the labels and shapes are vector-based, the browser can rasterize them at the output resolution. A compressed final video is still raster media, so fine lines may soften after encoding.

A common line-drawing effect uses `stroke-dasharray` and `stroke-dashoffset`. For a path of known length 120 units, a dash array of 120 and an offset of 120 hide the line; moving the offset to zero reveals it. For arbitrary paths, compute or define a suitable path length and verify the result. Drive the offset from the frame in Remotion or a registered seekable GSAP timeline in HyperFrames. Do not use a live clock when deterministic frame rendering is required.

The diagram is intentionally generic. It is useful for a simple request flow, but it does not show caching, queues, authentication or retries. Add those only when they are part of the point you are teaching. A complete production architecture diagram in a three-second social clip may be accurate but unreadable.

## 11. Visual depth without building a full 3D world

Many polished graphics look dimensional even though they consist mostly of flat layers. A background gradient, a soft shadow, a slightly tilted card and a slow change in scale can suggest depth. The viewer interprets overlap and relative motion as spatial cues.

A useful layer arrangement is:

- A nearly static dark background with one soft light source.
- A middle layer containing the main device or card.
- A foreground label or small accent.

Move the background less than the subject. Move the foreground slightly more if it does not obscure the content. This relative movement is called parallax. The effect works because closer objects appear to move more across the viewer's field of view as a camera changes position. In a 2D composition it is an approximation; it does not automatically produce geometrically correct depth.

Avoid making every layer move in opposite directions at high speed. The result can feel like the scene is swimming. Also avoid heavy blur behind small text that reduces contrast. A slow two-percent scale change on a background may be sufficient. Render the motion at normal speed: a large visual change that looks subtle while scrubbing can be distracting during playback.

### A conceptual parallax calculation

```js
// Pure math: time in seconds, output positions in pixels.
function layerOffsets(time) {
  const camera = Math.sin(time * 0.5) * 20;
  return {
    background: camera * 0.15,
    subject: camera * 0.5,
    foreground: camera,
  };
}
```

The same virtual camera value drives all layers, scaled by their depth factors. At time zero, all offsets are zero. Later, the foreground moves more than the background. This function is deterministic for a given `time`. It does not animate by itself; your composition must call it using frame-derived or seekable time and apply the returned values to the actual layers.

If a real 3D camera, complex lighting, reflections or objects rotating convincingly in space are essential, a 3D tool or a compatible WebGL pipeline may be a better fit. A 2D parallax treatment is faster for many product videos, but it cannot reveal the unseen side of a real object.

## 12. Transitions: connect ideas, not just scenes

A transition is the change from one scene to another. A direct cut is a transition; it can be clearer than a sophisticated wipe. Choose the transition based on the relationship between scenes:

- **Cut:** a new example or a change in topic. It preserves pace and is easy to time.
- **Fade:** a softer separation, a passage of time or a change in mood.
- **Match movement:** a shared visual element continues from one scene into the next, suggesting continuity.
- **Wipe or mask:** a deliberate reveal that can connect layouts when the direction is meaningful.

Suppose a UI screenshot zooms into a chart, then the next scene shows a larger version of the same chart. Aligning the chart's position and scale across the cut can make the viewer feel that they are moving closer to the same object. This requires matching the visual content and timing. If the chart data changes between the two scenes, the apparent continuity may mislead the viewer.

Transitions consume time. If a 20-second video spends one second on each of six elaborate transitions, six seconds are unavailable for stable content. Often a short, well-timed cut plus a consistent color palette feels more polished than a different effect at every boundary. Watch the edit with the sound muted; if the viewer cannot follow the information without relying on a sound effect, clarify the visual sequence.

## 13. Build a reusable motion system

A **motion system** is a set of shared design decisions: typical entrance duration, easing, travel distance, text hierarchy, colors and rules for hierarchy. It is not a requirement that every scene look identical. Its purpose is to give related videos a recognizable rhythm and make changes predictable.

You can start with a small token object:

```ts
// motionTokens.ts — ordinary TypeScript data.
export const motionTokens = {
  colors: {
    background: "#0f172a",
    surface: "#162538",
    text: "#f8fafc",
    accent: "#5eead4",
  },
  timingSeconds: {
    quick: 0.25,
    entrance: 0.6,
    hold: 1.5,
  },
  distancePixels: {
    subtle: 24,
    entrance: 45,
  },
} as const;
```

The object centralizes values; it does not animate anything by itself. In Remotion, convert a duration in seconds to frames using the composition's FPS, for example `motionTokens.timingSeconds.entrance * fps`. In an HTML/GSAP composition, the same duration can be used in seconds if the project is configured to consume the data. Avoid assuming the two frameworks can import a shared module without build configuration; sharing a design specification or JSON file can be simpler.

Reusable components should expose meaningful controls. A `Reveal` component might accept `start`, `duration` and `children`, as in the earlier example. A lower-third component might accept `name`, `role`, `start` and `duration`. Do not expose every CSS value unless the editor actually needs that flexibility; dozens of unconstrained parameters can make a visual system inconsistent.

At the same time, allow real content to vary. Test long names, large numbers and different line lengths. A component that looks great only for the sample text is not yet a dependable template. Provide reasonable wrapping, measure rendered text when necessary, and verify that a title remains in the safe area during its entrance and exit.

## 14. Code blocks and developer-focused visuals

Developer videos often show code, terminal output or architecture diagrams. The goal is to make the important line visible, not to fill the screen with as much code as possible. Choose a short realistic snippet, enlarge it, and highlight only the relevant operation. Explain surrounding context in narration or in a separate shot.

For example, if the topic is a database query, show the query first, then its simplified lookup diagram. Avoid inventing measured query times or presenting a fictional execution plan as output from a real database. If you do use real metrics, include the environment and conditions needed to interpret them; a colorful chart cannot make unsupported numbers trustworthy.

A code reveal can animate a highlight over a line, but avoid changing the code as a decorative effect if the viewer is trying to read it. Keep syntax highlighting consistent and contrast strong. A slow cursor movement to the highlighted line, followed by a hold, often communicates more than a fast typing simulation. If simulated typing is used, make sure the final code is correct and give viewers time to read it after the animation finishes.

When showing a terminal, use test data and remove private paths, credentials and customer information. Capture a clean recording rather than assuming a blur overlay will always hide sensitive information in every frame. If you replace real output with representative sample output, identify it as an example where the distinction matters.

## 15. Agent direction: ask for visual intent and evidence

An agent can implement CSS, React or GSAP quickly. It cannot infer your exact design taste, the factual accuracy of unseen source material, or whether a generated video looks good on your phone unless it has the relevant context and actual inspection capability. Give it a clear visual hierarchy and ask it to report what it tested.

### Claude Code prompt: create a reusable motion kit

```text
Inspect this Remotion project and use its existing conventions. Build three
editable components for a 9:16 developer explainer: an eased title reveal,
a UI callout, and an outro card. Use a restrained dark palette and one teal
accent. Keep all text editable and provide sensible defaults.

First create a still style frame and explain the layout. Then add motion:
title enters over 0.6 seconds, holds, and the callout appears after it.
Avoid wall-clock timing and external assets. Render a draft, inspect the
first, middle and final frames plus scene boundaries, and fix overlaps.
Explain each component's props and give an example of changing the timing.
If you cannot render or inspect the video, say so explicitly.
```

This asks for a design stage, a limited component set and verification. It avoids demanding an invented “viral” effect. Once you see the draft, give specific feedback: “The heading wraps onto three lines at phone size; reduce the words and preserve the type size,” or “the callout overlaps captions from 00:06 to 00:08.”

### Codex prompt: explain and improve a scene

```text
Read the existing IndexScene composition. Explain how its frame values
produce the title entrance and diagram reveal. Then add a simple animated
line connecting the two diagram labels, starting at 2 seconds and finishing
at 2.7 seconds. Keep the text and layout stable, and use the existing FPS
rather than hard-coding 30 in the animation math.

Render a preview and compare frames at the beginning, midpoint and end of
the line animation. Report the exact files changed and any validation you
could not run. Do not add new libraries or call paid APIs.
```

This prompt requires the agent to read the existing project before changing it. The request to avoid hard-coded FPS makes the component more portable. A useful follow-up asks the agent to explain why the line holds its final state after the animation, which should lead back to clamping.

### Review generated code as a developer

Read the file paths and component props. Check whether the agent used a stable time source and whether external fonts or assets are fetched at render time. Look for hard-coded dimensions that make a vertical composition overflow, and verify that a component's `start` values refer to the correct local or parent timeline. If the project has a `Sequence`, remember that frame values inside it may be shifted relative to the parent. The agent should explain the specific timing model used in the project rather than offering a generic claim.

Inspect the exported video yourself. A model's description of a render is not evidence of its appearance if no render or visual inspection happened. When an agent does perform a render, ask which frames were inspected, and review the full playback because a set of stills can miss unpleasant motion between them.

## 16. Common failures and practical fixes

| What you observe | What may be happening | A useful first revision |
| --- | --- | --- |
| Everything moves at once | No visual hierarchy or stagger | Make the background still and animate one important item at a time |
| Text is hard to read | Type too small, low contrast, short hold or overlay collision | Enlarge the text, shorten copy, lengthen the hold and inspect on a phone |
| A card feels abrupt | Linear start/stop, excessive travel or a sudden opacity change | Reduce travel and test a gentle ease-out |
| A title looks energetic but unclear | Per-letter movement competes with reading | Animate whole lines or words, then hold |
| UI callout points to the wrong place | Crop or scaling changed its coordinate system | Map the target coordinates through the displayed crop and retest |
| Line or label clips | Mask, parent overflow, wrong bounding box or edge safe area | Inspect the static end frame and add space around the element |
| Diagram looks authoritative but misleads | Oversimplified labels or invented values | Add context, label illustrative data, or use verified sources |
| Preview and render differ | Wall-clock timing, randomness, missing assets or fonts | Replace time source with frame-derived values; verify asset readiness |
| Reusable template breaks with longer copy | Fixed size or no wrapping strategy | Test real content variants and redesign the layout for the longest case |

Diagnose visual problems with a still frame as well as playback. If the static layout is already cramped, changing the easing will not fix it. If the static frame is strong but the animation feels wrong, inspect entrance duration, travel and the order in which elements attract attention.

## 17. Optional application: a developer-brand motion kit

Create a small kit around a single visual concept. Use a dark blue background, a light neutral text color, and one accent; change the palette if another choice better represents your brand. Design these four pieces:

1. A three-second opening title with a clear headline and a calm entrance.
2. A reusable label that can identify an app feature or a technical concept.
3. A diagram card showing a simple relationship, such as “request → API → response.”
4. An outro card with one specific call to action, such as a prompt to visit your project page.

Make a static style frame for each before animating. Decide which element enters first and where the viewer should look after it settles. Use a single timing and color token file if you are working in code. Render a draft and inspect it in portrait orientation on a phone. Take notes on readability and the relationship between narration and each visual, then revise only the largest issue in the next version.

If you post the video, its success depends on the topic, audience, distribution and many factors beyond the graphics. The kit can make your production more consistent and understandable; it cannot guarantee engagement.

## References and where to go next

- [Remotion animation and interpolation](https://www.remotion.dev/docs/interpolate) and [API reference](https://www.remotion.dev/docs/api).
- [HyperFrames GSAP animation guide](https://hyperframes.app/docs/3-guides/3-gsap-animation) and [HTML schema](https://hyperframes.app/docs/6-reference/html-schema).
- [MDN SVG tutorial](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorials/SVG_from_scratch) and [CSS transforms](https://developer.mozilla.org/en-US/docs/Web/CSS/transform).

The next lesson adds generative image and video assets to this vocabulary. The same principle remains: use generated footage where it supports the visual story, and keep exact labels, code and UI elements in layers you can verify and edit.
