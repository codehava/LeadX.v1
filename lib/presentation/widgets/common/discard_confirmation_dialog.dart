import 'package:flutter/material.dart';

/// A reusable discard confirmation dialog.
/// Shows when user tries to leave a form with unsaved changes.
class DiscardConfirmationDialog extends StatelessWidget {
  const DiscardConfirmationDialog({
    super.key,
    this.title = 'Buang Perubahan?',
    this.message = 'Perubahan yang belum disimpan akan hilang.',
    this.discardLabel = 'Buang',
    this.cancelLabel = 'Lanjutkan Edit',
  });

  final String title;
  final String message;
  final String discardLabel;
  final String cancelLabel;

  /// Show the discard confirmation dialog.
  /// Returns true if user confirms discard, false otherwise.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const DiscardConfirmationDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: Text(discardLabel),
        ),
      ],
    );
  }
}

/// Mixin for form screens that need discard confirmation.
/// Add this mixin to your State class and implement [hasUnsavedChanges].
mixin DiscardConfirmationMixin<T extends StatefulWidget> on State<T> {
  /// Override this to return true when form has unsaved changes.
  bool get hasUnsavedChanges;

  /// Call this when user attempts to navigate back.
  Future<bool> handleBackNavigation() async {
    if (!hasUnsavedChanges) return true;
    return await DiscardConfirmationDialog.show(context);
  }
}
