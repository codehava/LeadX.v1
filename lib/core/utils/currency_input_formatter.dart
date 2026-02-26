import 'package:flutter/services.dart';

/// A [TextInputFormatter] that formats numeric input as Indonesian Rupiah
/// currency with dot thousand separators (e.g., 1.500.000).
///
/// Only allows digits. Automatically inserts dot separators as the user types.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = _formatWithDots(digitsOnly);

    // Count how many digits are before the cursor in the new input
    final newCursorOffset = newValue.selection.end;
    var digitsBeforeCursor = 0;
    for (var i = 0; i < newCursorOffset && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    // Find the position in the formatted string that corresponds to
    // the same number of digits
    var formattedCursorPos = 0;
    var digitCount = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (digitCount == digitsBeforeCursor) break;
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitCount++;
      }
      formattedCursorPos = i + 1;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formattedCursorPos.clamp(0, formatted.length),
      ),
    );
  }

  static String _formatWithDots(String digits) {
    final buffer = StringBuffer();
    final length = digits.length;
    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// Parses a currency-formatted string (e.g., "1.500.000") back to a [double].
/// Strips dots and commas before parsing.
double? parseCurrency(String text) {
  if (text.isEmpty) return null;
  final cleaned = text.replaceAll('.', '').replaceAll(',', '');
  return double.tryParse(cleaned);
}

/// Formats a [double] value as Indonesian currency string with dot separators.
/// E.g., 1500000.0 → "1.500.000"
String formatCurrencyValue(double value) {
  final intValue = value.toStringAsFixed(0);
  return CurrencyInputFormatter._formatWithDots(intValue);
}
