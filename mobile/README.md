# StockWise Mobile - Flutter Application

A cross-platform mobile inventory management app built with Flutter following **Clean Architecture** principles.


This project implements Clean Architecture with proper separation of concerns across Domain, Data, and Presentation layers.

---

## 📁 Project Structure

```
lib/
├── core/                  # Core utilities & abstractions
├── common/                # Shared UI components & utilities
├── domain/                # Business logic layer (pure Dart)
├── data/                  # Data layer (API, models, repositories)
├── presentation/          # UI layer (pages, widgets, state)
├── main.dart              # App entry point
└── service_locator.dart   # Dependency injection setup
```

---

## 📦 Layer Breakdown

### 🎯 **`core/`** - Core Layer
**Purpose:** Fundamental building blocks used across all layers

```
core/
├── configs/              # App configurations
│   ├── theme/           # App theme & styling
│   ├── routes/          # Navigation routes
│   └── assets/          # Asset paths
├── error/               # Error handling abstractions
└── usecase/             # Base UseCase interface
    └── usecase.dart     # Abstract UseCase<T, Params>
```

**Key Concepts:**
- **UseCase Pattern:** All business operations extend `UseCase<T, Params>`
- **Configuration:** Centralized app settings
- **Error Handling:** Custom failure classes

---

### 🧠 **`domain/`** - Domain Layer (Business Logic)
**Purpose:** Pure business logic, independent of frameworks and UI

```
domain/
├── auth/
│   ├── entity/          # User entity (pure Dart)
│   ├── repository/      # Auth repository interface
│   └── usecases/        # Business operations
│       ├── signup.dart
│       ├── signin.dart
│       ├── get_user.dart
│       ├── is_logged_in.dart
│       ├── is_logged_out.dart
│       └── send_password_reset_email.dart
├── product/
│   ├── entity/          # Product entity
│   ├── repository/      # Product repository interface
│   └── usecases/
│       ├── get_product_usecase.dart
│       ├── get_product_by_sku.dart
│       └── update_product_quantity_usecase.dart
├── inventory/
│   ├── entity/          # Inventory entities
│   ├── repository/      # Inventory repository interface
│   └── usecases/
│       ├── get_inventory.dart
│       ├── get_stock_status.dart
│       └── get_inventory_summary.dart
├── trends/
│   ├── entity/          # Trend entities
│   ├── repository/      # Trends repository interface
│   └── usecases/
│       ├── get_trends.dart
│       ├── get_predictions.dart
│       └── run_scraper.dart
├── ai_assistant/
│   ├── entity/          # AI message entities
│   └── repository/      # AI repository interface
└── navigation/          # Navigation domain logic
```

**Key Principles:**
- ✅ **Framework Independent:** No Flutter dependencies
- ✅ **Single Responsibility:** Each use case does one thing
- ✅ **Dependency Inversion:** Depends on abstractions (interfaces)
- ✅ **Testable:** Pure Dart, easy to unit test

**Example Use Case:**
```dart
class SignupUseCase implements UseCase<Either, UserCreationReq> {
  @override
  Future<Either> call({UserCreationReq? params}) async {
    return await sl<AuthRepository>().signup(params!);
  }
}
```

---

### 💾 **`data/`** - Data Layer
**Purpose:** Implements domain contracts, handles API calls and data persistence

```
data/
├── auth/
│   ├── models/          # Data models (JSON serialization)
│   │   ├── user.dart
│   │   ├── user_creation_req.dart
│   │   └── user_signin_req.dart
│   ├── source/          # Data sources (API clients)
│   │   └── auth_api_service.dart
│   └── repository/      # Repository implementations
│       └── auth_repository_impl.dart
├── product/
│   ├── models/
│   ├── source/
│   │   └── product_remote_datasource.dart
│   └── repository/
│       └── product_repository_impl.dart
├── inventory/
│   ├── models/
│   ├── datasources/
│   │   └── inventory_remote_datasource.dart
│   └── repositories/
│       └── inventory_repository_impl.dart
├── trends/
│   ├── models/
│   ├── datasource/
│   │   └── trends_remote_datasource.dart
│   └── repositories/
│       └── trends_repository_impl.dart
└── ai_assistant/
    ├── models/
    ├── source/
    │   └── ai_remote_datasource.dart
    └── repository/
        └── ai_repository_impl.dart
```

**Key Responsibilities:**
- ✅ **API Communication:** HTTP requests to backend
- ✅ **Data Transformation:** JSON ↔ Models ↔ Entities
- ✅ **Repository Implementation:** Concrete implementations of domain interfaces
- ✅ **Error Handling:** Network errors, parsing errors

**Data Flow:**
```
API → DataSource → Model → Repository → Entity → UseCase
```

---

### 🎨 **`presentation/`** - Presentation Layer (UI)
**Purpose:** User interface, state management, and user interactions

```
presentation/
├── auth/
│   ├── pages/           # Login, Signup, Password Reset screens
│   ├── bloc/            # State management (if using BLoC)
│   └── widgets/         # Auth-specific widgets
├── home/
│   └── pages/           # Home dashboard
├── product/
│   ├── pages/           # Product list, details, edit
│   ├── provider/        # Product state provider
│   └── widgets/         # Product widgets
├── inventory/
│   ├── pages/           # Inventory screens
│   ├── provider/        # Inventory state provider
│   └── widgets/         # Inventory widgets
├── trends/
│   ├── pages/           # Trends & predictions
│   ├── provider/        # Trends state provider
│   └── widgets/         # Trend charts, graphs
├── ai_assistant/
│   └── pages/           # AI chat interface
├── Profile/
│   └── pages/           # User profile
├── qr_scanner/
│   └── pages/           # QR code scanner
├── splash/
│   └── pages/           # Splash screen
├── bottom_nav/
│   └── pages/           # Bottom navigation
└── mappers/
    └── user_presentation.dart  # Domain → Presentation mappers
```

**State Management:**
- **Provider Pattern:** Used for state management
- **Separation:** UI logic separated from business logic
- **Reactivity:** UI updates automatically on state changes

**Example Provider:**
```dart
class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final UpdateProductQuantityUseCase updateQuantityUseCase;
  
  // State management logic
}
```

---

### 🔧 **`common/`** - Shared Components
**Purpose:** Reusable UI components and utilities across features

```
common/
├── bloc/                # Shared BLoC/state management
├── helper/              # Helper functions
└── widgets/             # Reusable widgets
    ├── buttons/
    ├── inputs/
    └── cards/
```

**Contents:**
- Reusable buttons, inputs, cards
- Common dialogs and modals
- Shared animations
- Utility functions

---

### 🔌 **`service_locator.dart`** - Dependency Injection
**Purpose:** Centralized dependency injection using GetIt

**Structure:**
```dart
final sl = GetIt.instance;

Future<void> initializeServiceLocator() async {
  // Data Sources
  sl.registerLazySingleton<AuthApiService>(...);
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(...);
  
  // Use Cases
  sl.registerSingleton<SignupUseCase>(...);
  
  // Providers
  sl.registerFactory<ProductProvider>(...);
}
```

**Registration Types:**
- **Singleton:** Single instance throughout app lifecycle
- **LazySingleton:** Created on first use
- **Factory:** New instance each time

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure backend URL:**
   Edit `lib/service_locator.dart`:
   ```dart
   const baseUrl = "https://your-backend-url.com/api/";
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📱 Features

- ✅ **Authentication** - Login, Signup, Password Reset
- ✅ **Product Management** - View, search, update products
- ✅ **Inventory Tracking** - Real-time stock monitoring
- ✅ **Trend Analysis** - Market insights & predictions
- ✅ **AI Assistant** - Conversational inventory help
- ✅ **QR Scanner** - Quick product lookup
- ✅ **Profile Management** - User settings


---

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Test Structure
```
test/
├── domain/              # Domain layer tests
├── data/                # Data layer tests
└── presentation/        # Widget tests
```

---

## 📦 Dependencies

Key packages:
- `get_it` - Dependency injection
- `dartz` - Functional programming (Either, Option)
- `provider` - State management
- `http` / `dio` - HTTP client
- `flutter_secure_storage` - Secure token storage
- `qr_code_scanner` - QR scanning

---

## 🏛️ Clean Architecture Benefits

### ✅ **Separation of Concerns**
- Each layer has a single responsibility
- Easy to understand and maintain

### ✅ **Testability**
- Domain layer is pure Dart (no Flutter dependencies)
- Easy to write unit tests
- Mock dependencies easily

### ✅ **Flexibility**
- Swap data sources (API → Local DB)
- Change UI framework without affecting business logic
- Replace state management solution

### ✅ **Scalability**
- Add new features without breaking existing code
- Clear structure for team collaboration

### ✅ **Maintainability**
- Changes in one layer don't affect others
- Easy to locate and fix bugs

---

## 📐 Architecture Diagram

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Widgets, State Management)        │
│  - Pages, Widgets, Providers            │
└──────────────┬──────────────────────────┘
               │ Uses
               ▼
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│     (Business Logic - Pure Dart)        │
│  - Entities, Use Cases, Repositories    │
└──────────────┬──────────────────────────┘
               │ Implements
               ▼
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (API, Models, Repository Impl)         │
│  - Data Sources, Models, Repositories   │
└─────────────────────────────────────────┘
```

**Dependency Rule:** Dependencies point **INWARD**
- Presentation → Domain ← Data
- Domain has NO dependencies on outer layers

---

## 🎯 Best Practices Followed

1. ✅ **Single Responsibility Principle** - Each class has one job
2. ✅ **Dependency Inversion** - Depend on abstractions, not concretions
3. ✅ **Interface Segregation** - Small, focused interfaces
4. ✅ **Open/Closed Principle** - Open for extension, closed for modification
5. ✅ **DRY (Don't Repeat Yourself)** - Reusable components in `common/`

---

## 🔄 Data Flow Example

**User Login Flow:**
```
1. User enters credentials (Presentation)
   ↓
2. LoginPage calls SigninUseCase (Domain)
   ↓
3. SigninUseCase calls AuthRepository interface (Domain)
   ↓
4. AuthRepositoryImpl makes API call (Data)
   ↓
5. API returns JSON → Model → Entity
   ↓
6. Entity returned to Presentation
   ↓
7. UI updates with user data
```

---

## 🐛 Debugging

### Common Issues

**1. Dependency Injection Errors**
```dart
// Ensure service locator is initialized in main.dart
await initializeServiceLocator();
```

**2. API Connection Issues**
- Check `baseUrl` in `service_locator.dart`
- Verify backend is running
- Check network permissions in `AndroidManifest.xml` / `Info.plist`

**3. Token Expiration**
- Implement token refresh logic in data layer
- Handle 401 errors gracefully

---

## 📈 Future Improvements

- [ ] Add unit tests for all layers
- [ ] Implement offline-first architecture
- [ ] Add integration tests
- [ ] Improve error handling with custom Failure classes
- [ ] Add analytics and crash reporting
- [ ] Implement push notifications

---





StockWise Development Team

---

## 📚 Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture-tdd/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Provider Documentation](https://pub.dev/packages/provider)
