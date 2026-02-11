# Digital Queue Management System - Flutter Mobile App

A production-ready Flutter mobile application for managing government service queues, appointments, and help desk operations.

## 🎯 Overview

This application is part of a unified web + mobile platform designed for government sub-city offices to manage:
- Citizen service queues
- Appointment booking
- Help desk guidance
- Service status tracking
- Notifications

## ✨ Features

### Implemented
- ✅ **Authentication**: JWT-based login/logout with secure token storage
- ✅ **Dashboard**: Service cards with mode indicators (Online/Queue/Appointment)
- ✅ **Multi-Language**: English and Amharic support
- ✅ **Emerald Green Theme**: Professional Material 3 design
- ✅ **Error Handling**: Comprehensive error management with user-friendly messages
- ✅ **Offline Storage**: Secure token and user data persistence

### Planned
- 🔄 Help Desk with service details and required documents
- 🔄 Queue Management with real-time position updates
- 🔄 Appointment Booking with calendar view
- 🔄 Request Tracking with status timeline
- 🔄 Notifications with badge counts

## 🏗️ Architecture

**Clean Architecture** with three layers:
- **Presentation**: BLoC pattern for state management
- **Domain**: Business entities and repository interfaces
- **Data**: API integration and data models

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.8 or higher)
- Dart SDK (3.10.8 or higher)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   cd /home/hab/Desktop/digital\ service\ app/digital_service_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure API endpoint** (Optional)
   Edit `lib/core/constants/app_constants.dart`:
   ```dart
   static const String baseUrl = 'YOUR_API_URL';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Build Commands

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

### Run Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

## 🎨 Design System

### Colors
- **Primary**: Emerald Green (#10B981)
- **Background**: Light Gray (#F9FAFB)
- **Error**: Red (#EF4444)
- **Success**: Emerald (#10B981)
- **Warning**: Amber (#F59E0B)

### Typography
- **Font**: Inter (Google Fonts)
- **Styles**: Display, Headline, Title, Body, Label

### Icons
- 🌐 Online Service
- ⏳ Queue Service
- 📅 Appointment Service
- ✔️ Completed
- 🔄 In Progress
- ❌ Rejected

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants
│   ├── theme/          # Theme configuration
│   ├── utils/          # Utilities and helpers
│   ├── error/          # Error handling
│   ├── network/        # HTTP client
│   ├── di/             # Dependency injection
│   └── router/         # Navigation
├── features/
│   ├── auth/           # Authentication module
│   └── dashboard/      # Dashboard module
└── main.dart           # App entry point
```

## 🔧 Configuration

### API Endpoints
Update in `lib/core/constants/app_constants.dart`:
- Base URL
- Timeout values
- Polling intervals

### Localization
Add/edit translations:
- `assets/l10n/en.json` (English)
- `assets/l10n/am.json` (Amharic)

### Theme
Customize in `lib/core/theme/app_theme.dart`:
- Colors
- Typography
- Component styles

## 📚 Dependencies

### Core
- `flutter_bloc` - State management
- `dio` - HTTP client
- `go_router` - Routing
- `get_it` - Dependency injection

### Storage
- `flutter_secure_storage` - Secure token storage
- `shared_preferences` - User preferences

### UI
- `google_fonts` - Typography
- `table_calendar` - Calendar view (for appointments)
- `shimmer` - Loading animations

### Utilities
- `equatable` - Value comparison
- `dartz` - Functional programming
- `logger` - Logging

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test/
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📖 Documentation

- **Implementation Plan**: See `brain/implementation_plan.md`
- **API Contracts**: See `brain/api_contracts.md`
- **Walkthrough**: See `brain/walkthrough.md`
- **Task Tracking**: See `brain/task.md`

## 🔐 Security

- JWT token stored in FlutterSecureStorage
- Automatic token refresh on expiration
- HTTPS enforcement
- Input validation
- Secure error messages (no sensitive data exposure)

## 🌍 Localization

Supported languages:
- English (en)
- Amharic (am)

To switch language, use the language switcher in the app settings.

## 📝 License

This project is proprietary software for government use.

## 👥 Contributors

Developed by Google Deepmind Advanced Agentic Coding Team

## 📞 Support

For issues or questions, please contact the development team.

---

**Version**: 1.0.0+1  
**Last Updated**: February 9, 2026
# digital_service_mobile_app
