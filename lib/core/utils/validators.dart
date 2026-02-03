/// Reusable form validators for the LeadX CRM application.
///
/// All validators return `null` if valid, or an error message string if invalid.
/// Validators that check optional fields will return `null` for empty values.
class Validators {
  Validators._();

  /// Email regex pattern (RFC-compliant)
  static final _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
  );

  /// Indonesian phone number pattern (+62 or 08)
  static final _phoneRegex = RegExp(
    r'^(\+62|62|0)[\d\s\-]{8,14}$',
  );

  /// URL pattern (basic validation)
  static final _urlRegex = RegExp(
    r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    caseSensitive: false,
  );

  /// Validates email format.
  /// Returns null for empty values (optional field behavior).
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validates email format (required field).
  static String? validateEmailRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validates Indonesian phone number format.
  /// Returns null for empty values (optional field behavior).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    // Remove spaces and dashes for validation
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  /// Validates URL format.
  /// Returns null for empty values (optional field behavior).
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (!_urlRegex.hasMatch(value.trim())) {
      return 'Format URL tidak valid';
    }
    return null;
  }

  /// Validates percentage (0-100).
  /// Returns null for empty values (optional field behavior).
  static String? validatePercentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Masukkan angka yang valid';
    }
    if (number < 0 || number > 100) {
      return 'Nilai harus antara 0-100';
    }
    return null;
  }

  /// Validates positive number.
  /// Returns null for empty values (optional field behavior).
  static String? validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    // Remove thousand separators
    final cleaned = value.replaceAll('.', '').replaceAll(',', '');
    final number = double.tryParse(cleaned);
    if (number == null) {
      return 'Masukkan angka yang valid';
    }
    if (number < 0) {
      return 'Nilai tidak boleh negatif';
    }
    return null;
  }

  /// Validates Indonesian postal code (5 digits).
  /// Returns null for empty values (optional field behavior).
  static String? validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (!RegExp(r'^\d{5}$').hasMatch(value.trim())) {
      return 'Kode pos harus 5 digit';
    }
    return null;
  }
}
