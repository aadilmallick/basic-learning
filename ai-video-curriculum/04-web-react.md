# Lesson 4: HTML, CSS, JavaScript, SVG, and React for Video

Code-driven video tools build pictures from familiar web technologies. A title may be an HTML heading. A card can be a styled `div`. A diagram can be SVG. A Remotion scene is typically a React component whose output changes with the current frame. HyperFrames compositions use HTML and supported animation runtimes. When an AI agent generates a video project, the ability to read these pieces turns its output from a black box into something you can inspect, correct, and extend.

You do not need to become a full-time frontend engineer before making a video. You do need a practical mental model of how a browser constructs a visual scene and how code controls its appearance. This lesson teaches those prerequisites in the order they support the video work. The examples begin with a standalone web page, then introduce JavaScript and React. Later lessons connect these concepts to each renderer's actual timing and export API.

The running example is a small database-index explainer. It uses fictional labels and simple diagrams; it does not assert benchmark results or imply that all databases choose the same execution plan.

## 1. The browser as a visual canvas

A browser can display text, images, vector shapes, video, and interactive controls. It receives a description of the page, determines a layout, applies styling, and paints pixels. A code-based video renderer uses a browser or related rendering machinery to draw the scene for specific points in time, then combines the resulting frames into a video.

Three technologies have complementary jobs:

| Technology | Main responsibility | Example |
| --- | --- | --- |
| HTML | Describe elements and their relationships | A heading inside a card. |
| CSS | Define appearance and layout | White text, a dark background, and centered content. |
| JavaScript | Define behavior and calculate values | Change a highlight based on time. |

These are conceptual roles, not absolute walls. JavaScript can create HTML elements and change styles; CSS can also express animation. The division is useful because it gives you a starting point when diagnosing a problem: missing content often involves markup or data, positioning often involves layout, and incorrect timing often involves behavior.

A web page and a video frame are not identical products. A page may scroll and react to a user. A video frame has a fixed composition at a specific time. For video, you usually design within explicit dimensions and ensure that the renderer controls time. Still, the visual building blocks are often the same.

## 2. HTML: describing the objects in a scene

HTML is a markup language. It describes elements using tags. A heading might be written as:

```html
<h1>Find the right row</h1>
```

The opening tag is `<h1>`, the content is the text, and the closing tag is `</h1>`. An element can contain other elements:

```html
<section>
  <h1>Find the right row</h1>
  <p>An index helps narrow a search.</p>
</section>
```

Here the heading and paragraph are children of the section. The section is their parent. This parent-child relationship is important because layout and styles often apply to a parent and affect how its children appear.

### Attributes provide additional information

An attribute appears in an opening tag:

```html
<img src="diagram.png" alt="A query points to an index and a row" />
```

`src` tells the browser where the image is. `alt` provides a text alternative for contexts where the image cannot be seen or loaded. An image element does not wrap a closing tag in the same way a paragraph does.

Other useful attributes include `class`, which groups elements for styling; `id`, which identifies a specific element in a document; `width` and `height`, which can describe dimensions; and `aria-label`, which provides an accessible name in suitable contexts. Some frameworks attach specialized `data-*` attributes to elements. Those attributes are simply named data in HTML; a framework gives them additional meaning through its own documented conventions. Do not guess those conventions from the attribute name.

### The DOM is the page's element tree

The browser represents the document as a tree called the **Document Object Model**, or DOM. The markup's nesting becomes relationships between nodes. JavaScript can find those nodes and update them. For example:

```html
<h1 id="headline">Find the right row</h1>
<script>
  const headline = document.getElementById('headline');
  headline.textContent = 'Search with an index';
</script>
```

`getElementById` returns the element with the specified ID if it exists. `textContent` changes its text. The script is placed after the heading so the element exists when the script runs. In larger applications, code may instead wait for document readiness or use framework-specific lifecycle patterns.

For a video project, understand what creates an element before changing it. If React generates it from props, manually changing its DOM node can conflict with React's rendering. Edit the component's data or logic instead.

## 3. CSS: turning structure into a design

CSS applies visual rules to elements. A rule has a selector and declarations:

```css
.card {
  background: #18304a;
  color: #ffffff;
  padding: 24px;
  border-radius: 16px;
}
```

`.card` selects elements whose class includes `card`. Each declaration assigns a property such as `background` or `padding`. The browser combines applicable rules according to the cascade, specificity, and source order. If an element's style is not what you expect, inspect the computed style in browser developer tools; another rule may override yours.

### The box model

Most HTML elements can be understood as boxes. From inside outward, the box contains content, padding, a border, and margin:

- **Content** is where text or child elements appear.
- **Padding** adds space inside the border.
- **Border** surrounds the padded content.
- **Margin** adds space outside the border.

By default, a declared width may describe the content box rather than the total width including padding and borders. A widely used rule changes that calculation:

```css
* {
  box-sizing: border-box;
}
```

With `border-box`, an element declared as `width: 300px` includes its padding and border within that width. This simplifies composition work. It does not eliminate the need to consider margins or child overflow.

### Units: pixels, percentages, and viewport sizes

`px` is a CSS pixel, a coordinate unit used by the browser. It is not always one physical screen pixel on a high-density display. In video design, a composition may be defined in pixel dimensions, but preview scaling and device pixel ratios can affect how it appears on your monitor.

Percentages express values relative to a relevant containing dimension. For example, `width: 50%` is generally half the containing block's width. Viewport units such as `vw` and `vh` are relative to the browser viewport. Relative units can help responsive layouts, but a fixed-resolution video should be checked in the actual composition size and rendered output. Do not assume a layout that looks good in a resizable browser will automatically fit a 1080 × 1920 video.

`rem` is relative to the root font size; `em` is relative to a relevant font size. These can make a design system easier to scale. When exact frame coordinates matter, explicit values may be easier to reason about. The choice depends on the design and the renderer.

### Color and contrast

Hex colors such as `#18304a` specify red, green, and blue components. CSS also supports functions such as `rgb()` and `rgba()` or modern space-separated syntax. Alpha controls transparency. Transparency blends the element with whatever is behind it, so the resulting contrast depends on the background.

A light gray caption over a variable generated-video background may be readable in one frame and disappear in another. Use a stable panel, gradient, outline, or shadow where appropriate, and inspect the actual moving footage. Avoid encoding important meaning only through color; labels and shapes help viewers distinguish elements.

## 4. Layout: normal flow, flexbox, grid, and positioning

### Normal flow

Without special layout instructions, block elements such as headings and paragraphs generally appear one after another vertically. This is a useful default for text. If a scene contains several cards side by side, a layout system is usually clearer than manually assigning x positions to every card.

### Flexbox for one-dimensional arrangements

Flexbox arranges items along a main axis. In a row, `gap` controls the space between children, while `justify-content` distributes space along the main axis and `align-items` aligns along the cross axis.

```css
.flow {
  display: flex;
  gap: 16px;
  align-items: center;
}
```

```html
<div class="flow">
  <div class="node">Query</div>
  <div class="node">Index</div>
  <div class="node">Row</div>
</div>
```

In this example, the cards form a horizontal row. If you change `flex-direction` to `column`, the main axis becomes vertical. Flexbox is excellent for rows, columns, centered cards, and spacing a small set of elements.

### Grid for two-dimensional layouts

CSS Grid provides rows and columns. It is useful when a scene needs consistent alignment across several sections:

```css
.dashboard {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 20px;
}
```

The `fr` unit divides available space into fractions. Here the second column gets twice the flexible space of the first, after accounting for the gap and other constraints. Grid can be useful for a left-side explanation and right-side visual or for a consistent arrangement of cards.

### Positioning and layers

`position: relative` establishes a reference context for many absolutely positioned descendants. `position: absolute` removes an element from normal flow and places it using offsets such as `top` and `left` relative to its containing block.

```css
.scene {
  position: relative;
  width: 1080px;
  height: 1920px;
  overflow: hidden;
}

.badge {
  position: absolute;
  top: 100px;
  right: 80px;
}
```

This makes a badge sit near the upper-right corner of the scene. `overflow: hidden` clips content beyond the scene's bounds; that can be useful for entrances and masks, but it can accidentally cut off shadows or scaled elements.

`z-index` controls stacking in applicable stacking contexts. A larger value does not necessarily place an element above every element on the page because nested stacking contexts can constrain it. If a label disappears behind a panel, inspect both their stacking order and whether a parent creates a separate context through properties such as transforms or opacity.

Use absolute positioning where a video truly needs fixed placement. Use flexbox or grid where the relationship between items matters more than their exact coordinates. A scene can combine these techniques: an absolutely positioned panel may use flexbox internally.

## 5. A complete static scene you can run

Save this as `index-card.html`, then open it in a modern browser. It is a static illustration, not yet a video. The purpose is to see how markup and styling produce the composition before adding animation.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Database index explainer card</title>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      padding: 24px;
      background: #09111f;
      font-family: system-ui, sans-serif;
    }
    .scene {
      width: min(100%, 720px);
      aspect-ratio: 16 / 9;
      padding: 6%;
      border-radius: 24px;
      color: #f8fafc;
      background: linear-gradient(135deg, #173354, #102b31);
      overflow: hidden;
    }
    .eyebrow {
      color: #78e3c3;
      font-size: 14px;
      font-weight: 700;
      letter-spacing: 0.12em;
      text-transform: uppercase;
    }
    h1 {
      margin: 10px 0 8px;
      font-size: clamp(24px, 4vw, 42px);
      line-height: 1.1;
    }
    .description { color: #c7d9e6; font-size: 17px; }
    .flow {
      display: flex;
      gap: 14px;
      margin-top: 8%;
    }
    .node {
      flex: 1;
      min-width: 0;
      padding: 18px 10px;
      border: 1px solid #5d9f9b;
      border-radius: 12px;
      background: rgba(9, 27, 41, 0.7);
      text-align: center;
      font-weight: 700;
    }
  </style>
</head>
<body>
  <main class="scene">
    <div class="eyebrow">Database fundamentals</div>
    <h1>Find the right row</h1>
    <p class="description">A simplified path from a query to a matching row.</p>
    <div class="flow" aria-label="Query, index, and row">
      <div class="node">Query</div>
      <div class="node">Index</div>
      <div class="node">Row</div>
    </div>
  </main>
</body>
</html>
```

The `.scene` establishes a 16:9 viewport. The `aspect-ratio` property preserves that shape as its width changes, and `overflow: hidden` clips anything that exceeds the rounded container. The scene's padding gives the content breathing room. Inside it, `.flow` uses flexbox, and each `.node` uses `flex: 1` to take a share of the available width.

The `clamp()` font-size expression chooses a responsive value bounded by minimum and maximum sizes. This is useful in a browser preview but should be reviewed at the target frame size. If this were a final video, you would also inspect its smallest display size and ensure platform overlays do not cover important content.

### What to change first

Try changing the heading text. Observe that the layout remains intact if the title is a similar length. Now try a much longer title. It may wrap or occupy space intended for the diagram. This is a real template-design concern: editable content can vary. A reusable video must define limits or adapt its layout intentionally.

Try changing `.flow` to `flex-direction: column`. The elements stack, but the short 16:9 scene may not have enough height. The CSS is valid; the design is not necessarily suitable for that content and canvas. Code correctness and composition quality are separate checks.

## 6. JavaScript fundamentals for animation

JavaScript calculates values and directs behavior. If you know another programming language, much of the syntax will look familiar. The important point is to recognize data and control flow when an agent writes scene logic.

### Values and variables

```js
const title = 'Find the right row';
const durationSeconds = 4;
const showIndex = true;
```

`const` creates a binding that cannot be reassigned. The values here are a string, a number, and a boolean. Objects and arrays are also common:

```js
const scene = {
  title: 'Find the right row',
  durationSeconds: 4,
  labels: ['Query', 'Index', 'Row'],
};

console.log(scene.title);       // Find the right row
console.log(scene.labels[1]);   // Index
```

The object groups related properties. The array stores an ordered collection; indexing begins at zero. Note that `const` prevents rebinding `scene`, but does not automatically make its nested properties immutable. For predictable rendering, prefer treating configuration data as immutable rather than changing it unexpectedly during rendering.

### Functions turn inputs into outputs

```js
function secondsToFrames(seconds, fps) {
  return Math.round(seconds * fps);
}

const entranceFrames = secondsToFrames(0.8, 30);
console.log(entranceFrames); // 24
```

This function takes two inputs and returns a result. Naming it makes its intent clear, and centralizing the conversion helps avoid inconsistent calculations. Functions are also values in JavaScript, so you will encounter arrow function syntax:

```js
const secondsToFrames = (seconds, fps) => Math.round(seconds * fps);
```

Both examples express the same conversion. Arrow functions differ from regular functions in some language behavior, including how they handle `this`; that distinction is not needed for the basic scene calculations here.

### Arrays and `map`

A video scene often renders a similar element for each item in data. `map` transforms each item into a new value:

```js
const labels = ['Query', 'Index', 'Row'];
const numbered = labels.map((label, index) => `${index + 1}. ${label}`);
console.log(numbered); // ["1. Query", "2. Index", "3. Row"]
```

The callback receives the current item and its index. Template literals use backticks and `${...}` to insert expressions into a string. In React, a similar `map` can produce a list of elements. In a timing calculation, `index` can produce a stagger, such as `start + index * delay`.

### Conditions

```js
const currentTime = 2.4;
const indexIsHighlighted = currentTime >= 1.5 && currentTime < 3;

if (indexIsHighlighted) {
  console.log('Highlight the index');
}
```

This uses a half-open time interval: the highlight begins at 1.5 seconds and ends before 3 seconds. Such a convention makes adjacent intervals easier to combine without overlap. A video renderer's exact frame and sequence semantics may differ, so verify the framework's documentation and the boundary frames.

### Modules

As projects grow, split code into files. One file can export a function:

```js
// timing.js
export function secondsToFrames(seconds, fps) {
  return Math.round(seconds * fps);
}
```

Another can import it:

```js
// scene.js
import { secondsToFrames } from './timing.js';

console.log(secondsToFrames(2, 30));
```

These files must run in an environment configured for JavaScript modules. In a browser, a script can use `type="module"`; in a Node or bundled project, configuration depends on the project. Do not paste the second fragment into an unrelated runtime and assume imports will work without its setup.

## 7. A tiny data-driven browser interaction

The following complete page uses JavaScript to select one node. Save it as `highlight.html` and open it in a browser. The buttons emulate named points in a timeline so you can see the data-to-style relationship. A video renderer later replaces the button-driven state with a frame or timestamp supplied by the renderer.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Highlight a diagram</title>
  <style>
    body { font-family: system-ui, sans-serif; background: #111827; color: white; padding: 32px; }
    .flow { display: flex; gap: 12px; margin: 24px 0; flex-wrap: wrap; }
    .node { padding: 16px; border: 2px solid #63748b; border-radius: 12px; }
    .node.active { border-color: #55e6ba; background: #1d4a45; }
    button { padding: 10px 14px; margin-right: 8px; }
  </style>
</head>
<body>
  <h1>A simplified lookup</h1>
  <div class="flow" id="flow"></div>
  <div id="controls"></div>
  <script>
    const labels = ['Query', 'Index', 'Row'];
    const flow = document.getElementById('flow');
    const controls = document.getElementById('controls');
    const nodes = labels.map((label) => {
      const node = document.createElement('div');
      node.className = 'node';
      node.textContent = label;
      flow.appendChild(node);
      return node;
    });

    function render(activeIndex) {
      nodes.forEach((node, index) => {
        node.classList.toggle('active', index === activeIndex);
      });
    }

    labels.forEach((label, index) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.textContent = `Highlight ${label}`;
      button.addEventListener('click', () => render(index));
      controls.appendChild(button);
    });
    render(0);
  </script>
</body>
</html>
```

`document.createElement` creates a node; `appendChild` inserts it into its parent. `classList.toggle('active', condition)` adds the class when the condition is true and removes it when false. The CSS rule `.node.active` applies to an element having both classes. The `render` function is deliberately separate from the click handler, so another time source could choose the active index.

The example directly manipulates the DOM because it is plain JavaScript. A React component should normally express the same state in its returned markup instead of imperatively changing nodes behind React's back.

## 8. What React adds

React lets you describe user interfaces as components. A component is a function that returns a description of what should appear. The description often uses **JSX**, a syntax resembling HTML embedded in JavaScript or TypeScript.

```jsx
function SceneTitle() {
  return <h1>Find the right row</h1>;
}
```

`SceneTitle` is a component. The uppercase initial distinguishes a custom component from a lowercase HTML element in JSX. You can use it inside another component:

```jsx
function Scene() {
  return (
    <section>
      <SceneTitle />
      <p>A simplified lookup.</p>
    </section>
  );
}
```

React assembles these pieces into a tree. A video composition can use the same idea: a scene contains a title, cards, an arrow, and perhaps captions. The component tree makes it possible to reuse those parts and reason about their inputs.

### Props: component inputs

A component becomes reusable when it accepts data as props:

```jsx
function SceneTitle({ text }) {
  return <h1>{text}</h1>;
}

function Scene() {
  return <SceneTitle text="Find the right row" />;
}
```

`{ text }` in the function parameter destructures the `text` property from the props object. Curly braces inside JSX evaluate a JavaScript expression. This example gives the title an explicit input, so another scene can reuse the same component with different text.

Props flow from parent to child. If a title should change at a particular time in a video, the parent can calculate the appropriate value and pass it down. Avoid hiding important timing or content decisions inside deeply nested components unless the component truly owns that behavior.

### JSX is not HTML pasted into JavaScript

JSX resembles HTML but follows JavaScript and React conventions. For instance, use `className` rather than HTML's `class` attribute:

```jsx
<div className="node">Index</div>
```

Inline styles are JavaScript objects, so many CSS property names use camelCase:

```jsx
<div style={{ backgroundColor: '#18304a', borderRadius: 12 }}>
  Index
</div>
```

The outer braces insert a JavaScript expression into JSX; the inner braces create the object. React typically interprets certain numeric style values such as `borderRadius: 12` as pixels. Some properties are unitless, and custom values can be strings. Consult React's style documentation when the exact unit matters.

A React component must return one root element, or a fragment such as `<>...</>` that groups siblings without adding a DOM wrapper. JSX is transformed by the project's tooling; a browser does not execute arbitrary JSX directly from a plain script tag without a suitable build process.

## 9. A complete React example in an existing project

The following example assumes a working React project whose entry point supports JSX and imports CSS. If you do not have one, use the current official React guidance or the setup for the video framework you choose. This is a normal React illustration, not a complete Remotion composition.

Create `src/App.jsx`:

```jsx
import './App.css';

const defaultLabels = ['Query', 'Index', 'Row'];

function DiagramNode({ label, active }) {
  const className = active ? 'node node--active' : 'node';
  return <div className={className}>{label}</div>;
}

function LookupDiagram({ labels, activeLabel }) {
  return (
    <div className="flow" aria-label="Simplified lookup diagram">
      {labels.map((label) => (
        <DiagramNode
          key={label}
          label={label}
          active={label === activeLabel}
        />
      ))}
    </div>
  );
}

export default function App() {
  return (
    <main className="scene">
      <p className="eyebrow">Database fundamentals</p>
      <h1>Find the right row</h1>
      <p>A simplified path from a query to a matching row.</p>
      <LookupDiagram labels={defaultLabels} activeLabel="Index" />
    </main>
  );
}
```

Create `src/App.css`:

```css
* { box-sizing: border-box; }
body {
  margin: 0;
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 24px;
  background: #09111f;
  font-family: system-ui, sans-serif;
}
.scene {
  width: min(100%, 720px);
  aspect-ratio: 16 / 9;
  padding: 6%;
  color: white;
  background: linear-gradient(135deg, #173354, #102b31);
  border-radius: 24px;
}
.eyebrow { color: #78e3c3; text-transform: uppercase; letter-spacing: .1em; }
h1 { margin-bottom: 8px; }
.flow { display: flex; gap: 14px; margin-top: 8%; }
.node {
  flex: 1;
  padding: 18px 10px;
  border: 2px solid #5d9f9b;
  border-radius: 12px;
  text-align: center;
}
.node--active { background: #236357; border-color: #78e3c3; }
```

Your existing project's entry point must render `App`; many starter projects already provide this. For a typical React DOM entry point, the relevant code looks like this, assuming a corresponding `<div id="root"></div>` in the HTML:

```jsx
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.jsx';

createRoot(document.getElementById('root')).render(<App />);
```

The `labels.map` expression creates one `DiagramNode` for each label. The `key` helps React identify list entries across updates. Here the labels are unique and stable, so they are adequate keys; if labels can repeat or change, use a stable unique identifier from the data instead. `activeLabel` controls which node receives the active style. This example is static because `activeLabel` is fixed to `"Index"`.

In a video project, a parent might choose the active label from the current frame and pass it down. The component itself does not need to know whether that choice came from a timeline, an editor, or a test. This separation makes it easier to reuse and inspect.

## 10. TypeScript: making component contracts explicit

TypeScript adds static type checking to JavaScript. It can catch mismatched values during development, before the code runs. It does not automatically validate untrusted data at runtime, and type annotations are removed or transformed as part of building the project.

A typed component might look like this in a `.tsx` file:

```tsx
type DiagramNodeProps = {
  label: string;
  active: boolean;
};

export function DiagramNode({ label, active }: DiagramNodeProps) {
  return (
    <div className={active ? 'node node--active' : 'node'}>
      {label}
    </div>
  );
}
```

The `DiagramNodeProps` type says that `label` should be a string and `active` should be a boolean. If a caller passes `active="yes"`, a properly configured TypeScript project can report the mismatch. The type describes the expected contract; it does not provide the CSS or guarantee the design is readable.

A scene configuration can also be typed:

```ts
type SceneConfig = {
  title: string;
  durationInFrames: number;
  accentColor: string;
};

const scene: SceneConfig = {
  title: 'Find the right row',
  durationInFrames: 120,
  accentColor: '#78e3c3',
};
```

If configuration is loaded from a JSON file, network response, or user form, validate the actual values at runtime as well. A TypeScript annotation alone cannot prevent a malformed external file from containing a negative duration or missing title.

## 11. React rendering and video timing

A React component describes what the interface should look like for its inputs. In a frame-driven video, those inputs include a frame or time value supplied by the video framework. A simple conceptual function could choose an active node:

```js
function activeLabelAtFrame(frame, fps) {
  const seconds = frame / fps;
  if (seconds < 1) return 'Query';
  if (seconds < 2) return 'Index';
  return 'Row';
}
```

At 30 fps, frame 15 selects `Query`, frame 45 selects `Index`, and frame 75 selects `Row`. The function is deterministic for its inputs. A React composition can pass its result into `LookupDiagram`. The framework-specific hook or mechanism that supplies `frame` belongs to the relevant renderer; do not call a Remotion hook in an ordinary React app and expect it to work without a Remotion composition context.

This pure calculation is useful because a renderer may request frames out of order or in parallel. The output for frame 75 should not depend on whether frame 74 happened to run first. Avoid relying on a wall-clock timer or an incrementing counter to determine export state. Interactive web state and video timeline state solve different problems, even when both are implemented with React.

### Effects and asynchronous loading

A web app may use effects to fetch data or update the page after it first renders. Video export adds a timing concern: a renderer must know when required assets are ready. If an image or font loads after a frame has been captured, the export can contain missing or inconsistent content. Use the video framework's documented asset-loading and render-waiting mechanisms where needed, and test the actual export. Do not invent a delay based on how quickly your machine happened to load an asset once.

## 12. SVG: precise diagrams that scale

SVG stands for Scalable Vector Graphics. It describes shapes and paths using coordinates rather than storing a fixed grid of colored pixels. A browser can scale these shapes for different output sizes. SVG is useful for icons, arrows, lines, diagrams, and charts with crisp edges.

Here is a complete, standalone SVG file. Save it as `lookup.svg` and open it in a browser:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 180" role="img" aria-labelledby="title">
  <title id="title">Query, index, and row</title>
  <rect width="600" height="180" rx="20" fill="#102b3c" />
  <g fill="#204c57" stroke="#78e3c3" stroke-width="3">
    <rect x="30" y="55" width="130" height="70" rx="12" />
    <rect x="235" y="55" width="130" height="70" rx="12" />
    <rect x="440" y="55" width="130" height="70" rx="12" />
  </g>
  <g fill="#fff" font-family="sans-serif" font-size="24" text-anchor="middle">
    <text x="95" y="98">Query</text>
    <text x="300" y="98">Index</text>
    <text x="505" y="98">Row</text>
  </g>
  <g stroke="#fff" stroke-width="4" fill="none">
    <path d="M 170 90 H 220" />
    <path d="M 375 90 H 425" />
  </g>
</svg>
```

`viewBox="0 0 600 180"` defines the internal coordinate system. A rectangle's `x`, `y`, `width`, and `height` place it within that system. A `path` uses drawing commands: `M` moves to a point and `H` draws a horizontal line. The `<g>` element groups shapes that share styling.

In a React JSX file, inline SVG uses JSX attribute conventions; some hyphenated SVG attributes become camelCase, such as `strokeWidth` and `textAnchor`. Check the framework's current conventions if an attribute is ignored. In a standalone `.svg` file, the hyphenated SVG attributes shown above are valid.

### SVG text and fonts

Vector shapes scale cleanly, but text still depends on font availability and rendering. If the chosen font is absent during export, a fallback can change line breaks and alignment. Load fonts using the relevant renderer's documented method, verify licensing, and inspect the final output. Converting text to paths can lock its shape but makes it harder to edit or access; it is a tradeoff, not a default requirement.

### Animating SVG

A path's appearance can be animated by changing stroke properties, opacity, transform, or a clipping mask. One common reveal uses a dashed stroke and adjusts its offset. The geometry and timing need to be computed or controlled by the renderer. For complex diagrams, a sequence of small, clearly labeled changes is usually more informative than drawing every line simultaneously.

## 13. Choosing between HTML, SVG, Canvas, image, and video

| Medium | Strong at | Considerations |
| --- | --- | --- |
| HTML/CSS | Text, cards, layout, UI-like graphics | Font loading, wrapping, and layout must be checked at output size. |
| SVG | Shapes, paths, scalable diagrams and icons | Complex filters or huge SVG trees can increase rendering cost. |
| Canvas | Custom pixel drawing and large numbers of graphical elements | You must manage drawing and time; individual elements are not automatically DOM nodes. |
| Raster image | Photos, textures, generated stills and screenshots | Scaling up can reveal insufficient resolution; text is baked in. |
| Video clip | Recorded demos and generated footage | Exact internal elements are baked in; consider codec, timing and audio. |

A single scene can combine all five. For example, a generated background video can sit behind HTML captions and an SVG arrow. The decision is about the properties you need: editability, fidelity, performance, and the ability to compute a reliable frame.

## 14. Designing a reusable scene contract

A reusable component should expose the values a creator is likely to change and keep internal implementation details private. For an explainer card, useful inputs may include `title`, `description`, `labels`, `accentColor`, and the active label. Timing can be passed separately or owned by the surrounding composition.

Avoid making every CSS property a configurable prop immediately. Too many controls make it difficult to preserve a consistent visual system. Begin with the content and a few meaningful design choices. Add a parameter when a real use case requires it.

Also define constraints. If the card can display only a short title, document an approximate length and provide a fallback for overflow. If a label is missing, decide whether to omit the node or report an error. If a color is configurable, check contrast against the actual background. A flexible template is useful only if its variants remain legible and accurate.

## 15. Common mistakes and how to diagnose them

**The element is missing.** Inspect the DOM or React component tree. Confirm that the data exists, the component returns the element, and conditional logic is true. Then inspect opacity, display, clipping, and stacking. A missing element is not always a data problem.

**The element is in the wrong place.** Identify its layout parent and containing block. Check whether flexbox, grid, margins, absolute offsets, or transforms determine its position. Remove one layer of styling at a time.

**The same CSS works in one scene but not another.** Look for inherited styles, more specific selectors, parent size, and nested stacking contexts. A `width: 50%` value depends on the containing block, not a universal video width.

**A React list gives a key warning.** Supply a stable unique key to each sibling created by `map`. Avoid array indices if items can reorder or change identity, because React may associate state with the wrong item.

**The output changes between frames.** Find any wall-clock time, unseeded randomness, asynchronous request, or stateful animation that is not controlled by the renderer. Compute the appearance from the frame or use the framework's supported timeline mechanism.

**Text wraps unexpectedly.** Check the exact font, font loading, width, font size, line height, and actual content. A fallback font can change measurements. Test long but valid inputs and the target video resolution.

**The example does not start.** Distinguish a standalone HTML file from a React component that needs a project and build tool. Check the terminal error, entry point, import paths, installed dependencies, and file extension before changing scene logic.

## 16. Asking Claude Code and Codex to teach as they work

An agent can write an entire composition quickly, but that speed can conceal assumptions. Ask for a small, inspectable change and a plain-language explanation. Supply the repository context, target dimensions, content, and verification steps. The following prompts can be adapted to either agent.

### Claude Code: explain an existing scene

```text
Inspect the existing video project and explain how one scene becomes pixels.
Identify its HTML or React component tree, the CSS or inline styles that control
layout, and the code that determines its animation time. Explain how props and
frame values reach the visible elements. Do not modify files yet. Point out any
version-specific APIs and link to the project's installed documentation or
verified official references. Use a small diagram and concrete file references.
```

This prompt requests understanding before mutation. It is useful when inheriting a generated project whose structure is unfamiliar. The agent should distinguish what it actually found from what it inferred.

### Codex: refactor a repeated diagram

```text
In this project, find the repeated query, index, and row cards. Refactor them
into a reusable component driven by an array of data, while preserving the
current rendered appearance and timing. Keep stable keys, do not change the
meaning of the diagram, and explain the component props, map operation, and
styles. Run the project's relevant checks and render representative frames if
the toolchain supports it. Report what you actually verified and any gaps.
```

The requirement to preserve appearance matters: a structurally cleaner component is not an improvement if labels shift or a scene becomes unreadable. Ask for before-and-after screenshots or rendered frames when visual behavior is important.

### A targeted follow-up for either agent

```text
The title wraps onto three lines in the 9:16 export. Explain which parent width,
font, font size, and line-height determine the wrap. Propose two fixes with
tradeoffs. Implement the one that preserves the intended visual hierarchy,
then render and inspect the affected frame at the actual output dimensions.
```

This prompt names the symptom and requests a causal explanation. It avoids prescribing an arbitrary font-size reduction, which might fix wrapping while making the title too small to read.

## 17. Optional application: a static explainer scene

Create a scene with an editable title, a one-sentence explanation, and three diagram nodes. Start with the standalone HTML example. Change the copy, colors, and layout while retaining sufficient contrast. Then represent the nodes as data and render them from a reusable React component in a configured project.

As you work, keep the responsibilities clear. HTML or JSX describes the elements. CSS handles their arrangement and appearance. Data supplies the labels. A later timing function can choose the active node. This separation lets you change the story without rewriting the entire layout and lets you change the design without changing the underlying explanation.

Inspect the scene at the intended aspect ratio. Try a short and a long title. Confirm that the diagram does not overlap captions or leave the frame. If the scene must support multiple aspect ratios, create layout rules for each rather than assuming that scaling a landscape design into a vertical frame will remain readable.

Finally, use an agent to explain one part of your own code back to you. Compare its explanation with the actual files and browser output. If the agent describes an API or behavior that does not exist in the project, ask it to cite the exact file and line or check the official documentation. The aim is to retain ownership of the mental model while using the agent to accelerate implementation.

## Where this leads

You can now read the core pieces of a code-driven composition: markup creates a tree of elements; CSS lays them out; JavaScript calculates values; React packages the scene into reusable components; TypeScript documents and checks contracts; SVG provides precise scalable graphics. The next lesson applies those foundations to a real Remotion composition, where the renderer supplies a frame and the component calculates what should be visible at that frame.
