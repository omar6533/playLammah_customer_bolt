import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class _HelpTool {
  final String emoji;
  final String title;
  final String body;
  final bool beforeQuestion;
  const _HelpTool(this.emoji, this.title, this.body,
      {this.beforeQuestion = false});
}

class HomeHelpToolsSection extends StatelessWidget {
  final bool isDesktop;

  const HomeHelpToolsSection({super.key, required this.isDesktop});

  static const _helpTools = [
    _HelpTool('😴', 'الصمت حكمة',
        'تختارون واحد من الفريق المنافس يسكت ولا يشارك في الجواب',
        beforeQuestion: true),
    _HelpTool('✌️', 'جاوب جوابين', 'محتارين بين جوابين؟ اختر هالمساعدة'),
    _HelpTool('🎩', 'انكبهم',
        'جاوب صح وتجبيك النقاط وتخصم زيها من المنافس'),
    _HelpTool('📞', 'نأخذ مكالمة ونقول ألو',
        'اتصلوا على الصديق اللي ينقد الموقف'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF5F7),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 56 : 40,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text('وسائل المساعدة',
                style: AppTextStyles.xlargeTvExtraBold
                    .copyWith(color: AppColors.primaryRed, fontSize: 28)),
            const SizedBox(height: 8),
            Text('كل فريق يختار ٣ وسائل قبل بدء اللعبة',
                style: AppTextStyles.mediumRegular
                    .copyWith(color: AppColors.darkGray, fontSize: 14)),
            const SizedBox(height: 32),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _helpToolCard(_helpTools[0])),
                  const SizedBox(width: 16),
                  Expanded(child: _helpToolCard(_helpTools[1])),
                  const SizedBox(width: 16),
                  Expanded(child: _helpToolCard(_helpTools[2])),
                  const SizedBox(width: 16),
                  Expanded(child: _helpToolCard(_helpTools[3])),
                ],
              )
            else
              Column(
                children: _helpTools
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _helpToolCard(t),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _helpToolCard(_HelpTool tool) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(tool.emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 16),
          Text(tool.title,
              style: AppTextStyles.mediumBold
                  .copyWith(color: AppColors.primaryRed, fontSize: 16),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(tool.body,
              style: AppTextStyles.mediumRegular
                  .copyWith(color: AppColors.darkGray, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: tool.beforeQuestion
                  ? const Color(0xFFB5D9E8)
                  : AppColors.primaryRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              tool.beforeQuestion ? 'تُستخدم قبل السؤال' : 'تُستخدم بعد السؤال',
              style: AppTextStyles.mediumRegular.copyWith(
                color: tool.beforeQuestion
                    ? const Color(0xFF1A5C75)
                    : AppColors.primaryRed,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
