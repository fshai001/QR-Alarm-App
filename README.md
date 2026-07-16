# Flutter QR Code Alarm Clock

A production-grade Flutter application where alarms cannot be simple button-clicked or swiped away. The only way to dismiss an active alarm is by physically getting out of bed and using your device camera to scan a registered QR code (e.g., printed and stuck on your coffee mug, bathroom mirror, or kitchen fridge).

## How it Works
1. **Background Service**: Uses `android_alarm_manager_plus` to schedule exact alarms at OS level (via `AlarmClock` alerts, waking CPU).
2. **Locked Screen Wakeup**: Fullscreen intents via `flutter_local_notifications` turn on the screen and present the alarm dismissal interface even when locked.
3. **QR Verification**: Fires the camera using `mobile_scanner` to scan a target code and matches decoded strings in real-time.
4. **Persistent Local Alarms**: Stores alarm settings, custom QR keys, and schedule recurrence via `shared_preferences`.

## Getting Started

### 1. Installation
Install the necessary package dependencies in `pubspec.yaml`:
```bash
flutter pub get
```

### 2. Android Configuration
Ensure permissions in `android/app/src/main/AndroidManifest.xml` are set. Note: Android 13+ requires requesting runtime POST_NOTIFICATIONS permission at startup.

To enable exact alarms in Android 13/14, add:
- `SCHEDULE_EXACT_ALARM` or `USE_EXACT_ALARM`

### 3. iOS Configuration
Ensure your `ios/Runner/Info.plist` contains `NSCameraUsageDescription` for camera access, and that background modes are enabled under Capabilities in Xcode.

### 4. Build & Run
```bash
flutter run --release
```
