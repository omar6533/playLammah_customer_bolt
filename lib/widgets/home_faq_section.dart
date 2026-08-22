import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

class HomeFaqSection extends StatefulWidget {
  final bool isDesktop;

  const HomeFaqSection({super.key, required this.isDesktop});

  @override
  State<HomeFaqSection> createState() => _HomeFaqSectionState();
}

class _HomeFaqSectionState extends State<HomeFaqSection> {
  static const _faqs = [
    _FaqItem('كيف يمكنني إنشاء لعبة؟',
        'أنشئ حساب جديد في اللعبة وبعدها اضغط على إنشاء لعبة ، قسّم المتواجدين إلى فريقين متساويين ، لكل فريق يختار ٣ فئات ، اختار اسم لكل فريق وبعدها ابدأ اللعبة .'),
    _FaqItem('كم عدد اللاعبين المطلوبين؟',
        'الحد الأدنى شخصين والحد الأقصى غير محدود، المهم تقدرون تقسمون على فريقين.'),
    _FaqItem('ما هي وسائل المساعدة؟',
        'هي أدوات تساعدكم أثناء اللعبة مثل الصمت حكمة وجاوب جوابين وانكبهم ونأخذ مكالمة.'),
    _FaqItem('كيف يتم احتساب النقاط؟',
        'كل إجابة صحيحة تجيب نقطة لفريقك وتخصم نقطة من الفريق المنافس عند استخدام بعض الوسائل.'),
    _FaqItem('هل يمكنني اللعب من أي مكان؟',
        'نعم، يمكنكم اللعب من أي مكان عبر الجوال أو الكمبيوتر.'),
  ];

  int _openIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 120 : 24,
        vertical: widget.isDesktop ? 56 : 40,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text(
              'الأسئلة الشائعة',
              style: AppTextStyles.xlargeTvExtraBold
                  .copyWith(color: AppColors.primaryRed, fontSize: 28),
            ),
            const SizedBox(height: 24),
            // Single outer card wrapping all items
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEEEEE)),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  for (int i = 0; i < _faqs.length; i++) ...[
                    _faqRow(i),
                    if (i < _faqs.length - 1)
                      const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqRow(int i) {
    final faq = _faqs[i];
    final isOpen = _openIndex == i;

    return GestureDetector(
      onTap: () => setState(() => _openIndex = isOpen ? -1 : i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isOpen
            ? AppColors.primaryRed.withValues(alpha: 0.04)
            : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Question text on the right (RTL: first child = rightmost)
                Expanded(
                  child: Text(
                    faq.question,
                    style: AppTextStyles.mediumBold.copyWith(
                      color: AppColors.primaryRed,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 12),
                // Chevron on the left (RTL: last child = leftmost)
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primaryRed,
                  size: 22,
                ),
              ],
            ),
            if (isOpen && faq.answer.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                faq.answer,
                style: AppTextStyles.mediumRegular.copyWith(
                  color: AppColors.darkGray,
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
