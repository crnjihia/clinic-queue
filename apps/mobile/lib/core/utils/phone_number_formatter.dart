// path: apps/mobile/lib/core/utils/phone_number_formatter.dart
class PhoneNumberFormatter {
  PhoneNumberFormatter._();

  /// Normalizes and formats any Kenyan mobile phone number to E.164 (+2547XXXXXXXX or +2541XXXXXXXX)
  /// Returns null if the number is invalid.
  static String? toE164(String input) {
    // Strip all whitespace, dashes, and parentheses
    final cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Pattern 1: Already +254 (e.g. +254712345678, +254112345678)
    if (RegExp(r'^\+254[71]\d{8}$').hasMatch(cleaned)) {
      return cleaned;
    }

    // Pattern 2: Starts with 254 (e.g. 254712345678)
    if (RegExp(r'^254[71]\d{8}$').hasMatch(cleaned)) {
      return '+$cleaned';
    }

    // Pattern 3: Standard local format starting with 07 or 01 (e.g. 0712345678, 0110345678)
    if (RegExp(r'^0[71]\d{8}$').hasMatch(cleaned)) {
      return '+254${cleaned.substring(1)}';
    }

    // Pattern 4: 9 digits without leading 0 (e.g. 712345678)
    if (RegExp(r'^[71]\d{8}$').hasMatch(cleaned)) {
      return '+254$cleaned';
    }

    return null;
  }

  /// Validates whether a given string is a valid Kenyan mobile phone number.
  static bool isValidKenyanMobile(String input) {
    return toE164(input) != null;
  }
}

