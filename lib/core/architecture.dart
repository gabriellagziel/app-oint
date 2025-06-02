/// APP-OINT Core Architecture
///
/// This file documents the core architecture of the APP-OINT application,
/// following AGENTI V2 standards and DIR1 rules.
///
/// The application follows a modular architecture with clear separation of concerns:
///
/// 1. Feature Modules:
///    - Personal Dashboard (lib/screens/personal_dashboard_screen.dart)
///    - Appointment Management (lib/screens/appointment_edit_screen.dart)
///    - Calendar Integration (lib/services/calendar_service.dart)
///    - Notifications (lib/services/notification_service.dart)
///
/// 2. Core Services:
///    - Authentication (lib/services/auth_service.dart)
///    - Data Management (lib/services/appointments_service.dart)
///    - Localization (lib/l10n/)
///    - State Management (lib/providers/)
///
/// 3. Data Flow:
///    UI -> Feature Module -> Core Service -> Firebase Service
///
/// 4. State Management:
///    - Riverpod for reactive state management
///    - Providers for dependency injection
///    - StateNotifier for complex state
///
/// 5. Firebase Integration:
///    - Authentication for user management
///    - Firestore for data persistence
///    - Cloud Functions for serverless operations
///
/// 6. Localization:
///    - l10n for internationalization
///    - LocalizationsHelper for string management
///
/// 7. Testing Strategy:
///    - Unit tests for business logic
///    - Widget tests for UI components
///    - Integration tests for features
///
/// 8. Future Development:
///    - Calendar API integration
///    - Social authentication
///    - Offline support
///    - Batch operations
///
/// For detailed architecture documentation, see docs/ARCHITECTURE.md
///
/// @see docs/ARCHITECTURE.md
/// @see lib/services/auth_service.dart
/// @see lib/services/appointments_service.dart
/// @see lib/l10n/
/// @see lib/providers/
