# Lesson 9 — Generative images and video: directing shots you can actually use

A useful AI-generated video is not simply the output of one large prompt. It is a collection of decisions: what the audience must understand, which visual elements need to be exact, where creative variation is acceptable, how the shot moves, and how that shot will fit with the rest of the edit. In this lesson you will learn to make those decisions deliberately.

Our running example is a short developer video about a fictional tool called QueryLens. We want a cinematic background suggesting a database system, while an editable diagram and headline explain the idea accurately. The fictional product name and graphics are deliberately separate from any real product or performance claim.

By the end you will be able to turn a visual idea into a shot brief, choose between image generation and video generation, direct motion, handle failed generations, preserve continuity, and integrate a generated clip with code-rendered text. The examples use generic descriptions rather than assuming a particular subscription or model. Features and pricing change, so check the current provider documentation before paying or automating requests.

## 1. Start with the problem: imagination is not the same as control

Imagine asking an image model for “a futuristic database with SQL code on the screen.” The result may look impressive at first glance. But several things may be unusable:

- The SQL text could contain invented words or invalid syntax.
- The screen could be placed where you intended to put captions.
- A logo could change shape between frames once the image is animated.
- The camera motion could make the product difficult to read.
- The shot might look inconsistent with the next scene.

These are not necessarily surprising failures. A generative system produces a visual sample based on its learned patterns and available inputs. Your intent is communicated indirectly through prompts, reference media, and controls. Depending on the model, you may not be able to specify every pixel or guarantee that a precise object remains unchanged. Iteration and editorial judgment are part of the process.

A better division of responsibilities is:

| Element | Desired property | Suitable technique |
| --- | --- | --- |
| Atmospheric server-room background | Interesting texture and movement | Generated image or video |
| Exact title | Correct spelling and predictable placement | HTML, CSS, SVG, Remotion or an editor |
| Database diagram | Accurate labels and easy revision | Code-rendered shapes and text |
| Real product interface | Truthful representation | Actual recording or approved screenshot |
| Sound and captions | Understandable and synchronized | Recorded or licensed audio, verified transcript |

The principle is **separate the layer that creates atmosphere from the layer that communicates exact information**. This gives you the visual richness of generated footage without giving up control of your message.

## 2. The mental model: generate assets, then compose a video

A *shot* is a continuous piece of visual time. A *scene* is a storytelling unit and can contain one or more shots. An *asset* is a source item used to build a shot: an image, video, illustration, recording, audio file, font, or piece of code. A *composition* is the arranged result of those elements over time.

Consider a six-second shot:

1. A generated server-room clip fills the frame.
2. A dark translucent panel covers part of the clip.
3. The title “Find the right data faster” appears above the panel.
4. Three crisp vector boxes represent a search, an index and a result.
5. A human-recorded voice explains the idea.
6. Corrected captions appear near the bottom.

Only the first item needs to be generated video. The other layers remain independently editable. If the title changes, you can change the text rather than regenerate the background. If the background is too busy, you can replace or darken it without changing the diagram.

There is no universal requirement that every layer be code. A conventional editor, Remotion, or HyperFrames can act as the composition environment. The important feature is that you understand which parts are baked into footage and which remain editable.

## 3. A short guide to generation modes

### 3.1 Text to image

You write a description and receive one or more still images. This is useful for concept art, backgrounds, illustrations, reference frames, and visual exploration. A still image is relatively easy to inspect before you spend time or credits animating it.

A text-to-image brief might say:

> Wide, stylized server room at night. Dark navy architecture, soft teal indicator lights, clean geometric forms, restrained cinematic lighting. The left half is darker and visually quiet to leave space for an editable title. No readable text or logos. Vertical composition.

Notice that the prompt describes what should appear, where the visual weight should fall, and what space should remain usable. “No readable text” expresses an intention, not a guarantee. Check the result; some models may still produce unintended marks.

### 3.2 Image to image

You supply an existing image and ask a model to transform or reinterpret it. The original can influence composition, subject, palette or style, depending on the provider and selected controls. For example, an approved illustration of a server room might be restyled as a hand-painted scene.

The tradeoff is preservation versus transformation. A high transformation setting, where available, may create a striking style but change important forms. A low setting may preserve the composition but produce a less visible stylistic shift. The names and exact behavior of controls vary; do not assume a numeric setting means the same thing across services.

For a real product interface, avoid sending a confidential screenshot to an external service unless authorized. Even with permission, inspect the result carefully: transformations can alter labels, controls, or claims. Often it is safer to apply generated styling around the real recording, not to regenerate the interface itself.

### 3.3 Text to video

A text prompt describes both the appearance and the movement of a shot. A typical prompt needs the subject, setting, visual style, motion and camera direction. For example:

> In a dark stylized server room, the camera slowly moves forward between two rows of racks. Subtle teal indicator lights blink irregularly. Soft haze catches the light. The composition remains calm and readable, with clear dark space on the left. No people, logos or readable text.

The output is a moving clip. Depending on the model, you may also be able to specify length, resolution, aspect ratio, audio, references, or other controls. A prompt is not a strict program: two generations from the same input can differ, and even a fixed random seed may not be portable across models or versions.

### 3.4 Image to video

You supply a still image as the starting reference and describe what should change over time. This is particularly useful when composition matters: select a still you like first, then introduce movement. In the [Runway image-to-video guide](https://help.runwayml.com/hc/en-us/articles/48324313115155-Image-to-Video-Prompting-Guide), the image establishes the visual starting point and the prompt emphasizes motion; other providers may interpret inputs differently.

Example starting frame: the server-room image from Section 3.1.

Example motion instruction:

> The camera slowly dollies forward. Small teal lights pulse gently. A faint layer of haze drifts across the far end of the room. Keep the motion smooth and restrained.

This instruction avoids repeating every visual detail already visible in the image. It focuses on the changes we want. If the generated motion conflicts with the image, adjust the image or prompt. For example, a still with dramatic motion blur may make a request for a completely static scene harder to satisfy.

### 3.5 Reference-guided generation

Some services accept reference images, multiple frames, video, or other media to guide subject, style, camera behavior or continuity. Supported inputs and exact semantics differ. An identity reference might influence a character, whereas a first-frame input may establish a starting state; these are different forms of control. Consult the current documentation and conduct a short test before designing a production around one.

A reference helps communicate intent; it does not guarantee exact preservation. If a logo, UI or character must match precisely, inspect the frames or use a separate controlled layer. Also verify rights to use the reference and the service's terms for uploading it.

## 4. Pick the least complicated path that satisfies the shot

Ask four questions:

1. **Does the scene need movement within the generated image?** If no, a still with a gentle code-driven zoom may be enough.
2. **Do you need exact visual geometry or text?** If yes, build those elements in SVG, HTML or your editor.
3. **Do you need a specific composition?** If yes, create or select a reference image before generating motion.
4. **Can you afford variation?** If no, consider a recorded clip, a 3D scene, stock footage, or a deterministic animation instead.

Suppose the shot is a title over a softly moving star field. A still star field with a slow positional move may be cheaper and easier to control than a full generative video. If drifting smoke is central to the feeling of the shot, image-to-video may add useful organic movement. If the camera must travel past specific labeled components in a precise order, a 3D scene or code-driven graphic may be a better fit.

These options can coexist in the same video. You are choosing a technique for each shot, not pledging allegiance to one tool.

## 5. Write a brief before writing a prompt

A prompt is a request to a model. A *brief* describes the production problem, including details that may not belong in the final prompt. The brief gives you something stable to compare generations against.

Here is a practical shot brief:

```text
Shot ID: QL-03
Purpose: Introduce the idea that an index guides a search.
Duration in edit: approximately 6 seconds.
Format: 1080 × 1920, vertical, 30 fps final project.
Foreground: editable title and a three-part database diagram.
Background: stylized server room, not a literal product screenshot.
Composition: quiet dark left side; visual detail on the right.
Movement: slow forward camera move and restrained indicator-light motion.
Palette: deep navy, teal highlights, warm white text.
Audio: voiceover and licensed ambient bed added separately.
Must remain exact: title, diagram labels, product name, captions.
Generation constraints: no readable text, logos or identifiable people.
Review: no major geometry warping; title must remain readable on phone.
```

The brief is specific enough to guide your decisions while leaving the model room to produce an attractive background. It also names what should not be entrusted to the model: exact text and product identity.

### Why specify the purpose?

“Create a server room” tells the model what to depict. “Introduce the idea that an index guides a search” tells *you* what the audience should understand. If a visually stunning generation distracts from the diagram, the purpose helps you reject it. A shot succeeds when it supports the message.

### Why specify the edit duration separately?

A model may output only certain clip lengths, while your edit needs a different duration. You might generate a longer shot and use six seconds, or hold a still briefly before the generated movement. Avoid assuming a model can produce your exact duration or frame rate. Verify its current capabilities, and do not stretch footage so much that motion becomes visibly unnatural.

## 6. Build a small style bible

A *style bible* is a compact record of recurring visual decisions. It is not a long legal document or an unchangeable rule book. It prevents every new prompt from accidentally inventing a different visual world.

A useful starter version:

```yaml
project: QueryLens explainer
purpose: Explain one database concept to software developers
visual_mood: Clear, technical, calm, slightly cinematic
palette:
  background: '#07111F'
  surface: '#10243A'
  accent: '#35D7C0'
  text: '#F3F7FA'
typography:
  headline: Bold sans-serif, large and high-contrast
  body: Simple sans-serif, generous spacing
  code: Monospace, only where actual code is needed
shapes: Rounded rectangles and fine connecting lines
camera: Slow pushes and short lateral moves; no chaotic spins
lighting: Soft teal accents, dark backgrounds
text_policy: Render exact wording as an editable overlay
reference_assets:
  - approved-server-room-reference.png
  - approved-title-layout.png
```

The YAML above is a document format, not an API configuration for any particular generator. Save it as a project note and adapt the fields. A text description can be paired with reference images and annotated screenshots. Include *why* a reference is useful: “this lighting,” “this amount of empty space,” or “this typography hierarchy.” Without those notes, an agent may copy the wrong feature.

Be consistent without making every shot identical. A close-up and a wide shot can share a palette, lighting language and typography while using different compositions. Consistency helps the viewer feel they belong to the same project; variation keeps the video visually interesting.

## 7. Turn the brief into a prompt in layers

Prompting becomes easier when you separate concerns. The following structure is a planning aid, not a mandatory grammar:

1. **Subject and setting:** What is visible, and where?
2. **Composition:** What is prominent, and where is negative space?
3. **Style and lighting:** What visual treatment supports the story?
4. **Action:** What changes in the subject or environment?
5. **Camera:** How does the virtual viewpoint move?
6. **Constraints:** What elements should be avoided or reserved for overlays?

Start with a simple version:

> A stylized server room in a dark navy palette. The camera slowly moves forward.

Evaluate the output. If the title has nowhere to fit, add composition:

> A stylized server room in a dark navy palette. The camera slowly moves forward. Leave the left half visually quiet and dark for a title overlay.

If motion feels too busy, specify behavior:

> A stylized server room in a dark navy palette. The camera makes a smooth, slow forward move. Small teal indicator lights pulse subtly. The left half remains visually quiet and dark for a title overlay.

The point is not to make the prompt as long as possible. Every added phrase should clarify a decision. If a generation is wrong, change one or two meaningful variables so you can identify what improved it.

### A note on negative instructions

Statements like “no text” or “no people” can be useful, but providers differ in how well they follow negative language. Some offer separate negative-prompt fields; others do not. A model may still produce unwanted details. Use explicit positive composition instructions, inspect the result, and crop or regenerate if needed. Do not assume a negative prompt is an enforcement mechanism.

## 8. Direct the camera with concrete language

Many striking visuals come from understandable camera motion, not complicated effects. In a generated or 3D scene, imagine a camera observing the subject:

- **Push in / dolly in:** camera moves closer, increasing emphasis.
- **Pull back:** camera moves away, revealing context.
- **Truck:** camera moves sideways while maintaining a similar orientation.
- **Pan:** camera rotates left or right from its position.
- **Tilt:** camera rotates up or down.
- **Orbit:** camera moves around a subject.
- **Zoom:** the field of view changes; this can feel different from a physical move.

A generator may not obey these terms perfectly, and camera terminology can be interpreted differently. Describe both the term and the visual result: “The camera slowly moves sideways past the server racks, keeping the central rack near the middle of the frame.” This gives the model and the reviewer a clearer target.

For a tutorial video, prefer motion that gives the viewer time to read. A slow push creates depth without demanding much attention. Rapid orbiting, repeated cuts and flashing lights may be visually energetic but can compete with the explanation. When in doubt, animate the object that carries meaning and keep background motion quieter.

### Direct subject and environmental motion separately

Subject motion is the movement of the main object: a machine turning, a person walking, a chart rising. Environmental motion is secondary: particles drifting, lights blinking or clouds moving. Specify them separately when you need control:

> Keep the server racks stationary. The camera moves slowly forward while small indicator lights pulse and faint haze drifts in the background.

This does not guarantee still geometry, but it gives the model a less ambiguous goal than “everything moves cinematically.”

## 9. From still to motion: a reproducible production process

Let's design our six-second shot step by step.

### Step 1: create the layout as a still

Sketch a vertical frame in an editor or as simple HTML. Place the headline, diagram and caption area first. Then create a placeholder background with the same composition. The goal is to identify how much space the background actually has.

This may reveal that a “beautiful full-screen server room” is a poor background for the planned text. The useful image is one with low-detail regions where the important information will appear.

### Step 2: produce candidate stills

Use the shot brief and generate a small batch. Record the prompt and settings the provider makes available. Pick candidates using criteria tied to the edit:

- Is the composition usable behind the text?
- Does the palette match adjacent shots?
- Are there artifacts that will become more visible in motion?
- Is there unwanted text, a recognizable brand or an unintended subject?
- Can you crop it to the target aspect ratio without losing the point?

Select a strong starting image; do not select solely because a thumbnail looks impressive. Examine it at the actual intended resolution and crop.

### Step 3: animate the selected image

Give the generator the reference still and a concise motion description. Begin with one primary camera action and one secondary environmental action. More instructions can be added after you see the first result.

If the model supports multiple outputs, compare options against the same brief. Look for changes in architecture, bent lines, pulsing exposure, abrupt camera movements and distracting details. Some transformations are acceptable for an abstract background; they are less acceptable for a realistic product shot.

### Step 4: choose the useful section

A five-second generated clip does not need to be used from its first to last frame. The most stable three seconds may work better. Mark the usable in and out points in your shot log. If the shot must cover a longer narration, consider extending the sequence with a cut to a different visual rather than slowing the footage excessively.

### Step 5: compose exact information over it

Use your editing or code environment to add the title, diagram and captions. Adjust the background crop and darkness to support the overlay. Review the final composite, because a clip that looks attractive on its own may be too busy once text is added.

### Step 6: validate the final export

Inspect not just the editor preview but the exported file: playback, text, sound, edges, contrast and frame timing. Watch it on a small screen. If a headline is legible only when paused at full resolution, it is not yet doing its job.

## 10. Keep a shot log so iteration is explainable

A generation log prevents you from losing a successful prompt or paying to repeat a failed experiment. A simple CSV file is sufficient:

```csv
shot_id,variant,reference,prompt_summary,settings,outcome,decision
QL-03,A,server-still-a.png,slow push with teal lights,vertical; provider-default,good composition but lights too bright,revise
QL-03,B,server-still-a.png,slow push with softer lights,vertical; provider-default,stable motion and clear text space,select
QL-03,C,server-still-b.png,slow orbit with haze,vertical; provider-default,background too busy,reject
```

Use actual settings supplied by your provider, including model version, date, aspect ratio, requested duration, seed if available, and generation identifier when useful. Do not put API keys in this file. A seed is a reproducibility aid, not a universal guarantee: model updates, services and hidden settings may still change output.

A stronger log also records the source and rights of each input image, the cost or credit use, and the chosen in/out points. That information matters when you revisit a project or prepare it for publication.

### Compare variants fairly

When evaluating a prompt change, keep the other inputs as stable as the provider allows. Change the camera instruction, for example, while keeping the same reference and style. Multiple samples may still vary; a single better result does not prove a change always works. Your purpose is practical selection, not a statistically rigorous model evaluation.

## 11. Diagnose common generative artifacts

### Geometry warping

Straight lines bend, objects change shape, or architecture appears to melt. This may be acceptable in a surreal transition but distracting in a realistic interface or building.

Try a shorter shot, a smaller camera move, a simpler starting image, or a different generation. If the geometry needs to remain exact, animate a still with controlled transforms or use a real 3D scene. Do not conceal severe errors behind faster cuts if they make the explanation misleading.

### Flicker and exposure pulsing

The scene's brightness or texture changes unintentionally over time. Compare multiple frames and watch at normal playback speed. A less complex motion instruction or a different candidate might help. Subtle color correction may reduce the effect, but it cannot reliably repair missing information.

### Identity or style drift

A character, device or room changes appearance across shots. Use an approved style bible and reference assets where supported, keep shots short, and compare distinguishing features. For high-stakes identity consistency, controlled illustration or 3D models may be more suitable. Do not imply that a reference guarantees identical identity.

### Unwanted or incorrect text

A generated sign may look like text but contain invented letters. Crop it, cover it with a designed element, remove it through an appropriate editing technique, or regenerate. Place any wording that must be accurate in a separate text layer.

### Excessive movement

Busy backgrounds compete with narration and captions. Choose a calmer candidate, trim to a steadier section, or use a static background with a gentle controlled move. Slowing or stabilizing footage may introduce artifacts, so inspect the result.

### Resolution and aspect-ratio mismatch

A landscape output may not have enough information for a vertical crop. Reframe before generation when supported; otherwise plan a crop and test it at final resolution. Upscaling can improve apparent dimensions but cannot guarantee restoration of authentic detail. Avoid presenting generated details as factual evidence.

## 12. Continuity is a set of constraints

Continuity does not mean two shots must be visually identical. It means their differences make sense in sequence. Check:

- **Subject:** Is the same object recognizable and plausible across cuts?
- **Position:** Does a left-to-right action suddenly reverse direction without an editorial reason?
- **Lighting:** Are changes deliberate, or do they feel accidental?
- **Scale:** Does a device appear to change size relative to its surroundings?
- **Palette and treatment:** Do shots share the project's visual language?
- **Time:** Does one shot imply a different time of day or location?

For a developer explainer, continuity can be conceptual as well as visual. If a dot represents a query in one scene, suddenly changing it to represent a database row can confuse viewers. Define your symbols and keep them consistent.

A cut can hide small continuity differences, but it cannot fix a misleading story. Use the cut to change viewpoint or move to the next idea; do not treat it as permission to misrepresent the product.

## 13. Compositing: foreground, background, masks and clean plates

*Compositing* means combining multiple visual layers into one image. You already know a basic example: text placed over a photograph. More complex compositions may isolate a subject, change a background or add atmospheric effects.

An **alpha channel** represents transparency. Fully opaque pixels cover what is beneath them; fully transparent pixels reveal it; intermediate alpha values blend the two. A mask is a way to control that visibility across an image. Different formats and codecs support transparency differently, so verify the actual exported file if you need an alpha channel.

A **clean plate** is a background without the foreground element you intend to add or remove. Suppose a generated image shows a wall of servers and an unwanted floating label. A clean version without the label gives you a place to put your own exact text. Generating a clean plate can be preferable to trying to cover random text with a poorly matched patch.

A **matte** or mask can isolate a product, person or device from its background. Automated background removal can help, but inspect edges, hair, semi-transparent objects and motion. A hard halo around a subject is particularly noticeable against a dark background.

### Layer order matters

A useful order from back to front is:

1. Generated background footage.
2. Optional color tint or darkening layer.
3. Diagram panel and graphic shapes.
4. Exact title and labels.
5. Captions and any final branding.

If you darken the entire composite *after* adding the text, you may darken the text too. If you darken only the background layer, the text remains bright and readable. The same operation has a different effect depending on where it appears in the layer stack.

## 14. A runnable composite with Remotion

This example assumes a working Remotion project from Lesson 5. It uses a local file called `server-room.mp4` in the project's `public` folder. The video is a generated or licensed background you have permission to use. If you don't have one yet, add any local test video with the same filename; no API key or paid service is required.

Create `src/GeneratedBackdrop.tsx`:

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

export const GeneratedBackdrop: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const titleOpacity = interpolate(frame, [0, fps], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{backgroundColor: '#07111F', color: '#F3F7FA'}}>
      <OffthreadVideo
        src={staticFile('server-room.mp4')}
        muted
        style={{width: '100%', height: '100%', objectFit: 'cover'}}
      />
      <AbsoluteFill style={{backgroundColor: 'rgba(2, 9, 20, 0.68)'}} />
      <AbsoluteFill
        style={{
          padding: 80,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          gap: 36,
          fontFamily: 'Arial, sans-serif',
          opacity: titleOpacity,
        }}
      >
        <h1 style={{fontSize: 86, lineHeight: 1.05, margin: 0}}>
          Find the right data
        </h1>
        <div style={{display: 'flex', gap: 16, alignItems: 'center', fontSize: 36}}>
          <span>Search</span><span>→</span><span>Index</span><span>→</span><span>Result</span>
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

Register this component in the existing root, or adapt the following fragment to that root:

```tsx
import {Composition} from 'remotion';
import {GeneratedBackdrop} from './GeneratedBackdrop';

// Inside your registered root component's returned JSX:
<Composition
  id="GeneratedBackdrop"
  component={GeneratedBackdrop}
  durationInFrames={180}
  fps={30}
  width={1080}
  height={1920}
/>
```

The second block is intentionally a fragment: your project must have one registered root, and Lesson 5 covers its complete setup. Use the existing root rather than creating a second conflicting entry point.

Let's trace the rendering. `useCurrentFrame()` supplies the requested frame. At 30 fps, `fps` is 30, so the title's opacity goes from zero at frame 0 to one at frame 30. Clamping keeps it in the valid range before and after that interval. `OffthreadVideo` displays the background; `muted` avoids unintentionally mixing its audio. `objectFit: 'cover'` fills the frame and can crop edges, so inspect the crop. The translucent navy fill darkens the footage *before* the text is drawn. Finally, the title and diagram are independently editable HTML elements.

The composition lasts 180 frames, or six seconds at 30 fps. Ensure the source clip is long enough or intentionally edit its timing; do not assume it loops. A source with a different frame rate or aspect ratio may need extra attention. Preview, render using your project's documented commands, and inspect the actual MP4. Refer to [Remotion's API documentation](https://www.remotion.dev/docs/api) for version-specific behavior.

The diagram is deliberately simple. In a real explainer, you could make each node an SVG or React component, add timed emphasis, and place the caption area so it never overlaps the diagram. Do not imply that every database uses the same execution path merely because a simplified visual shows three boxes.

## 15. The equivalent conceptual workflow in HyperFrames

HyperFrames can serve as the composition environment instead of Remotion. Place the approved background clip in the project's assets, create timed media and overlay elements according to the current [HTML schema](https://hyperframes.app/docs/6-reference/html-schema), and animate the foreground with a seekable timeline. Run `npx hyperframes lint`, preview, render, and examine the exported file. The precise composition attributes and timeline registration should come from the installed HyperFrames skill and versioned documentation rather than guessed markup.

The underlying layers are the same: background video, darkening overlay, diagram, exact text and captions. The timing model is different: HyperFrames seeks the composition to the desired time, so use supported seekable animation patterns rather than relying on uncoordinated timers. You can also render the Remotion scene to a clip and use that clip in HyperFrames, but the title is then baked into that video unless you separately recreate it as an editable layer.

## 16. Use Claude and Codex as collaborators

An agent can help with briefs, code, shot comparisons and quality checks. It cannot know that a generated image matches your taste unless you supply the image or a description and review its assessment. Tell it what tools and assets are actually available. Do not let it silently call paid generation services or upload private files.

### Claude Code prompt: develop the shot brief

```text
I am making a 30-second vertical developer explainer about database indexes.
For a six-second scene, write a production brief for an atmospheric server-room
background with a separate editable diagram. Include composition, negative
space, lighting, camera movement, a still-image prompt, an image-to-video
motion prompt, and five concrete review criteria. Avoid performance claims.
Do not generate or purchase any assets. Explain why exact text should remain
separate from the generated shot.
```

### Codex prompt: implement and inspect the composite

```text
In this existing Remotion project, inspect the current files and add a six-second
1080x1920 composition using public/server-room.mp4 as a muted background. Add
an editable headline and a simple three-node diagram with a dark overlay behind
them. Animate the headline using frame-based timing. Use only existing local
assets. Render a draft if the project environment permits, inspect beginning,
middle, and ending frames, and report any missing assets or unverified steps.
Explain how to change the title, crop, and fade duration.
```

### A revision prompt for either agent

```text
At 00:03, the bright server lights make the diagram difficult to read.
Keep the foreground text bright. Darken only the background, reduce the
background movement if feasible, then rerender and inspect the same frame.
Describe the specific change and any remaining issues.
```

A strong prompt specifies the observable problem, the constraint, the requested change and the verification. It does not merely say “make it more professional.” You can still use subjective feedback, but translate it into things the agent can change: contrast, timing, spacing, color, visual density or movement.

## 17. Rights, privacy, cost and disclosure in the production workflow

Before uploading an image or recording, identify its owner, whether it contains sensitive information, and whether your provider permits the intended use. A reference image found online is not automatically licensed for commercial use. A real person's likeness or synthetic voice may require consent and may be subject to provider or platform restrictions. Follow the policies and law applicable to your situation.

Keep a simple asset manifest:

```text
Asset: server-room.mp4
Origin: generated using an approved provider
Input: original self-created reference image
Date and model: record actual values
Usage terms: link to terms reviewed on the generation date
Project use: atmospheric background, not a factual representation
Approval: record the responsible reviewer
```

The purpose of a manifest is to support a real decision later, not to create paperwork for its own sake. Record enough that you can answer where a visible asset came from and whether it can be reused.

Manage costs by creating still frames and low-cost drafts before high-quality renders where your provider supports those options. Set a budget, review pricing, and decide whether an agent may initiate generation. A locally rendered composition can still incur costs if it calls external services. Never embed provider API keys in client-side code or commit them to a repository.

## 18. A complete worked shot

Here is the entire decision chain for our QueryLens example:

1. **Message:** An index can help a database locate relevant data without checking every row; the actual execution plan depends on the query and database.
2. **Narration:** “An index gives the database another way to find matching rows.” This avoids a universal performance promise.
3. **Visual:** A query icon travels toward an index and then toward a highlighted result.
4. **Background:** A generated server room gives atmosphere but carries no factual claim.
5. **Reference:** A selected still has dark negative space behind the diagram and a consistent teal palette.
6. **Motion prompt:** Slow forward camera movement, subtle lights, stationary racks.
7. **Foreground:** Three code-rendered labeled nodes, with the query icon moving between them.
8. **Audio:** Record the narration separately; use a licensed or self-created ambient bed.
9. **Review:** Check whether the diagram is accurate, the labels are readable, the generation has no distracting warping, and the audio and captions match.
10. **Revision:** If the background obscures the diagram, darken or replace it. Do not regenerate accurate text unnecessarily.

This workflow combines the strengths of each medium. The generated clip supplies visual texture. Code supplies exact timing, labels and editability. Human review supplies intent, accuracy and taste.

## 19. Optional application

Create a single six-second background shot for one of your own developer topics. Write a brief, make a still image, animate it if you have access to a suitable model, and place a simple editable headline over it. If you do not have a generation service, use a licensed still or self-created graphic and animate the crop: the composition skills are the same. Save the brief, prompt, inputs, chosen output, rights notes and final render together.

## Further reading

- [Runway: Image-to-video prompting](https://help.runwayml.com/hc/en-us/articles/48324313115155-Image-to-Video-Prompting-Guide)
- [Runway: Text-to-video prompting](https://help.runwayml.com/hc/en-us/articles/42460036199443-Text-to-Video-Prompting-Guide)
- [Google Cloud: Video generation prompt guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/video/video-gen-prompt-guide)
- [Google Cloud: Generate videos from references](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/video/generate-videos-from-references)
- [Remotion API](https://www.remotion.dev/docs/api) and [HyperFrames HTML schema](https://hyperframes.app/docs/6-reference/html-schema)
