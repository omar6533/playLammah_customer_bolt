import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'red_pill_button.dart';

class _CategoryItem {
  final String name;
  final String description;
  const _CategoryItem(this.name, this.description);
}

class HomeCategoriesSection extends StatefulWidget {
  final bool isDesktop;
  final VoidCallback onCategoryTap;

  const HomeCategoriesSection({
    super.key,
    required this.isDesktop,
    required this.onCategoryTap,
  });

  @override
  State<HomeCategoriesSection> createState() => _HomeCategoriesSectionState();
}

class _HomeCategoriesSectionState extends State<HomeCategoriesSection> {
  late final PageController _controller;
  int _current = 1;

  // TODO: replace with Firestore stream
  static const _categories = [
    _CategoryItem('رياضة', 'أسئلة متنوعة في عالم الرياضة'),
    _CategoryItem('تاريخ', 'أسئلة عن تاريخ العرب والعالم'),
    _CategoryItem('علوم', 'أسئلة علمية تختبر معلوماتك'),
    _CategoryItem('فن وثقافة', 'أسئلة في عالم الفن والثقافة'),
    _CategoryItem('جغرافيا', 'أسئلة عن دول ومدن العالم'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.72, initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.isDesktop ? 56 : 40),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: widget.isDesktop ? 64 : 24),
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
              height: widget.isDesktop ? 340 : 280,
              child: PageView.builder(
                controller: _controller,
                itemCount: _categories.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (ctx, i) {
                  final active = i == _current;
                  return AnimatedScale(
                    scale: active ? 1.0 : 0.88,
                    duration: const Duration(milliseconds: 200),
                    child: _categoryCard(_categories[i], active),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            RedPillButton(
              label: '← شرح الفئة',
              onTap: widget.onCategoryTap,
              horizontal: 24,
              vertical: 12,
              fontSize: 14,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _categories.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _current ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _current
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline,
                      color: AppColors.primaryRed.withValues(alpha: 0.45),
                      size: 44),
                ),
                const SizedBox(height: 16),
                Text(cat.name,
                    style: AppTextStyles.mediumBold.copyWith(
                      color: active ? AppColors.primaryRed : AppColors.darkGray,
                      fontSize: 18,
                    )),
              ],
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
}
