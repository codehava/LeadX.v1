import 'package:flutter/material.dart';

/// Password strength levels.
enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// Widget to display password strength indicator.
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    required this.password,
    super.key,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final colorScheme = Theme.of(context).colorScheme;

    Color getColor() {
      switch (strength) {
        case PasswordStrength.weak:
          return colorScheme.error;
        case PasswordStrength.medium:
          return Colors.orange;
        case PasswordStrength.strong:
          return Colors.green;
      }
    }

    String getLabel() {
      switch (strength) {
        case PasswordStrength.weak:
          return 'Lemah';
        case PasswordStrength.medium:
          return 'Sedang';
        case PasswordStrength.strong:
          return 'Kuat';
      }
    }

    double getProgress() {
      switch (strength) {
        case PasswordStrength.weak:
          return 0.33;
        case PasswordStrength.medium:
          return 0.66;
        case PasswordStrength.strong:
          return 1;
      }
    }

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: getProgress(),
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(getColor()),
          minHeight: 4,
        ),
        const SizedBox(height: 4),
        Text(
          'Kekuatan password: ${getLabel()}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: getColor(),
              ),
        ),
      ],
    );
  }

  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.weak;
    }

    var score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Has lowercase
    if (password.contains(RegExp('[a-z]'))) score++;

    // Has uppercase
    if (password.contains(RegExp('[A-Z]'))) score++;

    // Has number
    if (password.contains(RegExp('[0-9]'))) score++;

    // Has special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Determine strength based on score
    if (score <= 2) {
      return PasswordStrength.weak;
    } else if (score <= 4) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.strong;
    }
  }

  /// Check if password meets minimum requirements.
  static bool isPasswordValid(String password) {
    return password.length >= 8 &&
        password.contains(RegExp('[a-z]')) &&
        password.contains(RegExp('[A-Z]')) &&
        password.contains(RegExp('[0-9]'));
  }
}
