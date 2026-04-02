# Sherpa-ONNX desktop assets

Place offline TTS runtime and model files here for Linux/Windows.

## Expected layout

- `assets/tts/bin/linux-x64/sherpa-onnx-offline-tts-play`
- `assets/tts/bin/windows-x64/sherpa-onnx-offline-tts-play.exe`
- `assets/tts/models/en/primary/model.onnx`
- `assets/tts/models/en/primary/tokens.txt`
- `assets/tts/models/en/backup/model.onnx`
- `assets/tts/models/en/backup/tokens.txt`
- `assets/tts/models/ml/primary/model.onnx`
- `assets/tts/models/ml/primary/tokens.txt`
- `assets/tts/models/ml/backup/model.onnx`
- `assets/tts/models/ml/backup/tokens.txt`

If runtime binaries are not bundled, install a Sherpa executable in PATH.
The app will try manifest command candidates first and then PATH.
