import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_radius.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';

/// Neo Brutalism text field with thick border
class NeoTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const NeoTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: AppRadius.textField,
              borderSide: const BorderSide(color: AppColors.dark, width: 3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.textField,
              borderSide: const BorderSide(color: AppColors.dark, width: 3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.textField,
              borderSide: const BorderSide(color: AppColors.accent, width: 3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.textField,
              borderSide: const BorderSide(color: AppColors.error, width: 3),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.textField,
              borderSide: BorderSide(color: AppColors.dark.withValues(alpha: 0.3), width: 3),
            ),
          ),
        ),
      ],
    );
  }
}