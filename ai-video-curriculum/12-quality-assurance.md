# Lesson 12 — Editing, Iteration, and Video Quality Assurance

A video can render successfully and still fail its audience. A title may be unreadable on a phone, a caption may cover the point of a diagram, or a cut may arrive before the viewer has understood the preceding scene. These are not necessarily programming errors. They are problems in the relationship between the video and the person watching it.

Quality assurance is the process of finding those problems, understanding their causes, and making changes you can verify. It combines technical checks, visual judgment, audio review, factual review, and repeated viewing in realistic conditions. In an AI-assisted workflow, it also means verifying what an agent actually produced rather than assuming that a confident completion message implies a good result.

This lesson develops a method that works with Remotion, HyperFrames, a conventional editor, or a hybrid workflow. We will use a hypothetical 20-second database-index explainer, but the process also applies to your developer videos, app walkthroughs, and product launches. The examples use local tools and illustrative timestamps; adapt them to your actual files.

## 1. Start with the audience's job

Before inspecting pixels, write down what a successful viewer should understand or do. For the database explainer, the objective could be:

> A developer who has heard of indexes but has never studied them should understand that an index can give a database another route to matching rows, and that maintaining an index has costs.

This statement lets you evaluate the video in terms of meaning. A beautiful scene where a glowing index appears has limited value if the viewer cannot tell how it relates to the table. A caption that says “instant lookup” may be concise and visually strong but is misleading because performance and plan selection depend on the query, data, and system.

Separate the objective from the constraints:

```text
Audience: developers with basic database familiarity.
Message: indexes may help locate matching rows and have maintenance costs.
Format: 9:16, approximately 20 seconds.
Voice: clear and conversational.
Assets: local diagram and narration; no confidential production data.
Review: phone-size readability, accurate captions, audible narration.
```

The constraints affect implementation. The objective determines whether the implementation is useful. Both belong in the production brief, and both should be revisited during review.

## 2. Think of quality as several independent layers

A useful review separates types of failure so that a fix addresses the actual cause:

| Layer | Main question | Example failure |
| --- | --- | --- |
| Meaning | Does the video teach or demonstrate the intended idea accurately? | A graphic implies that every index guarantees faster queries. |
| Story and pacing | Can a viewer follow the order and keep up? | A complex diagram is visible for half a second. |
| Visual communication | Can the viewer see and understand important elements? | Captions cover the highlighted row. |
| Audio | Is speech intelligible and synchronized? | Music masks the narrator's final sentence. |
| Technical delivery | Does the exported file have the expected properties and play correctly? | A 9:16 video was exported as a square crop. |
| Accessibility and permissions | Can intended viewers access it, and can you use its material? | Captions are inaccurate, or a music license does not cover publication. |

A single issue may affect more than one layer. For instance, a tiny code sample is both a visual and a communication problem. The table is not intended to create bureaucracy. Its purpose is to prevent a narrow check—such as “the command succeeded”—from being mistaken for the entire definition of quality.

## 3. Preview and export are different observations

A preview shows an approximation of what a composition should look like at a selected time. The final export is the actual encoded artifact a viewer receives. They can differ for several reasons:

- A font may be available during local preview but missing or loaded differently when rendered elsewhere.
- A browser may play a live animation according to wall-clock time, while an offline renderer seeks individual frames.
- A codec can introduce visual artifacts, especially around small text or gradients.
- Audio may be missing, mixed at a different level, or shifted because of track placement or conversion.
- A crop or aspect-ratio conversion may remove content near an edge.
- An external asset may load in preview but be unavailable to the rendering environment.

Therefore review both. Preview is valuable because it makes iteration fast. The final exported file is essential because it tests the delivery path. Watching a preview is not evidence that the MP4 was encoded correctly; opening the MP4 is not evidence that the source project is easy to edit. Each observation answers a different question.

## 4. Establish a reviewable baseline

When a draft is ready, freeze a reference version: save the project, note the revision or commit if using Git, and export a file with a clear version name such as `index-explainer-v01.mp4`. Keep a short record of the settings and source used for that render. Avoid overwriting the only copy of your first draft while you are still comparing changes.

A minimal review note can be a plain text file:

```text
Draft: index-explainer-v01.mp4
Source revision: local working tree, 2026-11-12
Canvas: 1080 × 1920, 30 fps
Intended duration: approximately 20 seconds
Narration: narration-v2.wav
Caption source: captions-v2.json
Review goal: clarity, timing, readable captions, correct export
```

These values are examples. Do not infer the export's actual properties from a project setting or filename; measure the file. A deliberate versioning scheme lets you answer a practical question: did the new draft fix the caption without introducing a different issue? If you cannot identify which source produced which video, comparison becomes guesswork.

### Review in passes

Trying to evaluate everything at once can overload your attention. Use separate passes:

1. **Story pass:** watch at normal speed without stopping. Note where you become confused or bored.
2. **Visual pass:** inspect composition, contrast, cropping, timing, and transitions.
3. **Audio and caption pass:** listen to speech and mix, then review the video muted with captions.
4. **Technical pass:** check metadata, playback, visual artifacts, and target-device presentation.
5. **Factual and asset pass:** verify claims, labels, source materials, permissions, and sensitive information.

You may combine passes for a very small project. The distinction is useful because different defects become visible when you direct attention to them.

## 5. Watch once without stopping

Your first viewing should approximate the audience's experience. Do not pause to admire a transition or inspect a spelling error immediately. Watch from start to finish at normal speed, preferably without the script in front of you. Afterwards, write down the intended message as you understood it and the moments where your attention or comprehension broke down.

This first pass is especially valuable when you wrote the script: you already know what the diagram is supposed to mean, so you may overlook ambiguity. If a trusted reviewer is available, show them the video without narrating over it. Ask what they understood and where they were confused. Their answer is evidence about the communication, not a vote on your personal taste.

A realistic note might be:

```text
00:00–00:03: Hook is readable, but the table appears before I know what it represents.
00:07–00:09: The index arrow moves so quickly that I miss its destination.
00:15–00:18: I hear the cost of updates, but the screen still says only “faster.”
```

These observations are more actionable than “the middle feels off.” They identify the time, the symptom, and the relationship between visuals and meaning. They also avoid jumping immediately to a specific fix: the arrow might need a longer hold, a clearer destination, reduced competing movement, or a combination.

## 6. Understand time precisely enough to edit it

A video frame rate tells you how many frames represent one second of video. At 30 fps:

```text
1 frame  = 1 / 30 second ≈ 0.0333 second
12 frames = 12 / 30 second = 0.4 second
15 frames = 15 / 30 second = 0.5 second
30 frames = 30 / 30 second = 1 second
```

If a title disappears at frame 150 and a new title begins at frame 150, the exact visual result depends on the composition's timing conventions. In many programming models, durations are half-open intervals: a segment from frame 0 for 150 frames covers frames 0 through 149. The next segment begins at frame 150. Understanding the convention prevents a one-frame gap or accidental overlap.

For a 20-second composition at 30 fps, there are 600 frames, normally numbered 0 through 599. The final frame is not frame 600. A frame-based renderer samples each frame at a particular time; a player then presents them in sequence. Check how your specific tool handles duration and seeking rather than assuming every editor exposes the same numbering.

### Use time as an editorial unit

“Hold this diagram for another 15 frames” is a precise request if the frame rate is known. “Hold it for half a second” is equally useful when discussing the result with a nontechnical collaborator. At 30 fps, those requests are equivalent. At 24 fps, half a second is 12 frames. Include the frame rate when translating between the two.

A long hold does not automatically improve comprehension. A static scene that contains too much information may still be difficult. First reduce the number of competing ideas, then give the important content enough time to be seen.

## 7. Inspect the frames where problems tend to hide

A full playback pass reveals the experience; targeted frame inspection reveals the cause. Inspect at least:

- The first visible frame and the final frame.
- Each scene boundary, including one frame before and after the cut when practical.
- The middle of major movements, where elements may cross or overlap.
- The point where text first becomes readable and the point before it disappears.
- Caption starts and ends, particularly where they overlap graphics.
- Moments when a generated clip transitions into a code-driven scene.

Why inspect the middle of a movement? An element can start and end in the correct position but pass through another element on its way. A card may animate behind a title and cover it for only a fraction of a second. A single still of the final layout would miss that defect.

Why inspect one frame around a boundary? A sequencing error can create a one-frame black flash or show the previous scene underneath the next. At normal speed, the viewer may perceive the result as a flicker without knowing why. Neighboring frames make the cause visible.

### Build a review table

Use the actual timeline of your draft:

| Time or frame | What to inspect | Expected result |
| --- | --- | --- |
| Start | First frame | No unintended blank or clipped title. |
| Scene 1 midpoint | Table and narration | The table is identifiable and text is readable. |
| Scene 1 → 2 boundary | Cut and overlays | No black flash, unwanted overlap, or missing caption. |
| Index arrow midpoint | Motion | The path is visible and points to the intended row. |
| Conclusion | Tradeoff and call to action | Claim is accurate and held long enough to read. |
| Final frame | Ending | No clipped fade, unexplained blank, or cut-off audio tail. |

This table is a test plan for a video: it identifies an observation and an expected result. It is not a substitute for watching motion. A still frame cannot show whether an animation is smooth or whether music masks speech.

## 8. Extract stills with FFmpeg

FFmpeg is a command-line media tool. The examples below assume it is installed and available on your `PATH`, that you are in a directory containing `index-explainer-v01.mp4`, and that you can write into the current directory. They create local files only. Replace the input path with your own video.

To extract a representative frame near 7.2 seconds:

```bash
ffmpeg -ss 7.2 -i index-explainer-v01.mp4 -frames:v 1 review-07-2.png
```

`-ss 7.2` seeks to approximately 7.2 seconds, `-i` selects the input, and `-frames:v 1` writes one video frame. Seeking behavior can depend on codec, container, timestamps and option placement; if exact frame identity matters, verify it with a frame-index method and inspect output. The PNG preserves the extracted still without adding JPEG compression, but it cannot reverse compression already present in the MP4.

To select a particular decoded frame by zero-based frame index, use a filter. This example selects frame 216, which corresponds to 7.2 seconds in a constant 30-fps timeline when frame zero starts at time zero:

```bash
ffmpeg -i index-explainer-v01.mp4 -vf "select=eq(n\,216)" -frames:v 1 review-frame-216.png
```

The `select` filter evaluates `n`, the decoded frame number, and keeps the requested frame. The escaped comma belongs to FFmpeg's filter syntax in a shell command. Frame indexing and timestamps can be more complex for variable-frame-rate input or files with unusual starting timestamps. Use the frame's actual timestamp if you require strict time alignment, and consult your FFmpeg version's documentation.

For several checkpoints, create a small script rather than manually typing many similar commands. This example selects by time and records the intended review points:

```python
from pathlib import Path
import subprocess

video = Path("index-explainer-v01.mp4")
output_dir = Path("review-stills")
output_dir.mkdir(exist_ok=True)

checkpoints = {
    "opening": 0.0,
    "table": 3.0,
    "index-motion": 7.2,
    "tradeoff": 15.0,
    "near-end": 19.5,
}

if not video.is_file():
    raise FileNotFoundError(video)

for label, seconds in checkpoints.items():
    destination = output_dir / f"{label}.png"
    subprocess.run(
        [
            "ffmpeg", "-y", "-ss", str(seconds), "-i", str(video),
            "-frames:v", "1", str(destination),
        ],
        check=True,
    )
    print(f"Created {destination}")
```

Save it as `extract_review_stills.py`, then run `python extract_review_stills.py`. `subprocess.run` passes arguments as a list rather than constructing a shell command, avoiding shell interpretation of a filename. `check=True` raises an error if FFmpeg returns a nonzero status. `-y` overwrites stills with those names, so use a dedicated review directory and avoid putting unrelated files there. A successful run creates images; you must still open and inspect them.

Do not request a timestamp beyond the actual video duration and assume an image was produced. Check the duration first. Near the end, choose a point safely inside the media; the exact final presentation timestamp depends on frame count and encoding.

## 9. Inspect metadata rather than trusting the filename

FFprobe can print media properties. A `.mp4` extension identifies a container, not the exact codec, dimensions, or frame rate inside it. A file named `vertical-final.mp4` can still have the wrong dimensions.

```bash
ffprobe -v error -show_entries \
  format=duration:stream=index,codec_type,codec_name,width,height,avg_frame_rate,sample_rate,channels \
  -of json index-explainer-v01.mp4
```

The JSON output includes selected stream information. A video stream may report width, height, codec name and an average frame rate represented as a fraction such as `30/1`. An audio stream may report sample rate and channels. The format duration describes the container; individual stream durations can differ. The output tells you what was encoded, not whether the content is legible or synchronized.

For a 1080 × 1920 frame, width divided by height is `0.5625`, equivalent to 9:16. A 1920 × 1080 frame is 16:9. The numbers matter because a file can have an appropriate aspect ratio at a different resolution, while an incorrectly oriented frame may have the same total pixel count.

Frame-rate fields deserve care. A fraction labeled `avg_frame_rate` is an average; it does not prove that every frame has the same interval. For frame-accurate work, determine whether the file is constant or variable frame rate and inspect timestamps as needed. Avoid “fixing” a healthy file by blindly converting its frame rate, because conversion can duplicate or drop frames and affect synchronization.

## 10. Test legibility at the size people actually see

An editor preview may occupy a large desktop monitor. A vertical video in a social feed may be displayed at only a fraction of its export size, with platform controls covering part of the frame. Therefore a 1080-pixel canvas is not evidence of readable text.

Reduce your preview to roughly the physical size at which you expect a viewer to see it, and test on a real phone when possible. The exact size and overlay placement depend on the platform, device, orientation, and app version. There is no universal pixel boundary that guarantees safety across all surfaces.

### What to look for

- Can you read the title without pausing or leaning closer?
- Is there sufficient contrast over the brightest and darkest parts of the footage?
- Are important labels large enough to distinguish from decorative details?
- Do captions obscure the object they describe?
- Does the platform's interface cover your call to action or diagram?
- Can a viewer follow the scene without reading several competing blocks at once?

A useful visual hierarchy gives the eye a starting point. For example, show “Indexes provide another route” as the primary headline, then reveal the index and a single highlighted row. If there are six equally bright labels, the viewer has to decide where to look while the narration continues. Removing unnecessary information often helps more than shrinking everything to fit.

### Contrast is not only color

White text can disappear against a bright background even if it is a large font. Add a dark backdrop, scrim, outline, or other separation where appropriate. Inspect moving footage throughout the caption's duration: a caption may be readable on a dark frame and become unreadable when a bright object moves behind it. Do not rely on a single representative frame for a changing background.

## 11. Evaluate movement, not just style

Motion has a job: introduce an element, show a relationship, guide attention, convey change, or connect scenes. When every object moves continuously, no movement stands out and the viewer has more work to do.

Review an animation in three parts:

1. **Entrance:** does the viewer have time to notice what appeared and where it came from?
2. **Hold:** is the final state stable long enough to understand it?
3. **Exit or transition:** does the next scene begin only after the important point is clear?

For the database example, an arrow can move from an index entry to a row. At the start, the source should be visible. During movement, the arrow should remain distinguishable from the background. At the end, the destination should be highlighted long enough to associate it with the index. If the arrow leaves the screen immediately, a smooth easing curve alone will not make the explanation clear.

### Diagnose a motion problem

Suppose a reviewer says, “The arrow is too fast.” There are at least three possible causes:

- The travel duration is short, so the eye cannot follow it.
- The arrow travels at a reasonable speed but is too thin or low contrast.
- Multiple other elements move at the same time, dividing attention.

Test the simplest plausible change first. Slow the arrow or reduce competing movement, render a short preview, and compare. A useful iteration changes a small number of variables so you can understand why the result improved or worsened.

### Frame determinism

A code-driven renderer may evaluate frames out of order or render them in parallel. If a visual depends on the current clock time, an unseeded random number, a network response that changes, or state accumulated only by playing previous frames, the output may differ between runs or from the preview. A robust animation can compute the desired appearance from the requested frame or a seekable timeline and stable inputs.

In practical terms, if frame 216 is requested twice with the same inputs, it should describe the same intended state. External footage and rendering details can still vary; “deterministic” is a property to test in your chosen workflow, not a blanket guarantee that all systems produce byte-identical output.

## 12. Review audio as its own experience

A video that looks polished can still be unusable if its speech is difficult to hear. Listen from beginning to end at a normal level. Check for clipped consonants, sudden volume changes, noise between edits, music masking words, effects that are louder than the voice, and a final word cut off at the end.

Then listen on a second device or speaker type. Headphones can reveal noise and clicks; a phone can reveal whether music masks narration on a small speaker. Avoid assuming that making the whole mix louder will repair a balance problem. If the music competes with the voice, lowering or changing the music may be more effective.

Listen to the exported file, not only the editor timeline. If the export has no audio, first check whether an audio stream exists, then investigate track mute settings, asset paths, codec support, and renderer settings. If the stream exists but is silent, the issue may be the mix or source rather than the container.

### Review captions twice

First, watch muted and ask whether the captioned video communicates the message. Second, play with audio and follow the text, checking names, numbers, punctuation, timing and synchronization. A caption can be perfectly readable and still be inaccurate. A correct transcript can be unusable if it appears too quickly or covers the diagram.

If every caption is late by the same amount, investigate the shared time offset. If the first caption is aligned and later captions become progressively late, investigate whether the transcript corresponds to the final audio and whether speed changes or edits caused drift. Use observations to decide which timing model is wrong rather than moving every cue by an arbitrary number.

## 13. Review factual claims and visual evidence

A technical explainer is a claim made through several channels at once: words, numbers, visuals, and sound. Check whether they agree. If the narrator says “an index may help,” a large headline reading “instant results every time” changes the meaning. If the video shows a fictional benchmark, a viewer can reasonably mistake it for a measured result unless you label it clearly.

For each factual statement, ask:

1. What exactly is being claimed?
2. What source or demonstration supports it?
3. Does the source apply to the version, conditions and context shown?
4. Does the diagram simplify the concept without introducing a false implication?
5. Are limitations represented where they matter to the message?

For a database index, show that the database *can* use an index to locate matching entries. Avoid implying that every query uses it or that an index has no cost. If you use benchmark numbers, document the workload and conditions and ensure the results actually exist. If the video is conceptual, use labels such as “illustrative” where a viewer could mistake an invented chart for measured data.

AI agents are useful reviewers, but they can confidently invent sources or oversimplify claims. Give them the approved source material and ask them to identify unsupported assertions. Then verify the flagged claims against reliable sources yourself. An agent's critique is a starting point for review, not proof of correctness.

## 14. Distinguish symptoms from causes

A good defect report describes what happens and how to observe it. It need not guess the implementation immediately.

Weak report:

```text
The video looks bad. Fix the animation.
```

Stronger report:

```text
At 00:07.2–00:08.0, the caption covers the highlighted database row.
The row is the focus of the narration. Move the caption to the reserved
upper region for this scene, keeping its wording and timing unchanged.
Render the same interval again and provide stills at 00:07.2 and 00:08.0.
```

The second report identifies the location, the conflict, the intended behavior, a proposed constraint, and evidence to collect. It does not require knowing which CSS rule is wrong. If the proposed fix introduces a new collision, revise the layout rather than mechanically obeying an unsuitable instruction.

### Prioritize defects by impact

A practical ordering is:

1. Incorrect or unsafe content, missing audio, broken playback, or exposed sensitive data.
2. A viewer cannot understand the message: unreadable text, incorrect captions, or a hidden diagram.
3. Distracting pacing, abrupt transitions, inconsistent sound, or obvious visual defects.
4. Decorative refinements such as a slightly different shadow or background texture.

This ordering is contextual. A decorative element may become high priority if it hides an important label or creates a misleading association. The point is to fix the cause of audience failure before spending an hour adjusting a subtle glow.

## 15. Make a controlled revision

A revision should have a hypothesis:

> The arrow is difficult to follow because it travels while three cards enter simultaneously. If we delay the cards until the arrow settles and extend the arrow's movement by 0.4 seconds, the relationship should be clearer.

Implement the change, render the affected interval, and compare with the earlier draft. Ask whether the arrow is easier to follow and whether the added time harms the next scene or causes narration and captions to drift. If the hypothesis was wrong, the comparison is still useful: you learned that competing motion was not the whole cause.

### Use local time carefully

In a component-based video, a scene may start at frame 180 in the overall composition. Inside a sequence that resets local time, the scene's first local frame may be 0. A requested change at global frame 216 therefore corresponds to local frame 36 in that scene. The exact behavior depends on the framework and placement; inspect the relevant sequence. This is a common reason an agent edits a value but affects the wrong moment.

```text
global frame = scene start frame + local frame
local frame  = global frame - scene start frame
```

At 30 fps, if the scene begins at 6 seconds, its start is frame 180. A moment at 7.2 seconds is global frame 216, or local frame 36. If the timeline has nested sequences, offsets can accumulate. Verify the resulting export rather than relying only on mental arithmetic.

### Preserve a known-good comparison

Name outputs clearly, for example `v01-before.mp4` and `v02-arrow-hold.mp4`, and record what changed. Do not compare two videos whose scripts, fonts, colors, and music all changed unless you are intentionally evaluating a whole new direction. Broad revisions are sometimes necessary, but small revisions make causes easier to identify.

## 16. Use image differences carefully

When migrating a composition from one renderer to another, still-frame comparisons can reveal missing elements or timing changes. A pixel difference highlights where images diverge, but a difference is not automatically a defect. Fonts, anti-aliasing, color conversion, compression and subpixel positioning can produce pixel changes even when the composition looks essentially the same. Conversely, a small-looking numerical difference can hide a meaningful change in a label or number.

A sensible comparison procedure is:

1. Match frame dimensions, intended timestamps, color settings, and source assets as closely as possible.
2. Export representative frames from both versions, ideally without adding avoidable lossy compression.
3. View the images side by side and, if helpful, generate a difference image.
4. Inspect important text, position, hierarchy and motion state manually.
5. Document expected differences, such as a substituted font or an intentionally changed transition.

The following FFmpeg command creates a visual difference between two same-size still images using the `blend` filter. It assumes `before.png` and `after.png` have matching dimensions. This is a diagnostic image, not a quality score:

```bash
ffmpeg -i before.png -i after.png \
  -filter_complex "[0:v][1:v]blend=all_mode=difference" \
  -frames:v 1 difference.png
```

Dark areas represent little or no pixel difference; brighter areas show changes. A bright edge around every letter can be a font-rendering difference. A missing word or a moved graphic also produces a difference but has a very different impact. Review the original images as well. Color management, transparency and mismatched frame timing can complicate interpretation.

## 17. Build a practical automated check

Automation is valuable for objective facts that can be checked reliably: whether a file exists, whether metadata can be read, and whether dimensions match an intended format. It cannot establish that a hook is compelling or a technical statement is true.

The following complete Python script calls `ffprobe` and checks a few properties of a local MP4. It uses only the Python standard library plus an installed `ffprobe` executable. Save it as `check_video.py` and run `python check_video.py index-explainer-v01.mp4`. It expects a portrait 1080 × 1920 video with an audio stream; modify the constants for your own deliverable.

```python
import json
from pathlib import Path
import subprocess
import sys

EXPECTED_WIDTH = 1080
EXPECTED_HEIGHT = 1920


def inspect_video(path: Path) -> dict:
    result = subprocess.run(
        [
            "ffprobe", "-v", "error", "-show_streams", "-show_format",
            "-of", "json", str(path),
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python check_video.py path/to/video.mp4")
        return 2
    path = Path(sys.argv[1])
    if not path.is_file():
        print(f"File not found: {path}")
        return 2

    try:
        metadata = inspect_video(path)
    except (FileNotFoundError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        print(f"Could not inspect video: {error}")
        return 2

    streams = metadata.get("streams", [])
    videos = [stream for stream in streams if stream.get("codec_type") == "video"]
    audios = [stream for stream in streams if stream.get("codec_type") == "audio"]
    failures = []
    if not videos:
        failures.append("No video stream found")
    else:
        video = videos[0]
        actual = (video.get("width"), video.get("height"))
        if actual != (EXPECTED_WIDTH, EXPECTED_HEIGHT):
            failures.append(f"Expected {EXPECTED_WIDTH}x{EXPECTED_HEIGHT}, got {actual}")
        print(f"Video codec: {video.get('codec_name', 'unknown')}")
        print(f"Average frame rate: {video.get('avg_frame_rate', 'unknown')}")

    if not audios:
        failures.append("No audio stream found")
    print(f"Container duration: {metadata.get('format', {}).get('duration', 'unknown')} seconds")
    for failure in failures:
        print(f"FAIL: {failure}")
    if failures:
        return 1
    print("Basic metadata checks passed. Review content and playback separately.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

The script reads metadata as structured JSON. It selects streams by `codec_type`, checks the first video stream's dimensions, and checks whether at least one audio stream exists. An exit code of 0 means these selected checks passed; 1 means a listed check failed; 2 means the script could not perform the inspection. It does not prove that the audio is audible, that frame timing is correct, that the captions are accurate, or that every player supports the codec. A silent audio stream still satisfies the presence check.

If your deliverable is intentionally silent, remove the audio requirement. If you expect a different resolution or several video streams, modify the check to match the brief. A test is useful only when its assumptions match the intended product.

## 18. Ask an AI agent to review evidence

An agent can inspect code, run metadata commands, extract frames, and sometimes view images or play media depending on its environment. These capabilities are not guaranteed. Ask it to report what it could actually inspect, and provide the draft, source project, review criteria and known problems. Avoid a prompt that rewards a confident answer regardless of evidence.

### Claude Code prompt: structured visual review

```text
Review the draft at renders/index-explainer-v01.mp4 and its source project.
The audience is developers new to indexes. The intended message is that an
index can offer another route to matching rows, with storage and update costs.

Check the file's dimensions, duration, streams and frame rate. Extract and
inspect representative stills at each scene boundary and at the midpoint of
major animations. Look for clipped text, caption collisions, low contrast,
and a mismatch between the visuals and the approved script in script.md.
Report each issue with a timestamp, evidence, severity and a proposed fix.
Do not claim to have heard audio or verified a fact unless you actually did.
Do not alter the project yet.
```

This is a review request. It tells the agent not to mutate the project before reporting. If your own workflow authorizes immediate changes, you can instead ask it to fix confirmed issues and rerender, but still require a record of what changed and what was checked.

### Codex prompt: implement one verified repair

```text
At 00:07.2 in renders/index-explainer-v01.mp4, the caption overlaps the
highlighted row. The approved wording and cue timing in captions.json are
correct. Inspect the relevant composition and identify the local/global time
relationship. Move the caption into the scene's reserved upper region without
covering the title. Render the affected interval and extract stills at 00:07.2
and 00:08.0. Explain the code change and report any checks you could not run.
Preserve the existing narration and caption wording.
```

This directs a narrow, testable repair. It explicitly preserves content and asks for evidence at two moments, which helps reveal whether moving a caption fixes one frame but creates a collision later.

### Ask for a separate technical review

```text
Inspect the final exported file with ffprobe. Compare its width, height,
frame rate, duration, video codec, and audio stream presence with the project
brief. Report the observed values and any mismatch. Then list the remaining
human checks that metadata cannot establish, including intelligibility,
caption accuracy, visual readability, and factual correctness.
```

The important distinction is between observed values and conclusions. If the agent reports “audio stream present,” that is evidence of a stream, not evidence that narration is audible. If it has not watched a video or heard the mix, it should not claim that it did.

## 19. A complete before-and-after example

Imagine the first draft has these problems:

- At 00:03, the headline and diagram occupy the same area.
- At 00:07.2, a caption hides the selected row.
- At 00:15, the spoken tradeoff is accompanied by a headline that still says “Faster searches,” creating an incomplete impression.
- The MP4 has the expected portrait dimensions, but the narration is quiet compared with music.

Begin with meaning and intelligibility. Change the final headline to communicate the actual tradeoff, and reduce music until the voice is easy to follow. Next, reserve space for the headline and diagram rather than forcing both into the same region. Finally, move the caption or adjust the diagram layout at 00:07.2.

After each change, render the affected interval when possible. Then render the full piece, because a local fix can affect the whole timeline. For example, extending the arrow animation by 0.4 seconds may push the next scene later; if narration and caption timing remain fixed, the new visual may no longer match the spoken sentence.

A review record could look like this:

```text
v01 → v02
- Replaced the conclusion label with “Faster reads can have update costs.”
- Lowered the music bed; narration unchanged.
- Reserved separate headline and diagram regions in scene 1.
- Moved the scene 2 caption to the upper safe region.

Verified
- Extracted scene 1 and scene 2 stills.
- Checked export dimensions and audio stream with ffprobe.
- Watched the full export and listened on headphones and a phone.

Still to verify
- Confirm caption availability and placement in the actual target platform.
- Check the music license for the planned publication.
```

The final section prevents “verified” from becoming a vague badge. It distinguishes the observations you made from the remaining work.

## 20. Common failure patterns

### A visually impressive intro delays the point

A five-second logo animation may feel short while editing, yet consume a large fraction of a 20-second clip. Review the opening as a viewer who does not already know you. Introduce the subject or a useful question early; if the logo is important, integrate it without making the audience wait for the content.

### Text is visible but not readable

A title may technically appear for a second, but its entrance animation can consume half that time. Count the period during which the text is stable and legible, not merely the period during which its element exists. Increase the hold, shorten the text, simplify the background, or reduce competing motion.

### The diagram is correct in isolation but wrong in context

A graphic may accurately depict an index entry pointing to a row, while the narration describes a different query. Review the synchronization of what is said and shown. If the graphic is illustrative, state that when it would otherwise be mistaken for an actual query plan.

### An agent fixes a screenshot and breaks motion

A static frame can look correct while the animated object collides with another element before or after that instant. Inspect the range of the change, including its midpoint and both endpoints. Watch the rendered interval at speed.

### Rendering fails only on another machine

Check relative and absolute paths, missing assets, installed fonts, browser or renderer dependencies, and environment-specific configuration. Store required project assets in a predictable structure and document setup. Avoid relying on an asset that only exists in one user's downloads folder. Do not assume a network-hosted font or image will always be available during offline or isolated rendering.

### Preview and export disagree

Look for wall-clock animations, asynchronous asset loading, unsupported seek behavior, unseeded randomness, video playback assumptions, and differing fonts. Reduce the problem to a short composition with one moving element, then compare the same timestamps. The exact fix depends on the renderer; use its current documentation for the supported timing model.

### The edit improves one format but harms another

A 16:9 layout cropped to 9:16 may lose labels or place a caption over the subject. Recompose for the new aspect ratio rather than assuming a center crop preserves the story. Keep the original asset and compare each output in its intended presentation context.

## 21. Finish with a release review

Before publishing, inspect the final exported version—not an earlier draft—and confirm that it corresponds to the intended source revision. A practical review includes:

- The core message is accurate and understandable without additional explanation.
- The first and last frames, scene boundaries, captions and important motion moments have been inspected.
- The video has been watched at normal speed, at phone size, with sound and muted.
- Narration is intelligible; music and effects support it; captions match the final audio.
- The file's dimensions, duration, streams and format match the delivery brief.
- The real target platform's crop, overlays, caption options and playback are checked where possible.
- Assets, music, voices, references and on-screen material are authorized for the intended use; sensitive information is absent.
- The project, source assets and export instructions are organized so a future revision is possible.

This list is a guide to observable outcomes, not a promise that every possible issue has been found. If you cannot perform a check, record that limitation. For example, “phone playback reviewed; target platform upload preview not yet checked” is more useful than a general claim that the video is ready everywhere.

## 22. Optional application: two measured iterations

Choose a short draft, even a simple title and diagram. Write its audience objective and create a baseline export. Watch it once at normal speed, then extract stills around two scene boundaries and one motion midpoint. Note three concrete issues with times and expected behavior.

In the first iteration, fix the issue that most affects understanding. Export a comparison and note the result. In the second iteration, fix one visual or audio issue. Watch the entire video again and record any remaining limitations. If an agent makes the changes, compare its report with the actual files and evidence.

The purpose is not to perform a ritual number of revisions. It is to develop a habit: observe, form a hypothesis, make a change, and verify its effect in the delivered artifact.

## Takeaways and references

A render is the beginning of review, not the end. Evaluate meaning, pacing, visuals, audio, captions, technical delivery and permissions as related but distinct concerns. Use precise timestamps and representative frames to diagnose defects; use actual playback to judge motion and sound. Automated checks can verify measurable properties, while human review remains necessary for clarity, correctness and experience. A good agent prompt names the objective, inputs, constraints and evidence expected, and an honest review identifies what was not checked.

For renderer-specific behavior, consult the current [Remotion documentation](https://www.remotion.dev/docs/) and [HyperFrames rendering guide](https://hyperframes.app/docs/3-guides/4-rendering). For local media commands, use the documentation for your installed FFmpeg and FFprobe versions; capabilities and options can differ by build.
