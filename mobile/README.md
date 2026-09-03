# StockWise Mobile

StockWise Mobile is a Flutter client for inventory management, product tracking,
market trends, barcode scanning, and AI-assisted inventory workflows.

The application uses Clean Architecture with Provider and BLoC for state
management. It communicates with the StockWise Django REST API using JWT
authentication.

## Features

- Email registration and JWT login
- Password reset and password change
- Profile editing with profile-picture upload
- Home dashboard with stock overview and recent history
- Product browsing and inventory status tracking
- Stock quantity updates
- Inventory history with product images
- Barcode and QR scanning for product lookup
- Market trends, predictions, and scraper actions
- AI assistant for inventory questions
- Secure access-token and refresh-token storage
- Android, iOS, web, Windows, macOS, and Linux project targets

## Technology

- Flutter 3.47.0
- Dart 3.13.0
- Provider and flutter_bloc
- GetIt dependency injection
- HTTP REST client
- dartz Either results
- flutter_secure_storage for JWT storage
- mobile_scanner for barcode and QR scanning
- image_picker for profile pictures
- fl_chart for trend visualizations

## Requirements

- Flutter SDK 3.47.0 or compatible stable release
- Dart SDK compatible with `pubspec.yaml`
- Android Studio and Android SDK for Android development
- Xcode for iOS development on macOS
- Visual Studio with Desktop development with C++ for Windows desktop builds
- A running StockWise backend for authenticated and data-driven features

Check the local setup with:

```bash
flutter doctor -v
flutter devices
```

## Project Setup

Run all Flutter commands from the `mobile` directory, where `pubspec.yaml` is
located.

```powershell
cd C:\Users\Administrator\Desktop\StockWise\mobile
flutter pub get
```

## Backend Configuration

The API and media URLs are configured in `lib/service_locator.dart`:

```dart
const baseUrl = "https://your-backend-host/api/";
const String mediaBaseUrl = "https://your-backend-host/media/";
```

For local development, start the backend from a separate terminal:

```powershell
cd C:\Users\Administrator\Desktop\StockWise\backend
python manage.py runserver 0.0.0.0:8000
```

To make a laptop-hosted backend available to a physical Android device, use a
reachable LAN address or an authenticated ngrok tunnel. Do not use
`localhost` or `127.0.0.1` in the mobile app when the backend runs on the
laptop.

Example ngrok setup:

```powershell
& "$env:LOCALAPPDATA\ngrok\ngrok.exe" config add-authtoken YOUR_TOKEN
& "$env:LOCALAPPDATA\ngrok\ngrok.exe" http 8000
```

Copy the HTTPS forwarding URL into `service_locator.dart`, including the
trailing `/api/` and `/media/` paths. Keep Django and ngrok running while the
app is in use. Never commit authentication tokens or private backend URLs.

## Run the Application

List available devices:

```bash
flutter devices
```

Run on a connected Android device:

```bash
flutter run -d 164632563D000174
```

Run on a named target:

```bash
flutter run -d android
flutter run -d chrome
flutter run -d windows
```

## Android Build

Create a debug APK:

```bash
flutter build apk --debug
```

The APK is generated at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Create a release APK or app bundle after configuring release signing:

```bash
flutter build apk --release
flutter build appbundle --release
```

## Branding

Branding assets are stored in `assets/vectors/`. The square cube logo is also
available as `assets/icon.png` for native tooling.

Launcher icons and native splash resources can be regenerated with:

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

The in-app splash screen is implemented in
`lib/presentation/splash/pages/splash.dart`.

## Architecture

```text
lib/
|-- common/                       Shared widgets and helpers
|-- core/                         Theme, assets, errors, and base use cases
|-- data/                         API services, models, and repositories
|   |-- auth/
|   |-- inventory/
|   |-- product/
|   |-- trends/
|   `-- ai_assistant/
|-- domain/                       Entities, contracts, and use cases
|-- presentation/                 Pages, widgets, and state management
|   |-- auth/
|   |-- home/
|   |-- inventory/
|   |-- product/
|   |-- trends/
|   |-- Profile/
|   |-- qr_scanner/
|   `-- splash/
|-- main.dart                     Application entry point
`-- service_locator.dart          GetIt dependency registration
```

The dependency direction is:

```text
Presentation -> Domain <- Data
```

The domain layer defines repository contracts. The data layer implements those
contracts and transforms API responses into domain entities. The presentation
layer consumes use cases and updates the UI through Provider or BLoC.

## Authentication and Profile Flow

1. Login or registration returns access and refresh JWT tokens.
2. Tokens are stored using `flutter_secure_storage`.
3. Authenticated requests send the access token as a Bearer token.
4. Profile edits use `PATCH /api/user/`.
5. Profile-picture edits use multipart `PATCH /api/user/`.
6. Password changes use `POST /api/users/change-password/`.
7. Profile and Home reload user data after an update and display saved media.

## API Endpoints Used

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | `/api/register/` | Create an account |
| POST | `/api/token/` | Obtain JWT tokens |
| POST | `/api/token/refresh/` | Refresh an access token |
| GET | `/api/user/` | Load the current user |
| PATCH | `/api/user/` | Update profile data and picture |
| POST | `/api/users/change-password/` | Change password |
| GET | `/api/products/` | Load products |
| GET | `/api/inventory/` | Load inventory |
| GET | `/api/trends/` | Load market trends |
| POST | `/api/ai/...` | Use AI assistant features |

## Quality Checks

Run static analysis and tests:

```bash
flutter analyze
flutter test
```

Format Dart files before review:

```bash
dart format lib test
```

## Troubleshooting

### No `pubspec.yaml` found

The command was run outside the Flutter project root. Change to:

```text
C:\Users\Administrator\Desktop\StockWise\mobile
```

### Windows Visual Studio toolchain error

Install the Visual Studio **Desktop development with C++** workload, including
MSVC build tools, CMake tools, and a Windows SDK. Alternatively, run on an
Android device or Chrome.

### Mobile cannot connect to the backend

Confirm Django is running, verify the configured URL, and make sure the phone
can reach the host. A physical Android phone cannot reach the laptop through
`localhost`; use the laptop LAN IP or ngrok.

### Images do not appear

Confirm the backend serves `/media/`, the configured `mediaBaseUrl` is current,
and the API returns the expected image path. Temporary ngrok URLs change when a
tunnel restarts.

### Android build asset or Gradle lock errors

Stop duplicate Flutter or Gradle runs, then clean generated output:

```powershell
cd C:\Users\Administrator\Desktop\StockWise\mobile
.\android\gradlew.bat --stop
flutter clean
flutter pub get
flutter build apk --debug
```

## Repository Layout

This repository also contains:

- `backend/`: Django REST API and database-backed services
- `mobile/`: this Flutter application
- `web/`: web frontend

See the backend README for server setup, database configuration, migrations,
email settings, and API administration.

## Security Notes

- Do not commit ngrok tokens, JWTs, passwords, or `.env` files.
- Use HTTPS for non-local environments.
- Configure restricted `ALLOWED_HOSTS` and production CORS settings before
  deployment.
- Configure Android and iOS release signing before publishing.
- Replace development tunnel URLs with a stable production API URL for release
  builds.

## License

This project is private software. Add the project license here before public
distribution.