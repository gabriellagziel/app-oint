import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  FakeFirebaseAppPlatform({
    required String appName,
    required FirebaseOptions firebaseOptions,
  }) : super(appName, firebaseOptions);

  @override
  Future<void> delete() async {}
}

class MockFirebasePlatform extends FirebasePlatform {
  final List<FirebaseAppPlatform> _apps = [];

  @override
  List<FirebaseAppPlatform> get apps => _apps;

  @override
  FirebaseAppPlatform app([String? name]) {
    return _apps.firstWhere((a) => a.name == (name ?? defaultFirebaseAppName));
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final app = FakeFirebaseAppPlatform(
      appName: name ?? defaultFirebaseAppName,
      firebaseOptions: options ??
          const FirebaseOptions(
            apiKey: 'test-api-key',
            appId: 'test-app-id',
            messagingSenderId: 'test-sender-id',
            projectId: 'test-project-id',
            storageBucket: 'test-bucket',
          ),
    );
    _apps.add(app);
    return app;
  }
}

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = MockFirebasePlatform();
}

class TestHelper {
  static Future<void> setupFirebaseForTesting() async {
    setupFirebaseMocks();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
        storageBucket: 'test-bucket',
      ),
    );
  }
}
