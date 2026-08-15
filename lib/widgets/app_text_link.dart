import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A tappable red text link, RTL-aware.
///
/// Use [trailingIcon] for links with an arrow (e.g. "العودة إلى الرئيسية ←").
/// Use [underline] for inline links like "نسيت كلمة المرور".
class AppTextLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool underline;
  final FontWeight fontWeight;
  final double fontSize;
  final IconData? trailingIcon;

  const AppTextLink(
    this.text, {
    super.key,
    this.onTap,
    this.underline = false,
    this.fontWeight = FontWeight.w400,
    this.fontSize = 13,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: AppTextStyles.mediumRegular.copyWith(
        color: AppColors.primaryRed,
        fontSize: fontSize,
        fontWeight: fontWeight,
        decoration: underline ? TextDecoration.underline : null,
        decorationColor: underline ? AppColors.primaryRed : null,
      ),
      textDirection: TextDirection.rtl,
    );

    final child = trailingIcon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              textWidget,
              const SizedBox(width: 4),
              Icon(trailingIcon, color: AppColors.primaryRed, size: 14),
            ],
          )
        : textWidget;

    return GestureDetector(onTap: onTap, child: child);
  }
}
