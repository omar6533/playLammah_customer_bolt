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
  // TODO: replace with Firestore stream
  static const _faqs = [
    _FaqItem('كيف يمكنني إنشاء لعبة؟',
        'أنشئ حساب جديد في اللعبة وبعدها اضغط على إنشاء لعبة، قسّم المتواجدين إلى فريقين متساويين، لكل فريق يختار ٣ فئات، اختار اسم لكل فريق وبعدها ابدأ اللعبة .'),
    _FaqItem('كم عدد اللاعبين المطلوبين؟',
        'الحد الأدنى شخصين والحد الأقصى غير محدود، المهم تقدرون تقسمون على فريقين.'),
    _FaqItem('ما هي وسائل المساعدة؟',
        'هي أدوات تساعدكم أثناء اللعبة مثل الصمت حكمة وجاوب جوابين وانكبهم ونأخذ مكالمة.'),
    _FaqItem('كيف يتم احتساب النقاط؟',
        'كل إجابة صحيحة تجيب نقطة لفريقك وتخصم نقطة من الفريق المنافس عند استخدام بعض الوسائل.'),
    _FaqItem('هل يمكنني اللعب من أي مكان؟',
        'نعم، يمكنكم اللعب من أي مكان عبر الجوال أو الكمبيوتر.'),
  ];

  final List<bool> _open = List.generate(5, (i) => i == 0);

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
            Text('الأسئلة الشائعة',
                style: AppTextStyles.xlargeTvExtraBold
                    .copyWith(color: AppColors.primaryRed, fontSize: 28)),
            const SizedBox(height: 24),
            for (int i = 0; i < _faqs.length; i++) _faqItem(i),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(int i) {
    final faq = _faqs[i];
    final open = _open[i];
    return GestureDetector(
      onTap: () => setState(() => _open[i] = !_open[i]),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(faq.question,
                      style: AppTextStyles.mediumBold.copyWith(
                          color: const Color(0xFFE40D50), fontSize: 15),
                      textAlign: TextAlign.right),
                ),
                const Spacer(),
                Icon(
                  open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFFE40D50),
                ),
              ],
            ),
            if (open && faq.answer.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(faq.answer,
                  style: AppTextStyles.mediumRegular
                      .copyWith(color: AppColors.darkGray, fontSize: 14),
                  textAlign: TextAlign.right),
            ],
          ],
        ),
      ),
    );
  }
}
