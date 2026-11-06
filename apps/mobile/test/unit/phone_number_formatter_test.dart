// path: apps/mobile/test/unit/phone_number_formatter_test.dart
import 'package:clinic_queue/core/utils/phone_number_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneNumberFormatter', () {
    test('formats local 07XXXXXXXX to +2547XXXXXXXX', () {
      expect(PhoneNumberFormatter.toE164('0712345678'), equals('+254712345678'));
      expect(PhoneNumberFormatter.toE164('0722000000'), equals('+254722000000'));
    });

    test('formats local 01XXXXXXXX (Airtel/Safaricom new prefix) to +2541XXXXXXXX', () {
      expect(PhoneNumberFormatter.toE164('0110345678'), equals('+254110345678'));
    });

    test('retains valid E.164 Kenyan numbers', () {
      expect(PhoneNumberFormatter.toE164('+254712345678'), equals('+254712345678'));
      expect(PhoneNumberFormatter.toE164('+254112345678'), equals('+254112345678'));
    });

    test('handles spaces, brackets, and dashes gracefully', () {
      expect(PhoneNumberFormatter.toE164('0712 345 678'), equals('+254712345678'));
      expect(PhoneNumberFormatter.toE164('+254 (712) 345-678'), equals('+254712345678'));
    });

    test('returns null for invalid or foreign phone numbers', () {
      expect(PhoneNumberFormatter.toE164('12345'), isNull);
      expect(PhoneNumberFormatter.toE164('071234567'), isNull); // 8 digits
      expect(PhoneNumberFormatter.toE164('+14155552671'), isNull); // US number
      expect(PhoneNumberFormatter.toE164('invalid-text'), isNull);
    });

    test('isValidKenyanMobile returns correct boolean', () {
      expect(PhoneNumberFormatter.isValidKenyanMobile('0712345678'), isTrue);
      expect(PhoneNumberFormatter.isValidKenyanMobile('+254712345678'), isTrue);
      expect(PhoneNumberFormatter.isValidKenyanMobile('0800000000'), isFalse);
    });
  });
}

