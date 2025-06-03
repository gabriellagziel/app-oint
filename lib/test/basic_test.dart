import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Tests', () {
    test('1 + 1 = 2', () {
      expect(1 + 1, equals(2));
    });

    test('true is true', () {
      expect(true, isTrue);
    });
  });
}
