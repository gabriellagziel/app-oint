import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'test-api-key',
      appId: 'test-app-id',
      messagingSenderId: 'test-sender-id',
      projectId: 'test-project-id',
    ),
  );
}
