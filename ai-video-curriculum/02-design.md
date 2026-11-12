# Lesson 2 — Design foundations for readable motion

In the previous lesson, you planned a short video explaining how a database index can offer an alternate search path. Now you will design what the viewer sees at a single moment. This may feel like a pause before the exciting part, but the pause has a purpose: animation moves a design through time. If the design is difficult to understand while still, movement generally gives the viewer more work to do, not less.

By the end of this lesson, you will know how to arrange a frame around one visual priority, use spacing and alignment to show relationships, choose readable type and contrast, and build a small reusable visual system. You will also create a complete HTML/CSS style frame and learn how to give Claude Code or Codex precise visual revision instructions. Later lessons animate these elements with frame-aware tools.

The examples use a vertical video frame for a developer audience. The principles apply to horizontal video, presentations, user interfaces and diagrams, although the available space and viewing conditions change the design decisions.

## 1. Why a static frame comes first

Imagine watching a video on a phone. The screen shows a headline, a database table, an index card, a caption, a logo, a moving background and a call to action. Each element may be individually attractive, but the viewer has only a moment to decide where to look. If every element has the same size, brightness and movement, none of them establishes a clear priority.

A **style frame** is a still image showing the intended look of a significant moment in the video. It answers visual questions before you animate:

- What is the main thing the viewer should notice?
- Can they read the text at the intended display size?
- Do related pieces look related?
- Can the caption fit without covering the explanation?
- Do colors, type and shapes feel like parts of one system?

A style frame is not the same as a storyboard frame. A storyboard is primarily concerned with sequence and meaning: what happens, in what order, and why. A style frame explores visual treatment: how a particular moment looks. In a small project, one still can serve both roles, but keeping the questions distinct helps you avoid polishing a scene before deciding whether the scene belongs in the story.

## 2. Hierarchy: decide what gets noticed first

**Visual hierarchy** is the order in which elements appear to matter. You can influence it with size, contrast, position, spacing, color, shape, focus and later, motion. Hierarchy does not mean the viewer's eyes will follow a perfectly predictable route. It means the design gives them useful cues about where to begin.

Consider a frame with these elements:

```text
A. Headline: “Find one user”
B. Diagram: a small table of rows with one matching row
C. Supporting note: “An index can offer another path”
D. Brand label: “Database fundamentals”
E. Caption: the current spoken sentence
```

If the point of the scene is to ask a question, the headline can be the strongest element, followed by the table. The brand label is supporting context and can be smaller. Captions need to be readable, but they should not obscure the important part of the diagram. In a later scene, the diagram may become the priority and the headline can become less prominent.

A useful first pass is to assign each element a role:

| Role | Example | Typical treatment |
| --- | --- | --- |
| Primary | Current idea or key visual | Largest or highest contrast; clear surrounding space |
| Secondary | Explanation or evidence | Smaller but still comfortably readable |
| Tertiary | Branding, metadata, decoration | Subtle and subordinate |
| Functional | Captions, required label | Readable and positioned to avoid content collisions |

These are roles, not fixed font sizes. A caption can be both functional and visually prominent because accessibility matters. The important question is whether the design makes the relationship between elements clear.

### Contrast is broader than color

Contrast is a difference between elements. Large versus small, bold versus regular, dense versus open, still versus moving and bright versus dark can all create emphasis. If everything is bold, boldness no longer distinguishes anything. If every object glows, the glow stops identifying the important object.

Start with one clear contrast. For example, make the headline large and the label smaller. Then use a restrained accent color to mark the matching row. Avoid adding a second accent, three shadows and a pulsing outline before checking whether the first distinction already works.

## 3. Composition: arrange the parts around the message

**Composition** is the arrangement of visual elements inside a frame. A frame has limited space, and a vertical frame has much more height than width. A useful approach is to divide the vertical space into functional regions:

1. A small context area near the top.
2. A headline and primary visual in the central area.
3. Supporting detail or captions below the main visual.
4. A margin around all content.

These are flexible regions, not a universal template. Platform controls, title length and the visual itself influence the final placement. Keep important content away from edges likely to be cropped or covered by playback controls. The exact safe area varies by platform and interface, so test the current upload preview rather than assuming a fixed number of pixels is guaranteed safe.

### Alignment creates order

When elements share an edge or center, viewers perceive them as intentionally related. Left-aligned text is often easy to scan because each line begins at the same position. A diagram can be centered within a card while the explanatory text aligns with the card's left edge. You do not need every element centered or every element left-aligned; you do need a consistent reason for the choices.

Suppose a headline starts 70 pixels from the left edge and the card below begins 84 pixels from the edge. The difference might be invisible as an intentional choice but visible as visual instability. Aligning both to the same margin makes the relationship feel clearer. If you deliberately offset one, make the difference meaningful enough to look intentional.

In CSS, a shared container can create this consistency:

```css
.content {
  width: min(86%, 780px);
  margin-inline: auto;
}
```

Here, `width` uses the smaller of 86% of the parent's width and 780 pixels. `margin-inline: auto` distributes remaining horizontal space evenly, centering the container. This is a static layout example, not a requirement for every composition. On a fixed 1080-pixel video canvas, you may choose explicit pixel values for precise placement; on a responsive web preview, percentage-based constraints can help the design scale.

### Proximity communicates relationships

Elements that are close together tend to be perceived as a group. Put a label near the diagram it explains. Put more space between two separate ideas than between a heading and its supporting sentence. This creates an implicit structure before the viewer reads a word.

For example:

```text
INDEX
A sorted lookup structure

[ diagram of index entries ]

MATCHING ROW
A row with the requested email
```

If all gaps are equal, the label-to-diagram relationship may be ambiguous. Reduce the gap between each label and its associated visual; increase the gap between groups. The exact numbers depend on canvas size and type scale, but the relationship between gaps is the important concept.

### Negative space is active space

The empty area around an object is sometimes called negative space. It lets an element stand apart, creates rhythm and makes a frame easier to scan. It is not wasted merely because no graphic occupies it.

This does not mean every frame should be sparse. A busy screen recording may be necessary to show real software. The design task is to guide attention within that complexity: crop carefully, highlight the relevant control, and avoid adding unnecessary labels over an already dense interface.

## 4. Grids, margins and spacing systems

A grid is a set of invisible guides for placement. For a vertical 1080 × 1920 video, you might define a left and right margin, a top context zone, a central content area and a lower caption region. You can then use the same guides for multiple scenes. Consistency reduces the feeling that every cut jumps to a completely unrelated visual system.

A spacing scale provides a small set of gaps rather than a different arbitrary gap everywhere. For a 1080-pixel-wide design canvas, a project might use values such as 12, 24, 36, 48 and 72 pixels. Those numbers are illustrative, not universal rules. What matters is consistency and visual adjustment at the actual output size.

```css
:root {
  --space-1: 12px;
  --space-2: 24px;
  --space-3: 36px;
  --space-4: 48px;
  --space-5: 72px;
}
```

Custom properties beginning with `--` are CSS variables. `:root` defines them at the document's root so descendants can use them. `var(--space-2)` retrieves the value. If you later change the design system, you can adjust a shared value rather than hunting through every rule.

Do not confuse mathematical consistency with optical balance. A round icon may appear slightly lower than a rectangular label even when their bounding boxes are mathematically aligned. Make small visual corrections after checking the design at output size. Likewise, a large headline may require a different gap from a small label even if both technically use the same scale.

## 5. Typography: make words easy to see and understand

Typography is the design and arrangement of text. In video it must work under conditions that are less forgiving than a webpage: viewers may be on a small screen, the text may appear briefly, and the image may be compressed or viewed while moving.

### The main properties

- **Font family** determines the overall letterforms. For a first project, choose a clear sans-serif family available in your environment or included with appropriate rights.
- **Font size** changes the visual scale of the text. Measure at the final canvas size and test the rendered result on a phone.
- **Weight** describes the thickness of strokes. Heavier text can improve emphasis, but excessively heavy type can close small counters in letters.
- **Line height** controls vertical distance between lines. Too little makes lines collide; too much can make a heading feel disconnected.
- **Letter spacing** changes space between letters. A little additional spacing can help small uppercase labels, while too much can make words harder to read.
- **Line length** affects readability. Long lines are difficult to track; extremely narrow columns cause awkward wrapping.

A small set of text styles can carry a whole video. For example:

```css
.eyebrow { font-size: 24px; font-weight: 700; letter-spacing: .12em; }
.headline { font-size: 72px; font-weight: 750; line-height: 1.05; }
.body { font-size: 32px; font-weight: 400; line-height: 1.4; }
.caption { font-size: 34px; font-weight: 650; line-height: 1.25; }
```

These are example values for a particular large design canvas, not a guarantee of platform readability. Their relationships are more important than the exact numbers: the headline is dominant, body copy supports it, and captions remain readable. A browser may synthesize a requested font weight if the font does not contain it; inspect the result and use weights your chosen font supports.

### Text should fit the available reading time

A viewer must read the text while also following the visual and narration. A good edit gives the text a stable hold. If the text takes too long to read, you have several choices: shorten it, spread the idea across scenes, increase the duration, or move detail into narration or a companion post.

For example, compare:

> “Database indexes are auxiliary structures that can support more efficient retrieval of rows depending on selectivity and query planning.”

with:

> “An index offers another path.”

The shorter line is easier to process in a brief scene, but it is incomplete on its own. Narration and the surrounding video should provide the needed qualification. Concision is useful when it preserves the intended meaning; removing every caveat can change the claim.

### Avoid accidental typography failures

A font may load in your browser but be absent in a render environment. Define a sensible fallback and make sure the final renderer can access licensed font files. Long product names can wrap unexpectedly. Test realistic longest-case text, not only a short placeholder. Avoid putting critical text directly over a detailed moving background; add a solid or translucent backing, reposition the text, or simplify the background.

## 6. Color and contrast

Color can identify roles: background, primary text, secondary text, accent and warning. It can also establish mood. A developer explainer might use a dark navy background, light text and a cyan accent. A different project might use a light background with a deep blue accent. Neither palette is inherently better; the important questions are whether the text is readable and whether the accent has a consistent meaning.

A simple token set might look like this:

```css
:root {
  --background: #101827;
  --surface: #1d2a40;
  --text: #f8fafc;
  --muted: #cbd5e1;
  --accent: #67e8f9;
  --border: #52657f;
}
```

Think of these names as roles, not just color values. `--accent` means “the color used for a highlighted element”; if you change the visual identity, you can change the value while preserving the role. This is why design systems name colors semantically rather than naming everything “blue1” and “blue2.”

**Luminance contrast** matters especially for text. Web Content Accessibility Guidelines provide useful reference thresholds for web content: 4.5:1 for normal text and 3:1 for large text under the relevant success criterion. These thresholds are useful design checks, but a video viewed through compression, over a moving background or at small size may need a larger practical margin. Check actual rendered frames; color samples alone cannot account for every visual condition. See the [WCAG contrast criterion](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html).

Do not use color as the only way to convey a distinction. If a matching row is cyan while all others are gray, also add a label, icon, border, underline or shape change. That helps viewers who cannot distinguish the colors and improves comprehension when the video is desaturated or compressed.

### Gradients, shadows and glow

These effects can create depth, but they are supporting tools. A gradient is a gradual transition between colors. A shadow suggests separation from a background. A glow can direct attention to an active element. If all objects have strong glow, the scene becomes noisy; if a shadow is too dark or diffuse, a card may appear muddy.

Start with a flat design that works. Add one subtle depth cue, then check whether it improves separation. On video, smooth gradients can show banding after compression, especially in dark areas. A higher-quality source or subtle texture can help, but always review the actual encoded file and platform upload rather than assuming a particular export will solve it.

## 7. A visual system for a series

A visual system is a set of repeatable choices that make separate scenes feel related. It is not just a logo. For a developer video series, define:

- A background and surface palette.
- One or two type families and a small type scale.
- Margins and a spacing scale.
- Shapes for cards, highlights and connectors.
- A consistent treatment for code, captions and labels.
- A small set of motion behaviors to add later.
- A rule for when generated footage or real screenshots are appropriate.

The purpose is to reduce repeated decisions and create recognizable structure. It should not force every scene into the same template. A full-screen real product demonstration may need different composition from a conceptual diagram, while still sharing type, color and caption treatment.

### Design tokens as code

A **token** is a named design decision. In CSS, a custom property can serve as a token. A React application may define tokens in a JavaScript object or stylesheet. The essential concept is independent of the framework: centralize recurring decisions and use names that express their role.

```js
const theme = {
  color: {
    background: "#101827",
    surface: "#1d2a40",
    text: "#f8fafc",
    accent: "#67e8f9"
  },
  spacing: { small: 12, medium: 24, large: 48 },
  radius: { card: 24 }
};
```

This JavaScript object is a data structure. The `theme.color.accent` expression reads the accent string; `theme.spacing.medium` reads the number 24. It does not automatically style anything. A program must use those values in a style or component. In CSS, a token is also just a named value until a rule uses it.

Tokens are useful because they let you make a coordinated change. If the accent color becomes mint, one edit can update the shared value. But semantic naming matters: if you used the same accent for a warning and an active element, changing it may unintentionally change the meaning of the warning. Give different concepts separate tokens when they need independent control.

## 8. Build a complete static style frame

Save the following as `style-frame.html` and open it in a browser. It is a self-contained visual study with no external packages or assets. It uses a fixed 1080 × 1920 design canvas and scales that canvas down to fit the browser window. The scaling lets you evaluate the layout, but a browser screenshot of this page is not automatically a finished 1080 × 1920 video frame.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Database index style frame</title>
  <style>
    :root {
      --bg: #101827; --surface: #1d2a40; --surface-2: #26364f;
      --text: #f8fafc; --muted: #cbd5e1; --accent: #67e8f9;
      --outline: #64748b;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0; min-height: 100vh; display: grid; place-items: center;
      background: #050a13; font-family: system-ui, sans-serif;
    }
    .viewport { position: relative; width: 360px; height: 640px; overflow: hidden; }
    .frame {
      position: absolute; inset: 0 auto auto 0; width: 1080px; height: 1920px;
      transform: scale(0.3333333333); transform-origin: top left;
      background: var(--bg); color: var(--text); padding: 110px 90px;
      display: flex; flex-direction: column;
    }
    .eyebrow { color: var(--accent); font-size: 30px; font-weight: 700;
      letter-spacing: .1em; text-transform: uppercase; }
    h1 { margin: 28px 0 24px; max-width: 850px; font-size: 100px;
      line-height: 1.04; letter-spacing: -.035em; }
    .subhead { color: var(--muted); font-size: 40px; line-height: 1.35;
      max-width: 830px; margin: 0; }
    .diagram { margin-top: 105px; background: var(--surface); border: 3px solid var(--outline);
      border-radius: 32px; padding: 42px; }
    .diagram-title { margin: 0 0 30px; font-size: 32px; color: var(--muted); }
    .row { display: flex; align-items: center; justify-content: space-between;
      gap: 20px; background: var(--surface-2); margin-top: 18px;
      border-radius: 18px; padding: 26px 30px; font-size: 32px; }
    .match { border: 4px solid var(--accent); }
    .badge { color: #071621; background: var(--accent); border-radius: 12px;
      font-size: 25px; font-weight: 800; padding: 10px 16px; }
    .note { margin-top: 65px; color: var(--muted); font-size: 32px; line-height: 1.4; }
    .caption { margin-top: auto; align-self: center; max-width: 820px; text-align: center;
      background: #050a13; border-radius: 18px; padding: 24px 32px;
      font-size: 38px; font-weight: 700; line-height: 1.3; }
  </style>
</head>
<body>
  <div class="viewport">
    <main class="frame">
      <div class="eyebrow">Database fundamentals</div>
      <h1>Find one user</h1>
      <p class="subhead">How can a database locate a matching row?</p>
      <section class="diagram" aria-label="Illustrative user table">
        <p class="diagram-title">Users table — simplified example</p>
        <div class="row"><span>alex@example.test</span><span>Row 1</span></div>
        <div class="row match"><span>sam@example.test</span><span class="badge">Match</span></div>
        <div class="row"><span>lee@example.test</span><span>Row 3</span></div>
      </section>
      <p class="note">Next: compare a scan with an index path.</p>
      <div class="caption">How does a database find one user among many?</div>
    </main>
  </div>
</body>
</html>
```

Let's examine what the code is doing.

The `.viewport` is 360 × 640 pixels, a 9:16 rectangle. The `.frame` is 1080 × 1920 pixels, also 9:16. CSS scales the frame to one-third of its original dimensions and anchors the scaling at the upper-left corner. Therefore, the frame fits exactly into the viewport: 1080 ÷ 3 = 360 and 1920 ÷ 3 = 640. The text and margins scale too.

The `main` element is the designed frame. Its flex layout arranges elements vertically. The `caption` has `margin-top: auto`, which takes remaining space above it and pushes it toward the bottom of the available content area. This is a convenient layout technique, but the resulting location still needs review against the actual platform's controls and against longer text. It is not a universal safe-area guarantee.

The matching row has both a cyan border and a “Match” badge. The meaning does not rely on color alone. The use of `example.test` makes the addresses illustrative; the table is not presented as real data. The note says that the next scene compares two paths, establishing continuity without adding a detailed explanation to this opening frame.

The example uses a system font for portability. If you use a custom font in a real video project, ensure the file is available to the rendering environment and that your use is licensed. Before using the design, try a longer headline and a longer caption. If they overflow, redesign the layout or constrain the input deliberately; simply reducing the font until everything fits can make the result unreadable.

### Why use a fixed design canvas?

A video is typically exported at known pixel dimensions. Designing on a 1080 × 1920 coordinate system makes it easier to discuss positions and type sizes consistently. A web preview, however, may be displayed in a smaller window, so it scales the canvas for inspection. When adapting this example to a production renderer, use that renderer's actual composition dimensions and preview mechanism rather than assuming a CSS transform exports the intended pixel resolution.

A responsive website and a fixed video composition have different goals. A website may reflow based on the viewer's browser size. A rendered video usually encodes one fixed frame size. You can still create separate compositions for different aspect ratios, but changing an output from 9:16 to 16:9 may require a deliberate layout redesign, not merely changing the container width.

## 9. Design three frames for one explainer

Use the same tokens and grid to design a set of related frames. The content changes, while typography, spacing and color provide continuity.

### Frame A: the question

The first frame from the code above asks how a database finds one user. Its hierarchy is: headline, table, question caption, supporting label. The table is simple enough to recognize quickly. The matching row is marked as a point of interest, but the scene does not yet claim a particular search method.

### Frame B: a scan

Replace the headline with “Inspect the rows.” Keep the table in approximately the same location. Add a small label identifying the example as a simplified scan. For a still style frame, highlight one row that is being inspected. In the later animated version, the highlight can move from row to row. Do not fill the frame with an explanation of every scan optimization; the purpose of this visual is to establish one understandable search path.

The benefit of keeping the table's position consistent is continuity: viewers recognize the object from the previous scene and can focus on what changed. A hard cut to an unrelated layout can still work when the story calls for it, but it has a higher reorientation cost.

### Frame C: an index path

Use a headline such as “Another search path.” Show a small index card to the left or above the matching row, depending on available space. Use an arrow or line to connect the card to the row. Label the visual “simplified” and do not depict a specific index structure unless that is what the lesson intends to teach. Leave room for a caption explaining that the database chooses a plan.

If the index card, arrow, row labels and captions make the frame too dense, simplify. You might show only three rows, reduce the number of labels, or split the concept into two frames. The right decision depends on the information you need to preserve.

### Compare the three frames

Put the stills side by side at equal scale. Check whether the headline position, type treatment and palette feel related. Then look at each at phone size. A consistent design that is too small in all three frames is consistently unreadable; consistency is valuable only when the individual frames work.

## 10. Crops, platform overlays and captions

A video can be technically 9:16 and still have important content obscured. A platform may overlay a username, description, buttons, progress indicators or other controls. These interfaces and crop rules change, and viewers may watch in different contexts. The safest practical method is to test the actual upload preview and keep essential information away from vulnerable edges.

Plan captions early. If you add them only after the diagram fills the frame, you may discover that the only available space covers a crucial label. Reserve an area in the composition and test the longest plausible caption, including a two-line caption. Use sufficient contrast and avoid making the caption background so large that it hides the visual evidence.

Captions and on-screen titles have different purposes. A title summarizes the idea. Captions represent spoken content and support viewers who cannot or choose not to listen. They may overlap in meaning, but they are not interchangeable. Review automatically generated captions for terminology, punctuation and timing. “Index” and a similarly sounding word can be mistranscribed, changing the lesson.

For multiple output formats, begin from the message and recompose each frame. A horizontal version can put narration-related text beside a diagram; a vertical version may stack them. Keep the same asset and style system where useful, but permit the layout to change. Inspect the result rather than relying on automatic center-cropping.

## 11. Direct an AI agent with design language

A vague request such as “Make it more professional” leaves too much room for interpretation. The agent may add gradients, glow and decorative shapes when the actual problem is that the headline is too small. Describe the observation and the intended effect:

```text
Observation: At phone size, the row labels are hard to read.
Change: Increase row-label size and reduce the number of visible rows to three.
Constraint: Keep the caption from covering the match badge.
Verification: Show a 9:16 still at the target resolution and a phone-sized preview.
```

This structure tells the agent what to change and how to check it. It also keeps the factual constraint intact: fewer illustrative rows do not imply the database contains only three rows.

### Claude Code prompt

```text
Create three static style frames for a vertical database-index explainer in
this folder. The frames should show a question, a simplified scan, and an
alternate index path. Use a restrained navy, light-text and cyan palette,
consistent type and margins, and a reserved caption area. The content is
illustrative: do not invent performance numbers or claim every query uses an
index. Make text and colors easy to edit. Explain the hierarchy and how to
preview the frames; inspect them at phone size if your environment permits.
Report any visual checks you could not perform.
```

### Codex prompt

```text
Build a self-contained HTML/CSS style-frame prototype for a 1080×1920 video.
Use shared CSS variables for background, surface, text, accent, spacing and
card radius. Create three selectable still scenes: question, scan and index
path. Keep captions separate from the core diagram and make the match clear
without relying on color alone. Use local placeholder assets. Explain each
layout decision and check for clipping, long-text wrapping and phone-size
readability. Do not claim visual verification unless you actually performed it.
```

The two prompts have the same design intent but specify different possible deliverables. An agent may use a screenshot tool, browser preview or another available method to inspect output. If it cannot inspect the visuals, open the files yourself and perform the checks. A successful code-generation step is not proof that the design is readable.

### A useful follow-up

```text
At the 8-second scene, the caption overlaps the diagram. Move the diagram up
and reduce its height by removing one nonessential row. Keep the headline size
unchanged. Render or capture the frame again and report whether the longest
caption fits without covering the highlighted row.
```

This request identifies a specific time, observed failure, desired change, constraint and verification. It gives the agent enough freedom to implement the change without losing the purpose of the scene.

## 12. Common mistakes and practical fixes

### Equal emphasis everywhere

**Symptom:** Every label is bright, bold and large; the viewer does not know where to look.

**Cause:** No hierarchy was assigned before styling.

**Fix:** Identify the primary message in the current scene. Make it clearly dominant, reduce the emphasis of supporting labels, and use the accent only where it explains something.

### Tiny text inside a beautiful frame

**Symptom:** A desktop screenshot looks polished, but labels disappear on a phone.

**Cause:** The design was judged at a larger display size than the final viewing context.

**Fix:** View the entire frame at approximately phone size. Reduce the amount of content before shrinking the font. If all detail is essential, split it across shots or offer a longer version.

### Inconsistent spacing

**Symptom:** Cards and labels seem slightly off even though no single gap looks obviously wrong.

**Cause:** Each margin was chosen independently.

**Fix:** Use a shared grid and spacing scale, then adjust optically where needed. Align related text and card edges.

### Insufficient contrast over footage

**Symptom:** A caption is readable over dark footage but disappears over a bright object.

**Cause:** The background changes while the text color remains fixed.

**Fix:** Add a stable backing, move the caption to a quieter area, or darken a local region. Check the entire shot, not only one still.

### Color communicates the whole meaning

**Symptom:** The matching row is distinguished only by a slight hue difference.

**Cause:** A visual distinction was treated as equivalent to a semantic label.

**Fix:** Add a border, icon or explicit text such as “Match,” and check the design in grayscale as one diagnostic.

### Styling hides a technical mistake

**Symptom:** A convincing arrow makes a simplified diagram look like a literal database trace.

**Cause:** Visual polish implies authority that the example has not earned.

**Fix:** Label diagrams as illustrative, verify the explanation, and keep the distinction between a conceptual model and a measured or recorded result clear.

### Every scene is identical

**Symptom:** Repeated cards and centered headings make the video monotonous.

**Cause:** Consistency was interpreted as using one composition for every idea.

**Fix:** Preserve tokens and visual language while varying the layout in response to the content. A full-screen recording, a side-by-side comparison and a close-up diagram can belong to the same visual system.

## 13. A repeatable review process

A useful design review proceeds from large decisions to small ones:

1. **Meaning:** Does the frame communicate the intended idea, and is the claim accurate?
2. **Hierarchy:** Is the primary message easy to identify without reading every label?
3. **Composition:** Are related elements grouped and aligned? Is the layout balanced?
4. **Legibility:** Can the smallest important text be read at expected viewing size?
5. **Contrast:** Does text remain distinct from its background? Are distinctions communicated in more than color?
6. **Resilience:** Do long captions, font fallback and different aspect ratios cause clipping?
7. **Consistency:** Do the frames share a purposeful visual system?
8. **Finish:** Are borders, shadows, icons and color treatments controlled and coherent?

This order prevents spending time on a subtle shadow while the underlying explanation is wrong. Review a static frame first, then review the animated sequence. Movement, transitions and changing footage can introduce new collisions or readability problems that no single still reveals.

### Optional application

Create three style frames for the database-index storyboard. Use the provided HTML file as a starting point, or use a design tool you already know. Record your choices in a short note: one sentence for the main visual priority, one for the palette, one for the caption area, and one for the biggest limitation of the visual metaphor. The next lesson will turn a still element into motion and explain frames, interpolation and easing from first principles.

## References

- [W3C WCAG 2.2: Contrast minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) — a useful contrast reference for text.
- [MDN: CSS custom properties](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties) — variables used for design tokens.
- [MDN: CSS flexible box layout](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_flexible_box_layout) — layout behavior used in the example.
- [MDN: CSS aspect-ratio](https://developer.mozilla.org/en-US/docs/Web/CSS/aspect-ratio) — ratios for responsive previews.
- [Remotion documentation](https://www.remotion.dev/docs/) and [HyperFrames documentation](https://hyperframes.app/docs/1-startup/1-introduction) — later production environments.
