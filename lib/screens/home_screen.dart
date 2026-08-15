import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';

// Placeholder models — replace bodies with Firebase stream data
class _CategoryItem {
  final String name;
  final String description;
  const _CategoryItem(this.name, this.description);
}

class _HelpTool {
  final String emoji;
  final String title;
  final String body;
  final bool beforeQuestion;
  const _HelpTool(this.emoji, this.title, this.body,
      {this.beforeQuestion = false});
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _categoryController;
  int _currentCategory = 1;
  final List<bool> _faqOpen = List.generate(5, (i) => i == 0);

  // TODO: replace with Firestore stream
  static const _categories = [
    _CategoryItem('رياضة', 'أسئلة متنوعة في عالم الرياضة'),
    _CategoryItem('تاريخ', 'أسئلة عن تاريخ العرب والعالم'),
    _CategoryItem('علوم', 'أسئلة علمية تختبر معلوماتك'),
    _CategoryItem('فن وثقافة', 'أسئلة في عالم الفن والثقافة'),
    _CategoryItem('جغرافيا', 'أسئلة عن دول ومدن العالم'),
  ];

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

  @override
  void initState() {
    super.initState();
    _categoryController =
        PageController(viewportFraction: 0.72, initialPage: _currentCategory);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          AppNavbar(onLoginTap: () => context.router.push(const LoginRoute())),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _heroSection(isDesktop),
                  _stepsSection(isDesktop),
                  _categoriesSection(isDesktop),
                  _statsSection(),
                  _helpToolsSection(isDesktop),
                  _faqSection(isDesktop),
                  _ctaBanner(isDesktop),
                  const AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HERO ────────────────────────────────────────────────────────────
  Widget _heroSection(bool isDesktop) {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            _redButton('ألعب الآن',
                () => context.router.push(const LoginRoute())),
          ],
        ),
      ),
    );
  }

  // ─── STEPS ───────────────────────────────────────────────────────────
  Widget _stepsSection(bool isDesktop) {
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
              style: AppTextStyles.mediumBold
                  .copyWith(color: fg, fontSize: 18),
              textAlign: TextAlign.right),
        ],
      ),
    );
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────────
  Widget _categoriesSection(bool isDesktop) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: isDesktop ? 56 : 40),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24),
              child: Column(
                children: [
                  Text('شرح الفئات',
                      style: AppTextStyles.xlargeTvExtraBold.copyWith(
                          color: AppColors.primaryRed, fontSize: 28)),
                  const SizedBox(height: 12),
                  Text(
                    'تختارون 6 فئات، وترا إجمالي الأسئلة 36، خلوها متنوعة عشان تاخذون معلومات جديدة !',
                    style: AppTextStyles.mediumRegular
                        .copyWith(color: AppColors.darkGray, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: isDesktop ? 340 : 280,
              child: PageView.builder(
                controller: _categoryController,
                itemCount: _categories.length,
                onPageChanged: (i) =>
                    setState(() => _currentCategory = i),
                itemBuilder: (ctx, i) {
                  final active = i == _currentCategory;
                  return AnimatedScale(
                    scale: active ? 1.0 : 0.88,
                    duration: const Duration(milliseconds: 200),
                    child: _categoryCard(_categories[i], active),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _redButton('← شرح الفئة',
                () => context.router.push(const LoginRoute()),
                horizontal: 24, vertical: 12, fontSize: 14),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _categories.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentCategory ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentCategory
                        ? AppColors.primaryRed
                        : AppColors.primaryRed.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard(_CategoryItem cat, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF9F0F2) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? AppColors.primaryRed.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Character placeholder — replace with Image.asset per category
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color:
                        AppColors.primaryRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline,
                      color:
                          AppColors.primaryRed.withValues(alpha: 0.45),
                      size: 44),
                ),
                const SizedBox(height: 16),
                Text(cat.name,
                    style: AppTextStyles.mediumBold.copyWith(
                      color: active
                          ? AppColors.primaryRed
                          : AppColors.darkGray,
                      fontSize: 18,
                    )),
              ],
            ),
          ),
          // "أجد الفئات" diagonal sticker
          Positioned(
            top: 14,
            right: 14,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A827),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('أجد الفئات',
                    style: AppTextStyles.mediumBold
                        .copyWith(color: Colors.white, fontSize: 10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATS ───────────────────────────────────────────────────────────
  Widget _statsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: const Color(0xFF303D42),
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
    );
  }

  Widget _statItem(String number, String label) {
    return Column(
      children: [
        Text(number,
            style: AppTextStyles.xlargeTvExtraBold
                .copyWith(color: Colors.white, fontSize: 48)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.mediumRegular.copyWith(
                color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
      ],
    );
  }

  // ─── HELP TOOLS ──────────────────────────────────────────────────────
  Widget _helpToolsSection(bool isDesktop) {
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
              child: Text(tool.emoji,
                  style: const TextStyle(fontSize: 32)),
            ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: tool.beforeQuestion
                  ? const Color(0xFFB5D9E8)
                  : AppColors.primaryRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              tool.beforeQuestion
                  ? 'تُستخدم قبل السؤال'
                  : 'تُستخدم بعد السؤال',
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

  // ─── FAQ ─────────────────────────────────────────────────────────────
  Widget _faqSection(bool isDesktop) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 120 : 24,
        vertical: isDesktop ? 56 : 40,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text('الأسئلة الشائعة',
                style: AppTextStyles.xlargeTvExtraBold
                    .copyWith(color: AppColors.primaryRed, fontSize: 28)),
            const SizedBox(height: 24),
            for (int i = 0; i < _faqs.length; i++)
              _faqItem(i),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(int i) {
    final faq = _faqs[i];
    final open = _faqOpen[i];
    return GestureDetector(
      onTap: () => setState(() => _faqOpen[i] = !_faqOpen[i]),
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

  // ─── CTA BANNER ──────────────────────────────────────────────────────
  Widget _ctaBanner(bool isDesktop) {
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
            _redButton('← إنشاء لعبة',
                () => context.router.push(const RegisterRoute())),
          ],
        ),
      ),
    );
  }

  // ─── SHARED ──────────────────────────────────────────────────────────
  Widget _redButton(
    String label,
    VoidCallback onTap, {
    double horizontal = 32,
    double vertical = 16,
    double fontSize = 16,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: horizontal, vertical: vertical),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyBold
              .copyWith(color: Colors.white, fontSize: fontSize),
        ),
      ),
    );
  }
}
