import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class HomeStatsSection extends StatelessWidget {
  const HomeStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dark background
        Positioned.fill(
          child: Container(color: const Color(0xFF303D42)),
        ),
        // Decorative wave shapes — centered, full width
        Positioned.fill(
          child: Image.asset(
            'assets/images/home_state_shapes.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        // Stats content
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem('+40', 'فئة'),
                _statItem('+36', 'سؤال بكل جولة'),
                _statItem('3', 'وسائل مساعدة'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statItem(String number, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          number,
          style: AppTextStyles.xlargeTvExtraBold
              .copyWith(color: Colors.white, fontSize: 48),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.mediumRegular.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
