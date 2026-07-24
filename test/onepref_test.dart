import 'package:flutter_test/flutter_test.dart';
import 'package:onepref/onepref.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnePref Tests', () {
    test('InAppEngine singleton instance is available', () {
      final engine = InAppEngine.instance;
      expect(engine, isNotNull);
    });
  });
}
