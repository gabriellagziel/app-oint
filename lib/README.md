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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- All contributors who have helped shape this project

## Quickstart
1. Clone the repo: `git clone https://github.com/gabriellagziel/app-oint.git`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`
4. To contribute, see [CONTRIBUTING.md](CONTRIBUTING.md)
