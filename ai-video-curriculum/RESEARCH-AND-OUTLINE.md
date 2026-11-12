# AI Video, Remotion & HyperFrames: Research and Curriculum

Research snapshot: November 12, 2026. Tools, pricing and model capabilities change quickly; check linked documentation before installing or buying. This is a research brief and detailed curriculum outline, not the complete lessons.

## The goal

Learn to produce polished animated explainers, software demos, product launches and short developer videos for LinkedIn and other channels. You will understand the visual and technical decisions well enough to direct Claude Code or Codex, inspect their work, debug it, and eventually build repeatable video workflows yourself.

Assumptions: you are comfortable with programming but may be new to React, HTML animation, editing, and motion design. The curriculum teaches the required web concepts in context. Practice projects are optional applications, not quizzes.

# Part 1 — What the research shows

## 1. What “AI video” actually means

Several different processes are often grouped under that label. A polished video might combine all of them:

1. **AI-assisted planning:** a language model helps turn an idea into a script, shot list, visual references, and an edit plan. A human checks the facts and controls the message.
2. **Code-driven motion graphics:** an agent writes React, HTML, CSS, SVG, or animation code. A renderer captures frames and encodes them as a video. This is especially useful for exact text, diagrams, interface mockups, charts and repeatable layouts.
3. **Generative images and video:** image models create stills; video models generate moving shots from text, a starting image, or other references. These produce imagery and motion, but give less predictable control over exact words, continuity and fine changes.
4. **Generated or recorded audio:** voiceovers, music and effects can be recorded, licensed or synthesized. Transcription creates timed captions; the editor still checks words and synchronization.
5. **Editing and compositing:** clips, text, graphics and sound are layered, timed, corrected and exported. An editor or a code-based renderer can perform this step.

For a concrete 30-second developer explainer, the agent might write the script and animate accurate code blocks in Remotion; an image model might create a stylized server-room backdrop; an image-to-video model could animate that backdrop; and a human might record the voice and approve the final edit. No one technique is responsible for every visual.

### Why the graphics look impressive

A visual can be ordinary web content combined with strong art direction: type hierarchy, contrast, spatial depth, camera-like movement, synchronized sound, and well-timed transitions. Common ingredients include oversized kinetic typography, masks and reveals, device mockups, animated UI, parallax layers, particles, gradient lighting, 3D objects, and charts whose movement tells a story. An AI agent can generate the code, while the quality still depends on composition, timing, source assets, and iteration.

A practical recipe for a product launch: capture the real UI; isolate it in a device frame; put it over a restrained animated background; move the virtual camera slowly; highlight the active control at the narration cue; add a short sound accent; cut to a readable benefit statement. Build a static frame first, then animate its most meaningful elements.

## 2. How the tools fit together

| Approach | Best fit | Control and tradeoff |
| --- | --- | --- |
| Remotion | React/TypeScript compositions, reusable templates, programmatic variants | Exact frame-based logic and composable components; requires coding and layout skills. |
| HyperFrames | HTML/CSS/JavaScript compositions, seekable GSAP motion, agent-led editing | Browser-native visual authoring; must follow its timing and composition conventions. |
| Generative image/video | Visual concepts, atmospheric footage, stylized backgrounds, hard-to-film shots | Fast exploration and rich imagery; shot consistency, text and precise changes may require retries or compositing. |
| Conventional editor | Editorial timing, recorded footage, sound mixing and finishing | Direct timeline editing and human judgment; template automation varies by tool. |
| 3D/animation tools | Complex controllable cameras, models, simulations and depth | High control and consistency; modeling, lighting and rendering add effort. |

[Remotion](https://www.remotion.dev/docs/) uses React components and frame-based functions. [HyperFrames](https://hyperframes.app/docs/1-startup/1-introduction) uses HTML compositions and seeks supported animation runtimes to the required time. Both turn browser-rendered frames into video. They are **alternatives that can also be combined**, not a required stack in which one always runs inside the other. See the [HyperFrames comparison](https://github.com/heygen-com/hyperframes/blob/main/docs/guides/hyperframes-vs-remotion.mdx).

### Three ways to combine them

- **Rendered-media handoff:** render a Remotion composition to a video and place it as a HyperFrames clip, or export HyperFrames media for use in another editor or composition. This is the simplest boundary; internal elements become baked pixels. Allow for encoding and color differences.
- **Translate:** port suitable Remotion code into native HTML/GSAP for editing in HyperFrames, then compare original and translated frames. Some React patterns cannot translate cleanly. Follow the project's [migration guidance](https://github.com/heygen-com/hyperframes/blob/main/skills/remotion-to-hyperframes/SKILL.md).
- **Hosted runtime:** use a supported seekable browser runtime inside HyperFrames where appropriate, exposing time and parameters. Its migration guidance describes constraints. This is an advanced integration, not an assertion that arbitrary Remotion/React projects embed directly.

Start with one renderer per video. Combine them when existing assets or a specific editing need justify the extra workflow.

## 3. Frame-based animation: the underlying idea

At 30 frames per second, a 10-second video contains 300 frames. The renderer asks what each frame should look like at a particular time and encodes those images into a playable file. A title fading in over the first second can use `opacity = min(frame / 30, 1)`: frame 0 is invisible, frame 15 is half visible, frame 30 is fully visible. Real motion also uses easing to change the rate of movement.

In Remotion, `useCurrentFrame()` provides the current frame and `interpolate()` maps a frame range to a visual value. HyperFrames instead controls the timeline by seeking to a time. In both cases, prefer animation that can be evaluated at any requested frame; wall-clock timers and unseeded randomness can make preview and export disagree. See [Remotion interpolation](https://www.remotion.dev/docs/interpolate) and [HyperFrames rendering](https://hyperframes.app/docs/3-guides/4-rendering).

## 4. Generative footage, voice and visual consistency

For text-to-video, the prompt needs both the scene and its motion. For image-to-video, the input image establishes the visual starting point; the motion prompt describes subject action, camera movement, speed and environmental motion. This is Runway's documented guidance for its image-to-video workflow; other models may behave differently. See [Runway's guide](https://help.runwayml.com/hc/en-us/articles/48324313115155-Image-to-Video-Prompting-Guide) and [Google's prompt guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/video/video-gen-prompt-guide).

Example: first create or supply a still of a dark, teal-lit server room. Then prompt: “The camera slowly dollies forward between the racks; small status lights pulse softly; steady cinematic movement.” Review the resulting clip for warping, unwanted motion, readable interface details and continuity. Put exact titles or code in the composition layer rather than relying on the generated shot to reproduce them reliably.

For consistency, keep a short visual brief: palette, typefaces, subject reference images, camera language and example frames. Generate short shots separately, choose the strongest, then assemble them. Reference images and first/last-frame controls are model-specific; see [Google's reference guidance](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/video/generate-videos-from-references). AI voices, music and stock assets also need licensing, consent and commercial-use checks appropriate to the chosen provider.

## 5. The production loop

**Brief → script → storyboard/animatic → asset acquisition → composition → narration and captions → preview → revise → export → review.**

1. Decide audience, one message, length, platform and aspect ratio.
2. Write the voiceover and define a shot-by-shot timing plan. Roughly time narration; don't force a fixed number of words per second onto every speaker.
3. Produce still style frames and a low-cost animatic before making expensive generated shots.
4. Gather real UI recordings, licensed assets, generated images and audio; record each asset's origin and permissions.
5. Build the composition; keep text editable and layouts safe for vertical crops and platform overlays.
6. Synchronize voice, captions, cuts and sound effects. Review captions manually.
7. Inspect frames at scene boundaries and motion midpoints; watch the actual export with sound, on a phone as well as a desktop. Check contrast, clipping, pacing and audio levels.
8. Export a master and versions for the target platforms. Measure render time and generation costs before scaling.

## 6. Installation and agent workflows

Tools can change quickly; verify OS requirements and installation steps in current documentation. HyperFrames lists Node.js 22+, npm/npx and FFmpeg for its local workflow in [HeyGen's setup guide](https://help.heygen.com/en/articles/15001510-hyperframes-x-heygen). Remotion's project setup will state its own current requirements. Review third-party skills, package code and permissions before installing or granting shell/network access; run commands in a project folder you control.

### Remotion with Claude Code

The [official Claude Code plugin guide](https://www.remotion.dev/docs/ai/claude-code-plugin) provides:

```bash
claude plugin marketplace add remotion-dev/claude-code-plugin
claude plugin install remotion@remotion
```

Restart Claude Code and open your project folder. Example prompt:

```text
/remotion:remotion-create Create a 20-second 9:16 developer explainer
about why database indexes speed up lookups. First propose a 4-scene
storyboard and style frames. Use editable React components, real explanatory
labels, and simple frame-driven animation. Use a placeholder for narration;
do not invent benchmark results. Preview, render, inspect representative frames,
and explain the files and how to change timing. Ask before purchasing any assets.
```

### Remotion with Codex

The [official Codex plugin guide](https://convert.remotion.dev/docs/ai/codex-plugin) describes opening the Remotion plugin in the ChatGPT desktop app and using `$remotion`. Remotion also documents agent skills, which can be installed in an existing Remotion project:

```bash
npx remotion skills add
```

See [Remotion Agent Skills](https://www.remotion.dev/docs/ai/skills). Depending on your Codex environment, availability and invocation of installed skills can differ; follow its current instructions. Example Codex prompt:

```text
Use the installed Remotion skills to create a 20-second vertical explainer
in this repository. Explain database indexes with four visual scenes and
editable labels. First write a scene plan and identify any missing assets.
Implement frame-based animations, render a draft, inspect key frames, and
fix overlaps or unreadable text. Document setup and editing instructions.
Use placeholders instead of paid services and do not make up statistics.
```

### HyperFrames with either agent

The [official quickstart](https://hyperframes.app/docs/1-startup/2-quickstart) documents:

```bash
npx skills add heygen-com/hyperframes
```

In Claude Code the quickstart documents `/hyperframes`, `/hyperframes-cli`, and `/gsap` skill commands. For Codex, ask it to use installed HyperFrames skills; invocation syntax depends on the environment. For both, adapt this prompt:

```text
Create a 15-second 9:16 product teaser with HyperFrames for an imaginary
app called QueryLens. Start with a storyboard and static style frame. Animate
an editable UI mockup, a short benefit headline, and a final call to action.
Use only local placeholder assets; no paid services. Follow the installed
HyperFrames skill and current schema. Run lint, preview and render, inspect
frames at every scene boundary, and report how to change the copy and colors.
```

Useful documented project commands, run from the project directory, include `npx hyperframes preview`, `npx hyperframes lint`, and `npx hyperframes render --output output.mp4`; options and requirements are in the [CLI reference](https://hyperframes.app/docs/5-packages/cli). Verify final playback rather than assuming a successful command means good design.

### Prompting pattern for both agents

Give the agent the audience and objective, exact aspect ratio and duration, visual references, scene beats, permitted assets and budget, required editable elements, deliverables, and quality checks. Ask it to inspect the rendered output and explain important changes. For factual videos, provide approved source material and require it to flag uncertainty. Example refinement: “At 00:08 the caption overlaps the card. Move it above the card, hold the frame for another half second, rerender and check the transition.”

## 7. Costs, rights and limits

HyperFrames' repository identifies its framework as Apache-2.0, while hosted models or services can have separate charges and terms. Remotion uses its own license and distinguishes use cases, including video-creation tools; check the [current pricing and license](https://www.remotion.dev/docs/license/pricing) before commercial or automated deployment. Image/video generation, voice, stock, cloud renders and model access can each have separate usage charges. Compare a few sample renders before choosing a provider. Do not upload confidential code, company screens, personal data or unlicensed reference assets to a service without authorization. Obtain consent for a person's likeness or voice and verify platform and provider rules on disclosure and usage.

# Part 2 — Detailed curriculum outline

Each stage builds on earlier stages. The concrete deliverable is a small addition to a growing portfolio; all applications are optional. Claude and Codex are used throughout to plan, implement, inspect and explain, with a human reviewing the result. The stages specify what the eventual lessons will teach rather than claiming the lessons are already written.

## Stage 1 — Visual storytelling and the video production pipeline

**Outcome:** Turn one idea into a visual plan with a clear beginning, middle and end.

- Identify audience, promise, hook, evidence and call to action; distinguish a demo from an explainer or advertisement.
- Translate narration into visual beats, storyboards, a shot list and an animatic; align timing with spoken words.
- Understand aspect ratio, resolution, frames per second, codecs, containers, compression and why preview differs from final export.
- Break down several types of video: screen recording plus overlays; animated infographic; generated-footage montage; code-driven launch.
- Application: storyboard a 20-second LinkedIn video explaining a database index. Produce shot descriptions and timing, not unsupported performance claims.
- Agent use: ask Claude and Codex independently to critique the storyboard for clarity and verify the script's technical statements.

## Stage 2 — Design foundations for readable motion

**Outcome:** Design a strong static frame before adding motion.

- Composition, hierarchy, alignment, spacing, grids, contrast, type scale and color; readability on a small phone screen.
- Visual systems: define palette, typography, shapes, shadows, texture and reference frames; avoid overloading each scene.
- Safe areas, captions and overlays across 9:16, 1:1 and 16:9; test actual platform crops and UI overlays.
- Application: create three still frames for the same explainer and review at phone size.

## Stage 3 — Animation principles from first principles

**Outcome:** Explain and create motion that directs attention.

- Frames and time; keyframes, interpolation, easing, anticipation, overshoot, settling and stagger.
- Position, scale, rotation, opacity, transforms, anchors and coordinate systems; 2D vs faux 3D.
- Why changing everything simultaneously makes a scene hard to follow; entrances, holds and exits.
- Reproducibility and why animation driven by the requested frame is easier to render reliably.
- Application: animate one title and one diagram using linear and eased motion; compare their behavior and timing.

## Stage 4 — Web and React prerequisites

**Outcome:** Read the code the agent writes and make simple changes confidently.

- HTML elements, DOM, attributes, images and video; CSS selectors, box model, positioning, flexbox and grid.
- JavaScript values, objects, arrays, functions, modules and destructuring; TypeScript props and types where used.
- React components, JSX, props, composition and rendering; how a component describes visual output.
- SVG shapes and paths; when to choose SVG, CSS, Canvas, images or video.
- Application: build a static card and diagram with editable copy, then refactor repeated elements into components.

## Stage 5 — First Remotion video

**Outcome:** Build and render a short, editable composition without relying on an opaque generated project.

- Project structure and setup; composition width, height, FPS and duration; Studio preview vs rendering.
- `useCurrentFrame`, `useVideoConfig`, `interpolate`, clamping and `spring` with small runnable examples.
- `Sequence` and `Series`, local versus parent time; composing scenes and controlling overlap.
- Assets, fonts, video and audio; deterministic behavior and common rendering failures.
- Application: a 10-second title, animated diagram and outro; inspect key frames and the exported MP4.
- Agent use: Claude and Codex each implement a small change, then explain the frame calculations and how to adjust them.

## Stage 6 — First HyperFrames video

**Outcome:** Author, preview, lint and render a seekable HTML composition.

- Project structure, root composition, timed clips and the current HTML schema; why data attributes and timeline registration matter.
- CSS layout and GSAP timelines; seeking and timing in seconds; media clips and audio.
- CLI workflow: initialize according to current quickstart, preview, lint, render and inspect.
- Distinguish local editing, the Studio app and hosted/connected options; check current availability and costs.
- Application: reproduce the Stage 5 idea using native HTML/GSAP; compare maintainability and editing experience.

## Stage 7 — Remotion and HyperFrames together

**Outcome:** Choose a sensible integration boundary and know what stays editable.

- Choose one primary renderer based on team skills, assets, editing needs and licensing.
- Rendered video handoff: dimensions, FPS, audio, alpha, color, codec and quality; avoid unnecessary lossy re-encoding.
- Translate supported React compositions to native HyperFrames; identify unsupported state, async, dependencies and visual substitutions.
- Hosted seekable runtimes as an advanced option; limitations around time, randomness, resources and determinism.
- Compare before/after frames and document differences. Application: render a Remotion lower third and incorporate it as a clip; then port a small title card and compare editability.

## Stage 8 — Motion graphics toolkit

**Outcome:** Build a reusable vocabulary of polished visual treatments.

- Kinetic typography, per-word timing, masks, reveals, lower thirds, callouts, wipes and scene transitions.
- Animated UI, code blocks, cursor movement, device frames, highlights and scrolls; avoid presenting fictional UI as a real product.
- Graphs, diagrams and data-driven animation; label values accurately and preserve scale.
- Depth through parallax, gradients, light, blur, layered shadows and particles; motion hierarchy and restraint.
- Application: build a reusable title, diagram, callout and outro set for a personal developer brand.

## Stage 9 — Generative image and video workflows

**Outcome:** Direct generative assets deliberately and integrate them into an editable composition.

- Text-to-image, image-to-image, text-to-video, image-to-video and reference-driven generation; model-specific controls and constraints.
- Design a style bible, generate reference frames, direct camera and subject motion, compare variations and maintain a shot log.
- Plan short shots, preserve continuity, handle flicker, artifacting, visual drift and unwanted text; regenerate only problematic shots when possible.
- AI-generated backdrops vs exact graphics; use masks, compositing, clean plates and overlays.
- Application: produce one image-led atmospheric shot, then overlay a crisp, code-rendered diagram and title.
- Agent use: Claude/Codex write a shot brief and prompt variants; user chooses the provider and controls paid generation.

## Stage 10 — Screen recordings and real product demonstrations

**Outcome:** Show a real app accurately and make its actions easy to follow.

- Plan screen captures, anonymize sensitive information and prepare realistic demo data.
- Capture cursor actions, crop and reframe, highlight controls, add zooms and smooth transitions without hiding important context.
- Combine a real recording with generated surroundings, motion graphics and annotations.
- Application: create a 30-second walkthrough of one of your own apps, with a hook, demonstration and clear outcome.

## Stage 11 — Narration, music, sound design and captions

**Outcome:** Deliver an understandable video with synchronized, accessible audio and text.

- Recording basics, room noise, microphone placement, clean edits, levels and intelligibility.
- Synthetic voice options, consent and pronunciation; speech timing, music beds and sound accents.
- Transcription vs alignment; timestamps, word grouping, caption styling, correction, punctuation and safe areas.
- Separate captions from burned-in text where needed; accessibility, contrast and silent playback.
- Application: narrate the explainer, generate a caption draft, correct it manually and mix a restrained soundtrack.

## Stage 12 — Editing, iteration and visual quality assurance

**Outcome:** Diagnose a weak video and improve it systematically.

- Review first and last frames, scene boundaries, mid-motion frames, text wrapping, crops, layering and timing.
- Check phone readability, audio start/end, volume consistency, clipped content, caption accuracy, stutters and export artifacts.
- Develop a revision vocabulary: “hold for 12 frames,” “reduce travel,” “increase contrast,” “cut on the narration cue.”
- Agent feedback loop: ask for screenshots and a render; inspect the evidence; request targeted changes; verify again.
- Application: revise one draft through two rounds and record why each change improved the story.

## Stage 13 — Templates, data and automation

**Outcome:** Create variants efficiently without sacrificing accuracy or visual quality.

- Separate content, assets, timing and styling; parameterized React components or HyperFrames variables.
- Batch rendering, data validation, naming, manifests, versioned dependencies, caching and error handling.
- Rendering locally vs cloud, render concurrency, storage and per-render costs; keep secrets outside source control.
- Review human approval, factual checks, rights and cost controls before generating at scale.
- Application: produce three versions of a developer tip from structured content, with manual review of each output.

## Stage 14 — Advanced visual techniques

**Outcome:** Know when a project needs more than 2D layouts and select the right technique.

- SVG path animation, vector illustration, Lottie, Canvas, shaders and particle systems.
- Three.js and Blender concepts: models, materials, lights, cameras and rendering; integrate 3D as a seekable runtime or rendered clip when supported.
- Tracking, keying, rotoscoping, depth, motion blur, color grading and compositing fundamentals.
- Performance and deterministic rendering tradeoffs; fallback to pre-rendered footage when live effects are unreliable.
- Application: produce a short 3D-inspired logo reveal or a layered parallax scene and explain the chosen pipeline.

## Stage 15 — Portfolio and publishing capstone

**Outcome:** Publish-ready video assets and a reusable source repository.

- Plan and produce three related pieces: a 20-second concept explainer, a 30-second real product walkthrough, and a 45–60-second launch video combining code-driven and generated visuals.
- Include brief, storyboard, source, asset and license manifest, caption text, render instructions and exported videos.
- Create at least one Claude-assisted and one Codex-assisted workflow; compare agent instructions, revisions and results without assuming either agent did work it did not perform.
- Review source attribution, personal/company information, commercial rights, audio, accurate claims and platform-specific presentation.
- Optional: derive clips or alternate aspect ratios and evaluate actual audience response without promising virality.

## Suggested lesson format

Each future lesson should start with the problem and necessary prerequisites, then develop one idea with a small working example, explain its parts, and extend it to a realistic video. Include both Claude and Codex prompts, troubleshooting, meaningful tradeoffs, and optional hands-on application. Avoid mandatory quizzes. When a command or model capability depends on a version, verify current documentation before teaching it.

## Primary references

- [Remotion documentation](https://www.remotion.dev/docs/), [Agent Skills](https://www.remotion.dev/docs/ai/skills), [Claude plugin](https://www.remotion.dev/docs/ai/claude-code-plugin), [Codex plugin](https://convert.remotion.dev/docs/ai/codex-plugin), [captions](https://www.remotion.dev/docs/captions/displaying), and [license/pricing](https://www.remotion.dev/docs/license/pricing).
- [HyperFrames project](https://github.com/heygen-com/hyperframes), [quickstart](https://hyperframes.app/docs/1-startup/2-quickstart), [CLI](https://hyperframes.app/docs/5-packages/cli), [rendering](https://hyperframes.app/docs/3-guides/4-rendering), and [migration guidance](https://github.com/heygen-com/hyperframes/blob/main/skills/remotion-to-hyperframes/SKILL.md).
- [Runway image-to-video guide](https://help.runwayml.com/hc/en-us/articles/48324313115155-Image-to-Video-Prompting-Guide) and [text-to-video guide](https://help.runwayml.com/hc/en-us/articles/42460036199443-Text-to-Video-Prompting-Guide).
- [Google generative video prompt guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/video/video-gen-prompt-guide) and [reference-guided generation](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/video/generate-videos-from-references).
