class PhoneNumberFormatter {
  static String normalize({
    required String dialCode,
    required String rawNumber,
  }) {
    String number = rawNumber.trim().replaceAll(RegExp(r'\D'), '');
    String code = dialCode.trim();

    if (!code.startsWith('+')) {
      code = '+$code';
    }

    if (number.startsWith('0') && number.length > 1) {
      number = number.substring(1);
    }

    return '$code$number';
  }

  static bool isValidInternationalPhone(String fullPhone) {
    final regex = RegExp(r'^\+[1-9]\d{7,14}$');
    return regex.hasMatch(fullPhone);
  }
}
