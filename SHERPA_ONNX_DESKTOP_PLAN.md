# Sherpa-ONNX Desktop Plan (Linux + Windows)

## Goal
Ship smooth offline TTS for Malayalam and English on Linux and Windows using Sherpa-ONNX, with robust fallback behavior and measurable quality.

## Scope
- Platforms: Linux, Windows only
- Languages: Malayalam (`ml`), English (`en`)
- Mode: Offline TTS
- Existing mobile `flutter_tts` flow is unchanged for Android/iOS

## Definition of Done
- Malayalam and English each have:
  - 1 primary model
  - 1 backup model
- Language-first routing works:
  - Malayalam text -> Malayalam model chain
  - English text -> English model chain
- Fallback chain works reliably on desktop:
  - Sherpa primary -> Sherpa backup -> existing local fallback (`espeak-ng`/`spd-say` on Linux)
- No queue deadlocks on synthesis failure
- Meets performance/quality gates below

## Performance and Quality Gates
- Cold init (model load): <= 2.5s on low-end desktop test machine
- Warm init (already loaded): <= 500ms
- Time to first audio chunk: <= 400ms average
- Real-time factor (RTF): <= 0.8 on target machines
- Peak memory increase per active model: <= 700MB
- Subjective quality score (1-5):
  - English >= 4.0
  - Malayalam >= 3.8
- Pronunciation correctness list pass rate:
  - English >= 95%
  - Malayalam >= 90%

## Work Breakdown (14-Day Execution Plan)

### Day 1-2: Architecture and Interface
1. Add engine abstraction in app layer:
   - `SpeechEngine` interface
   - `SystemSpeechEngine` (current behavior)
   - `SherpaOnnxSpeechEngine` (new desktop engine)
2. Add engine selection mode in settings model:
   - `auto`, `system_only`, `sherpa_only`
3. Add desktop-only runtime guard:
   - Sherpa path enabled only on Linux/Windows

Acceptance:
- App builds on Linux and Windows with no behavior change yet
- Engine mode can be selected in code/config

### Day 3-4: Native/Desktop Integration
1. Integrate Sherpa-ONNX runtime for Linux and Windows build targets
2. Add model discovery/loader service with model manifest
3. Add synthesis method and stop/cancel support

Acceptance:
- Can synthesize one fixed English sentence and one Malayalam sentence from Sherpa on both platforms
- Stop/cancel works during playback

### Day 5-6: Language Routing and Fallback Chain
1. Add language detector (simple locale/text script-based routing)
2. Route by language:
   - Malayalam -> Malayalam model chain
   - English -> English model chain
3. Add fallback chain:
   - primary -> backup -> local fallback
4. Add cooldowned retry and failure counters per model

Acceptance:
- Forced failure of primary model switches to backup without crash
- Queue continues processing after failures

### Day 7-8: Benchmark Harness
1. Create fixed benchmark corpus:
   - 30 English lines
   - 30 Malayalam lines
2. Capture metrics:
   - init time
   - first audio latency
   - RTF
   - peak memory
3. Save benchmark output as JSON for comparison

Acceptance:
- Benchmark runs from one command
- Results reproducible across reruns

### Day 9-10: Model Selection
1. Benchmark candidate models per language
2. Score candidates with weighted rubric:
   - Naturalness 45%
   - Pronunciation 25%
   - Latency 20%
   - Memory 10%
3. Select 2 models per language:
   - `primary`, `backup`

Acceptance:
- Final manifest contains chosen 4 models total
- Selection notes documented with measured numbers

### Day 11-12: Settings and UX
1. Add desktop-only Sherpa section in settings:
   - Engine mode
   - Current active model
   - Fallback reason/status
2. Add clear runtime status in voice section:
   - engine in use
   - last fallback cause

Acceptance:
- User can verify whether speech is from system or Sherpa
- UI state updates correctly after fallback events

### Day 13: Reliability and Regression Testing
1. Run stress test (500 queued utterances mixed languages)
2. Validate no deadlocks, no unbounded memory growth
3. Verify stop/reset behaviors during active synthesis

Acceptance:
- No crashes/deadlocks in stress test
- Queue latency remains stable over long run

### Day 14: Stabilization and Release Preparation
1. Final lint/analyze/test run
2. Update README with desktop setup instructions
3. Add troubleshooting section for missing model/runtime

Acceptance:
- Release checklist complete
- Desktop setup documented clearly

## Model Manifest Design
Create a manifest file for desktop model management.

Suggested shape:
- `id`
- `language` (`en`, `ml`)
- `tier` (`primary`, `backup`)
- `path`
- `sampleRate`
- `sizeMB`
- `checksum`
- `notes`

## Test Matrix
- Linux low-end
- Linux mid-range
- Windows low-end
- Windows mid-range

For each matrix row test:
- English primary
- English backup
- Malayalam primary
- Malayalam backup
- Forced fallback behavior

## Risks and Mitigation
1. Model size too large
- Mitigation: keep backup models small and load-on-demand

2. Malayalam model quality variance
- Mitigation: evaluate multiple candidates and keep backup chain

3. Desktop runtime differences
- Mitigation: platform-specific CI checks and dedicated smoke tests

4. Startup latency spikes
- Mitigation: lazy-load model on first use plus warm-up option

## Immediate Next 5 Tasks (Start Here)
1. Create `SpeechEngine` abstraction and wire existing system engine behind it
2. Add desktop guard and `sherpa_only/system_only/auto` engine mode
3. Add model manifest file and loader scaffold
4. Integrate Sherpa synthesis call for one test phrase per language
5. Add fallback chain logic with structured logs
