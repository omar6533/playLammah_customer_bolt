import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AuthTitle extends StatelessWidget {
  final String text;

  const AuthTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.xlargeTvExtraBold.copyWith(
        color: AppColors.primaryRed,
        fontSize: 28,
      ),
      textDirection: TextDirection.rtl,
    );
  }
}

class AuthSubtitle extends StatelessWidget {
  final String text;

  const AuthSubtitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.mediumRegular.copyWith(
        color: Colors.grey[500],
        fontSize: 14,
      ),
      textDirection: TextDirection.rtl,
    );
  }
}
