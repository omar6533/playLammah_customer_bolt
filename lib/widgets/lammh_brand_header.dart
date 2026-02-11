import 'package:flutter/material.dart';
import 'package:trivia_game/widgets/lammah_logo.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LammhBrandHeader extends StatelessWidget {
  final double logoSize;
  final Color logoColor;
  final bool showTagline;
  final bool showLoadingIndicator;
  final double titleFontSize;
  final double taglineFontSize;

  const LammhBrandHeader({
    Key? key,
    this.logoSize = 120,
    this.logoColor = AppColors.white,
    this.showTagline = true,
    this.showLoadingIndicator = false,
    this.titleFontSize = 36,
    this.taglineFontSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LammhLogo(
          size: logoSize,
          color: logoColor,
        ),
        const SizedBox(height: 32),
        Text(
          'لمة ونتحدى',
          style: AppTextStyles.textXx2TvExtraBold.copyWith(
            color: logoColor,
            fontSize: titleFontSize,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 12),
          Text(
            'PlayLammh.com',
            style: AppTextStyles.largeTvBold.copyWith(
              color: logoColor.withOpacity(0.9),
              fontSize: taglineFontSize,
            ),
          ),
        ],
        if (showLoadingIndicator) ...[
          const SizedBox(height: 48),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(logoColor),
          ),
        ],
      ],
    );
  }
}
