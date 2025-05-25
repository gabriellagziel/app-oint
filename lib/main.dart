import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart' as fs;
import 'utils/web_utils.dart';
import 'package:logging/logging.dart';
import 'features/personal/services/notification_service.dart';
import 'l10n/app_localizations.dart';
import 'config/env.dart';
import 'app_router.dart';
import 'features/meetings/models/meeting.dart';
import 'features/reminders/models/reminder.dart';
import 'features/tasks/models/task.dart';
import 'package:app_oint/core/localization/app_localizations.dart';
import 'package:app_oint/screens/onboarding/onboarding_page.dart';

final _logger = Logger('Main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize environment variables
  await Env.init();

  // Initialize Stripe
  fs.Stripe.publishableKey = Env.stripePk;
  await fs.Stripe.instance.applySettings();

  await NotificationService().initialize();

  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    _logger.info('${record.level.name}: ${record.time}: ${record.message}');
  });

  if (kIsWeb) {
    setupGoogleSignInInterop((credential) {
      _logger.info('Received Google Sign-In credential: $credential');
      // Handle the credential
    });
  }

  runApp(const LocalizationWrapper(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      localizationsDelegates: [AppLocalizations.delegate],
      supportedLocales: const [
        Locale('en'), // English
      ],
      routes: routes,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatWhatDoYouWant)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/meeting/list'),
              child: const Text('Meetings'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/reminder/list'),
              child: const Text('Reminders'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/task/list'),
              child: const Text('Tasks'),
            ),
          ],
        ),
      ),
    );
  }
}
