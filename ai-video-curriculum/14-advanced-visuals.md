# Lesson 14: Advanced Visual Techniques for AI-Assisted Videos

A camera appears to travel through a glowing data center. A diagram draws itself over the footage. A floating product interface rotates, catches a highlight and lands beside a title. These visuals can make a technical idea feel tangible, but the effect you see on screen rarely reveals how it was made. It might be a 3D scene, an image with layered parallax, an AI-generated shot, a screen recording composited over a background, or a combination of several techniques.

This lesson gives you a way to reason about that choice. You will learn the fundamentals of vector paths, Canvas, particles, 3D, masks, tracking, compositing, motion blur and color. You will also learn how to direct Claude or Codex to build these effects while maintaining control over timing and accuracy. The goal is not to master every visual tool in one sitting; it is to understand the pieces well enough to choose the simplest workable pipeline, explain what the agent is doing, and diagnose a disappointing result.

## 1. Start with the visual problem

Suppose a narration says: “Requests travel from users to a server.” There are many ways to visualize this:

- Show labeled boxes and an animated arrow.
- Show dots traveling along a path between the boxes.
- Show a stylized 3D network with a camera moving between nodes.
- Use generated footage of a glowing data center and overlay exact labels.

All four are possible. They do not communicate equally well. For a beginner lesson, labeled boxes and a single moving dot may make the causal relationship clearer than a dense 3D network. For a short launch teaser, atmospheric footage may help set a mood, but it should not be mistaken for a factual architecture diagram.

Before choosing a technique, identify the purpose of the shot: explain a relationship, orient the viewer, emphasize a change, establish mood, or demonstrate a real interface. Then list constraints: exact words, movement, background transparency, reuse, duration, budget, render time, and how easy the scene must be to revise. A complex technique is justified when it gives you control or expression you need, not merely because it is available.

| Technique | Most useful when | Common limitation |
| --- | --- | --- |
| CSS and SVG | Crisp type, diagrams, paths, UI and simple 2D effects | Complex lighting and physical depth require simulation or artistic tricks. |
| Canvas | Many custom-drawn elements or pixel-level effects | Elements are not automatically individual DOM nodes; custom drawing and accessibility need work. |
| Lottie | Reusing supported vector animation exported by compatible tools | Effects and features vary across exporters and renderers. |
| WebGL / Three.js | Interactive or programmatic 3D, lights and camera | Performance, determinism and setup are more involved. |
| Blender or other 3D renderer | Controlled modeling, materials, lighting and offline rendering | Requires 3D skills and may have long render times. |
| Generated image or video | Atmospheric imagery and fast visual exploration | Fine geometry, exact words and continuity can be hard to control. |
| Conventional compositor/editor | Layering footage, masks, tracked elements and finishing | Workflow portability and automation depend on the project and tool. |

These options are complementary. A video might use a generated background, an SVG diagram, a real product recording and a rendered 3D object, all placed in a Remotion composition. Another video may be entirely native HTML and CSS in HyperFrames.

## 2. Understand layers before effects

Compositing is the operation of combining visual layers into a final image. Think of a stack: a background at the bottom, a generated clip above it, a dark overlay, a diagram, captions, and a logo. The top visible layer covers the ones below according to its opacity and mask.

The essential distinction is between the source of a layer and the operation applied to it. A source may be a still image, video clip, a vector drawing, a 3D render or text. Operations may position, scale, crop, blur, recolor, mask or blend it. The final frame results from the ordered combination.

A simplified alpha compositing formula for one pixel is:

```text
result = foreground × alpha + background × (1 - alpha)
```

Here alpha ranges from 0 to 1: 0 means the foreground contributes nothing; 1 means the foreground completely covers the background. Actual image processing may also involve premultiplied alpha, color spaces and more complex blend modes. That simplified equation is enough to understand why a half-transparent foreground shows some background through it, but it is not a complete color-management model.

A practical example: place a dark translucent rectangle over bright generated footage and put white text on top. The overlay reduces background variation behind the text, improving readability. It is not always necessary to darken the whole frame: a localized gradient or panel can preserve more of the image. Review contrast across the entire moving clip, because a white title readable over a dark area may disappear when a bright object moves behind it.

### Transform order matters

A layer can be translated, scaled and rotated. These transformations operate relative to a coordinate system and an anchor. Rotating an object around its center looks different from rotating it around its top-left corner. Translating then rotating can produce a different result from rotating then translating because transformations are not generally commutative.

In CSS, set `transform-origin` deliberately. In 3D, define where an object's origin and pivot are. In either case, avoid assuming the screen's center is automatically the object's rotation center. If an interface card flies in from an unexpected direction, inspect its parent transforms as well as its own values.

## 3. Vector graphics: resolution-independent shapes

SVG stands for Scalable Vector Graphics. Rather than storing every pixel, an SVG usually describes shapes such as paths, circles and rectangles. A renderer converts those descriptions into pixels at the requested size. This makes SVG useful for diagrams and icons that must remain crisp in multiple output resolutions.

Here is a complete static HTML file. Save it as `network.svg.html` and open it in a browser. It shows two labeled nodes and a connecting arrow.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Simple network graphic</title>
  <style>
    body { margin: 0; background: #0d1525; color: white; font-family: sans-serif; }
    svg { display: block; width: min(100%, 900px); margin: 3rem auto; }
    .node { fill: #1c314b; stroke: #67e8d4; stroke-width: 3; }
    text { fill: white; font-size: 26px; text-anchor: middle; }
  </style>
</head>
<body>
  <svg viewBox="0 0 900 300" role="img" aria-label="Client sends a request to a server">
    <defs>
      <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5"
        markerWidth="8" markerHeight="8" orient="auto-start-reverse">
        <path d="M 0 0 L 10 5 L 0 10 z" fill="#67e8d4" />
      </marker>
    </defs>
    <rect class="node" x="80" y="90" width="230" height="120" rx="20" />
    <rect class="node" x="590" y="90" width="230" height="120" rx="20" />
    <path d="M 320 150 L 580 150" fill="none" stroke="#67e8d4"
      stroke-width="5" marker-end="url(#arrow)" />
    <text x="195" y="160">Client</text>
    <text x="705" y="160">Server</text>
  </svg>
</body>
</html>
```

The `viewBox` defines the SVG's internal coordinates. The browser can scale the SVG while preserving that coordinate system. The `rect` elements draw boxes; `rx` rounds their corners. The `path` starts at `M 320 150` and draws a line to `L 580 150`. A marker adds an arrowhead. The text is centered using `text-anchor: middle` and explicit x coordinates. The image label provides an accessible description for a browser; a rendered video also needs a meaningful voiceover or captions for information conveyed visually.

This is static, which is useful. Check the composition and words before adding motion. If you cannot read the diagram when still, animation will not reliably fix it.

## 4. Animate a path by revealing its stroke

A path can appear to draw itself. One common technique is to use a dashed stroke whose dash and gap are each as long as the path. By changing the dash offset, you slide the visible portion along the path. The underlying shape is not being physically drawn by a pen; the pattern on the stroke is moving.

For a straight path of known length 260 SVG units, a frame-driven formula is:

```js
function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function pathOffset(frame, startFrame, durationFrames, pathLength) {
  const progress = clamp((frame - startFrame) / durationFrames, 0, 1);
  return pathLength * (1 - progress);
}

console.log(pathOffset(0, 0, 30, 260));  // 260: hidden
console.log(pathOffset(15, 0, 30, 260)); // 130: halfway
console.log(pathOffset(30, 0, 30, 260)); // 0: fully visible
```

Use the result as `stroke-dashoffset`, with `stroke-dasharray` equal to the path length. In a Remotion component, calculate the value using `useCurrentFrame` and render it as an SVG property. In a HyperFrames composition, use a supported seekable timeline and check the current schema. A complex curved path may not have an obvious length; the browser's SVG APIs can measure a path, but measurements dependent on loading or layout need to be available deterministically before rendering. Avoid a hidden assumption that every arbitrary path has length 260.

A moving dot can also communicate travel. For a straight horizontal line from x=320 to x=580, calculate `x = 320 + 260 * progress`. For a curved path, a point-at-length function can return a position along the path. The visual meaning differs: drawing a line reveals a connection, while a moving dot represents an item traveling. Decide which claim you want to make. A moving dot is a metaphor for a request; it is not a measurement of actual network latency unless tied to real data.

## 5. Masks and reveals

A mask controls which parts of a layer are visible. Imagine a rectangle covering a word; the reveal expands from left to right. You can create this using a clipping rectangle, an SVG mask, CSS `clip-path`, or a renderer-specific effect. Each approach has different browser, performance and export implications.

The following complete browser example demonstrates a manually controlled reveal. Save it as `reveal.html`:

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Reveal concept</title>
<style>
  body { background:#101827; color:white; font:700 56px sans-serif; padding:60px; }
  .window { overflow:hidden; width:var(--reveal); white-space:nowrap; }
  input { display:block; width:320px; margin-top:40px; }
</style>
</head>
<body>
  <div class="window" id="reveal" style="--reveal: 50%">A clearer way to learn</div>
  <label for="amount">Reveal amount</label>
  <input id="amount" type="range" min="0" max="100" value="50">
  <script>
    const slider = document.querySelector('#amount');
    const reveal = document.querySelector('#reveal');
    slider.addEventListener('input', () => {
      reveal.style.setProperty('--reveal', `${slider.value}%`);
    });
  </script>
</body>
</html>
```

The `overflow: hidden` declaration clips content outside the window. The custom property sets the window's width. The slider illustrates the variable a timeline could drive. This is an interactive demonstration, not a deterministic video composition: an actual render must calculate the reveal amount from the requested frame or seekable time, not from a human moving a slider.

Masks are also used for screen replacement, text reveals, split screens and spotlighting. Hard edges create a sharp graphic treatment; soft edges create a gentler transition. Excessive blur can make a composition muddy or expensive to render. Make the mask serve the storytelling beat: reveal a label when the narration introduces it, or expose an interface when the feature is described.

## 6. Canvas: drawing pixels with instructions

HTML Canvas provides a drawing surface. JavaScript issues commands such as “draw a circle here” or “fill a rectangle there.” Unlike ordinary DOM elements, objects drawn on Canvas are not automatically separate elements after drawing. If you need to move one dot, a common approach is to clear the canvas and redraw the full scene for the current time.

The following self-contained file computes a frame from the slider and redraws three particles. It is a learning example, not a video renderer.

```html
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>Frame-driven particles</title></head>
<body style="background:#101827;color:white;font-family:sans-serif">
  <canvas id="scene" width="720" height="300"></canvas>
  <label>Frame <input id="frame" type="range" min="0" max="120" value="0"></label>
  <script>
    const canvas = document.querySelector('#scene');
    const ctx = canvas.getContext('2d');
    const slider = document.querySelector('#frame');
    const particles = [
      { x: 120, y: 90, speed: 1.1, radius: 8 },
      { x: 200, y: 160, speed: 0.7, radius: 12 },
      { x: 80, y: 230, speed: 1.5, radius: 6 },
    ];
    function draw(frame) {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = '#67e8d4';
      for (const particle of particles) {
        const x = (particle.x + frame * particle.speed) % canvas.width;
        ctx.beginPath();
        ctx.arc(x, particle.y, particle.radius, 0, Math.PI * 2);
        ctx.fill();
      }
    }
    slider.addEventListener('input', () => draw(Number(slider.value)));
    draw(0);
  </script>
</body>
</html>
```

The position is a direct function of the frame: `initial x + frame × speed`. The modulo operator wraps a particle across the canvas width. If you move the slider backwards to an earlier frame, the same positions return. This illustrates deterministic seeking. A video integration should call the draw function with the renderer's current frame or time through the renderer's supported interface; the example does not claim that moving a slider itself creates a video.

Canvas can handle many objects efficiently, but redrawing, shadows, filters and high resolution can still be expensive. Use it when custom drawing provides value. Use ordinary HTML/SVG when you need separate editable text and a small number of visual elements. The decision depends on the scene, not a blanket rule that one rendering surface is always faster.

## 7. Particles and reproducible randomness

Particles are small repeated elements: sparks, dots, dust or flowing data points. The impression of complexity comes from variation in position, size, speed and opacity. The practical challenge is that `Math.random()` can return different values each time the scene renders. If frames are rendered out of order or a preview is regenerated, particles may jump or change position.

There are two common solutions. First, precompute an array of particle properties once and store it with the project or video input. Second, generate properties using a seeded pseudo-random number generator. A seed is a starting value; with the same algorithm, seed and call order, it produces the same sequence. A seed is not a guarantee of identical outputs if the code or environment changes.

Here's a simple deterministic generator for visual examples, not for cryptography:

```js
function makeRandom(seed) {
  let state = seed >>> 0;
  return () => {
    state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
    return state / 2 ** 32;
  };
}
const random = makeRandom(42);
const dots = Array.from({ length: 4 }, () => ({
  x: random() * 720,
  y: random() * 300,
  radius: 3 + random() * 5,
}));
console.log(dots);
```

The generator updates an integer state and scales it to a number between 0 and 1. `Math.imul` performs 32-bit multiplication; `>>> 0` converts the result to an unsigned 32-bit integer. Use it only for decorative variation, not security. For each frame, calculate a dot's position from its stored initial parameters and the frame. Avoid modifying a global particle position by “one step” on each render call: a renderer may ask for frame 200 before frame 199.

A particle field should not compete with the message. Reduce particle contrast behind text, avoid creating a dense visual texture, and check motion at small sizes. If your viewer needs to follow a single data point, give that point a distinct color or shape and make background particles subordinate.

## 8. The 3D mental model: scene, camera, light

A 3D scene describes objects in a coordinate system. A camera determines what portion of the scene is visible and how it is projected onto a 2D image. Materials describe how surfaces respond to light. Lights illuminate the scene. The renderer computes an image from that arrangement for each point in time.

A product card floating in space might consist of a thin rectangular mesh, a material displaying the product UI as a texture, a background, one broad light, and a camera. If the camera moves closer, the card takes up more of the frame. If the card rotates, its apparent shape changes through perspective. If a light moves, the visible highlight changes even if the object stays still.

The crucial lesson is that “3D look” is not synonymous with a large number of objects. A single card with consistent perspective, soft lighting and a well-planned camera move can look more polished than a cluttered scene. Start with composition and lighting before adding particles and effects.

### Coordinate systems and transformations

A 3D point has x, y and z coordinates. Commonly x is left/right, y is up/down, and z is depth, but exact conventions and camera direction depend on the library. An object's local coordinates describe it relative to itself; world coordinates incorporate parent transforms. The camera transforms the world into what appears on screen. For debugging, ask: Is the object in view? Is the camera pointing at it? Is the material visible? Is there enough light? Is it behind another object or clipped by the near/far planes?

This resembles UI layout debugging: parent containers change a child's apparent position, and stacking order can hide elements. The extra dimension adds perspective and occlusion. A camera pointing away from the subject can yield an empty frame even when the object exists.

## 9. Three.js and Blender: choosing the boundary

Three.js is a JavaScript library for 3D scenes typically rendered with WebGL in a browser. It can fit naturally into web-based video systems when the integration can render the requested scene at a specified frame. Blender is a 3D creation application with modeling, animation, lighting and rendering tools. A Blender render can be exported as frames or video and imported into a composition. The practical difference is not that one is “real 3D” and the other is not; it is where you author the scene, how you drive time, and what remains editable in the final composition.

**Choose a live browser 3D scene** when data-driven parameters, reusable geometry or integration with a web project matter, and your renderer supports a deterministic time interface. Measure performance and verify graphics hardware compatibility.

**Choose a pre-rendered clip or frame sequence** when you need complex 3D, want the final composition to render more cheaply, or the live effect cannot be reliably sought. You can still move, crop, layer and time the clip later, but cannot change the 3D object's lighting inside the encoded pixels without returning to the source project.

**Choose a 2D illusion** when a tilted card and subtle shadows communicate the intended depth. A CSS perspective transform can be enough for a restrained launch graphic; it does not provide physically accurate 3D lighting or occlusion.

If you need transparent 3D output, choose a format and codec that actually preserve alpha, and verify the importer's interpretation. Not every MP4 supports useful transparency, and some formats use premultiplied rather than straight alpha. Test an edge against both light and dark backgrounds to catch halos. If your final scene does not require transparency, rendering against the intended background may simplify the workflow.

Consult [Three.js documentation](https://threejs.org/docs/) and [Blender's manual](https://docs.blender.org/manual/en/latest/) for current setup and APIs. Project-specific integrations must follow the relevant Remotion or HyperFrames documentation; not every interactive Three.js scene can simply be pasted into a composition and expected to seek correctly.

## 10. Camera language and visual motivation

A camera move can reveal information, follow a subject, change emphasis or make a cut feel continuous. A push-in moves the camera closer; a pull-back reveals context; a pan rotates the view; a truck moves sideways. A zoom changes focal length or a simulated field of view, which is visually different from physically moving the camera. In casual conversation people may call both “zooming,” but their perspective effects can differ.

A good motion plan names a start, end, duration and purpose. For example: “From 00:02 to 00:04, move slowly toward the highlighted cache card while the narration explains a cache hit.” A vague instruction such as “make it cinematic” leaves many choices unspecified. You can still use open-ended prompts for exploration, but document the result you select so you can revise it.

Keep camera movement compatible with text. Text attached to a moving 3D object may become too small, tilted or distorted to read. One solution is to place explanatory text in a 2D overlay that remains screen-aligned while the background moves. This makes the label precise and editable. It also makes clear that the overlay is a graphic, not part of the photographed or generated physical scene.

## 11. Tracking, keying and rotoscoping

Tracking estimates motion in a shot so another element can follow it. For example, you may attach a label to a moving device screen. A simple point tracker follows a recognizable feature; a planar tracker estimates the movement of a flat surface; 3D camera tracking attempts to infer camera motion and scene geometry. Each requires suitable visual information. Blur, occlusion, reflections and featureless surfaces can make tracking unreliable.

Keying removes pixels based on a property, commonly a color such as green. It can isolate a subject filmed against a controlled background. Keying quality depends on lighting, separation, hair, shadows and compression. A single hard color threshold can leave jagged edges or remove similarly colored clothing.

Rotoscoping creates a mask around a subject over time. It can be manual or assisted by AI segmentation. AI can speed up the first pass, but a moving hand, hair, transparency or occluded object still needs inspection. The principle is to separate the subject from its background; the method and quality differ with the footage.

For a product demo, avoid making the workflow harder than necessary. If the product screen is already a clean recording, place it directly inside a device mockup rather than tracking a screen in generated footage. Use tracking when the moving shot materially improves the story and the screen replacement can be made convincing.

## 12. Motion blur and temporal sampling

In real photography, a camera collects light over an exposure interval. Moving objects can appear blurred because their position changes during that interval. A synthetic frame computed at a single instant may look unnaturally sharp, especially during a fast transition. Motion blur approximates the accumulation of multiple positions during the exposure.

A simple conceptual model samples several times around the frame time and averages their images. This can require more rendering work. Some renderers offer optimized motion blur or post-processing; the exact behavior depends on the tool. Do not add blur to everything by default. It may make small type harder to read and conceal poor timing. Reduce speed or add a hold if text needs to be legible.

Consider a title sliding in over 12 frames at 30 fps: that is 0.4 seconds. It might benefit from a small amount of blur during the move, but the final hold should remain sharp. If the title moves 800 pixels in 0.4 seconds, it covers 2,000 pixels per second on average; that can feel abrupt on a phone. Adjust timing, distance and easing together. Motion blur is a finishing choice, not a replacement for good motion design.

## 13. Color, gradients and visual integration

When footage and graphics come from different sources, they may look disconnected. One image may be warm and low contrast; an interface may be bright and cool; a generated background may have saturated neon. You can unify them through an intentional palette, consistent contrast, shadows, subtle overlays and appropriate grain. Start with white balance and exposure if you have real footage, then add a restrained creative treatment.

Color correction fixes or balances an image; color grading makes creative choices about its look. The distinction is useful even though actual workflows can overlap. A stylized grade should not make captions illegible or distort a product's brand colors beyond acceptable limits.

Color management matters at the boundaries. Different files may use different color spaces, transfer functions and metadata. Preview environments can also interpret them differently. When a render looks washed out or unexpectedly saturated, compare the source, encoder settings and playback environment; do not assume changing CSS colors is the right fix. For consistent production, document the expected working and export settings and test on more than one display.

## 14. A complete example: layered data-center explainer

Let's design a 12-second shot explaining a simplified request flow. The video is a visual metaphor, not a measurement of network activity.

**Step 1: Define the story.** The viewer should see a request leave a client, reach a server, and receive a response. The narration uses simple language and avoids claiming that all real architectures contain only these two components.

**Step 2: Choose the sources.** Use either an authorized/generated server-room background clip or a static image with slow parallax. Draw client and server cards as SVG/HTML. Create exact text and arrows in the composition, not inside the generated background. Record or synthesize narration with appropriate rights, and create corrected captions.

**Step 3: Design the first frame.** Put the client on the left, the server on the right, and a clear empty corridor for the arrow. Darken the footage where the diagram sits. Test the labels at the final phone-sized display. The visual hierarchy is: diagram first, caption second, atmospheric background third.

**Step 4: Animate a request.** Over one second, reveal the arrow or move a bright dot from client to server. Then hold it long enough for the viewer to read. For the response, use a different color and label or a reversed arrow. At 30 fps, use frames deliberately: for example, request movement frames 60–89, hold from 90, response movement frames 150–179. These are illustrative timing decisions; adapt them to the actual voice recording.

**Step 5: Add depth carefully.** Slowly scale the background image from 1.00 to 1.03 over the shot while keeping the diagram fixed to the screen. This makes the image feel less static without changing the diagram's geometry. If using a video, check whether its own camera movement makes additional scaling distracting.

**Step 6: Composite and review.** Check the alpha edges, titles and captions across the brightest and darkest moments. Watch with sound and verify that the moving dot matches the narration. If the background causes visual confusion, replace or simplify it. Render a draft before spending time on particle effects.

**Step 7: Export and compare.** Check actual dimensions, frame rate, duration, and audio. Compare the phone view with a static frame and the full playback. Keep the background asset and project source with provenance so the scene can be revised later.

## 15. Ask Claude Code to construct an effect

```text
In the current Remotion project, build a 12-second 9:16 explainer scene:
a client card sends a request dot to a server card, then receives a response.
Use editable SVG and frame-driven timing. Use an existing local background if
available; otherwise create a simple CSS gradient, not a paid generation call.
Place captions in a separate safe area. First show a still layout, then add
motion. Render a draft, inspect the start, middle and end of each movement, and
explain the frame calculations. Do not claim the scene represents measured
network latency. Tell me which files and inputs control the appearance.
```

A productive follow-up names the visual result: “The arrow overlaps the subtitle at 00:04. Move the diagram upward, reduce the background contrast, and render the affected frames again.” This is more actionable than “make it pop,” although the latter can be useful when you are intentionally exploring creative directions.

## 16. Ask Codex to compare techniques

```text
Inspect this project and create two small, locally rendered alternatives for
an animated data flow: (A) an SVG path with a moving dot, and (B) a Canvas
version driven by the same frame number. Keep the message and timings the
same. Explain the tradeoffs in editability, accessibility, deterministic
rendering and performance. Use the installed framework's documented APIs;
label any code that is illustrative rather than executable. Render both,
inspect representative frames, and report what you actually verified.
```

This prompt uses the agent as both builder and teacher. It sets a fair comparison by holding the message and timing constant. It also asks the agent to distinguish verified results from expectations. If its environment cannot render, request complete source and clear instructions, but do not accept a claim that it visually checked files it could not open.

For AI image-to-video generation, a separate prompt to the generation tool could be: “A slow forward camera move through a dark, teal-lit server room; subtle indicator lights pulse; no text or logos; consistent lighting.” Start with an approved reference still when using an image-to-video workflow. Model behavior varies; review the selected result for warped equipment, inconsistent lights and unintended text before using it. Exact labels stay in the code-driven overlay.

## 17. Troubleshooting and performance

**The preview moves but the final render is frozen.** Check whether animation uses wall-clock timers or `requestAnimationFrame` without the renderer's time integration. A video renderer may capture frames at arbitrary times and cannot infer that an interactive loop should advance. Drive the visual from the requested frame or the framework's supported seeking mechanism.

**Random particles change between renders.** Replace unseeded randomness with stored values or a fixed, deterministic generator. Ensure the same number and ordering of random calls; adding a new call changes the subsequent sequence.

**The 3D scene is black or empty.** Check the camera position and orientation, near and far clipping planes, object scale, materials, lights, canvas size, asset loading and graphics support. Test one simple visible object before debugging a complex imported scene.

**Text flickers or appears in a fallback font.** Ensure the font is loaded and available before frame capture, use a local or otherwise reliable asset where appropriate, and check the renderer's supported font-loading method. Font licensing and deployment remain separate concerns.

**A transparent edge has a dark halo.** Check whether the source and importer agree on straight versus premultiplied alpha and whether the footage was rendered against a colored matte. Test on multiple backgrounds; the correct fix depends on the actual source and tool.

**The render is too slow.** First identify which layer is expensive. Heavy blur, large shadows, 3D, video decoding and multiple high-resolution layers can increase cost. Reduce unnecessary effects, preview at lower resolution, pre-render a stable layer, or render a shorter segment. Benchmark changes instead of assuming that one technique is always faster. Final output quality should be reviewed after optimization.

**The AI clip changes the subject's shape between frames.** Select a shorter, cleaner generation, use a better reference image, simplify the requested motion, or treat the clip as a background. A composited exact diagram can carry the important information while the generative layer provides mood.

## 18. Choosing a technique under real constraints

Imagine three requests. First, a 15-second tutorial about indexes with accurate labels and diagrams. Use SVG or HTML for the core explanation and possibly a subtle background. Second, a stylized app launch featuring a rotating device. Start with a 2D card if it meets the brief; use Three.js or a 3D render if a true camera move or realistic lighting matters. Third, an atmospheric montage about future computing. Generated shots may be appropriate, but exact product claims and interface text should be separately controlled.

In all three, choose what you want to remain editable. A text layer is easy to revise when separate from the background. A baked image may be hard to update. A pre-rendered 3D object is easy to assemble but requires reopening the 3D source to change its lighting. A live scene can be parameterized but may introduce rendering and compatibility complexity. These are tradeoffs, not rigid rankings.

You now have a vocabulary for looking at a video and asking: what are its layers, what moves, who controls time, which parts must be exact, and what must remain editable? Those questions let you direct an AI agent as a collaborator while preserving your own judgment about the story.

### References

- [SVG documentation](https://developer.mozilla.org/en-US/docs/Web/SVG), [Canvas documentation](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API), and [CSS transforms](https://developer.mozilla.org/en-US/docs/Web/CSS/transform).
- [Three.js documentation](https://threejs.org/docs/) and [Blender manual](https://docs.blender.org/manual/en/latest/).
- [Remotion documentation](https://www.remotion.dev/docs/) and [HyperFrames rendering](https://hyperframes.app/docs/3-guides/4-rendering).
- [Runway image-to-video prompting guide](https://help.runwayml.com/hc/en-us/articles/48324313115155-Image-to-Video-Prompting-Guide).
