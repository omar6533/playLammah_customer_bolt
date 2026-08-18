import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'category_card.dart';
import 'red_pill_button.dart';

class _CategoryItem {
  final String name;
  final String description;
  final String icon;
  const _CategoryItem(this.name, this.description, this.icon);
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
  late PageController _controller;
  int _current = 1;

  // TODO: replace with Firestore stream
  static const _categories = [
    _CategoryItem('رياضة', 'أسئلة متنوعة في عالم الرياضة', '⚽'),
    _CategoryItem('تاريخ', 'أسئلة عن تاريخ العرب والعالم', '📜'),
    _CategoryItem('علوم', 'أسئلة علمية تختبر معلوماتك', '🔬'),
    _CategoryItem('فن وثقافة', 'أسئلة في عالم الفن والثقافة', '🎨'),
    _CategoryItem('جغرافيا', 'أسئلة عن دول ومدن العالم', '🌍'),
  ];

  double get _viewportFraction => widget.isDesktop ? 0.20 : 0.60;
  double get _carouselHeight => widget.isDesktop ? 420 : 380;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: _viewportFraction,
      initialPage: _current,
    );
  }

  @override
  void didUpdateWidget(HomeCategoriesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDesktop != widget.isDesktop) {
      final old = _controller;
      _controller = PageController(
        viewportFraction: _viewportFraction,
        initialPage: _current,
      );
      old.dispose();
    }
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
              padding:
                  EdgeInsets.symmetric(horizontal: widget.isDesktop ? 64 : 24),
              child: Column(
                children: [
                  Text('شرح الفئات',
                      style: AppTextStyles.xlargeTvExtraBold
                          .copyWith(color: AppColors.primaryRed, fontSize: 28)),
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
              height: _carouselHeight,
              child: PageView.builder(
                controller: _controller,
                itemCount: _categories.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (ctx, i) {
                  final active = i == _current;
                  return AnimatedScale(
                    scale: active ? 1.0 : 0.88,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CategoryCard(
                        nameAr: _categories[i].name,
                        icon: _categories[i].icon,
                        isSelected: active,
                        onTap: widget.onCategoryTap,
                      ),
                    ),
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
}
