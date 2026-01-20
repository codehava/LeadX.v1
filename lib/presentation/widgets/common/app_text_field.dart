import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A styled text field with validation support.
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.autofillHints,
  });

  /// Email input field.
  const AppTextField.email({
    super.key,
    this.label = 'Email',
    this.hint = 'Enter your email',
    this.helperText,
    this.controller,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
  })  : keyboardType = TextInputType.emailAddress,
        textInputAction = TextInputAction.next,
        obscureText = false,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        prefixIcon = Icons.email_outlined,
        prefix = null,
        suffix = null,
        inputFormatters = null,
        autofillHints = const [AutofillHints.email];

  /// Password input field.
  factory AppTextField.password({
    Key? key,
    String label = 'Password',
    String hint = 'Enter your password',
    String? helperText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool enabled = true,
    bool autofocus = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    FocusNode? focusNode,
  }) {
    return _AppPasswordField(
      key: key,
      label: label,
      hint: hint,
      helperText: helperText,
      controller: controller,
      validator: validator,
      enabled: enabled,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
    );
  }

  /// Phone number input field.
  const AppTextField.phone({
    super.key,
    this.label = 'Phone',
    this.hint = 'Enter phone number',
    this.helperText,
    this.controller,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
  })  : keyboardType = TextInputType.phone,
        textInputAction = TextInputAction.next,
        obscureText = false,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        prefixIcon = Icons.phone_outlined,
        prefix = null,
        suffix = null,
        inputFormatters = null,
        autofillHints = const [AutofillHints.telephoneNumber];

  /// Multiline text area.
  const AppTextField.multiline({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 4,
    this.minLines = 2,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.focusNode,
  })  : keyboardType = TextInputType.multiline,
        textInputAction = TextInputAction.newline,
        obscureText = false,
        prefixIcon = null,
        prefix = null,
        suffix = null,
        inputFormatters = null,
        onSubmitted = null,
        autofillHints = null;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        prefix: widget.prefix,
        suffix: widget.suffix,
      ),
    );
  }
}

/// Password field with toggle visibility.
class _AppPasswordField extends AppTextField {
  const _AppPasswordField({
    super.key,
    super.label,
    super.hint,
    super.helperText,
    super.controller,
    super.validator,
    super.enabled,
    super.autofocus,
    super.onChanged,
    super.onSubmitted,
    super.focusNode,
  }) : super(
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          obscureText: true,
          prefixIcon: Icons.lock_outlined,
          autofillHints: const [AutofillHints.password],
        );

  @override
  State<AppTextField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
