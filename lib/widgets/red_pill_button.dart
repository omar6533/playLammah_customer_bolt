import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RedPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double horizontal;
  final double vertical;
  final double fontSize;

  const RedPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.horizontal = 32,
    this.vertical = 16,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyBold.copyWith(color: Colors.white, fontSize: fontSize),
        ),
      ),
    );
  }
}
