import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_radius.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';

/// Neo Brutalism button with press animation
class NeoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        transform: Matrix4.translationValues(
          _isPressed ? 5 : 0,
          _isPressed ? 5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: widget.isOutlined ? AppColors.card : AppColors.accent,
          borderRadius: AppRadius.button,
          border: Border.all(color: AppColors.dark, width: 3),
          boxShadow: _isPressed
              ? []
              : [
                  const BoxShadow(
                    color: AppColors.dark,
                    offset: Offset(5, 5),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else ...[
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.isOutlined ? AppColors.text : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: widget.isOutlined
                    ? AppTextStyles.button.copyWith(color: AppColors.text)
                    : AppTextStyles.button,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small variant of NeoButton
class NeoButtonSmall extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const NeoButtonSmall({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  State<NeoButtonSmall> createState() => _NeoButtonSmallState();
}

class _NeoButtonSmallState extends State<NeoButtonSmall> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        transform: Matrix4.translationValues(
          _isPressed ? 4 : 0,
          _isPressed ? 4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: AppRadius.button,
          border: Border.all(color: AppColors.dark, width: 3),
          boxShadow: _isPressed
              ? []
              : [
                  const BoxShadow(
                    color: AppColors.dark,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(widget.label, style: AppTextStyles.buttonSmall),
          ],
        ),
      ),
    );
  }
}