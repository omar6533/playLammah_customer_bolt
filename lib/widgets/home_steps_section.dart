import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

const _kCardWine = Color(0xFF4E1028);

class HomeStepsSection extends StatelessWidget {
  final bool isDesktop;

  const HomeStepsSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Product photo background — no heavy overlay so photo stays visible
        Positioned.fill(
          child: Image.asset(
            'assets/images/hero_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        // Step cards — extra top padding exposes the photo above the cards
        Padding(
          padding: EdgeInsets.only(
            left: isDesktop ? 64 : 20,
            right: isDesktop ? 64 : 20,
            top: isDesktop ? 80 : 100,
            bottom: isDesktop ? 72 : 56,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(
                          child: _stepCard(
                              '1', 'نختار فئات الأسئلة', _CardStyle.wine)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _stepCard('2', 'نحدد الفريقين ووسائل المساعدة',
                              _CardStyle.red)),
                      const SizedBox(width: 16),
                      Expanded(
                          child:
                              _stepCard('3', 'نبدأ التحدي', _CardStyle.light)),
                    ],
                  )
                : Column(
                    children: [
                      _stepCard('1', 'نختار فئات الأسئلة', _CardStyle.wine),
                      const SizedBox(height: 12),
                      _stepCard(
                          '2', 'نحدد الفريقين ووسائل المساعدة', _CardStyle.red),
                      const SizedBox(height: 12),
                      _stepCard('3', 'نبدأ التحدي', _CardStyle.light),
                    ],
                  ),
          ),
        ),
        // Abstract diagonal-stripe accent — fixed height so it stays thin on desktop
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 52,
          child: Image.asset(
            'assets/images/hero_bg_abstract.png',
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _stepCard(String number, String label, _CardStyle style) {
    final Color bg;
    final Color fg;
    switch (style) {
      case _CardStyle.wine:
        bg = _kCardWine;
        fg = Colors.white;
      case _CardStyle.red:
        bg = AppColors.primaryRed;
        fg = Colors.white;
      case _CardStyle.light:
        bg = const Color(0xFFFCE8EC);
        fg = AppColors.primaryRed;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(number,
              style: AppTextStyles.xlargeTvExtraBold
                  .copyWith(color: fg, fontSize: 52)),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.mediumBold.copyWith(color: fg, fontSize: 18),
              textAlign: TextAlign.right),
        ],
      ),
    );
  }
}

enum _CardStyle { wine, red, light }
