# APP-OINT

A modern appointment management system built with Flutter and Firebase, following AGENTI V2 architecture standards.

## Architecture Overview

APP-OINT is built with a modular architecture that separates concerns into distinct layers:

### Core Components

- **Personal**: User profile and appointment management
- **Studio**: Business profile and service management
- **Admin**: System administration and monitoring
- **Enterprise**: Multi-tenant and organization management

### Technical Stack

- **State Management**: Riverpod for reactive state management
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions)
- **Localization**: Built-in support for multiple languages
- **UI**: Material Design 3 with custom theming

### Key Features

- Real-time appointment management
- Calendar integration
- Push notifications
- Multi-language support
- Offline capabilities

## Getting Started

1. Clone the repository
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)
4. Run the app:

   ```bash
   flutter run
   ```

## Documentation

- [Architecture Documentation](docs/ARCHITECTURE.md)
- [Development Guidelines](docs/DEVELOPMENT.md)
- [API Documentation](docs/API.md)

## Contributing

Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
