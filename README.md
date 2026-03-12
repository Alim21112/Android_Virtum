# AndroidVirtum (Virtum Health) — Mobile + Mock Backend

This repository contains:

- **`mobile/`**: Flutter mobile app
- **`backend/`**: Node.js (Express) mock API used by the mobile app

## Prerequisites

- **Flutter SDK** (Dart is bundled with Flutter)
- **Android Studio** (or Android SDK + an emulator) for Android builds/runs
- **Node.js + npm** for the backend
- **Windows PowerShell** (recommended for the helper script)

## Quick start (run backend + mobile)

From the repo root:

```powershell
.\start-all.ps1
```

Optional: run on a specific device/emulator ID:

```powershell
.\start-all.ps1 -DeviceId <DEVICE_ID>
```

What it does:

- Installs backend dependencies (if needed) and runs **`npm start`** in `backend/`
- Runs **`flutter pub get`** (if needed) and then **`flutter run`** in `mobile/`

## Run manually

### 1) Start the backend

```powershell
cd .\backend
npm install
npm start
```

By default the API listens on **port 3000** and binds to **`0.0.0.0`** (accessible from your phone on the same network).

### 2) Run the Flutter app

```powershell
cd .\mobile
flutter pub get
flutter run
```

## Build an APK

Run these commands from `mobile/`:

### Debug APK

```powershell
cd .\mobile
flutter build apk --debug
```

### Release APK

```powershell
cd .\mobile
flutter build apk --release
```

APK output path (default Flutter location):

- **Release**: `mobile/build/app/outputs/flutter-apk/app-release.apk`
- **Debug**: `mobile/build/app/outputs/flutter-apk/app-debug.apk`

## Configure API base URL / IP address

The mobile app uses a hardcoded API base URL in:

- `mobile/lib/services/api_service.dart` → `ApiService.baseUrl`

Update this value to point to the machine where `backend/` is running:

- **Android Emulator (AVD)**: use `http://10.0.2.2:3000`
- **Real device**: use your PC’s local IP on the same Wi‑Fi/LAN, e.g. `http://192.168.1.50:3000`

Notes:

- Your phone and PC must be on the **same network**.
- Ensure Windows Firewall allows inbound connections to **port 3000** (or allow Node.js).

## Troubleshooting

- **Can’t connect from device**: verify `ApiService.baseUrl`, backend is running, and port 3000 is reachable from the phone.
- **Emulator networking**: `localhost` from the emulator is *the emulator itself*; use `10.0.2.2` to reach your PC.

