# Lesson 15 — Build a portfolio and publishing workflow

A portfolio is not merely a folder of finished MP4 files. It is a set of projects that demonstrates your ability to identify an audience, explain an idea, choose a visual technique, make a credible claim, and deliver a usable result. The source files and production notes matter because they let you revise the work, create variants, and explain your decisions later.

In this capstone, you will plan a small series of developer videos for your personal brand. The series contains three pieces:

1. A roughly 20-second concept explainer.
2. A roughly 30-second walkthrough of a real application.
3. A roughly 45–60-second launch video combining code-driven graphics with generated or other visual assets.

The durations are planning targets, not obligations to pad the video. A clear 18-second explanation is better than a 20-second video with two seconds of empty repetition. Likewise, a demonstration that requires 35 seconds to be honest may deserve that time. Adjust the actual edit around the message and the recorded narration.

This lesson combines the previous topics into an end-to-end process. It provides concrete briefs, repository layouts, examples, review procedures, and prompts for Claude Code and Codex. You can use Remotion, HyperFrames, a conventional editor, or a combination. The capstone is a production plan and teaching example; it does not claim that the videos, screenshots, generated assets, or measurements have already been produced.

## 1. What a strong portfolio demonstrates

Imagine that someone watches three videos you made. What can they infer from them?

A concept explainer can demonstrate that you can simplify a technical subject without making it misleading. A product walkthrough can show that you can explain real software through visible behavior. A launch video can show that you can combine storytelling, motion, audio and brand presentation into a coherent piece.

The videos should not all look or sound identical. They should share a recognizable visual language while solving different communication problems. A technical explainer may use simple diagrams and calm pacing. A walkthrough may use screen recording and a cursor highlight. A launch video may open with a more cinematic shot and use faster transitions. Their shared typography, palette, captions and voice make them feel like related work.

A useful portfolio has four layers:

| Layer | What it contains | Why it matters |
| --- | --- | --- |
| Viewer-facing work | Videos, titles and descriptions | Shows the finished communication |
| Creative reasoning | Briefs, scripts and storyboards | Explains what each piece was intended to accomplish |
| Editable source | Compositions, project files, data and settings | Makes corrections and variants possible |
| Provenance and review | Asset sources, rights, captions and quality checks | Makes the work maintainable and trustworthy |

You do not need to publish every internal file. Some source assets may contain private information or have licenses that prevent redistribution. Keep a private production record, then publish only files you have the right to share. If a public repository cannot include an asset, replace it with a clearly labeled placeholder and explain how to supply an authorized local copy.

## 2. Define a series before defining individual shots

A series is a promise to your audience about the kind of content they will receive. For your developer brand, a reasonable promise might be:

> “Short visual explanations and practical demonstrations that help developers understand tools and build useful software.”

This is broad enough to cover databases, libraries and products, but narrow enough to guide choices. A video about a product should show a useful action. A concept explainer should make an idea clearer. A visual effect should support one of those goals.

Write a series brief:

```text
Audience: Developers interested in understanding software and practical tools.
Voice: Clear, curious, direct and technically careful.
Visual style: Dark navy surfaces, high-contrast text and a restrained cyan accent.
Typography: One readable sans-serif family and a clear hierarchy.
Format: Design each video for a primary destination; create variants deliberately.
Captions: Corrected against the final narration and placed away from key content.
Evidence: Real product interactions for claims about existing features.
Generated media: Allowed as labeled illustrative material, not as proof of behavior.
```

The exact colors and voice are yours to change. The value of the brief is that it makes repeated decisions explicit. If every new video requires selecting a completely new palette, type scale and caption style, production becomes slower and the portfolio becomes less cohesive. On the other hand, if the brief prevents you from presenting a real interface clearly, revise the system rather than forcing the content into a rigid template.

### Create a visual kit

A small kit can include:

- A background and surface color.
- Primary and secondary text colors.
- One accent color and a non-color cue for important distinctions.
- Two or three text sizes with rules for their use.
- A card style, border treatment and spacing scale.
- A lower-third or name label.
- A caption style.
- A short outro or call-to-action treatment.

Keep these as editable design tokens where possible. For instance:

```js
export const videoTheme = {
  colors: {
    background: "#101827",
    surface: "#1d2a40",
    text: "#f8fafc",
    muted: "#cbd5e1",
    accent: "#67e8f9"
  },
  spacing: { small: 12, medium: 24, large: 48 },
  radius: { card: 24 }
};
```

This is a plain JavaScript module exporting an object. It is not automatically a complete Remotion or HyperFrames theme. A composition or stylesheet must actually read these values. The purpose of the example is to show how recurring decisions can live in one editable place. If your project uses CSS variables instead, that is equally valid.

## 3. Choose a project structure that survives revisions

A video project changes more often than the first render suggests. You may revise narration, replace a screenshot, correct a caption, change an accent color, or export a new aspect ratio. Organize files so you can tell which materials are source and which are outputs.

A repository might look like this:

```text
video-portfolio/
├── README.md
├── shared/
│   ├── theme.css
│   └── asset-manifest.example.json
├── 01-index-explainer/
│   ├── brief.md
│   ├── script.md
│   ├── storyboard.md
│   ├── captions/
│   ├── assets/
│   ├── src/
│   └── exports/
├── 02-product-walkthrough/
│   ├── brief.md
│   ├── script.md
│   ├── storyboard.md
│   ├── captions/
│   ├── assets/
│   ├── src/
│   └── exports/
└── 03-launch-film/
    ├── brief.md
    ├── script.md
    ├── storyboard.md
    ├── captions/
    ├── assets/
    ├── src/
    └── exports/
```

This is an organizational example, not a required framework layout. A Remotion project may have its own `src` and `public` conventions; a HyperFrames project has its own composition and asset conventions. Preserve the structure required by the actual tools you use, then add clear production notes around it.

`brief.md` records audience, message, evidence and constraints. `script.md` holds the final narration and on-screen text. `storyboard.md` explains the sequence. `assets/` contains permitted source material or placeholders. `src/` holds editable composition code. `captions/` stores corrected caption files. `exports/` can hold local outputs, but large binaries may not belong in a normal Git repository. Decide whether to use an appropriate large-file solution, external storage, release artifacts or another approach based on your repository and asset rights.

Do not commit API keys, private recordings, customer data or assets you are not authorized to distribute. A `.gitignore` can reduce accidental commits but cannot retroactively remove a secret already committed to history. Review staged changes before committing and use the secret-management approach appropriate to your environment.

## 4. Keep a production manifest

A manifest is a structured list of what a project uses and what you know about it. It is especially useful when a video combines original code, an AI-generated still, a screen recording, a licensed music track and synthesized voice. Six months later, you should be able to determine what can be reused and what needs a new license.

An example manifest:

```json
{
  "project": "index-explainer",
  "assets": [
    {
      "id": "table-diagram",
      "path": "assets/table-diagram.svg",
      "type": "original-graphic",
      "source": "Created for this project",
      "rightsStatus": "owned",
      "notes": "Illustrative data; no real user information"
    },
    {
      "id": "music-placeholder",
      "path": "assets/music-placeholder.txt",
      "type": "placeholder",
      "source": "No music selected",
      "rightsStatus": "not-applicable",
      "notes": "Replace only after checking the chosen license"
    }
  ]
}
```

The manifest does not grant rights. It records your understanding and the supporting source information you have verified. For a licensed asset, keep a link or receipt and note any attribution, modification, redistribution or platform restrictions. For generated assets, record the provider, model or tool where relevant, date, input references, and the applicable terms you reviewed. The precise rights depend on the provider, plan, source material and jurisdiction; avoid assuming all generated media can be used in every commercial context.

For a human voice or likeness, document the appropriate permission. If you record your own voice, note that it is your recording. If a collaborator appears or speaks, obtain and retain their consent for the intended uses. Never use a private company screen simply because it is visually convenient.

## 5. Video one: the concept explainer

The first video teaches a single idea. Use the database-index story developed in earlier lessons, or replace it with another concept you can explain accurately, such as a cache, a queue or a coroutine suspension point.

### Define the outcome

```text
Audience: Developers who know tables and rows.
Question: How can a database find a particular row?
Takeaway: An index can provide another search path; the optimizer chooses a plan.
Evidence: A labeled illustrative diagram, not a measured benchmark.
Duration: Approximately 20 seconds.
Primary format: 9:16.
```

The important phrase is “can provide.” It avoids promising that an index always improves a query or is always selected. If you later show a specific database plan, use a real query and explain the engine and conditions. Do not turn a conceptual illustration into a fabricated measurement.

### Draft the script and visual beats

| Approximate time | Narration | Visual | Viewer takeaway |
| --- | --- | --- | --- |
| 0–4 s | “How does a database find one user among many?” | Table and search field | There is a search problem |
| 4–8 s | “One option is to inspect rows for a match.” | Sequential row highlight | A scan is one possible path |
| 8–15 s | “An index can offer another way to locate matching data.” | Index card and path to row | An index is an additional search structure |
| 15–20 s | “The database chooses a plan for the query.” | Both paths and a plan label | An index is not a universal choice |

The timing is only a proposal. Read the script naturally and compare the recording with the storyboard. If the spoken words do not fit, edit the script or extend the video. A video is not improved by squeezing a dense idea into a predetermined length.

### Select the visual technique

For this piece, code-driven graphics are a good fit because the labels and arrows need to be exact and editable. Remotion can render React components as frames. HyperFrames can render an HTML-based composition using its supported timing conventions. Either is sufficient. You do not need to combine frameworks merely to demonstrate that you know both.

A simple style frame might contain three rows, a search label, and a matching row marked with both a border and text. Add animation only after the frame is readable. The row highlight can move in steps; the index card can enter after the narration introduces it; the final comparison can hold long enough for the viewer to understand it.

### Review the educational claim

Before rendering, write down what the viewer might infer incorrectly. For example:

- An index is always faster.
- A database always scans every row in a scan.
- Every index has the same structure.
- The animation is an exact execution trace.

Adjust the narration or labels to prevent the most important misconceptions. You cannot teach every database detail in 20 seconds, but you can avoid presenting a simplified model as a universal rule.

## 6. Video two: the real product walkthrough

The second piece demonstrates actual software. Choose an application you own or are authorized to show. If your app is not ready, make a local demonstration project or label the interface as a prototype. Do not use a fictional interface while presenting it as an existing feature.

### The difference between a claim and evidence

Suppose the claim is “QueryLens makes query information easier to inspect.” A screen recording can show the user opening a query, selecting a result and seeing the details. That demonstrates the interface behavior. It does not, by itself, prove that every user completes work faster or that the product improves database performance.

A stronger script describes what is visible:

> “Select a query to see its details in one place.”

A claim such as “Find problems 10 times faster” needs a defined measurement, comparison, sample and context. If you do not have them, do not include the number.

### Prepare a safe recording environment

Before recording:

1. Create or select synthetic demo data.
2. Close unrelated applications and notifications.
3. Check browser tabs, account names, URLs, logs and file paths for private information.
4. Set a readable window size and zoom level.
5. Rehearse the interaction and confirm the feature works as shown.
6. Record a clean take with a little space before and after the interaction.

A blurred secret is not always a reliable substitute for removing it from the source recording. If possible, avoid capturing the sensitive information at all. If you must redact, inspect the final export frame by frame around transitions, crops and motion. The safest demonstration uses a purpose-built environment with synthetic data.

### Example storyboard

```text
0–4 s: Hook — “Want a clearer view of your queries?”
4–9 s: Show the real application's query list.
9–17 s: Select one query; highlight the details that actually appear.
17–24 s: Show a second relevant action, if it exists and helps the story.
24–30 s: Hold on the result and invite the viewer to learn more.
```

Do not add a second action merely to fill the timeline. A clear demonstration of one useful interaction may be stronger. Use a cursor highlight or zoom to direct attention, but do not crop out context needed to understand what happened. If you accelerate or cut an interaction, make sure the edit does not imply a different sequence or conceal a required step.

### Make the recording readable

A 9:16 canvas is narrow relative to a desktop application. Several approaches are possible:

- Record a narrow application window if the interface supports it.
- Crop to the relevant region, then show a wider context shot before or after.
- Animate a camera-like crop across a larger recording.
- Place the recording inside a device or browser frame with an explanatory label.
- Use a horizontal version if the interface cannot be shown honestly in a vertical crop.

Each choice has tradeoffs. A close crop improves legibility but can hide context. A wide view preserves context but makes details small. A moving crop can bridge the two but may distract if it moves while the viewer is trying to read. Plan the crop around the action and give the viewer a stable hold after the movement.

### Add overlays without falsifying the interface

Overlays can be arrows, callouts, captions, magnified details or a cursor highlight. They should explain what is visible. If you add a button label that is not present in the real interface, make it clear that it is an annotation. If a simulated interaction replaces a real recording, label it as a mockup.

A useful revision request might be:

```text
The query name is too small in the current 9:16 crop. Start with a wide view
for context, then crop closer to the selected query before the click. Keep the
cursor visible and hold the selected state for two seconds. Do not add UI that
is not present in the recording.
```

That request specifies the problem, desired behavior and truthfulness constraint. It is more useful than asking for “more engaging editing.”

## 7. Video three: the launch film

The third piece combines techniques into a coherent launch story. It may use code-driven graphics, a real screen recording, original or licensed images, generated imagery, voice and music. The key is to assign each element a job.

A sample structure for a 45–60-second launch film:

1. **Problem:** Show a recognizable situation the audience wants to improve.
2. **Promise:** Introduce the product and its central benefit.
3. **Demonstration:** Show real behavior that supports the promise.
4. **Differentiation:** Explain one or two relevant features or design choices.
5. **Close:** Invite a specific next action.

If the product is an early prototype, say so where that context matters. If a feature is planned rather than available, label it accordingly. A launch film is persuasive, but persuasion does not require pretending that unbuilt features already exist.

### Example creative brief

```text
Product: QueryLens, an imaginary query-inspection application.
Audience: Developers who want to inspect query information.
Core message: A clear interface can make query details easier to explore.
Evidence: A real recording of the current prototype's available interactions.
Visual approach: Code-driven typography and callouts; one atmospheric generated
background; real screen recording for product behavior.
Audio: Narration recorded by the creator; licensed or original music if used.
Call to action: Visit the project page or read the build notes.
```

The generated background establishes mood. It does not prove the product's behavior. The screen recording supplies that evidence. The code-driven title and callouts provide precise, editable text. These roles keep each technique aligned with what it does well.

### Plan a generated shot

Suppose you want a stylized abstract server-room background. First create a reference still that fits the palette and leaves an uncluttered area for text. Then, if using an image-to-video tool, describe the intended motion: “A slow forward camera move; subtle indicator lights; no abrupt cuts.” Review the resulting shot for flicker, warped objects and unwanted text.

Provider capabilities and terms differ. Check current documentation, costs, output rights and privacy rules before uploading references or generating paid media. Use a placeholder until you have selected an authorized provider. If the background contains a recognizable person, product or copyrighted reference, obtain the necessary permissions and evaluate whether that reference is appropriate for the intended use.

### Assemble in layers

Think of the final image as a stack:

1. Background footage or color.
2. A darkening or contrast layer if needed for readability.
3. Screen recording or product graphic.
4. Exact text and callouts.
5. Captions and branding.

Audio has its own layers: narration, music and sound effects. The editor or renderer combines them into the final output. Keep the editable source of each layer when possible. A title baked into a generated video is harder to correct than a title rendered as text above the footage.

## 8. Make a project manifest and validate it with code

The following small Python program validates a local JSON manifest. It uses only the Python standard library. It checks that required fields exist and that referenced local asset paths do not escape the project directory. It does not verify legal rights, media quality, or whether the assets are appropriate; those require human review.

Save it as `validate_manifest.py` in the project root:

```python
#!/usr/bin/env python3
"""Check the shape and local paths of a video asset manifest."""

import json
import sys
from pathlib import Path

REQUIRED_FIELDS = {"id", "path", "type", "source", "rightsStatus"}


def validate(manifest_path: Path) -> list[str]:
    errors: list[str] = []
    root = manifest_path.parent.resolve()

    try:
        data = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"Cannot read manifest: {exc}"]

    if not isinstance(data, dict):
        return ["Manifest must be a JSON object."]
    if not isinstance(data.get("project"), str) or not data["project"].strip():
        errors.append("project must be a nonempty string.")

    assets = data.get("assets")
    if not isinstance(assets, list):
        return errors + ["assets must be a list."]

    seen_ids: set[str] = set()
    for index, asset in enumerate(assets):
        label = f"assets[{index}]"
        if not isinstance(asset, dict):
            errors.append(f"{label} must be an object.")
            continue
        missing = REQUIRED_FIELDS - asset.keys()
        if missing:
            errors.append(f"{label} missing: {', '.join(sorted(missing))}")
            continue
        for field in REQUIRED_FIELDS:
            if not isinstance(asset[field], str) or not asset[field].strip():
                errors.append(f"{label}.{field} must be a nonempty string.")
        asset_id = asset.get("id")
        if isinstance(asset_id, str):
            if asset_id in seen_ids:
                errors.append(f"Duplicate asset id: {asset_id}")
            seen_ids.add(asset_id)
        raw_path = asset.get("path")
        if not isinstance(raw_path, str) or not raw_path.strip():
            continue
        candidate = (root / raw_path).resolve()
        if not candidate.is_relative_to(root):
            errors.append(f"{label}.path escapes the project directory.")
        elif not candidate.is_file():
            errors.append(f"{label}.path does not exist: {raw_path}")
    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python validate_manifest.py asset-manifest.json")
        return 2
    errors = validate(Path(sys.argv[1]))
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("Manifest structure and local asset paths passed validation.")
    print("Review rights, content and media quality separately.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

Run it with Python 3.9 or newer because `Path.is_relative_to()` is used:

```bash
python validate_manifest.py asset-manifest.json
```

The program reads the manifest, checks that `project` is a nonempty string and `assets` is a list, and then checks each asset object. It detects duplicate IDs, missing required fields and nonexistent files. It resolves each asset path relative to the manifest's directory and rejects paths outside that directory. A successful result means only that the manifest has the expected structure and its local files exist. A file can exist and still be unlicensed, inaccurate or unsuitable.

The code is intentionally conservative and small. For a larger project, you might also validate content hashes, allowed file types, required attribution fields or a schema version. Add a check only when it addresses a real workflow need and explain what the check can and cannot prove.

## 9. Use Claude and Codex as collaborators

The capstone asks you to use at least one Claude-assisted and one Codex-assisted workflow. The goal is not to crown one tool the winner. You want to observe how well each agent understands the brief, modifies the project, explains decisions and reports uncertainty in the environment where you use it.

### Claude workflow: storyboard and visual design

In Claude Code, open the relevant project folder and use the installed framework skill if available. The exact plugin commands and capabilities can change, so consult the current official documentation for your environment. A prompt:

```text
Read brief.md and script.md for the concept explainer. Create storyboard.md
with four timed scenes, a description of what appears in each scene, and the
reason each visual supports the narration. Then create a static style frame
using the existing theme. The audience knows database tables but not indexes.
Do not make numerical performance claims or imply that an index is always used.
Use only local, authorized assets. Explain how to edit the frame. If you can
inspect the image, report what you checked; otherwise say that visual review
is still needed. Do not purchase or upload anything.
```

After reviewing the result, make a focused request:

```text
The second scene has too many row labels for a phone screen. Reduce it to
three illustrative rows, enlarge the labels, and keep the same overall timing.
Preserve the statement that the database may choose a scan. Show or describe
the updated result and report any checks you could not perform.
```

The second prompt gives feedback about an observable problem. It does not assume that an agent can see an image unless the environment actually supports visual inspection.

### Codex workflow: implementation and verification

In Codex, open the project or repository and use the relevant installed skill when available. Example:

```text
Using the approved storyboard and existing project conventions, implement the
20-second vertical index explainer. Keep the headline, scene timing, colors and
labels editable. Use frame-driven timing appropriate to the chosen framework.
Do not add unsupported performance claims. Render a draft if dependencies are
available, inspect representative frames if the environment permits, and report
exactly which checks succeeded or were blocked. Update the README with setup,
preview and render steps. Do not call paid services or upload source assets.
```

A follow-up request can focus on one defect:

```text
At the transition into the index scene, the arrow covers the caption. Move the
arrow into the diagram area, preserve the narration timing, and check the frames
before, during and after the transition. Explain the file and values you changed.
```

The agent's report is useful evidence, but verify critical claims yourself. If it says it rendered a file, open that file. If it says a caption is readable, inspect it at the intended viewing size. If it says a test passed, understand what that test actually covers.

### Compare the workflows fairly

Use the same brief and similar constraints when comparing agents. Record:

- The task and input materials provided.
- The environment and installed skills or tools.
- The files each agent changed.
- The number and nature of revision rounds.
- Whether the agent reported limitations accurately.
- The quality of the final output after human review.

Do not compare one agent's first draft against another agent's third revision without acknowledging the difference. Also do not record an action as completed merely because a prompt asked for it. The result, logs and actual files determine what happened.

## 10. A review plan for each video

Quality assurance combines automated and human checks. Automated checks can detect missing files, invalid data, code errors or a failed render. They cannot reliably judge whether a metaphor is misleading, whether a joke lands, or whether the pacing feels natural to the intended audience.

### Review the content

Read the final narration and on-screen text. Check each factual claim against an appropriate source or real product behavior. Distinguish measured results from illustrative examples. Confirm that a generated or simulated scene is not presented as documentary evidence. If the script contains uncertainty, keep the qualification visible or audible where it matters.

### Review the visuals

Inspect at least:

- The first frame and first few seconds.
- A stable frame from each scene.
- Frames immediately before and after each cut or transition.
- Midpoints of important motion.
- The longest caption and longest label.
- The final frame and any end card.

Look for clipping, overlaps, inconsistent fonts, unreadable labels, missing assets, unexpected crop, visual artifacts and accidental disclosure of private information. A frame-by-frame check is valuable around transitions, but it does not replace watching the video at normal speed.

### Review the sound

Listen with headphones and ordinary speakers if possible. Check that the narration begins and ends cleanly, that music does not mask speech, and that sound effects are not unexpectedly loud. Watch once with the sound off to check whether captions and visuals still convey the essential message. Check caption accuracy against the final narration, not an earlier draft.

### Review the actual export

Open the exported MP4 or other delivery file in a standard player. Check duration, orientation, audio, first and last frames, and playback. If you create a platform-specific upload, inspect the platform's current preview because transcoding and interface overlays can change the result. A successful render command proves that a file was produced; it does not prove that the file tells the story well.

### A review record

```text
Project: 02-product-walkthrough
Export: walkthrough-vertical-v03.mp4
Reviewed: [date and reviewer]
Claims checked: Interface interactions compared with current prototype.
Visual checks: First/last frames, all scene boundaries, phone-size preview.
Audio checks: Narration and music listened to in full.
Caption checks: Corrected against final narration.
Open issues: [list concrete issues, or “none identified in this review”].
```

“None identified” is more precise than claiming the video is perfect. It states the result of a particular review without implying that every possible problem has been ruled out.

## 11. Exporting, versions and delivery

A project may have several forms:

- The editable source project.
- A high-quality master or intermediate, if your workflow needs one.
- A platform delivery file.
- Captions in an editable text format and, where useful, a separate subtitle file.
- A thumbnail or cover image.
- A written description and links.

Use names that communicate project, format and revision, such as `index-explainer-vertical-v03.mp4`. Avoid names such as `final-final-really-final.mp4`; they make it difficult to identify the approved version. A version number is not a substitute for a review record, but it helps connect feedback to a specific file.

Do not repeatedly re-encode a compressed delivery file when you can render again from source or an appropriate master. Each lossy generation may introduce additional artifacts. Check current platform requirements for accepted formats, aspect ratios and upload limits; those details change and should not be hardcoded as permanent rules.

### Separate aspect-ratio versions

A 16:9 video is not automatically a good 9:16 video. If you crop the center of a wide screen recording, the button being discussed may disappear. If you shrink the entire wide recording into a vertical frame, labels may become unreadable. Design each version around the important content:

- For 16:9, show the interface and explanation side by side.
- For 9:16, stack the explanation and a focused crop, with a wider context shot when needed.
- For 1:1, balance the diagram and caption space in a square layout.

Shared source components and tokens can reduce duplication, but some manual re-composition is often necessary. Inspect every output separately.

## 12. Write a repository README that another person can use

A README should answer what the project is, how to preview it, what dependencies are needed, and what material is intentionally omitted. It should not include credentials or claim that every asset can be redistributed.

Example:

```markdown
# Developer video portfolio

Three short videos demonstrate a technical concept, a real application
interaction, and a product launch. Each project contains a brief, script,
storyboard, editable source, and corrected captions.

## Projects

- `01-index-explainer`: a conceptual animation about database indexes.
- `02-product-walkthrough`: a recording of an authorized demo environment.
- `03-launch-film`: a product story combining graphics and media assets.

## Setup

Install the dependencies documented inside the relevant project folder.
Check the current framework documentation and license before use.

## Assets

Some media is replaced by placeholders in this public repository. See each
project's asset manifest for source and rights notes. Supply your own authorized
assets where the README identifies a placeholder.

## Review

Each final export should be checked for factual accuracy, captions, audio,
readability, privacy and asset permissions before publication.
```

Replace generic setup instructions with the actual commands and versions used by your finished project. If the repository contains multiple framework projects, explain which commands run in which directory. Verify the instructions from a clean environment when practical; an instruction that works only because of an unrecorded local dependency is not a reliable setup guide.

## 13. Publishing with a clear claim

A post that accompanies a video should help the viewer understand why the video is relevant. For a developer explainer, you might write a short context sentence, identify the idea, and invite a useful next step. For a product walkthrough, say what the feature does and whether it is a prototype or available product.

Example copy for an illustrative explainer:

```text
How does a database find one row among many?

I made a short visual explanation of scans and indexes. The animation is a
simplified model: the database's optimizer chooses a plan based on the query
and available information.

The longer notes explain the tradeoffs behind indexes.
```

This copy makes a clear promise and labels the simplification. It does not claim that a particular posting formula guarantees reach. A good hook earns attention by making the topic relevant and understandable; distribution depends on the audience, platform, timing, competition and other factors outside your direct control.

Before publishing, check the destination's current terms, accessibility options and disclosure requirements. Include captions and an informative description. Verify links and the product's availability. If an asset requires attribution, place it where the license and platform permit it to be noticed.

## 14. Learn from results without confusing correlation and cause

After publication, you may have access to impressions, views, watch time, completion, reactions, comments, clicks or other metrics. Definitions and availability vary by platform and can change. Read the platform's current definitions before comparing numbers.

A useful analysis begins with a question:

> “Do viewers reach the moment where the main explanation begins?”

If retention drops before that point, possible explanations include an unclear opening, a mismatch between the post and video, slow pacing or the wrong audience. The metric alone does not identify the cause. Review the video and comments, compare with other relevant examples, and make a hypothesis for the next version.

Avoid making strong causal claims from one post. Two videos may differ in topic, audience, posting time, thumbnail and length. If one performs better, you cannot know which difference caused the result. For a modest experiment, change one major creative variable while keeping the goal and audience as comparable as practical, then treat the outcome as directional evidence rather than proof.

A small learning log can be enough:

```text
Video: index-explainer-v1
Question: Is the opening question clear to developers unfamiliar with indexes?
Observation: [record the actual available metric or qualitative feedback]
Possible explanation: [hypothesis, not a fact]
Next change: Show the search field in the first second and shorten the title.
Limitations: Topic and distribution may differ in the next post.
```

The log ties a change to a reason. It also protects you from treating a single successful or unsuccessful post as a universal rule about video production.

## 15. A practical completion checklist

A capstone is complete when the planned outputs exist and have been reviewed against the goals you set. Use this checklist as a working tool, not as a claim that all steps have already occurred:

- [ ] Three distinct briefs identify audience, message, evidence and format.
- [ ] The concept explainer uses an accurate, labeled simplification.
- [ ] The walkthrough shows real authorized behavior or clearly labels a prototype.
- [ ] The launch film separates illustrative generated imagery from product evidence.
- [ ] Each project has a script, storyboard and editable source.
- [ ] Asset origins, permissions and attribution requirements are recorded.
- [ ] No secrets, private company data or unauthorized personal information appear.
- [ ] Captions match the final narration and remain readable.
- [ ] The final exports have been watched in full with and without sound.
- [ ] Important scene boundaries and phone-sized frames have been inspected.
- [ ] Each published aspect ratio has been reviewed independently.
- [ ] README instructions describe actual setup and any omitted assets.
- [ ] Claude-assisted and Codex-assisted work is described accurately, including limitations.
- [ ] Publication claims and links match what is actually available.

If an item fails, fix the cause and recheck the affected output. A corrected source file does not automatically update an old export; render again and inspect the new file. If a permission or license is uncertain, replace the asset or resolve the question before publishing that version.

## 16. Continue building after the capstone

The three videos form a foundation for a repeatable workflow. You can reuse the theme, title components, caption style and asset manifest while changing the story and evidence for each project. Over time, you may build a small library of diagrams, code-block treatments, screen-recording layouts and transitions.

Keep the source of truth clear. The script should match the final narration, the captions should match the final audio, and the manifest should describe the assets actually used in the approved export. When you update a video, update the relevant records as part of the same change.

Your strongest long-term advantage is not access to a particular model or effect. It is the ability to choose the right representation for an idea, give an agent a precise task, inspect the result critically, and improve the work through deliberate iteration. The tools can generate and render many possibilities; your judgment connects them to a useful story.

## References

- [Remotion documentation](https://www.remotion.dev/docs/) and [license and pricing](https://www.remotion.dev/docs/license/pricing).
- [HyperFrames documentation](https://hyperframes.app/docs/1-startup/1-introduction) and [CLI reference](https://hyperframes.app/docs/5-packages/cli).
- [Runway image-to-video prompting guide](https://help.runwayml.com/hc/en-us/articles/48324313115155-Image-to-Video-Prompting-Guide) for an example of provider-specific motion prompting.
- [Python pathlib documentation](https://docs.python.org/3/library/pathlib.html) for path handling in the manifest validator.
- [WebVTT specification](https://www.w3.org/TR/webvtt1/) for a caption format; check the requirements of your chosen platform and tool.
