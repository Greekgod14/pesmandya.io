# pesmandya.io

ByteGreens is a hackathon AgriTech demo app with:
- AI crop disease scanner (`backend ai/cv/index.html`)
- Mock farmer marketplace (`backend ai/cv/market.html`)
- Impact dashboard (`backend ai/cv/dashboard.html`)

## Setup

1. Install dependencies:

```powershell
& "C:/Users/Chiranthan M J/AppData/Local/Python/pythoncore-3.14-64/python.exe" -m pip install -r "requirements.txt"
```

2. Set your Gemini API key:

```powershell
setx GEMINI_KEY "YOUR_KEY_HERE"
```

3. Start the simple backend (market + dashboard data):

```powershell
cd "c:\Users\Chiranthan M J\Desktop\pes hack\pesmandya.io\backend ai\cv"
& "C:/Users/Chiranthan M J/AppData/Local/Python/pythoncore-3.14-64/python.exe" -m uvicorn main:app --reload --port 8000
```

4. Start the full CV engine:

```powershell
& "C:/Users/Chiranthan M J/AppData/Local/Python/pythoncore-3.14-64/python.exe" -m uvicorn computer_vision:app --reload --port 8001
```

## Access

- `backend ai/cv/index.html` → scanner UI
- `backend ai/cv/market.html` → marketplace UI
- `backend ai/cv/dashboard.html` → dashboard UI

Open these files directly in your browser or serve the `backend ai/cv` folder with a static file server.

## Flutter Mobile App

A mobile frontend is available in `bytegreens_flutter`.

1. Install Flutter SDK.
2. Open `pesmandya.io/bytegreens_flutter`.
3. Run `flutter pub get`.
4. If needed, run `flutter create .` to generate platform files.
5. Start the backend servers on `8000` and `8001`.
6. Use `flutter run` to launch the app on an emulator or device.

> On Android emulators the app uses `10.0.2.2` to reach `localhost`. For a real phone, replace the backend host in `bytegreens_flutter/lib/api_service.dart` with the machine IP on your local network.

## Notes

- Gemini key is loaded from `GEMINI_KEY` environment variable.
- If Gemini is not configured, the CV engine runs in degraded mode with stubbed AI responses.
- `BYTEGREENS_README2.md` contains the original hackathon guide and page content.