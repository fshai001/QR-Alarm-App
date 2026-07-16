# Building the QR Alarm Clock APK

This project builds a real Android APK entirely in the cloud via **GitHub Actions** —
you don't need to install Flutter or Android Studio on your own computer.

## What's in this project
- `lib/` — the real Dart source code (alarm scheduling, QR scanner, ring screen)
- `pubspec.yaml` — dependencies (kept intentionally minimal and well-maintained:
  `mobile_scanner` for QR scanning, `flutter_local_notifications` for exact,
  full-screen alarm triggering, `audioplayers` for the ringtone)
- `assets/alarm_sound.mp3` — a generated placeholder alarm tone (swap this file for
  your own sound later if you want, keeping the same filename)
- `android/app/src/main/AndroidManifest.xml` — the permissions needed (camera, exact
  alarms, notifications) and lock-screen wake flags
- `.github/workflows/build-apk.yml` — the recipe GitHub Actions follows to turn all
  of the above into a signed-for-testing `.apk` file automatically

## How the alarm works
1. When you save an alarm, the app schedules an exact, repeating, full-screen-intent
   notification with Android's OS directly (via `flutter_local_notifications`) —
   no fragile background-service plugin involved.
2. At the scheduled time, Android wakes the device, unlocks the screen if needed, and
   launches the app straight into the alarm-ringing screen.
3. The alarm sound loops continuously until the correct QR code is scanned.

## One-time setup
1. Create a new **public** GitHub repository (public repos get free Actions minutes).
2. Push the contents of this folder to it (see the batch script provided separately,
   or `git init && git add . && git commit -m "init" && git push`).

## Getting your APK
1. Go to your repo's **Actions** tab.
2. The workflow runs automatically on every push to `main` — or click **Run workflow**
   to trigger it manually.
3. Wait for the green checkmark (a few minutes).
4. Open the completed run, scroll to **Artifacts**, and download
   `qr-alarm-clock-release-apk` — unzip it to get `app-release.apk`.

## Installing on your phone for UAT
- Transfer `app-release.apk` to your phone (email, cloud drive, USB) and tap it to
  install.
- You'll need to allow **"Install unknown apps"** for whichever app you use to open it
  (Android will prompt you the first time — just follow the on-screen steps).

## Notes for UAT
- **Exact alarms on Android 12+**: the app requests the "Alarms & reminders"
  permission automatically on first launch. If it doesn't trigger, check that
  permission is granted in system Settings for this app.
- **Notification permission (Android 13+)**: the app also requests notification
  permission on first launch — required for the full-screen alarm to display.
- **Battery optimization**: some phones (Samsung, Xiaomi, OnePlus especially) kill
  background alarms aggressively. For real-world testing, disable battery
  optimization for this app in Settings.
- **Placeholder alarm sound**: `assets/alarm_sound.mp3` is a generated placeholder
  tone so the app runs end-to-end out of the box.
