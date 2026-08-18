import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'red_pill_button.dart';

class HomeHeroSection extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onCtaTap;

  const HomeHeroSection({
    super.key,
    required this.isDesktop,
    required this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 80 : 48,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.primaryRed.withValues(alpha: 0.25)),
              ),
              child: Text(
                'لعبة ثقافية جماعية من شخصين فأكثر',
                style: AppTextStyles.mediumRegular
                    .copyWith(color: AppColors.primaryRed, fontSize: 13),
              ),
            ),
            const SizedBox(height: 28),
            RichText(
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: AppTextStyles.xlargeTvExtraBold.copyWith(
                  color: AppColors.primaryRed,
                  fontSize: isDesktop ? 72 : 40,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: 'لمّة',
                    style: AppTextStyles.xlargeTvExtraBold.copyWith(
                      color: AppColors.primaryRed,
                      fontSize: isDesktop ? 72 : 40,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(text: ' وتحدي وين تبي'),
                ],
              ),
            ),
            const SizedBox(height: 36),
            RedPillButton(label: 'ألعب الآن', onTap: onCtaTap),
          ],
        ),
      ),
    );
  }
}
