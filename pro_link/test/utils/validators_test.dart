import 'package:flutter_test/flutter_test.dart';
import 'package:pro_link/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns null for valid email', () {
      expect(Validators.email('hello@example.com'), isNull);
    });

    test('returns error for invalid email', () {
      expect(Validators.email('bad-email'), isNotNull);
    });
  });

  group('Validators.mark', () {
    test('returns null for valid range values', () {
      expect(Validators.mark('0'), isNull);
      expect(Validators.mark('20'), isNull);
      expect(Validators.mark('12.5'), isNull);
    });

    test('returns error for out of range values', () {
      expect(Validators.mark('-1'), isNotNull);
      expect(Validators.mark('21'), isNotNull);
    });
  });
}
