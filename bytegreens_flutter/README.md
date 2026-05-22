# ByteGreens Flutter App

This Flutter frontend connects to the ByteGreens backend services in `pesmandya.io`.

## What it connects to
- `http://10.0.2.2:8000/weather`
- `http://10.0.2.2:8000/market`
- `http://10.0.2.2:8000/stats`
- `http://10.0.2.2:8001/cv/analyze`

## Setup

1. Install the Flutter SDK.
2. Open a terminal in `pesmandya.io/bytegreens_flutter`.
3. Run:

```bash
flutter pub get
```

4. If you do not have generated platform files yet, run:

```bash
flutter create .
```

5. Start both backend services:

```powershell
cd "c:\Users\Chiranthan M J\Desktop\pes hack\pesmandya.io\backend ai\cv"
& "C:/Users/Chiranthan M J/AppData/Local/Python/pythoncore-3.14-64/python.exe" -m uvicorn main:app --reload --port 8000
```

```powershell
& "C:/Users/Chiranthan M J/AppData/Local/Python/pythoncore-3.14-64/python.exe" -m uvicorn computer_vision:app --reload --port 8001
```

6. Run the app on an Android emulator:

```bash
flutter run
```

## Notes

- The app uses `10.0.2.2` for the Android emulator to reach the local machine.
- For a physical device, update `lib/api_service.dart` to use your computer's local network IP.
- Use a real camera or pick an image to send to the `/cv/analyze` endpoint.
