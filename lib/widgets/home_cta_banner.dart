import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
    // Shape widths: on desktop let them fill by height; on mobile cap them so they
    // don't eat into the center content area.
    final double shapeWidth1 = isDesktop ? 220 : 90;
    final double shapeWidth2 = isDesktop ? 110 : 60;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 40 : 32,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFFC7EEFF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shape 1 — left wave decoration
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: shapeWidth1,
              child: Image.asset(
                'assets/images/HomeCtaBanner_shape_1.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          // Shape 2 — right spiral decoration
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: shapeWidth2,
              child: Image.asset(
                'assets/images/HomeCtaBanner_shape_2.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
          // Content — horizontal padding clears the shapes
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 260 : 110,
              vertical: isDesktop ? 48 : 36,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '! لعبتك الأولى علينا',
                    style: AppTextStyles.xlargeTvExtraBold.copyWith(
                      color: AppColors.primaryRed,
                      fontSize: isDesktop ? 40 : 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'جاهزين تلعبون؟ جربها الآن',
                    style: AppTextStyles.mediumRegular.copyWith(
                      color: AppColors.darkGray,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onCtaTap,
                    // arrow_forward mirrors to ← in RTL context
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('إنشاء لعبة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 24,
                        vertical: 14,
                      ),
                      textStyle:
                          AppTextStyles.mediumBold.copyWith(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
