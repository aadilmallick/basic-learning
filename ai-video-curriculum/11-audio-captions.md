# Lesson 11 — Narration, Sound, and Captions

A visual can communicate an idea, but the viewer still needs enough time and attention to understand it. Audio changes how that attention is directed. A clear voice carries the explanation, music provides emotional context, and small sound effects make visual actions feel deliberate. Captions let viewers follow when they cannot hear or prefer to watch silently.

These elements work best when they support the same message. A dramatic music track, a fast synthetic voice, and captions that cover the diagram may each seem impressive in isolation, yet together they can make an explainer harder to understand. In this lesson we build a calm, repeatable process: prepare the narration, record or synthesize it, edit the voice, synchronize it with a visual timeline, add and verify captions, and mix supporting sound at a level that leaves the voice understandable.

The running example is a short developer video about database indexes. Its claims are intentionally modest: an index can help a database locate matching rows without examining every row, but whether a particular query uses one depends on the database, query, data, and execution plan. We will create illustrative timing and commands; you can substitute a product demo or another topic.

## 1. First understand the three timelines

Imagine a 20-second video with three independently editable tracks:

1. A **visual timeline** determines what appears on screen at each moment: a title, an animation of rows, an index diagram, and a final takeaway.
2. An **audio timeline** determines when the voice, music, and effects start and stop, and how their loudness changes.
3. A **text timeline** determines when each caption appears and disappears.

All three are expressed relative to a shared beginning. If the narrator says “the database can use the index” at 8.2 seconds, the index diagram should be visible at a meaningful point around that time, and the corresponding caption should also be displayed. A timeline is therefore a set of time relationships, not just a stack of files.

At 30 frames per second, 8.2 seconds corresponds to frame `8.2 × 30 = 246`. This conversion helps when a visual renderer uses frames but a transcription service gives milliseconds. The general formula is:

```text
frame = seconds × frames_per_second
seconds = milliseconds / 1000
frame = (milliseconds / 1000) × frames_per_second
```

When the result is not a whole frame, a visual must select an integer frame. For example, 8,215 ms at 30 fps gives 246.45 frames. Round to the nearest frame if you are aligning a visual cut. At normal short-form frame rates, a rounding difference of a fraction of a frame is usually much smaller than the editorial changes you will make by eye and ear. This calculation does not mean that the underlying audio itself is only accurate to a frame: audio is sampled many thousands of times per second.

### Frames and audio samples

An image frame is one picture. An audio sample is a measurement of a waveform's amplitude at an instant. A common sample rate is 48,000 samples per second. At 30 fps, one video frame spans 1,600 audio samples at that sample rate. This explains why a waveform view can show details that are too short to represent as a separate video frame.

You normally do not edit individual samples for a narration track. The distinction matters when a cut creates a click, when recorded sound drifts from video, or when converting formats. It also makes clear why “30 fps audio” is not a meaningful description: video uses frames; audio uses samples.

## 2. Write for the ear, not the page

Writing a script is an audio production step. A paragraph that reads clearly may feel dense when spoken because listeners cannot pause and reread it. Give the listener one idea at a time, choose familiar words where they are accurate, and allow images to carry some of the explanation.

Consider these two versions:

> Database indexes are auxiliary data structures maintained by a database management system that enable optimized retrieval by reducing the number of records that must be inspected under applicable query-planning conditions.

> An index gives the database another way to find matching rows. Instead of checking every row, it may follow the index to the relevant ones.

The first sentence includes real ideas, but it requires the listener to hold several abstract phrases in memory. The second uses a concrete action: find matching rows. It also says “may,” because an index is not guaranteed to be chosen or faster for every query. The short form is easier to synchronize with an animation of rows and a highlighted path.

A sample script for a short explainer:

> A database can search a table row by row. As that table grows, some searches become expensive. An index gives the database another route to matching rows. It has costs too: indexes use storage and must be updated when data changes. The best choice depends on your queries.

Read that aloud with a stopwatch. Do not assume a universal words-per-second value. Different narrators pause differently, and a phrase that introduces a new diagram may need extra silence. Record the actual duration, then build the scene timing around the recording or adjust the delivery deliberately.

### Give narration room to breathe

A useful first pass places a short pause after each important claim. That pause creates space for a visual to appear and settle. For instance:

| Approximate beat | Voice | Visual |
| --- | --- | --- |
| Opening | “A database can search a table row by row.” | Rows appear and a highlight travels down them. |
| Problem | “As that table grows, some searches become expensive.” | The table expands; the scan takes longer. |
| Mechanism | “An index gives the database another route to matching rows.” | A compact index points to a matching row. |
| Tradeoff | “Indexes use storage and must be updated when data changes.” | An index icon gains a storage label and update arrow. |
| Conclusion | “The best choice depends on your queries.” | A query and execution-plan icon appear. |

These beats are editorial intent, not a claim that the speech lasts a specific number of seconds. After recording, replace approximate boundaries with actual timings.

Avoid using a caption as the only source of a critical disclaimer while the voice and visual imply the opposite. Captions should help people access the message, not silently change it.

## 3. Decide between your voice and a synthetic voice

A recorded human voice and a synthetic voice both have legitimate uses. Your own voice can make a developer video feel personal and can be easier to update locally. A synthetic voice can be useful for testing timing, prototyping, or producing accessible variants, but its pronunciation, emotional emphasis, and delivery still need review. The choice does not remove the need for editing.

| Consideration | Your recorded voice | Synthetic voice |
| --- | --- | --- |
| Initial setup | Microphone and reasonably quiet space | A provider or local model and a compatible workflow |
| Revision | Re-record lines with matching distance and tone | Generate another take; compare continuity and pronunciation |
| Privacy and rights | Control your recording and any collaborators' consent | Check provider terms, data retention, allowed use and voice rights |
| Consistency | Can vary by session or microphone position | May vary by generation, settings, or model version |
| Personal brand | Naturally carries your delivery | Can be useful for prototypes or a consciously chosen style |

Do not clone or imitate someone's voice without appropriate consent and rights. Treat a provider's generated audio as an asset with its own terms. If your project includes confidential material, check whether the service may receive or retain the script or uploaded audio before using it. These are workflow decisions tied to the actual provider, not a generic assumption that every provider handles data in the same way.

### Pronunciation and meaning

Technical words often expose a weakness in speech synthesis. “SQL” may be read as letters or as a word. “PostgreSQL,” “JSON,” names of libraries, and command flags may be spoken inconsistently. First try writing a version intended for speech while preserving the correct displayed caption. If a provider supports pronunciation dictionaries or phonetic controls, follow its current documentation. Do not silently alter the meaning of an acronym to make the voice sound natural.

A good production record has both versions:

```text
Display text: Run SQL EXPLAIN to inspect the query plan.
Spoken text: Run “sequel explain” to inspect the query plan.
Review note: Confirm that the spoken pronunciation matches the intended audience.
```

The quoted pronunciation above is just one possible preference, not a rule. If captions are intended to transcribe speech, the caption should represent what was actually said while preserving intelligibility. A separate on-screen code label can show the exact command.

## 4. Record a clean voice track

The easiest noise to remove is noise that never enters the recording. Begin with a quiet room, close unnecessary windows, and turn off controllable noise sources if practical. A room with soft furnishings often produces fewer distracting reflections than a bare room. You do not need a professional booth to make a usable first recording.

Position the microphone consistently. Avoid placing it directly in the airflow from your mouth, which can exaggerate plosive sounds such as “p” and “b.” A pop filter or a slight off-axis position can help. Keep a comfortable distance and maintain it between sentences. If you move close on one line and far away on the next, the level and room sound change, making editing harder.

### Input level and clipping

A digital waveform has a maximum representable level. When the recording chain is driven beyond its limit, peaks can be clipped. Clipping can create distortion that is difficult to repair because the waveform's original peaks were not recorded accurately. Leave headroom rather than trying to make the raw recording as loud as possible. A rough starting point for spoken peaks might be around `-12 dBFS`, but the exact target depends on the microphone, interface, delivery, and recording application; use the meter, listen, and make a short test.

`dBFS` means decibels relative to digital full scale. A peak of `-12 dBFS` is below the maximum; `0 dBFS` is the digital ceiling. A lower peak does not automatically imply poor quality, and the peak meter alone does not tell you how loud the speech will feel over time.

Record a short test containing your quiet and emphatic speaking levels. Listen with headphones. Check for clipping, fan noise, room echo, mouth noise, and inconsistent distance. Correct the recording conditions before recording the full script.

### Record in manageable sections

Instead of trying to speak a complete script perfectly in one take, record one or two sentences at a time. If you make a mistake, pause briefly and repeat the sentence. The pause creates a visible gap in the waveform for locating the good take later. Avoid making a loud clap next to the microphone unless your workflow specifically requires a synchronization marker; unexpected peaks can clip.

At the end, record a few seconds of the room with no speech. This **room tone** can help you judge background noise and cover small gaps if necessary. It is not a substitute for a quiet recording environment.

Keep the raw recording. Save edits to a new file or work in an editor that retains the source. That gives you the option to repair a bad cut without rerecording everything.

## 5. Understand the audio processing chain

Audio editing is a sequence of decisions, not a magic “make it professional” button. A typical chain may include cleaning, equalization, compression, and final loudness adjustment, but every process has a cost if overused.

### Noise reduction

Noise reduction attempts to suppress unwanted sounds. Gentle reduction can make a steady hum less noticeable; aggressive reduction can make speech sound watery or artificial. Before applying it, compare a bypassed version with the processed version on headphones. If the room is very noisy, improving the recording environment or rerecording may sound better than heavy processing.

### Equalization

An equalizer changes the relative level of frequency ranges. A low-frequency cut can reduce rumble, while a small adjustment elsewhere can improve clarity. There is no universally correct set of frequencies: a setting that helps one voice and microphone can thin out another. Start with small changes and listen to full sentences rather than tuning by numbers alone.

### Compression

A compressor reduces the difference between louder and quieter parts when the signal crosses its threshold. Properly used, it can make narration easier to hear consistently. Too much compression can emphasize breaths and room noise or make speech sound flat. Learn the concepts before copying a preset:

- **Threshold:** where compression starts to act.
- **Ratio:** how strongly it reduces level above that threshold.
- **Attack:** how quickly it reacts after a signal exceeds the threshold.
- **Release:** how quickly it stops reducing level after the signal falls.
- **Makeup gain:** level added after compression, if needed.

A compressor is not the same thing as turning the volume down. A volume control shifts quiet and loud passages together; compression changes their relationship.

### Normalization and loudness

Peak normalization adjusts a track so its highest peak reaches a selected value. Integrated loudness measures perceived loudness over a period using a standardized method. Two tracks with the same peak can have very different perceived loudness: one may have a single sharp peak and otherwise quiet speech, while another remains consistently loud. Listen at a consistent monitoring level and check current delivery requirements for your platform instead of treating one loudness target as universal.

A limiter can constrain peaks, but it is not a cure for a badly balanced mix. If a limiter works constantly, lower or rebalance the underlying sources. Avoid promising that a specific command guarantees compliance with every platform: platforms have different, changing requirements and may process uploads themselves.

## 6. A small local audio inspection workflow

The following commands use FFmpeg and FFprobe, which must be installed and available on your `PATH`. They inspect and process a local file named `narration.wav`. They do not call a paid service. Always keep the original and listen to the result; command success does not tell you whether the voice sounds good.

First inspect duration, codec, sample rate and channels:

```bash
ffprobe -v error -show_entries format=duration -show_entries stream=codec_name,sample_rate,channels -of default=noprint_wrappers=1 narration.wav
```

`ffprobe` reads media metadata. `-v error` suppresses most informational logs, `-show_entries` selects fields, and `-of default=noprint_wrappers=1` produces a compact output. The result tells you technical facts such as whether the file is mono or stereo; it does not judge sound quality.

To make an unprocessed working copy with a known sample rate and stereo layout:

```bash
ffmpeg -i narration.wav -ar 48000 -ac 2 narration-working.wav
```

`-i` supplies the input, `-ar 48000` requests 48 kHz output, and `-ac 2` requests two channels. A mono voice duplicated to stereo is still a centered mono source; creating two channels does not create a spatial recording. You may prefer to keep narration mono until a final mix. Resampling does not improve the fidelity of a poor recording, and repeated unnecessary conversions can degrade lossy sources.

To inspect loudness, FFmpeg provides the `loudnorm` filter. Its measured values are diagnostic, not a promise of platform compliance:

```bash
ffmpeg -i narration-working.wav -af loudnorm=print_format=summary -f null -
```

This processes the audio to a null output and prints a measurement summary. Exact filter behavior and options can vary with your FFmpeg build; consult `ffmpeg -h filter=loudnorm` for that installation. The command is not a finished mix and does not change the source file. For a published video, evaluate the final combined voice, music and effects, not narration alone.

### Silence and breaths are editorial material

A clean edit is not necessarily the shortest edit. A tiny pause before a conclusion can give a diagram time to settle. Breath can sound natural; removing every breath can make a voice feel rushed. The goal is to remove distractions and control pacing, not to erase signs of human speech.

For a problematic cut, zoom into the waveform and listen. Abruptly joining two nonzero waveform points may cause a click. A short crossfade or a cut near a suitable quiet region often helps, though the best choice depends on the sound. Do not apply long fades that swallow consonants.

## 7. Add music and sound effects with a purpose

Think of the voice as the foreground and music as the environment. If both compete for the same attention, the viewer struggles to follow the explanation. Start by listening to the voice without music. Then add music quietly, and raise it only until it supports the intended feeling. Finally, listen on small speakers or phone speakers; music that seems subtle in headphones can mask speech on another device.

**Masking** occurs when one sound makes another harder to hear, particularly when they share frequency content or occur at the same time. Turning the music down is often more effective than trying to fix a crowded arrangement with complex processing. A track with fewer instruments or less rhythmic activity may fit narration better.

Sound effects can reinforce a meaningful event: a soft click as a button activates, a subtle whoosh as a diagram transitions, or a gentle accent when a final result appears. Their timing should match the visible event. If a sound occurs before the viewer sees the action, it may feel disconnected; sometimes a deliberately early sound can anticipate a transition, but that should be a choice.

### Ducking

Ducking lowers a background track while the voice is speaking, then lets it recover between phrases. You can automate this manually in an editor or use a sidechain-capable audio tool. Listen for obvious pumping: music that repeatedly jumps in and out can draw more attention than a constant, appropriately low level. If you use a filter or plugin, verify its inputs and settings in the version you have installed rather than pasting a complicated command without understanding which track controls which.

### Obtain usable assets

For each music or effect file, record its source, creator, license or agreement, and the scope of permitted use. Note whether attribution is required, whether commercial publication is allowed, and whether the license covers the platforms you intend to use. A file available for download is not automatically cleared for every use. A generated music service can impose its own terms; check those too.

## 8. Transcription, alignment, captions and subtitles

These terms are related but not interchangeable:

- **Transcription** converts speech into text. An automatic transcript may mishear names, punctuation, code identifiers, or technical terms.
- **Alignment** associates text with time ranges in the audio. Word-level alignment can support animated word highlights; sentence-level timings can be enough for ordinary subtitles.
- **Captions** commonly include spoken words and relevant non-speech information such as `[door closes]` where useful for understanding. Definitions and accessibility conventions vary by context.
- **Subtitles** commonly present dialogue, sometimes translated. In casual product discussions these labels are often used loosely; ask what the deliverable must contain.
- **Burned-in text** is rendered into the video pixels and cannot be turned off by the player.
- **Sidecar captions** are a separate file, often `.srt` or `.vtt`, that a compatible platform or player can display. Platform support and styling control vary.

A transcription model may return words and timestamps, but it cannot guarantee correctness. Review the transcript against the actual narration and correct both text and timings. Do not assume a syntactically valid SRT is a correct transcript.

### A small SRT example

An SRT file is plain text. Each cue has an index, a start and end time, and one or more lines of text. Blank lines separate cues:

```srt
1
00:00:00,000 --> 00:00:03,500
A database can search a table row by row.

2
00:00:03,500 --> 00:00:07,000
An index gives it another route
to matching rows.
```

The times above are illustrative, not a transcript of a real recording. The timestamp format is hours, minutes, seconds, and milliseconds separated by a comma. The first cue is intended to be visible from the beginning until 3.5 seconds. Editors and players may differ in how they handle exact boundary instants, so inspect actual playback. Replace the timings with times measured from your audio.

Good caption chunks follow natural phrases. Avoid splitting a person's name, a function name, or a short phrase across a confusing boundary. Limit how much text appears at once, give viewers enough time to read, and check that the next cue does not arrive before the voice reaches it. Line length and reading-speed guidance depend on the destination and audience; treat platform specifications as constraints when provided, then review visually.

### Caption placement

Place captions where they do not cover the key diagram, user interface, or platform controls. A fixed bottom position is easy but can conflict with a speaker's name or a button. A safer layout reserves a caption region during composition. If a layout uses the lower part of the frame for important information, place captions elsewhere and review the result on the target device.

Maintain sufficient contrast against both dark and light footage. A solid or translucent background, outline, or shadow can improve readability, but a shadow cannot rescue text that is too small. Test at phone size. Avoid a rapidly changing color scheme that makes words harder to follow. If you animate a highlighted word, keep the full phrase legible before and after the highlight moves.

## 9. Build a timing file from corrected cues

A small structured file makes captions easier to reuse in a code-driven composition. Save the following as `captions.json`:

```json
[
  {
    "startMs": 0,
    "endMs": 3500,
    "text": "A database can search a table row by row."
  },
  {
    "startMs": 3500,
    "endMs": 7000,
    "text": "An index gives it another route to matching rows."
  }
]
```

Each object is one cue. `startMs` and `endMs` are relative to the start of the narration, and `text` is the verified display text. If narration begins two seconds into your final composition, add that offset when placing the cues or shift the narration to the start; do not forget that their time origins differ.

The following standalone Python script validates basic timing and creates a SubRip file. It uses only the Python standard library. Save it as `make_srt.py` next to `captions.json` and run `python make_srt.py`. The script flags overlaps because this example expects one caption at a time. Some workflows intentionally overlap speakers, in which case revise that policy rather than assuming all overlap is invalid.

```python
import json
from pathlib import Path

INPUT = Path("captions.json")
OUTPUT = Path("captions.srt")


def timestamp(milliseconds: int) -> str:
    hours, remainder = divmod(milliseconds, 3_600_000)
    minutes, remainder = divmod(remainder, 60_000)
    seconds, millis = divmod(remainder, 1_000)
    return f"{hours:02}:{minutes:02}:{seconds:02},{millis:03}"


def main() -> None:
    cues = json.loads(INPUT.read_text(encoding="utf-8"))
    if not isinstance(cues, list):
        raise ValueError("Expected an array of captions")

    blocks = []
    previous_end = 0
    for number, cue in enumerate(cues, start=1):
        start = cue["startMs"]
        end = cue["endMs"]
        text = cue["text"].strip()
        if not isinstance(start, int) or not isinstance(end, int):
            raise ValueError(f"Cue {number}: timestamps must be integers")
        if start < 0 or end <= start or not text:
            raise ValueError(f"Cue {number}: invalid time range or empty text")
        if start < previous_end:
            raise ValueError(f"Cue {number}: overlaps the previous cue")
        blocks.append(
            f"{number}\n{timestamp(start)} --> {timestamp(end)}\n{text}"
        )
        previous_end = end

    OUTPUT.write_text("\n\n".join(blocks) + "\n", encoding="utf-8")
    print(f"Wrote {len(blocks)} cues to {OUTPUT}")


if __name__ == "__main__":
    main()
```

`divmod` splits a number into a quotient and remainder. We repeatedly divide milliseconds into hours, minutes, seconds, and the remaining milliseconds. The `:02` and `:03` format specifications pad numbers with zeros. The validation catches a negative time, an empty cue, an end before a start, and unintended overlaps. It does not check spelling, whether a cue matches the spoken words, or whether viewers can read it in time. Those checks require listening and review.

## 10. Relate captions to a Remotion composition

In a Remotion project, a composition can derive the active caption from the current frame. The following is an intentionally focused component fragment: it assumes a correctly configured Remotion project and an array of verified cue objects as above. It illustrates the timing calculation; integrate it into the complete composition from the Remotion lesson and render it with your project's supported version.

```tsx
import React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from "remotion";

type Caption = { startMs: number; endMs: number; text: string };

export function CaptionOverlay({ cues }: { cues: Caption[] }) {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const currentMs = (frame / fps) * 1000;
  const activeCue = cues.find(
    (cue) => currentMs >= cue.startMs && currentMs < cue.endMs,
  );

  if (!activeCue) return null;
  return (
    <AbsoluteFill style={{ justifyContent: "flex-end", alignItems: "center", padding: 100 }}>
      <div style={{
        maxWidth: "85%", color: "white", background: "rgba(0,0,0,0.8)",
        padding: "18px 24px", fontSize: 48, textAlign: "center",
      }}>
        {activeCue.text}
      </div>
    </AbsoluteFill>
  );
}
```

`useCurrentFrame()` supplies the current frame within the relevant sequence, and `useVideoConfig()` provides the frame rate. Dividing the frame by `fps` gives elapsed seconds; multiplying by 1,000 converts it to milliseconds. The condition uses an inclusive start and exclusive end. This convention avoids showing two adjacent cues at the same instant when one ends exactly as the next starts. If the component is placed inside a shifted sequence, account for its local frame and the origin of the cue timings.

This example does not import or transcribe audio, choose line breaks, or guarantee that the overlay avoids every visual. It renders text into the frame: those captions are burned in. Remotion also has a captions package and documented approaches for caption display; consult [Remotion's caption guide](https://www.remotion.dev/docs/captions/displaying) for the current API and installation details. The separate SRT can still be used where a platform supports sidecar captions.

## 11. Narration and captions in a HyperFrames workflow

The same concepts apply when a HyperFrames composition owns the timeline: place the narration on the intended track, make caption timing relative to the same origin, and ensure caption animation is seekable. The exact HTML attributes, animation registration, and audio conventions are version-sensitive. Start from a current official example, use the installed HyperFrames skills, and run the project's lint command. A generic CSS animation driven by the browser's wall clock is not automatically equivalent to a timeline the renderer can seek reliably.

A useful handoff to the agent is explicit about what you already have:

```text
Use the narration file assets/narration.wav and the corrected captions.json.
Create editable caption elements timed from the start of the composition.
Place captions in a reserved lower region without covering the index diagram.
Use the current HyperFrames schema and a seekable timeline. Lint the project,
render a draft, and capture frames at the start, middle, and end of each cue.
Report any source/caption timing mismatch; do not silently rewrite the script.
```

This prompt does not guarantee the agent has a voice service, has transcribed anything, or can hear the result. Check its actual tool use, and listen to the export yourself.

## 12. A practical workflow from voice to final captions

Here is the complete process for the database video:

1. Finalize a short factual script and decide which ideas need visual emphasis. Read it aloud; rewrite awkward language.
2. Record your voice in sections, or generate a permitted synthetic draft. Save the raw source separately.
3. Select the best takes and make gentle cuts. Treat noise, equalization and compression only when needed. Export a working voice file.
4. Measure the actual duration. Mark the beginning and end of each spoken idea in the editor or in a cue sheet.
5. Build the visuals around those beats. Let important graphics hold long enough to be understood.
6. Transcribe and align the narration. Correct technical names and punctuation. Ensure captions match the finished audio, not an earlier script draft.
7. Place captions in a reserved area and review line breaks, contrast and reading time.
8. Add music and a few purposeful effects. Lower them until every word remains clear; listen on headphones and a small speaker.
9. Export a video and, when supported and desired, a separate caption file. Watch the export with sound, then again muted with captions.
10. If you rerecord or move narration, update the timing data and repeat the relevant checks. A caption file can become stale even when the text itself has not changed.

### Example cue sheet

```text
Time range       Asset           Editorial intent
00:00–00:03.5    narration       State the row-by-row search idea
00:00–00:03.5    caption 1       Match the first spoken sentence
00:03.5–00:07    narration       Introduce the index route
00:03.5–00:07    caption 2       Match the second spoken sentence
00:04–00:07      soft accent     Reinforce the route appearing
Entire piece     music bed       Support mood without masking voice
```

The times are placeholders. A real cue sheet should be generated or corrected against the real performance. If you shift the narration to begin at 0.8 seconds, the corresponding caption and visual cues must also shift or be deliberately retimed.

## 13. Debug common problems

### “The words are right, but the captions feel late.”

Check the cue times against the waveform and the actual exported video. The text file might be relative to the beginning of a narration clip, while the clip begins later in the overall video. Alternatively, the video or player may introduce a delay during a format conversion. Determine the offset using a clearly audible word and a visible frame, then correct the timeline. Do not repeatedly adjust individual cues if every cue shares the same offset.

### “The beginning matches, but captions drift by the end.”

A constant offset cannot fix progressive drift. Check whether the narration used for transcription is the same version and duration as the final track. Look for speed changes, edited pauses, or frame-rate interpretation problems in your editing workflow. Avoid simply scaling all timestamps until you understand the cause; a cut in the middle is not a uniform time stretch.

### “The music sounds fine on my computer but masks speech on a phone.”

Small speakers reproduce frequencies differently and may make a busy music track compete with voice. Lower the music, choose a simpler arrangement, and listen at a normal level. Check the final file, not only the editor's monitoring output. If possible, ask another listener to identify words without seeing the script.

### “The generated voice mispronounces a technical term.”

Confirm the intended pronunciation. Try a speech-oriented spelling, provider-supported pronunciation controls, or a separate recorded line. Listen to the replacement in context and verify that captions and code labels still show the intended term. Record any provider-specific setting needed to reproduce the take.

### “My narration sounds thin or unnatural after cleanup.”

Compare the processed audio with the raw track at a similar monitoring level. Bypass each process in turn to identify the cause. Reduce aggressive noise suppression, equalization or compression; if the raw source contains severe noise or clipping, a new recording may be the best repair.

### “The caption file passed validation but is still wrong.”

A validator checks structure; it cannot establish meaning, readability or accurate timing. Read along while listening, inspect awkward line breaks, verify proper nouns and numbers, and watch the video at its intended size. A valid file is only the start of quality assurance.

## 14. Direct Claude Code and Codex effectively

The following prompts provide a job, inputs, constraints and observable checks. Adapt file paths to your project. The agent should report what it actually inspected and what remains for you to hear or review.

### Claude Code prompt: prepare narration and captions

```text
I have a local Remotion project. My approved script is in script.md,
my recorded voice is assets/narration.wav, and my draft timed transcript
is captions.json. Review the project and explain the existing timing model.

Create a caption overlay that follows the current Remotion documentation,
uses the verified transcript without changing its wording, and stays clear
of the main diagram. Validate cue order and nonnegative durations. Render a
short preview and capture representative frames at each cue boundary.
Do not use an external speech API or upload the audio. Explain how I can
listen to the result and edit the timing. Report any checks you could not run.
```

The useful constraints are concrete: an approved script establishes the content source; local-only processing avoids an unrequested external upload; cue-boundary images let you inspect placement; and asking for unperformed checks prevents the agent's written confidence from substituting for evidence.

### Codex prompt: find and repair synchronization drift

```text
In this project, captions start aligned but are visibly late by the end.
Inspect the narration asset, cue data, frame rate, sequence offsets, and any
retiming applied to the audio. First report the most likely causes and the
measurements that support them. Fix the source of the drift if it is in the
project, without changing the meaning of the captions. Render a test export
and provide timestamps or screenshots for beginning, middle, and end.
Do not assume a constant offset fixes progressive drift.
```

This asks for diagnosis before a broad adjustment. If Codex cannot listen or inspect the final media in its environment, it should say so; the user still needs to review audio and caption timing in playback.

### Refinement prompt

```text
At 00:07.2 the caption overlaps the highlighted row. Keep the words and cue
timing unchanged, move the caption to the reserved upper area for this scene,
and render stills at 00:07.2 and 00:08.0. Explain which layout rule you changed.
```

A good revision names the actual defect, a time, the desired outcome, and what must remain unchanged. It is much easier to verify than “make it more professional.”

## 15. Optional application: finish a 20-second explainer

Record or synthesize a brief, accurate explanation of a concept you know. Produce a voice track, a two- or three-cue caption file, and a minimal video with editable text. Your output should include the raw recording, the edited voice, the corrected timed transcript, and the final export. Note which assets and permissions you used.

In your first review, listen without looking at the screen: can you understand the idea and every word? In your second review, watch muted: do the captions and visuals make sense together? In your third, watch on a phone at a normal volume. Improve one specific issue at a time, then export again. This is an application of the lesson, not a requirement to memorize a fixed set of audio settings.

## Takeaways and further reading

Voice, captions, and pictures are synchronized tracks with a shared time origin. Clean recording conditions reduce later processing. Captions must be corrected against the actual final narration, timed for reading, and positioned so they do not hide the message. Music and effects should reinforce the story while leaving speech intelligible. An agent can implement and inspect the workflow, but a successful render and a syntactically valid caption file do not replace listening and human review.

For current framework details, see [Remotion's caption documentation](https://www.remotion.dev/docs/captions/displaying), [HyperFrames documentation](https://hyperframes.app/docs/), and the documentation installed with your own FFmpeg build. Check the chosen platform's current caption and delivery requirements before publishing.
