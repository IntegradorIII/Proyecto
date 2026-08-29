import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? helperText;
  final String? hintText;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.helperText,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}