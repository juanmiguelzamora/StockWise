# StockWise

StockWise is a smart and scalable inventory management system designed to help businesses effectively monitor, control, and optimize their stock levels. The system addresses common inventory issues such as overstocking, stockouts, and inefficient manual tracking by providing a centralized, automated, and real-time platform for stock management.

## Repository Overview

```text
StockWise/
|-- backend/       Django REST API, authentication, database, and services
|-- mobile/        Flutter application for Android, iOS, and desktop targets
|-- web/frontend/  React web application
`-- README.md      Project overview and shared setup
```

## Main Features

- JWT authentication with email-based accounts
- Registration, login, password reset, and password change
- Profile editing and profile-picture upload
- Product catalog and inventory management
- Stock quantity updates and inventory history
- Product images across web and mobile views
- QR and barcode scanning in the mobile client
- Market trends and demand predictions
- Automated trend and product scraping
- AI assistant for inventory questions
- Responsive web interface and cross-platform mobile client

## Technology Stack

### Backend

- Python
- Django 5
- Django REST Framework
- Simple JWT
- MySQL-compatible database configuration
- scikit-learn, NumPy, pandas, and SciPy
- Selenium, BeautifulSoup, lxml, and pytrends

### Web

- React 19
- TypeScript
- Vite
- React Router
- Axios
- Tailwind CSS
- Recharts
- Framer Motion

### Mobile

- Flutter 3.47.0
- Dart 3.13.0
- Provider and flutter_bloc
- GetIt dependency injection
- HTTP REST client
- flutter_secure_storage
- mobile_scanner
- image_picker
- fl_chart

## Requirements

Install the following tools before starting development:

- Python 3.10 or newer
- Flutter SDK 3.47.0 or compatible stable release
- Dart SDK compatible with `mobile/pubspec.yaml`
- Node.js and npm
- MySQL or another configured database
- Android Studio and Android SDK for Android development
- Visual Studio with Desktop development with C++ for Windows Flutter builds
- ngrok for exposing a local backend to a physical mobile device, when needed

## Configuration

### Backend Environment

Create `backend/.env` and configure values appropriate for your environment:

```env
SECRET_KEY=replace-with-a-secure-secret
DEBUG=True
DB_NAME=stockwise
DB_USER=your-database-user
DB_PASSWORD=your-database-password
DB_HOST=127.0.0.1
DB_PORT=3306
```

Configure email settings as required for password reset. Never commit `.env`, passwords, tokens, or private keys.

### Mobile API URL

Set the API and media URLs in `mobile/lib/service_locator.dart`:

```dart
const baseUrl = "https://your-api-host/api/";
const String mediaBaseUrl = "https://your-api-host/media/";
```

A physical Android device cannot use `localhost` or `127.0.0.1` to reach a backend running on the development computer. Use the computer's LAN IP or an authenticated ngrok tunnel.

## Run the Full Stack

Use separate terminals for each service.

### 1. Backend

```powershell
cd C:\path\to\StockWise\backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

### 2. Optional ngrok Tunnel

Use this when testing from a physical phone outside the local network:

```powershell
ngrok config add-authtoken YOUR_TOKEN
ngrok http 8000
```

Copy the HTTPS forwarding URL into the mobile `baseUrl` and `mediaBaseUrl` values. Keep the backend and tunnel running.

### 3. Web Client

```powershell
cd C:\path\to\StockWise\web\frontend
npm install
npm run dev
```

Vite prints the local web URL in the terminal, normally `http://localhost:5173`.

### 4. Mobile Client

```powershell
cd C:\path\to\StockWise\mobile
flutter pub get
flutter devices
flutter run -d YOUR_DEVICE_ID
```

For a connected Android device:

```powershell
flutter run -d 164632563D000174
```

## Backend API

The main API routes are:

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | `/api/register/` | Register an account |
| POST | `/api/token/` | Log in and obtain JWT tokens |
| POST | `/api/token/refresh/` | Refresh an access token |
| GET | `/api/user/` | Get the current user |
| PATCH | `/api/user/` | Update profile data or picture |
| POST | `/api/users/change-password/` | Change the current password |
| GET | `/api/products/` | List products |
| GET | `/api/inventory/` | List inventory |
| GET | `/api/trends/` | List market trends |
| POST | `/api/ai/...` | Use AI assistant features |

Authenticated requests use:

```text
Authorization: Bearer <access-token>
```

Uploaded media is served from `/media/` during development. Configure a production media service before deployment.

## Architecture

```text
                         +------------------+
                         |   React Web App  |
                         +--------+---------+
                                  |
                         +--------v---------+
                         |   Django REST API |
                         +--------+---------+
                                  |
             +--------------------+--------------------+
             |                    |                    |
       Database             Media Storage       ML and AI Services
             |
                         +--------^---------+
                         |   Flutter Client  |
                         +------------------+
```

The mobile client follows Clean Architecture:

```text
Presentation -> Domain <- Data
```

The domain layer defines entities and repository contracts. The data layer implements API access and model conversion. The presentation layer contains screens, widgets, and Provider/BLoC state management.

## Quality Checks

### Backend

```powershell
cd backend
python manage.py test
```

### Web

```powershell
cd web/frontend
npm run lint
npm run build
```

### Mobile

```powershell
cd mobile
flutter analyze
flutter test
flutter build apk --debug
```

## Troubleshooting

### `No pubspec.yaml found`

Run Flutter commands from `mobile`, not the repository root.

### Windows Flutter toolchain error

Install Visual Studio's **Desktop development with C++** workload, including MSVC build tools, CMake tools, and a Windows SDK. Android and Chrome targets do not require the Windows toolchain.

### Mobile cannot connect to the API

Confirm Django is listening on `0.0.0.0:8000`, verify the mobile API URL, and ensure the phone can reach the computer. Replace expired ngrok URLs after restarting a tunnel.

### Images do not appear

Check that the API returns an image path, that Django serves `/media/`, and that the mobile `mediaBaseUrl` points to the current backend host.

### Gradle asset or directory lock

Stop duplicate Flutter/Gradle processes and run:

```powershell
cd mobile
.\android\gradlew.bat --stop
flutter clean
flutter pub get
flutter build apk --debug
```

## Security and Deployment

Before production deployment:

- Set `DEBUG=False`.
- Use a strong secret key and secure database credentials.
- Restrict Django `ALLOWED_HOSTS` and CORS origins.
- Serve all API and media traffic over HTTPS.
- Replace ngrok with a stable production API domain.
- Configure production media storage and backups.
- Configure Android and iOS release signing.
- Store secrets in environment variables or a secrets manager.
- Add monitoring, logging, and crash reporting.
- Do not publish development credentials, JWTs, or ngrok tokens.

## Application Documentation

- [Backend documentation](backend/README.md)
- [Mobile documentation](mobile/README.md)
- [Web documentation](web/frontend/README.md)

## License

This project is private software. Add the appropriate license before public distribution.
