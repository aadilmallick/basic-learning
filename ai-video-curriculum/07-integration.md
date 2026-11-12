# Lesson 7 — Combining Remotion and HyperFrames

## What you will learn

A good video project does not need to commit every visual element to the same tool. You might inherit an animated React title built in Remotion while the rest of the video is maintained as HTML and GSAP in HyperFrames. Or you might already have a stable HyperFrames composition and want to reuse it in a Remotion-based product. The practical question is how to move work across that boundary without accidentally changing its appearance or overstating what can still be edited.

By the end of this lesson you should be able to choose among three integration strategies, explain what each preserves, render an existing Remotion composition as a media file, plan a native translation, and check whether the result actually matches the source. You will also understand why a video can look right in one preview and wrong after export, and how to give Claude Code or Codex a bounded, verifiable integration task.

The examples assume you have studied the preceding Remotion and HyperFrames lessons. You should know what a composition, frame, FPS and GSAP timeline are. If any term is unfamiliar, the relevant ideas are repeated below in the context needed for integration. Commands and library conventions are based on the linked documentation as of November 2026; inspect the documentation for the installed versions before relying on an exact flag or API.

## 1. Begin with the problem: two systems, one final picture

Imagine a 20-second product explainer. A designer has already built a beautiful two-second title animation in Remotion. The rest of the production team has built the other 18 seconds in HyperFrames and wants to assemble the complete video there. You have three plausible paths:

1. Render the Remotion title to a video and add that video as a clip in HyperFrames.
2. Recreate the title using native HTML, CSS and GSAP that HyperFrames can directly edit and seek.
3. If the source uses a suitable supported browser runtime, keep that runtime and adapt it to the destination's clock.

These are not equivalent. The first preserves the appearance as a sequence of pixels but hides the original elements inside those pixels. The second exposes the elements again, but requires a translation and visual comparison. The third can preserve complex rendering code but only when that code can be asked to draw a particular time reliably and has an appropriate integration adapter.

The key distinction is the **boundary** between systems. Think of a layered design file exported as a PNG. The PNG preserves what the picture looks like but does not keep its editable text layers. Video handoff behaves similarly, except that the exported file contains a sequence of frames plus optional audio. Moving pixels between programs is easy. Moving editable meaning, such as a title component, an animation curve, a font choice and the source timing, takes more work.

Remotion and HyperFrames are alternatives, not a required two-stage stack. If your team can create and edit the whole project comfortably in one, adding the second creates a new render, debugging and compatibility boundary. Integration makes sense when you have reusable existing material, a genuine editing need, or a specific capability that warrants it.

## 2. Compare the integration levels

| Strategy | What moves | What remains editable downstream | Best reason to use it | Main cost |
| --- | --- | --- | --- | --- |
| Media handoff | A rendered MP4, WebM, MOV or frame sequence | Placement, trim, scale and other outer clip properties; not individual pixels | Reuse a stable result quickly | Internal text, layers and motion are baked in |
| Native translation | The design and animation are rewritten as destination-native elements and timelines | Translated elements and exposed parameters | The downstream team needs to change copy or timing | Translation work and visual differences |
| Hosted runtime | Compatible code runs inside a destination-managed time model | Position, timing and deliberately exposed controls; details depend on adapter | Preserve complex existing drawing code | Integration constraints and careful frame-seeking verification |

The official [HyperFrames migration skill](https://github.com/heygen-com/hyperframes/blob/main/skills/remotion-to-hyperframes/SKILL.md) describes these as media, native and hosted levels. It lists important blockers for direct native translation, including certain React state/effect patterns, asynchronous metadata, and some UI-kit dependencies. A blocker does not mean the original component is badly written; it means that a direct source-to-source conversion cannot safely preserve its behavior under that workflow.

A hosted runtime is not a promise that any React or Remotion app can be embedded unchanged. The runtime must be supported or adapted, must be ready when frames are captured, and must be able to draw the requested time consistently. Follow the current runtime and migration documentation rather than inventing a generic `embedRemotion()` API. When those conditions cannot be met, rendering to media is usually the safest baseline.

### A decision procedure

Start by asking: **Which future edit must the downstream editor be able to make?** If the answer is “only move the title to an earlier point,” media is often sufficient. If the answer is “change the presenter's name every week,” baking the name into a file may be awkward. Native translation or moving that name into a separate editable overlay would be more useful.

Next ask whether the original visual already exists and passes review. A stable, approved lower third often deserves a media handoff. If the design changes daily and both teams own the code, a translation may repay its initial cost. For a complex WebGL scene with an existing seek adapter, hosted integration might preserve more of the original while allowing composition around it. It is still necessary to compare rendered frames.

Finally, account for maintenance. If the source and translated copy evolve independently, they can drift. The team must decide which copy is authoritative and whether changes flow in one direction. Keep a short record of the source revision, export settings and known deviations.

## 3. Two clocks: frames and seconds

Remotion usually describes animation in frames. HyperFrames compositions use time in seconds for timing attributes and seek supported timelines to a requested moment. The conversion is:

```text
seconds = frame / framesPerSecond
frame = seconds × framesPerSecond
```

Suppose a title begins at frame 15 and reaches its final position at frame 45 in a 30 FPS composition. Its entrance starts at 0.5 seconds, ends at 1.5 seconds, and lasts one second. The same visual at 60 FPS would use frames 30 through 90 for the same absolute times.

This sounds mechanical, but frame boundaries matter. A composition of 90 frames at 30 FPS has a duration of three seconds. Its frame indices are 0 through 89; index 90 would be the first frame of a fourth second and does not belong to that 90-frame composition. Likewise, when two clips meet at 3.0 seconds, avoid counting the boundary frame twice or leaving an accidental empty frame. Inspect the frame before the cut, the cut itself, and the frame after the cut.

An agent can help calculate timing, but it cannot decide the intended editorial beat unless the brief says what it should be. “Enter during the first second and hold until the cut at three seconds” is more useful than “make it snappy.”

## 4. A small source composition

The following component is intentionally focused on one visual. Place it in an existing, correctly scaffolded Remotion project and register it as a `LowerThird` composition. The registration after the component is shown separately because an existing project may already have its own root.

```tsx
// LowerThird.tsx
import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame, useVideoConfig } from "remotion";

export const LowerThird: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = interpolate(frame, [0, fps * 0.5], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ backgroundColor: "#101827", justifyContent: "flex-end", padding: 72 }}>
      <div
        style={{
          opacity: progress,
          transform: `translateX(${(1 - progress) * -80}px)`,
          borderLeft: "8px solid #2dd4bf",
          paddingLeft: 24,
          color: "white",
          fontFamily: "Arial, sans-serif",
        }}
      >
        <div style={{ fontSize: 64, fontWeight: 700 }}>Aadil Mallick</div>
        <div style={{ fontSize: 34, color: "#cbd5e1" }}>Developer and creator</div>
      </div>
    </AbsoluteFill>
  );
};
```

```tsx
// Excerpt for an existing Remotion root component.
// Import Composition from "remotion" and LowerThird from "./LowerThird".
<Composition
  id="LowerThird"
  component={LowerThird}
  width={1920}
  height={1080}
  fps={30}
  durationInFrames={90}
/>
```

The `progress` value moves from zero to one over half a second, regardless of the project's FPS. Before the interval it is clamped at zero; afterward it stays at one. We use that one value both for opacity and horizontal position. At the start, the text is invisible and shifted 80 pixels to the left. At the end of its entrance, it is fully opaque and has no horizontal offset. It remains on screen through the end of the three-second composition.

This specific example has an opaque dark background. Its exported clip therefore covers whatever is underneath. That makes it appropriate as a full-frame title card or proof-of-concept, but it is **not yet a transparent lower-third overlay**. We will handle transparency separately instead of assuming that an MP4 will preserve it.

Use the project's existing Remotion root and scripts. The registration fragment deliberately is not a whole project; adding another `registerRoot()` entry to an established project may conflict with its existing setup. If you are unsure where the registered composition lives, ask the agent to inspect the repository before editing.

## 5. Media handoff: render and import

From the Remotion project root, a documented basic rendering pattern is:

```bash
npx remotion render LowerThird out/lower-third.mp4
```

The composition ID selects the registered composition. The output path is where the encoded media is written. Depending on project configuration, Remotion version, and licensing eligibility, options or a license key may be needed; follow the [rendering](https://www.remotion.dev/docs/render) and [licensing](https://www.remotion.dev/docs/license/pricing) pages for the version you installed. A successful exit means a file was created, not that it looks or sounds correct.

Play the export and verify its duration, dimensions and entrance. Then copy it to the HyperFrames project's asset directory. Rather than assuming every version's scaffold has identical markup, start with an official HyperFrames example and place a timed video clip within its existing composition. This is a **clip fragment**, not a complete standalone HyperFrames project:

```html
<!-- Place inside an existing HyperFrames composition; path is relative to it. -->
<video
  id="lower-third"
  class="clip"
  src="assets/lower-third.mp4"
  data-start="2"
  data-duration="3"
  data-track-index="1"
  muted
></video>
```

Here `data-start="2"` places the clip at two seconds of the destination composition; `data-duration="3"` gives it three seconds on the timeline; and the track index places it on a track. Exact stacking depends on the composition's DOM and styling. The `muted` attribute is appropriate for this silent example. If the source has audio, follow the current media and audio documentation to determine how it should be included; merely omitting `muted` is not a complete mixing plan.

The `class="clip"` and timing attributes matter because HyperFrames interprets the element as a timeline clip. Read the [HTML schema](https://hyperframes.app/docs/6-reference/html-schema) for the current requirements, including composition root, dimensions, timeline registration, and how duration is determined. Avoid directly animating a `<video>` element in ways the framework warns against; animate a suitable wrapper when instructed by the current documentation.

From the HyperFrames project, the basic inspection workflow is:

```bash
npx hyperframes lint
npx hyperframes preview
npx hyperframes render --output out.mp4
```

See the [CLI reference](https://hyperframes.app/docs/5-packages/cli). The preview lets you scrub the edit, while the actual output checks the full capture and encoding path. Check that the root composition is at least five seconds long so the entire clip can play from second two through second five. In a GSAP-driven composition, the timeline length and root configuration influence duration; an embedded three-second video alone does not guarantee the parent lasts long enough.

### What has been preserved?

The destination has the motion and name as pixels. You can usually move, trim, scale or crop the clip, subject to the destination's features. But changing “Aadil Mallick” to another name requires changing the Remotion source and rendering the file again. The HyperFrames editor does not discover an editable name layer inside the MP4.

If only the name needs frequent editing, a useful hybrid is to export an unlabeled decorative plate and place a native editable text layer on top in the destination. That design choice moves the changeable information across the boundary as meaning, while preserving the complex reusable visual as media. Confirm the plate's timing and text position in both environments.

## 6. Transparency: what an overlay really requires

An overlay usually needs transparent regions so the viewer can see the video underneath. An RGB pixel represents color; an alpha channel represents opacity. Alpha zero means transparent and alpha one means opaque, with intermediate values for partial transparency. Antialiased edges need intermediate alpha values to blend smoothly. A normal opaque MP4 export should not be assumed to contain usable transparency.

There are three practical approaches:

- **Use an opaque full-screen clip.** Simple, widely compatible, and fine when the composition is meant to cover the screen.
- **Render with a supported alpha-capable codec or image sequence.** This can preserve transparency, but the producing renderer, container, codec, browser decoder and consuming renderer must all support it in the particular workflow.
- **Rebuild only the overlay natively.** A simple title bar may be easier to reproduce than to troubleshoot across incompatible alpha implementations.

For example, Remotion documents a transparent WebM export using an alpha-capable configuration:

```bash
npx remotion render --image-format=png --pixel-format=yuva420p --codec=vp8 LowerThird out/lower-third-alpha.webm
```

Before trying this, remove the opaque background from the component; otherwise it will still cover the frame even if the codec supports alpha. This command illustrates the documented shape, but check the current [transparent-video documentation](https://www.remotion.dev/docs/transparent-videos) and test your specific playback and capture environment. Browser support for alpha in an encoded file can differ from what a media inspector reports. A file claiming an alpha pixel format is not enough: put a bright checkerboard behind the overlay in the actual destination, render it, and inspect the result.

Transparent PNG sequences are another useful intermediary when a tool accepts them. They may use more storage and require careful naming and timing. They preserve each frame independently, but they do not automatically carry synchronized audio. Keep audio as a separate asset and explicitly align it.

Alpha problems have several causes: an opaque source background, a codec that discards alpha, a decoder that ignores alpha, an incorrect interpretation of premultiplied alpha, or a later export that flattens the layer onto black. Edge halos can indicate a mismatch in how color and alpha are combined. Diagnose each stage with a simple red or cyan background before debugging a full video.

## 7. Dimensions, aspect ratio and scaling

A 1920×1080 clip has a 16:9 aspect ratio. A 1080×1920 composition has a 9:16 ratio. Moving the first into the second forces a choice: fit, crop, redesign, or place it inside a smaller framed area. Scaling is not the same as redesigning for the new screen. A large horizontal title can become tiny when fitted into a vertical canvas.

For a vertical developer video, consider exporting the source in the same 1080×1920 dimensions as the destination. If the title was designed for horizontal video, translate or redesign it instead of scaling blindly. If you intentionally show a horizontal screen recording in a vertical video, use the surrounding space for a headline and captions, then zoom into relevant details only when they remain legible and truthful.

Scaling a raster clip up can make type and thin lines look soft. Native vector or HTML text can often be re-rendered more cleanly at the target resolution, though fonts and browser layout must still match. Scaling down may hide small details. Inspect at the actual intended viewing size, not just at full-screen desktop size.

The same concern applies to FPS. A 30 FPS clip within a 30 FPS project provides a straightforward one-to-one temporal mapping when their start times align. A 24 FPS source in a 30 FPS output requires resampling, repeated frames or interpolation depending on the renderer; motion may look different. Mixing frame rates is possible, but perform a test export before committing to a look that depends on smooth movement.

## 8. Audio, synchronization and the hidden double soundtrack

A video file may contain both a visual stream and an audio stream. If your Remotion export includes music and you add the same music to the HyperFrames timeline, viewers will hear two copies. Depending on alignment, this can become louder, produce echo, or create phase artifacts. Conversely, muting the clip may remove an important sound effect along with unwanted music.

Decide ownership before exporting. One clean arrangement is: source renders picture only; destination owns the master narration, music and sound effects. Another is: source owns a self-contained effect or voice clip; destination does not duplicate it. Either can work if documented. If the source includes a synchronized sound accent that is difficult to separate, render an explicit audio stem and align it on the destination timeline.

Write down the intended start time and inspect the export with headphones. A displayed timeline may show a clip at exactly two seconds while the encoded audio includes a short lead-in, or the source itself may have silence before the effect. The useful observation is what you hear in the final file, not merely where the audio block is drawn in the editor.

When cutting at a hard boundary, a waveform can start or stop abruptly and produce a click. Fade or crossfade where appropriate, taking care not to alter an intentional transient such as a click sound. Keep original audio files and project settings so you can fix mix issues without regenerating unrelated video frames.

## 9. Color and compression: why pixels can change

Your source may start as CSS color values, be captured into image frames, encoded to a video, decoded by the destination, then encoded again. Each step can change values. Video commonly uses color models and limited or full ranges that do not map perfectly to RGB values used in browser rendering. Lossy codecs can blur edges, particularly around small high-contrast text, or alter fine gradients.

This is not an argument that media handoff is unusable. It is a reason to test with the graphics that matter. A slow-moving background can tolerate more compression than thin white code text on a black background. If the text looks muddy, try a higher-quality intermediate, a more suitable codec, an image sequence, or a native text overlay. For exact comparison, use lossless or comparable image-frame outputs when possible; comparing two different lossy encoders may measure encoding differences rather than a design error.

The migration guide recommends particular comparison settings for its workflow; follow that guide rather than treating a single numerical similarity score as universal. Color spaces, gamma, antialiasing, font rasterization, and different browser versions can all affect a numerical comparison even if the animation is acceptable. Human inspection and documented tolerances remain necessary.

Avoid exporting and re-exporting repeatedly during development. Keep the original source and render a clean intermediate from it. One extra encoding step is often harmless; ten lossy generations can noticeably degrade fine details. The final export should be evaluated against the actual distribution target, not an imagined guarantee that every platform will preserve your original file unchanged.

## 10. Native translation: transfer the design, not just the syntax

Suppose the downstream editor needs to change the name in Studio. You decide to translate the lower third into native HyperFrames HTML and GSAP. The conceptual mapping is:

| Source concept | Destination concept | Question to verify |
| --- | --- | --- |
| Composition dimensions and FPS | Root composition dimensions and render FPS | Are the canvas and output settings the same? |
| Current frame | Current time in seconds | Is frame zero represented at time zero? |
| `interpolate()` range | Seekable timeline tween | Are start, end, interpolation and clamping equivalent? |
| React element and styles | HTML element and CSS | Are font metrics and layout the same? |
| `Sequence` offset | Clip or subcomposition start | Are local and parent times aligned? |
| `staticFile()` path | Relative destination asset URL | Are the exact same files loaded? |

For our example, the entrance is linear over the first 0.5 seconds. The conceptual GSAP tween is:

```js
// Illustrative timeline fragment; attach it to the paused, registered
// timeline required by the installed HyperFrames composition template.
timeline.fromTo(
  "#nameplate",
  { opacity: 0, x: -80 },
  { opacity: 1, x: 0, duration: 0.5, ease: "none" },
  0
);
```

The destination timeline must follow the current HyperFrames registration conventions. This fragment alone is not a complete project, and an ordinary `gsap.timeline()` that plays using the wall clock is not automatically a correct seekable composition. Start with a scaffolded example, attach the tween using its documented conventions, run the linter, and check the result in a rendered file. `ease: "none"` is significant: the source interpolation is linear, while a different easing curve would produce different intermediate positions even with the same endpoints.

The timing calculation comes directly from the source: `fps * 0.5` frames equals 0.5 seconds. At 0.25 seconds, linear progress is 0.5, so opacity should be about 0.5 and horizontal shift about −40 pixels. This middle frame is often more informative than comparing only the start and end. If the title lands correctly but the middle position differs, the easing may be wrong. If its position matches but letters wrap differently, inspect font availability, font size, width and line-height.

A translation also needs a duration that matches the whole source, not merely the half-second entrance. If the destination timeline ends at 0.5 seconds, the title will not hold for the intended three seconds. Follow the current composition template's method for setting or extending duration. Check the first frame, 0.25 seconds, 0.5 seconds, the hold, and the last frame before the cut.

### Build a translation record

Save a small notes file beside the translated composition:

```markdown
# Translation notes

Source: lower-third, revision 91ab2c3 (replace with the actual revision)
Target: native HyperFrames title scene
Canvas: 1920 × 1080; target 30 FPS; duration 3 seconds
Timing: linear entrance, 0–0.5 seconds; hold to end
Font: Arial with sans-serif fallback; verify availability on the render host
Known differences: none observed in reviewed frames (or list each difference)
Checks: source and destination stills at 0, 0.25, 0.5, 1.5 and final frame
```

The sample revision is a placeholder, not a claim that such a commit exists. Replace it with the real source identifier. Record actual findings instead of writing “none observed” before checking. If the original uses a particular licensed font, include its permitted distribution and use. A fallback is not necessarily visually identical, even when both fonts are sans-serif.

### Common translation pitfalls

A CSS `transform` can contain translation, scaling and rotation. Order matters: translating and then scaling is not necessarily equivalent to scaling and then translating. `transform-origin` also affects the result. A converter that copies final values but changes their order can produce noticeably different motion. Compare intermediate frames and inspect the composed transform.

React may recompute layout as props change, while a translated static HTML page might have different assumptions about the data. If the source uses a dynamic name of unpredictable length, test a short name, a long name and characters outside basic ASCII. Verify overflow and font fallback. Exact editable text is only valuable if it remains readable after real content changes.

A spring is not generally the same as a generic ease-out. Both may move toward a target, but a spring can overshoot and oscillate. Preserve the actual motion curve using an appropriate supported technique or document the approximation. Avoid claiming frame-perfect translation merely because the endpoints match.

## 11. Hosted runtimes: matching the destination's clock

An interactive web animation often advances using `requestAnimationFrame`, `Date.now()` or a repeating timer. These are appropriate for normal real-time interactions, but an offline renderer may request frames out of order or render different frames in parallel. The renderer needs an answer to: “What should this scene look like at exactly 2.3 seconds?” Waiting 2.3 seconds in real time is both slow and unreliable.

A seekable runtime separates the scene state from elapsed wall-clock time. Conceptually, it behaves like this:

```js
// Conceptual JavaScript, not a HyperFrames adapter API.
function drawAtTime(seconds) {
  const progress = Math.min(Math.max(seconds / 2, 0), 1);
  const rotationDegrees = 180 * progress;
  return { rotationDegrees };
}

console.log(drawAtTime(0));   // { rotationDegrees: 0 }
console.log(drawAtTime(1));   // { rotationDegrees: 90 }
console.log(drawAtTime(2));   // { rotationDegrees: 180 }
```

The same input gives the same result and does not depend on which frames were requested earlier. This is the mental model behind reliable seeking. Real hosted integrations need to connect a drawing runtime to the actual HyperFrames frame-adapter interface and wait for assets to load. Follow the project's current runtime references, because names and supported integrations can change.

Random particles illustrate a subtle trap. If each requested frame calls `Math.random()`, the renderer might draw different particle positions each time it captures the same frame. Seeded randomness can make initial particle positions reproducible. Then derive each particle's position from its seed and requested time. If physics depends on the entire previous frame history, either implement a deterministic simulation that can reconstruct state at arbitrary time, cache its results, or pre-render it as media. Merely calling `Math.random()` once in an effect is not a reliable cross-process solution.

Asynchronous assets introduce another trap. A screenshot captured before a font or image loads can have missing or substituted content. Ensure the adapter's documented readiness mechanism completes before capture. Where practical, use local, versioned assets and avoid a live network dependency during a render. The objective is not to ban networks; it is to prevent a temporarily unavailable remote resource from changing or breaking your video.

## 12. Visual verification is part of integration

The word “works” has several meanings. A command can finish successfully while the export has the wrong duration. A preview can look correct while a decoded clip drops transparency. A title can look right at the first and last frames while its timing curve changes in between. Good integration checks all three: structural validity, timeline behavior and final visual quality.

Use a representative frame plan:

1. Capture the source and target at the first frame.
2. Compare a quarter of the way through each entrance.
3. Compare the motion midpoint.
4. Compare the final entrance frame and a hold frame.
5. Inspect the last frame before a cut, the cut and the next frame.
6. Watch the complete rendered result with audio.

If the source and target have different frame rates, compare corresponding times rather than merely the same numerical frame index. At 30 FPS, frame 15 corresponds to 0.5 seconds; at 60 FPS, frame 30 corresponds to the same time. Be explicit about rounding and any frame-rate conversion in your comparison report.

For an automated first pass, FFmpeg can extract frames from files. This command seeks to the half-second point and writes one PNG. The exact frame selected can vary with timestamp and seeking behavior, so use exact frame-index filtering or source frame sequences when a rigorous frame-for-frame comparison is required:

```bash
ffmpeg -i source.mp4 -ss 0.5 -frames:v 1 source-half-second.png
ffmpeg -i target.mp4 -ss 2.5 -frames:v 1 target-half-second.png
```

The second seek is at 2.5 seconds because our destination clip starts at 2.0 seconds. Both stills should depict the source at local time 0.5 seconds. These commands require FFmpeg and assume files exist in the current directory. Timestamp seeking is useful for a quick visual check but is not itself a proof of exact equivalence. Audio should be checked separately.

An automated image-difference score can guide attention, but it cannot tell you whether a one-pixel color difference matters less than a missing label. Compare source and destination with matching resolution, color handling, and appropriate decoded frames. Then record meaningful differences: clipped text, changed typeface, timing drift, dropped shadows, missing audio, or altered color. If a deliberate adaptation changes aspect ratio, exact pixel matching is not the right target; compare the intended information and timing instead.

## 13. An end-to-end worked decision

A developer launch video needs an animated UI walkthrough and a name caption. The walkthrough is already a 30-second Remotion composition with many reusable React components. A teammate wants to add an HTML-based closing screen in HyperFrames.

First, determine the actual need. If the teammate needs only to place the Remotion walkthrough before the closing screen, render it as a high-quality clip. Keep the React source in version control for future changes. Place it at time zero; place the HyperFrames closing scene at the clip's end. Give the full timeline enough duration to include both. Check aspect ratio, FPS, audio ownership and whether the audio fades across the cut.

Second, identify the name caption. If the caption is embedded in the walkthrough and never changes, leave it in the clip. If the caption changes per presenter, split it out: render the walkthrough without the caption and create an editable native overlay in the destination. This reduces repeated full-video renders when only a name changes. It also means the destination now owns the typography and timing of the caption; document those decisions.

Third, prepare a visual comparison. Render a baseline from Remotion. In the destination, capture at the local source times 0, 5, 15 and just before 30 seconds, plus the closing transition. Compare the decoded source with the rendered destination. Investigate any missing frames or artifacts before showing the result to a stakeholder. Report the chosen handoff level for each part, not just “integrated.”

Fourth, plan future edits. The Remotion project is the source of truth for the walkthrough; the HyperFrames project is the source of truth for the closing scene and native caption. When the UI changes, rerender the walkthrough from a known commit and replace the clip, then repeat the same verification. This avoids the maintenance problem of two independently edited versions of the same UI.

## 14. Directing Claude Code and Codex

An effective agent prompt gives a concrete task and sets the verification boundary. Both agents need access to the relevant local project files and documentation; neither should be assumed to have rendered or inspected anything it merely described. If a workflow requires installing a skill or paid service, inspect that dependency and authorize any costs separately.

### Claude Code: preserve an approved Remotion scene as media

```text
Inspect the existing Remotion project and the HyperFrames project in this
workspace. The approved Remotion composition is LowerThird. Add its three-
second render to the HyperFrames video at 00:02 as a full-frame clip.

First report the current dimensions, FPS, duration, codec and whether the
source contains audio. Follow the installed framework skills and current
project conventions. Do not rewrite the source design. Render a draft, run
HyperFrames lint, and inspect frames before, during and after the handoff.
Report what remains editable in HyperFrames and any observed differences.
Do not download paid assets or use paid APIs.
```

The prompt states the source, target, placement, desired fidelity, inspection and cost boundary. If the agent cannot render because a dependency is missing, it should report that limitation instead of claiming visual verification. A helpful follow-up is: “Show me the exact files you changed and explain why the source's local frame zero appears at two seconds in the destination.”

### Codex: translate a simple element and compare

```text
Using the installed HyperFrames migration guidance, inspect the Remotion
LowerThird composition. Determine whether it is eligible for native
translation; identify blockers instead of guessing. If it is suitable,
translate the nameplate and its linear half-second entrance into native
HTML/GSAP while preserving a three-second total duration.

Use the same canvas, font and colors. Keep the name editable. Render both
versions at the same FPS, inspect representative frames including 0.25 s,
0.5 s and the final frame, and write translation notes documenting exact
checks and any mismatch. Do not claim pixel equivalence without evidence.
```

Codex may have different installed skills or render capabilities depending on the environment. The request to inspect the installed migration guidance is more robust than assuming a particular slash-command syntax. If it cannot complete an exact comparison, it can still document the missing dependency and produce a precise manual verification plan.

### An iteration prompt for either agent

```text
The translated title is aligned at the start and end, but at 0.25 seconds
it is farther right than the reference. Investigate the tween's easing and
local start time. Preserve the scene duration and typography. Render the
same comparison frames again and show what changed.
```

This points to observed evidence rather than asking for a vague “improvement.” It names the expected invariant, the suspicious properties and a clear retest. If the difference comes from another cause, a competent agent should explain it rather than forcing the suggested diagnosis.

## 15. Troubleshooting guide

| Symptom | Likely causes | First check |
| --- | --- | --- |
| Clip does not appear | Incorrect asset URL, missing clip metadata, invisible layout or insufficient parent duration | Lint, inspect the asset path and scrub the root timeline |
| Black box around an overlay | Opaque source or alpha discarded/unsupported | View against a bright checkerboard in the final renderer |
| Text is wider or wraps | Missing font, fallback, font weight or container size differs | Verify actual loaded fonts and computed dimensions |
| Movement feels wrong despite same start/end | Different easing, stagger or time origin | Compare positions at 25%, 50% and 75% of motion |
| Clip stops early | Destination composition or GSAP timeline ends first | Compare root duration to clip start plus clip duration |
| Audio echoes | Source and destination both include a soundtrack | Inspect source streams and mute or remove one copy intentionally |
| Captured frame changes between renders | Wall clock, unseeded randomness, async assets or network | Repeat the same timestamp; isolate time and assets |
| Colors or edges look soft | Scaling, compression, color conversion or wrong source resolution | Compare decoded stills and test a higher-quality intermediate |

A table gives starting hypotheses, not a diagnosis. Change one variable at a time. For example, when investigating a black box, first view the alpha file over a colored background in a known compatible player, then in the destination preview, and then in the destination's rendered export. The first stage where transparency disappears narrows the problem. If it never existed in the source, changing the destination cannot restore the missing alpha channel.

## 16. Optional application: two integration paths for one title

Create a three-second source title with editable name and role in Remotion. Render it as an opaque MP4 and place it in a HyperFrames composition. Confirm its start, end, visual scale and local timing. Then recreate only the title text and entrance as native HTML/GSAP, using the same font and canvas. Compare frames and note which properties remain editable in each version.

A useful result is not “the native version is always better.” It is a concrete comparison: the media version needed one export and matched the approved source, while the native version allowed a name change without rerendering the source but took additional verification. Your project and edit frequency determine which tradeoff is worth making.

## References and next step

- [HyperFrames migration skill](https://github.com/heygen-com/hyperframes/blob/main/skills/remotion-to-hyperframes/SKILL.md) and [API mapping](https://github.com/heygen-com/hyperframes/blob/main/skills/remotion-to-hyperframes/references/api-map.md).
- [HyperFrames composition data and HTML schema](https://hyperframes.app/docs/6-reference/html-schema), [GSAP guide](https://hyperframes.app/docs/3-guides/3-gsap-animation), and [CLI](https://hyperframes.app/docs/5-packages/cli).
- [Remotion rendering](https://www.remotion.dev/docs/render), [transparent video](https://www.remotion.dev/docs/transparent-videos), and [encoding guide](https://www.remotion.dev/docs/encoding/).

The next lesson uses these building blocks to create the visual treatments viewers actually see: animated titles, UI highlights, diagrams, transitions and a coherent motion system.
