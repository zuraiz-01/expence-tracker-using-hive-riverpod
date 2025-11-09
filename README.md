# expence_track_hive

Your Own Expence Tracker — Flutter app using Hive (local DB) and Riverpod (state management), with PDF export and Firebase notifications.

## Overview

This repository contains a Flutter expense-tracker sample app that stores expenses locally with Hive, uses Riverpod for state management, can export expense reports to PDF, and integrates Firebase for push notifications (FCM) and cloud storage use-cases. It also demonstrates a simple client-side flow for sending FCM messages (for development only).

Key features
- Local storage with `Hive` and `hive_flutter`
- State management with `flutter_riverpod`
- Export expense report as PDF (`pdf` package)
- In-app and local notifications via `firebase_messaging` + `flutter_local_notifications`
- Example helper to send FCM messages using an access token (development only — see Security)

## Requirements

- Flutter SDK (tested with Flutter stable matching Dart SDK >= 3.9)
- Android Studio / Xcode (for mobile builds)
- A connected Android/iOS device or emulator
- Firebase project (for push notifications)

## Quick start

1. Clone the repo:

```powershell
git clone <repo-url>
cd expence-tracker-using-hive-riverpod
```

2. Install dependencies:

```powershell
flutter pub get
```

3. Platform-specific Firebase setup

- Android: place your `google-services.json` in `android/app/` (already present in this repo if configured).
- iOS: place `GoogleService-Info.plist` in `ios/Runner/` and add it to the Xcode project.
- Web: run the FlutterFire CLI to generate `lib/firebase_options.dart` and initialize with `DefaultFirebaseOptions.currentPlatform`.

Recommended: use the FlutterFire CLI to wire Firebase for all platforms (installs `firebase_options.dart`):

```powershell
# install CLI
dart pub global activate flutterfire_cli
# run configuration (interactive)
flutterfire configure
```

4. Enable Developer Mode on Windows (if building to Windows) — this allows symlinks for plugin builds:

```powershell
# Open settings UI
start ms-settings:developers
# OR, enable via registry (Admin required)
# reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 1 /f
```

5. Run the app (example for Android):

```powershell
flutter clean
flutter run -d <your-device-id>
```

## How notifications work in this project

- The app registers for FCM and saves the device token in a Hive box named `token` under the key `fcmToken`.
- When a PDF is exported (or certain user actions occur like balance update or expense add/update), the app calls a helper that sends a POST to the FCM HTTP v1 API using an access token. The message includes a `data` key such as `{ "pdf_path": "<local-path>" }`.
- When the app receives the FCM message it converts it to a local notification (via `flutter_local_notifications`). The local notification payload contains the PDF path so tapping the notification opens the PDF using `open_filex`.

Important: the current repository contains a development helper that can fetch an access token using service account information (see `lib/services/get_server_key.dart`) and then sends messages directly from the device. This is insecure for production. See Security below for recommendations.

## Files of interest

- `lib/main.dart` — app entry point and initialization (Hive, Firebase, splash screen)
- `lib/pages/splash_screen.dart` — animated splash screen shown on app start
- `lib/pages/home_page.dart` — main UI for expenses, PDF export button
- `lib/services/notificaton_service.dart` — handles FCM registration and local notifications
- `lib/services/send_notification_service.dart` — helper to call FCM v1 endpoint from the app (development-only)
- `lib/services/get_server_key.dart` — generates/returns an access token using a service account JSON (sensitive)
- `lib/services/pdf_service.dart` — PDF generation logic
- `lib/services/fcm_service.dart` — lightweight FCM listeners

## Security notes (read carefully)

- Do NOT store service account private keys or long-lived server credentials in a client app in production. The repo currently includes a convenience flow that generates access tokens on-device for development only — this is insecure and should be replaced by a server.
- Recommended production flow:
	1. Upload generated PDFs to a secure backend or Cloud Storage (Firebase Storage).
	2. Trigger a server-side process (Cloud Function/your backend) that sends FCM notifications to target devices using the server's credentials.

If you want, I can scaffold a Firebase Cloud Function to accept a POST and send the notification securely.

## Troubleshooting (common issues seen while developing)

- AAR metadata / desugaring error (example: flutter_local_notifications requires desugar_jdk_libs >= 2.1.4):
	- Fix: edit `android/app/build.gradle.kts` and bump `coreLibraryDesugaring('com.android.tools:desugar_jdk_libs:2.1.4')`, then run `flutter clean` and rebuild.
- Invalid `android:name` in `<receiver>` manifest entry (example caused by typos):
	- Fix: ensure `android/app/src/main/AndroidManifest.xml` has the correct receiver class name for `flutter_local_notifications`:

```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver" ... />
```

- Windows symlink / plugin build error:
	- Enable Developer Mode (Settings -> For developers) or run the registry command as admin shown above.

## Testing notifications

- To test FCM delivery with the device token you can use the Firebase Console (Cloud Messaging -> Send your first message) or Postman with the v1 endpoint. The repo includes `send_notification_service.dart` as a helper to send messages using a resolved access token (development).

Example manual request body (v1 API):

```json
{
	"message": {
		"token": "<device-token>",
		"notification": { "title": "Test", "body": "Hello" },
		"data": { "pdf_path": "C:/path/to/expense_report.pdf" }
	}
}
```

## Development notes

- State management: the app uses `flutter_riverpod` (providers in `lib/providers/*`). If you add new UI state, prefer Riverpod providers over `setState` for consistency.
- Hive boxes used:
	- `expensesBox` — stores expense objects
	- `token` — stores `fcmToken`
	- `serverKeyBox` — stores a short-lived `server_access_token` (development only)
	- `notifications` — cached notifications (optional)

## Commands (handy)

```powershell
# fetch deps
flutter pub get

# clean build
flutter clean

# run on connected device
flutter run -d <device-id>

# analyze project
flutter analyze
```

## Want secure notifications instead?

I can add a sample Firebase Cloud Function (Node.js) that accepts a POST with `deviceToken`, `title`, `body`, `pdfPath` and sends an FCM message securely using the service account — let me know and I'll scaffold it for you.

## License

This project is provided as-is for learning and demonstration. Review any included keys or service-account files and remove them before publishing the app or sharing the repository publicly.

