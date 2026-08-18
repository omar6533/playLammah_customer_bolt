import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'red_pill_button.dart';

class HomeCtaBanner extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onCtaTap;

  const HomeCtaBanner({
    super.key,
    required this.isDesktop,
    required this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 40 : 32,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 24,
        vertical: isDesktop ? 48 : 36,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFC7EEFF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text('! لعبتك الأولى علينا',
                style: AppTextStyles.xlargeTvExtraBold.copyWith(
                    color: AppColors.primaryRed,
                    fontSize: isDesktop ? 40 : 28),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('جاهزين تلعبون؟ جربها الآن',
                style: AppTextStyles.mediumRegular
                    .copyWith(color: AppColors.darkGray, fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            RedPillButton(label: '← إنشاء لعبة', onTap: onCtaTap),
          ],
        ),
      ),
    );
  }
}
