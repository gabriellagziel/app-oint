import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get stripePk => dotenv.env['STRIPE_PK']!;
  static String get functionsBaseUrl => dotenv.env['FUNCTIONS_BASE_URL']!;

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }
}
