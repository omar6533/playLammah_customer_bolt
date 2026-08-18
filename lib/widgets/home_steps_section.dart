import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HomeStepsSection extends StatelessWidget {
  final bool isDesktop;

  const HomeStepsSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 56 : 40,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3D0A18), Color(0xFF600522)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: isDesktop
            ? Row(
                children: [
                  Expanded(child: _stepCard('1', 'نختار فئات الأسئلة', false)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _stepCard(
                          '2', 'نحدد الفريقين ووسائل المساعدة', false)),
                  const SizedBox(width: 16),
                  Expanded(child: _stepCard('3', 'نبدأ التحدي', true)),
                ],
              )
            : Column(
                children: [
                  _stepCard('1', 'نختار فئات الأسئلة', false),
                  const SizedBox(height: 12),
                  _stepCard('2', 'نحدد الفريقين ووسائل المساعدة', false),
                  const SizedBox(height: 12),
                  _stepCard('3', 'نبدأ التحدي', true),
                ],
              ),
      ),
    );
  }

  Widget _stepCard(String number, String label, bool isLight) {
    final fg = isLight ? AppColors.primaryRed : Colors.white;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFCE8EC) : AppColors.primaryRed,
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
              style:
                  AppTextStyles.mediumBold.copyWith(color: fg, fontSize: 18),
              textAlign: TextAlign.right),
        ],
      ),
    );
  }
}
