# Lesson 3: Animation Principles from First Principles

A static image tells your viewer what exists. Animation adds another dimension: it tells them what changed, when it changed, and what they should notice first. In a software explainer, this added dimension is valuable because an idea usually has an order. A database receives a query, examines an index, finds a location, and returns a row. If all four concepts appear at once, the viewer must infer the order. If the animation introduces one relationship at a time, the movement itself helps explain it.

This lesson develops the mechanics of animation slowly, beginning with the individual frame. It then connects those mechanics to motion design decisions: easing, emphasis, sequencing, readability, and visual depth. We will use a standalone browser example, so you can inspect the complete process without setting up a video framework first. Later, you can apply the same ideas in Remotion and HyperFrames even though those tools expose time differently.

By the end, you should be able to describe a movement as a function of time, choose sensible timings, recognize common mistakes, and direct an AI coding agent with more precision than “make it look cool.”

## 1. What animation actually is

A video is a sequence of still images displayed in rapid succession. Each still image is a **frame**. A moving circle is therefore not one circle physically traveling across a monitor. It is a succession of images in which the circle appears at slightly different positions.

At 30 frames per second, or **30 fps**, one second of video consists of 30 frames. A ten-second composition has:

```text
30 frames/second × 10 seconds = 300 frames
```

If frames are numbered starting at zero, their indices are 0 through 299. The time associated with frame `f` at a frame rate `fps` is:

```text
time in seconds = frame / fps
```

For example, frame 15 at 30 fps corresponds to 0.5 seconds. The frame is sampled at that point in time. A 300-frame clip at 30 fps occupies 10 seconds of playback even though the last sampled frame starts at 299/30 seconds, just before 10 seconds.

This matters when your agent says that a title should finish moving “at frame 30.” At 30 fps that is one second; at 60 fps it is only half a second. It is often easier to think in seconds and convert to frames for an API that requires frame counts:

```js
const fps = 30;
const entranceSeconds = 0.8;
const entranceFrames = Math.round(entranceSeconds * fps); // 24
```

The rounding is necessary because a frame index is an integer. Some durations will not map to a whole number of frames. For instance, 0.75 seconds at 30 fps is 22.5 frames, so a system must choose a nearby frame or represent the timeline in finer units and sample it later.

### Frame rate and perceived smoothness

A higher frame rate provides more samples per second. When motion is sufficiently different from one frame to the next, additional samples can make it appear smoother. However, higher frame rate does not automatically improve design. A badly timed animation remains badly timed at 60 fps. More frames may also increase rendering and encoding work.

Your target platform, the source footage, and the nature of the content influence the frame rate you choose. A project with 30 fps screen recordings often works naturally at 30 fps. If you must change frame rates, inspect fast motion, cursor movements, and panning footage in the final export; conversion may duplicate, drop, or synthesize frames depending on the workflow.

### Duration, frames, and storage are different concepts

A resolution such as 1080 × 1920 describes the size of each frame. A frame rate describes how often frames are displayed. Duration describes how long the sequence plays. An encoder and its settings affect how much disk space that sequence occupies. Increasing resolution or frame rate generally increases the amount of visual information to process, but file size cannot be inferred from those numbers alone because the codec and compression settings matter.

A browser preview may skip frames when the machine cannot draw quickly enough. An offline renderer can instead compute frames one by one, taking longer than the finished video duration. The exported video may play smoothly even if its production was slower than real time. The opposite is also possible: a smooth-looking preview does not prove that exported fonts, assets, audio, or timing are correct. Always inspect the actual export.

## 2. An animation is a value that changes over time

Consider a title that starts at horizontal coordinate 100 and ends at 500. We can describe it using a function:

```text
horizontal position = a function of time
```

At the start, that function returns 100. At the end, it returns 500. At intermediate times, it returns positions between those values. This is the central idea behind most motion graphics. The value can represent nearly anything:

- `x` and `y` position;
- rotation in degrees;
- scale, where 1 means the original size;
- opacity, usually between 0 and 1;
- blur radius;
- a color or a gradient stop;
- the amount of a path revealed;
- a camera position or a chart value.

The time-to-value function can be visualized as a curve. A straight line means a value changes at a constant rate. A curved line means the rate changes over time. Easing is the deliberate choice of that curve.

The function model is especially useful with programmatic video. A renderer can ask, “What should the frame at 2.4 seconds look like?” Each element computes its appearance from that time. It does not need to watch every previous frame being played.

## 3. Keyframes and interpolation

A **keyframe** specifies a value at a particular point in time. For a simple entrance, we could say:

| Time | Title x position | Opacity |
| --- | ---: | ---: |
| 0.0 s | 100 px | 0 |
| 1.0 s | 500 px | 1 |

The animation system fills the time between those keyframes. That filling process is called **interpolation**. For linear interpolation, first calculate how far we are through the interval:

```text
progress = (currentTime - startTime) / (endTime - startTime)
```

Then interpolate between the start and end values:

```text
value = startValue + (endValue - startValue) × progress
```

At 0.25 seconds of a one-second animation, progress is 0.25. The position is `100 + (500 - 100) × 0.25`, or 200 px. Opacity is `0 + (1 - 0) × 0.25`, or 0.25.

The formula has an important limitation: before the start or after the end, progress would be outside the intended 0–1 range. At two seconds, for example, progress would be 2 and the title would travel beyond its destination. **Clamping** restricts a value to a range:

```js
function clamp(value, minimum, maximum) {
  return Math.min(maximum, Math.max(minimum, value));
}

function progressBetween(time, start, end) {
  if (end <= start) {
    throw new Error('The end time must be later than the start time.');
  }
  return clamp((time - start) / (end - start), 0, 1);
}

function lerp(startValue, endValue, progress) {
  return startValue + (endValue - startValue) * progress;
}

const p = progressBetween(0.25, 0, 1);
console.log(lerp(100, 500, p)); // 200
```

`lerp` is short for linear interpolation. The function itself does not know about pixels, seconds, or opacity. It just maps a progress value onto a numerical interval. The meaning comes from how you use the result.

Clamping and interpolation are often built into animation libraries, but understanding the underlying calculation helps you recognize why a title jumps, disappears, or continues moving when it should stop. In a code review, find the time interval, the progress calculation, and the output interval. Those three pieces explain most basic animation behavior.

### An interval has boundaries

Suppose an element appears from frame 30 through frame 59. That is 30 frames if the end is exclusive: `[30, 60)`. At 30 fps, it occupies one second. Libraries differ in how they express ranges, and a sequence's duration is often easier to reason about than an inclusive last-frame number. When a transition flashes or a gap appears, inspect whether adjacent intervals overlap or leave an unrendered frame.

Do not assume every library's `Sequence`, timeline, or trimming operation uses identical boundary conventions. Read its documentation and check the exported boundary frames when exact cuts matter.

## 4. Easing: changing the rate of change

Linear interpolation is mathematically simple but can feel mechanical. A physical object often accelerates, decelerates, or settles; a viewer's attention also benefits from a clear arrival rather than a sudden stop. An **easing function** transforms linear progress into a different progress value.

For example, a simple ease-out function is:

```js
function easeOutQuad(progress) {
  return 1 - (1 - progress) ** 2;
}
```

It starts quickly and slows as it approaches the destination. At `progress = 0.5`, the eased value is 0.75, so the element has completed 75% of its distance halfway through the allotted time. It covers a lot of distance early and spends the rest of the interval settling.

Compare three approaches:

```js
function linear(p) {
  return p;
}

function easeInQuad(p) {
  return p * p;
}

function easeOutQuad(p) {
  return 1 - (1 - p) * (1 - p);
}
```

An ease-in starts slowly and accelerates. An ease-out starts quickly and slows. An ease-in-out combines both behaviors. A practical convention is to let an entering title ease out into its resting position: it arrives decisively, then becomes still enough to read. A departing title can ease in as it accelerates away. These are conventions, not rules. The message, style, and available time decide what feels right.

Easing maps the input range to a new progress curve. You still interpolate the actual property afterward:

```js
const progress = progressBetween(currentTime, 0, 0.8);
const easedProgress = easeOutQuad(progress);
const x = lerp(-80, 0, easedProgress);
```

This separation is powerful. You can use the same easing function for position, scale, and opacity, or use different curves for different properties. For example, opacity may reach 1 before the position has completely settled. That can make the words readable while their movement finishes.

### Avoid mistaking “more motion” for “better motion”

A very bouncy entrance can fit a playful consumer app, but it may undermine a careful explanation of query execution. Large elastic movements draw attention to themselves and consume time. Use the smallest movement that communicates the intended change. You can always make motion more expressive after the content is understandable.

## 5. Springs, overshoot, and settling

Many animation systems offer a **spring** model. Rather than manually selecting every point on a curve, you supply parameters that influence how an imagined spring moves toward a target. A spring can overshoot, reverse, and settle. In practical terms, it is useful for a card popping into place or a small notification attracting attention.

The important controls vary by library, but they commonly relate to stiffness, damping, and mass. As an intuition, stronger restoring force tends to pull an element toward its target more quickly, while more damping tends to reduce oscillation. Exact formulas, units, defaults, and resulting durations depend on the implementation; consult the specific API rather than transferring parameter values blindly between libraries.

**Overshoot** means the animated value passes its target before returning. If a title's desired x position is 0, its path might briefly reach +8 px and then settle back to 0. **Settling** is the period during which the motion becomes small enough to appear stationary. If the title's entire display lasts only one second, a spring that settles in 1.5 seconds never gets a clean reading hold. Inspect the actual duration rather than assuming a spring finishes when it first crosses the target.

Do not overshoot every property. Opacity is usually constrained to a valid range, and excessive scale overshoot can move text outside its container. A subtle position overshoot paired with a simple fade can provide life without sacrificing legibility.

## 6. Anticipation, holds, and follow-through

Animation principles describe not only mathematical curves but the information conveyed by motion.

**Anticipation** is a small preparatory movement before the main action. A card might shift slightly backward before moving forward. In an instructional video, anticipation can signal that something important is about to happen, but it must remain short enough not to delay the explanation.

A **hold** is a period of visual stability. If a sentence appears and immediately exits, the viewer has no time to read it. Holds are especially important for technical diagrams: show the relationship, let the viewer inspect it, and only then introduce the next change. Voiceover and captions also compete for attention, so a dense graphic may need a longer hold than a simple icon.

**Follow-through** occurs when a secondary element continues moving briefly after the main element has stopped. A small shadow or decorative accent can settle after a card arrives. The design should still make the primary information feel stable. Avoid applying follow-through to text if it makes reading difficult.

A common structure for a single scene is:

```text
Entrance → readable hold → meaningful change → second hold → exit or cut
```

The sequence makes an argument through time. The first hold establishes the scene; the meaningful change explains an event; the second hold gives the audience a chance to absorb the outcome.

## 7. Position and the coordinate system

In a typical browser coordinate system, the origin `(0, 0)` is at the top-left of the relevant coordinate space. Increasing `x` moves right; increasing `y` moves down. That means a value of `y = -40` can position an element 40 pixels above its original position when used in a translation.

A browser element can have a layout position and then a visual transform applied on top. For example, a card might be centered by its parent layout and translated 40 pixels downward for its entrance:

```css
.card {
  transform: translateY(40px);
}
```

When it reaches `translateY(0)`, it returns to the position determined by layout. This distinction matters. If you try to animate both the layout and a transform without understanding how they combine, an element can appear to move unpredictably.

The relevant coordinate space depends on the property and containment. An absolutely positioned element is positioned relative to its containing block; a transformed child is transformed relative to its own geometry and transform origin. Nested transforms compound. A parent scaled to 0.5 also scales the apparent movement of its child. When debugging, temporarily remove parent transforms to isolate the issue.

### Scale and transform origin

`scale(1)` is the original size; `scale(0.9)` is 90% of that size. By default, a CSS transform usually uses the element's center as its origin. If a bar chart should grow upward from its base, setting `transform-origin: bottom` makes more sense than scaling from the center:

```css
.bar {
  transform-origin: bottom;
  transform: scaleY(0.5);
}
```

A rotation also happens around the transform origin. A door rotating around its center looks different from a door rotating around its hinge. Use origin intentionally when animating charts, pointers, and UI panels.

### Transform order matters

Transform operations compose, and changing their order can produce a different result. A rotated coordinate system affects the apparent direction of subsequent operations. Keep a predictable transform structure, and if an animation needs independently controlled movement and rotation, place the element inside a wrapper: translate the outer wrapper and rotate the inner element. That makes the intent easier to inspect.

## 8. Stagger and visual hierarchy

A **stagger** delays a set of similar animations so that they begin one after another. If three cards each enter over 0.5 seconds and the stagger is 0.15 seconds, the second begins 0.15 seconds after the first, and the third begins 0.30 seconds after the first. Their animations overlap.

```js
const cardStart = sceneStart + cardIndex * 0.15;
const cardProgress = progressBetween(time, cardStart, cardStart + 0.5);
```

Stagger can communicate order or help the eye follow a group. It can also waste time: a list of twelve items with a long stagger may take too long to appear. For large groups, shorten the delay, reveal groups, or display all items at once and animate only the item being discussed. An entrance effect is not automatically a meaningful explanation.

Visual hierarchy asks which element should receive attention first, second, and third. Size, contrast, position, movement, and narration all contribute. If a flashing background and a tiny explanatory label compete, the movement is working against the content. Start with a clear static composition, then add motion to strengthen the hierarchy that already exists.

A useful pattern for technical videos is **context → focus → relationship**. First establish the full system. Next emphasize the component being discussed. Finally animate the connection or data flow. Do not remove context so aggressively that the viewer forgets where the highlighted component belongs.

## 9. A complete frame-driven browser experiment

The following example contains all HTML, CSS, and JavaScript in one file. Save it as `animation-lab.html` and open it in a modern browser. No package installation is required. The slider represents time in a three-second scene. Moving it calculates the appearance of the title and diagram for that exact time.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Frame-driven animation lab</title>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      padding: 24px;
      background: #101727;
      color: #f5f7ff;
      font-family: system-ui, sans-serif;
    }
    .stage {
      position: relative;
      width: min(100%, 720px);
      aspect-ratio: 16 / 9;
      overflow: hidden;
      background: linear-gradient(135deg, #17264b, #172b32);
      border-radius: 20px;
    }
    .title {
      position: absolute;
      left: 8%;
      top: 12%;
      margin: 0;
      font-size: clamp(24px, 5vw, 44px);
    }
    .row {
      position: absolute;
      left: 8%;
      right: 8%;
      top: 47%;
      display: flex;
      justify-content: space-between;
      gap: 8px;
    }
    .card {
      width: 30%;
      padding: 18px 8px;
      text-align: center;
      background: #234453;
      border: 1px solid #70e1c1;
      border-radius: 12px;
    }
    .controls { margin-top: 18px; max-width: 720px; }
    input { width: 100%; }
  </style>
</head>
<body>
  <main>
    <div class="stage" aria-label="Three animated database concepts">
      <h1 class="title" id="title">Find the right row</h1>
      <div class="row">
        <div class="card">Query</div>
        <div class="card">Index</div>
        <div class="card">Row</div>
      </div>
    </div>
    <div class="controls">
      <label for="time">Scene time: <output id="timeLabel">0.00 s</output></label>
      <input id="time" type="range" min="0" max="3" step="0.01" value="0" />
      <button id="play" type="button">Play from start</button>
    </div>
  </main>
  <script>
    const slider = document.getElementById('time');
    const label = document.getElementById('timeLabel');
    const title = document.getElementById('title');
    const cards = [...document.querySelectorAll('.card')];
    const playButton = document.getElementById('play');
    const duration = 3;
    let playbackRequest = null;

    function clamp(value, min, max) {
      return Math.min(max, Math.max(min, value));
    }
    function progress(time, start, end) {
      return clamp((time - start) / (end - start), 0, 1);
    }
    function easeOut(p) {
      return 1 - (1 - p) ** 2;
    }
    function lerp(start, end, p) {
      return start + (end - start) * p;
    }
    function render(time) {
      const titleProgress = easeOut(progress(time, 0, 0.7));
      title.style.opacity = String(titleProgress);
      title.style.transform = `translateY(${lerp(32, 0, titleProgress)}px)`;

      cards.forEach((card, index) => {
        const start = 0.55 + index * 0.22;
        const cardProgress = easeOut(progress(time, start, start + 0.5));
        card.style.opacity = String(cardProgress);
        card.style.transform = `translateY(${lerp(26, 0, cardProgress)}px)`;
      });
      label.value = `${time.toFixed(2)} s`;
      slider.value = String(time);
    }
    slider.addEventListener('input', () => {
      cancelAnimationFrame(playbackRequest);
      render(Number(slider.value));
    });
    playButton.addEventListener('click', () => {
      cancelAnimationFrame(playbackRequest);
      let startTimestamp;
      function tick(timestamp) {
        if (startTimestamp === undefined) startTimestamp = timestamp;
        const elapsed = Math.min((timestamp - startTimestamp) / 1000, duration);
        render(elapsed);
        if (elapsed < duration) playbackRequest = requestAnimationFrame(tick);
      }
      playbackRequest = requestAnimationFrame(tick);
    });
    render(0);
  </script>
</body>
</html>
```

### Reading the example

The `render(time)` function owns the visual state. It calculates the title's progress from 0 to 0.7 seconds, applies an ease-out curve, and maps that result to opacity and vertical position. The cards use the same approach, with a different starting time for each index. Because `render` derives every value from `time`, you can drag the slider backward and forward and obtain the same state for the same input.

`requestAnimationFrame` is used only to drive the interactive preview's clock. It asks the browser to call `tick` as it paints. The visual state still comes from the `render(time)` function. A programmatic video renderer should instead call an equivalent rendering function with its requested frame or timestamp; do not assume an unsynchronized real-time loop will be captured reliably.

Notice also that the example does not claim to be a finished video exporter. It demonstrates animation logic in a browser. Remotion and HyperFrames provide their own composition, timeline, and render mechanisms, which the later lessons cover.

### Changing the experiment

To compare easing, replace `easeOut(progress(...))` with `progress(...)` for the title. The same duration and endpoints now produce a constant-speed move. The title travels evenly and stops abruptly. Restore easing and compare how it settles.

To increase the stagger, change `index * 0.22` to `index * 0.4`. The third card now starts later. If the scene ends before the final card has a readable hold, either increase the total scene length or reduce the stagger. This demonstrates that timing choices are coupled: changing one beat can affect everything that follows.

To make the entrance less conspicuous, change the starting translation from 26 pixels to 12 pixels. The cards still establish order, but the movement claims less attention. This is often an effective first refinement for instructional content.

## 10. Timing motion to a script

Imagine this narration:

> “An index gives the database a faster way to locate matching rows.”

A possible scene plan is:

| Time | Audio | Visual |
| --- | --- | --- |
| 0.0–1.0 s | “An index…” | Show a table and a separate index label. |
| 1.0–2.5 s | “…gives the database a faster way…” | Highlight a path through the index. |
| 2.5–4.0 s | “…to locate matching rows.” | Reveal the corresponding row and hold. |

These are illustrative timings. Record the actual voiceover and adjust to the speaker's pauses and delivery. Do not assume that a screen action must align with the exact beginning of every spoken word. Sometimes a visual slightly before the phrase prepares the viewer; sometimes a visual after the phrase confirms it. The relationship should feel intentional and preserve comprehension.

The wording is also a simplified conceptual explanation, not a claim that every query becomes faster or that every database uses the same index design. A production lesson or explainer should give appropriate technical context and avoid inventing performance numbers.

### Build a timing table

A simple JavaScript timing table can make your intent explicit:

```js
const fps = 30;
const scenes = [
  { name: 'context', startSeconds: 0, durationSeconds: 1.2 },
  { name: 'index-path', startSeconds: 1.2, durationSeconds: 1.6 },
  { name: 'result', startSeconds: 2.8, durationSeconds: 1.2 },
];

for (const scene of scenes) {
  const startFrame = Math.round(scene.startSeconds * fps);
  const durationFrames = Math.round(scene.durationSeconds * fps);
  console.log(scene.name, { startFrame, durationFrames });
}
```

This is a planning aid, not a framework-specific sequence declaration. If independently rounded start times and durations must align exactly, compute boundaries once and derive each duration from adjacent boundary frames. That avoids accumulating rounding discrepancies.

## 11. Two dimensions, faux depth, and camera language

A flat composition can suggest depth without becoming a 3D scene. Place a foreground card over a background, scale the background more slowly, add a subtle shadow, and use a small amount of blur on distant decorative elements. This is often called **faux 3D** because the viewer perceives depth even though the elements may simply be 2D layers.

**Parallax** is the apparent difference in movement between layers at different depths. In a controlled 2D composition, you can move the foreground slightly faster than the background. The visual implies that the layers occupy different distances. Excessive parallax, however, can cause the viewer to lose track of text and diagrams.

A **push-in** can be simulated by slowly scaling a group around a focal point. A **pan** can be simulated by translating a larger composition within a fixed viewport. Remember that scaling a parent scales its children, including text. If text becomes too large, clipped, or blurry, consider animating separate layers or rendering at an appropriate resolution.

Real 3D tools provide actual cameras, depth, perspective, lighting, and occlusion, but they introduce additional complexity. Use a 3D renderer when its control is needed for the idea; a subtle 2D transform may be sufficient for a product card or chart.

## 12. Determinism and reproducible frames

A composition is deterministic when the same inputs produce the same output. In video rendering, the goal is that asking for frame 100 twice yields the same visual result. Determinism supports parallel rendering, seeking, repeatable debugging, and reliable comparison.

Problematic sources of nondeterminism include:

- using the current wall-clock time to select an animation state;
- calling unseeded randomness every time a component renders;
- relying on a CSS animation or requestAnimationFrame loop that is not synchronized with the renderer;
- loading changing network data while frames are captured;
- using asynchronous fonts or images without ensuring they are ready;
- relying on accumulated physics state without a reproducible method to compute the requested point.

For example, `Math.random()` inside a render function may give a particle a new location whenever the renderer evaluates the frame. It will flicker rather than move smoothly. Generate fixed particle parameters from a seed, or define the particle's position as a stable function of frame and particle index. Whether a particular framework supports a seeded random helper is version-specific; consult its documentation.

A simple deterministic motion function is:

```js
function particleX(frame, fps, initialX, pixelsPerSecond) {
  const seconds = frame / fps;
  return initialX + seconds * pixelsPerSecond;
}

console.log(particleX(60, 30, 100, 25)); // 150
```

Given the same inputs, this always returns the same result. Real projects may also wrap a position, use easing, or fade a particle in and out; the principle remains the same.

Determinism does not guarantee that every platform produces bit-identical pixels. Fonts, browser versions, codecs, GPU behavior and environment differences can still matter. It does mean your own animation is not arbitrarily changing because it depends on an uncontrolled clock or random draw.

## 13. Motion accessibility and practical viewing

Strong flashes, rapid flicker, continuous shaking, and large unexpected movements can make a video uncomfortable or inaccessible. Favor clear transitions, avoid unnecessary flashing, and provide accessible captions. If your delivery is an interactive player with a reduced-motion option, design an alternative that communicates the same information with less movement; exported video itself may require a separate reduced-motion version.

Readability also depends on how long text stays visible. Test on a phone at a normal viewing distance and with sound off. Captions, platform controls, and the creator's interface may cover portions of the frame; safe areas depend on the platform and placement, so verify the current player rather than relying on a universal fixed margin.

## 14. Troubleshooting common failures

| Symptom | Likely cause | How to investigate |
| --- | --- | --- |
| A title flies past its destination | Progress extrapolates beyond 1 | Inspect and clamp the input interval. |
| An object jumps at the scene boundary | Different coordinates or an off-by-one boundary | Compare the last frame before the cut and first frame after it. |
| Text appears but is unreadable | Too little hold time, small size, or low contrast | Pause the exported frame at phone size; simplify and hold longer. |
| Movement changes on each render | Randomness, current time, or asynchronous inputs | Replace uncontrolled inputs with fixed parameters and frame-driven calculations. |
| A scene feels busy | Too many simultaneous changes | Freeze nonessential layers and animate the explanatory relationship. |
| An element clips while scaling | Its bounds exceed an `overflow: hidden` container | Inspect the transformed bounds and the parent viewport. |
| Preview and export differ | Unsynchronized motion, missing assets or fonts, environment changes | Inspect exported frames and renderer logs; ensure assets are ready. |

When debugging, isolate one animated property at a time. Fix the starting and ending values, then inspect the progress calculation, then the easing function, and finally the layering. This sequence is more reliable than changing all parameters at once.

## 15. Directing Claude Code and Codex

The following prompts assume you have an existing local project and have chosen a renderer. Adjust them to your actual environment and tools; an agent should inspect the repository and applicable documentation before making version-specific changes.

### Claude Code: explain and improve a title entrance

```text
Inspect this video project and identify the code that controls the title
entrance. Explain the current frame or time calculation, start and end values,
easing, and duration in plain language. Then change only the title so it enters
from 24 pixels below over 0.7 seconds, settles without overshoot, and remains
fully readable for at least 1.5 seconds. Preserve the project's existing FPS.
Render or capture representative start, middle, settled, and exit frames using
the project's supported workflow. Report what you verified and any limitations.
```

The prompt supplies measurable requirements, but allows the agent to choose the library-specific implementation. “Without overshoot” refers to the value not passing its target. The readability requirement concerns both the timing and the design; a tool cannot prove readability merely by computing duration.

### Codex: animate a relationship

```text
In this repository, animate a three-node diagram explaining query → index →
row. First inspect the existing composition and its documentation. Preserve
the current layout and color palette. Reveal each node in order with a short
stagger, then highlight the connecting path in the order of the narration.
Use deterministic frame- or timeline-driven animation; do not use uncontrolled
randomness or a wall-clock timer for exported motion. Show me the timing table,
code changes, and rendered frames at the scene boundaries and midpoint. Do not
invent a benchmark or claim every query uses an index.
```

To refine either agent's work, give observable feedback: “At 2.3 seconds, the index label overlaps the path. Move the path below the label and slow its reveal by 0.2 seconds.” Ask the agent to inspect the new output after changing it. Treat generated code and a successful render as drafts that still need visual review.

## 16. A complete mini-project plan

Create a six-second animation in which a database query reaches an index and then points to a row. Start with a static scene containing three legible cards. At time 0, show the query card. Introduce the index card shortly afterward. Draw or reveal the connecting line. Then reveal the result card and highlight it. Hold the final arrangement so the viewer can understand the relationship.

The simplest version needs only position, opacity, and a line reveal. Add a small ease-out to the card entrances. Use color to identify the active step, but retain text labels so that meaning does not depend on color alone. If the animation looks cramped, increase spacing or simplify the cards before reducing font size.

Check these points in the exported video: the first visible frame, the first fully readable frame, each point where one element hands off to another, and the final hold. Watch once with sound and once without. If you cannot understand the relationship without reading your original plan, make the relationship more explicit rather than adding decoration.

For later work, keep the timing values together in a small configuration object. Give values meaningful names such as `indexRevealStart` and `resultHoldDuration`. This makes revisions easier than searching for unexplained numbers across many components.

## Where this leads

You now have a practical model: a video is sampled in frames; each animated property is calculated for a time; interpolation connects values; easing changes the rate; and design choices determine which changes deserve attention. The next lesson supplies the HTML, CSS, JavaScript, SVG, and React foundations needed to implement these ideas in code-based video tools. Keep this lesson's browser experiment as a small laboratory whenever an easing or timing decision feels abstract.
