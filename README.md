<<<<<<< HEAD
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
=======
[![Flutter CI](https://github.com/gabriellagziel/app-oint/actions/workflows/flutter.yml/badge.svg)](https://github.com/gabriellagziel/app-oint/actions/workflows/flutter.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![codecov](https://codecov.io/gh/gabriellagziel/app-oint/branch/main/graph/badge.svg)](https://codecov.io/gh/gabriellagziel/app-oint)

# APP-OINT

A Flutter application for managing appointments and bookings.

## Stripe Integration Setup

### 1. Environment Variables

Add the following environment variables to your Firebase Functions config:

```bash
firebase functions:config:set stripe.secret_key="sk_test_..." stripe.webhook_secret="whsec_..." app.url="https://your-app.web.app"
```

### 2. Stripe Products & Prices

Create the following products and prices in your Stripe dashboard:

1. Basic Plan
   - Price ID: `price_basic_monthly`
   - Amount: $9.99/month
   - Features: Up to 20 meetings per day, basic booking features

2. Pro Plan
   - Price ID: `price_pro_monthly`
   - Amount: $29.99/month
   - Features: Unlimited meetings, advanced features

### 3. Webhook Setup

1. Install the Stripe CLI
2. Run `stripe listen --forward-to localhost:5001/your-project/us-central1/handleStripeWebhook`
3. Copy the webhook signing secret and set it in Firebase config

### 4. Flutter Setup

1. Add your Stripe publishable key to your Flutter app:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Stripe
  await Stripe.instance.applySettings();
  Stripe.publishableKey = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  
  runApp(const ProviderScope(child: MyApp()));
}
```

2. Build with the publishable key:

```bash
flutter build web --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

## Features

- Basic and Pro subscription plans
- Stripe Checkout integration
- Customer portal for subscription management
- Feature gating based on subscription status
- Webhook handling for subscription events

## Development

1. Install dependencies:
```bash
flutter pub get
cd functions && npm install
```

2. Run the app:
```bash
flutter run
```

3. Deploy functions:
```bash
firebase deploy --only functions
```

## Testing

1. Unit tests:
```bash
flutter test
```

2. Integration tests:
```bash
flutter test integration_test
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
<<<<<<< HEAD
=======

## Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- All contributors who have helped shape this project

## Quickstart
1. Clone the repo: `git clone https://github.com/gabriellagziel/app-oint.git`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`
4. To contribute, see [CONTRIBUTING.md](CONTRIBUTING.md)
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53
