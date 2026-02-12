import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_event.dart';
import '../bloc/category/category_state.dart';
import '../utils/responsive_helper.dart';
import '../widgets/primary_button.dart';
import '../services/app_service.dart';

@RoutePage()
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final Set<String> _expandedCategories = {};
  final Map<String, List<dynamic>> _categorySubcategories = {};

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const LoadCategoriesEvent());
    _loadAllSubcategories();
  }

  Future<void> _loadAllSubcategories() async {
    final appService = AppService();
    final categories = await appService.getMainCategories();
    for (final category in categories) {
      final subcategories =
          await appService.getSubCategoriesForMainCategory(category.id);
      _categorySubcategories[category.id] = subcategories;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختر الفئات', style: AppTextStyles.largeTvBold),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7931E), Color(0xFFFF8C42)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              );
            }

            if (state is CategoryError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTextStyles.mediumRegular.copyWith(
                    color: AppColors.white,
                  ),
                ),
              );
            }

            if (state is CategoryLoaded) {
              return _buildModernLayout(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildModernLayout(BuildContext context, CategoryLoaded state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    if (isMobile) {
      return Column(
        children: [
          Expanded(
            child: _buildCategoriesSection(context, state),
          ),
          Container(
            color: AppColors.white,
            child: _buildSelectedCategoriesPanel(context, state),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildCategoriesSection(context, state),
        ),
        Container(
          width: 400,
          color: AppColors.white,
          child: _buildSelectedCategoriesPanel(context, state),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context, CategoryLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'إجدد الفئات',
                  style: AppTextStyles.extraLargeTvBold.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...state.mainCategories.map((category) {
            final isExpanded = _expandedCategories.contains(category.id);
            return _buildCategorySection(context, state, category, isExpanded);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    CategoryLoaded state,
    dynamic category,
    bool isExpanded,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCategories.remove(category.id);
                } else {
                  _expandedCategories.add(category.id);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.nameAr,
                      style: AppTextStyles.extraLargeTvBold.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildSubcategoryCards(context, state, category.id),
            ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCards(
    BuildContext context,
    CategoryLoaded state,
    String categoryId,
  ) {
    final subcategories = _categorySubcategories[categoryId] ?? [];
    final screenWidth = MediaQuery.of(context).size.width;

    if (subcategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(
            color: AppColors.primaryRed,
          ),
        ),
      );
    }

    int crossAxisCount = 3;
    double cardWidth = 180;

    if (screenWidth < 600) {
      crossAxisCount = 3;
      cardWidth = (screenWidth - 80) / 3;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
      cardWidth = (screenWidth - 120) / 3;
    } else {
      crossAxisCount = 4;
      cardWidth = 200;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = subcategories[index];
        final isSelected =
            state.selectedSubcategoryIds.contains(subcategory.id);
        final selectedCount = state.selectedSubcategoryIds.length;
        final canSelect = isSelected || selectedCount < 6;

        return InkWell(
          onTap: canSelect
              ? () {
                  context.read<CategoryBloc>().add(
                        ToggleSubcategoryEvent(subcategoryId: subcategory.id),
                      );
                }
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا يمكن اختيار أكثر من 6 فئات'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
          child: Opacity(
            opacity: canSelect ? 1.0 : 0.5,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'باقي 6 لعبة',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth < 600 ? 8 : 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subcategory.icon,
                          style:
                              TextStyle(fontSize: screenWidth < 600 ? 32 : 40),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical:
                          screenWidth < 600 ? AppSpacing.xs : AppSpacing.sm,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      subcategory.nameAr,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 600 ? 11 : 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedCategoriesPanel(
    BuildContext context,
    CategoryLoaded state,
  ) {
    final selectedCount = state.selectedSubcategoryIds.length;
    final canStart = selectedCount >= 6;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
          child: Text(
            'الفئات المختارة ($selectedCount/6)',
            style: AppTextStyles.largeTvBold.copyWith(
              fontSize: isMobile ? 18 : 24,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (!isMobile)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: state.selectedSubcategoryIds.map((subcategoryId) {
                  final subcategory = _findSubcategory(state, subcategoryId);
                  final category =
                      _findCategoryForSubcategory(state, subcategoryId);
                  if (subcategory == null || category == null)
                    return const SizedBox();

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.nameAr,
                                style: AppTextStyles.mediumRegular.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subcategory.nameAr,
                                style: AppTextStyles.mediumBold.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<CategoryBloc>().add(
                                  ToggleSubcategoryEvent(
                                      subcategoryId: subcategoryId),
                                );
                          },
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            children: [
              if (!canStart)
                Text(
                  'يجب اختيار 6 فئات على الأقل',
                  style: AppTextStyles.mediumBold.copyWith(
                    color: isMobile ? AppColors.white : AppColors.darkGray,
                    fontSize: isMobile ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: isMobile ? AppSpacing.sm : AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canStart
                      ? () => _navigateToGameSetup(context, state)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canStart
                        ? const Color(0xFFF48FB1)
                        : AppColors.lightGray,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? AppSpacing.md : AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ابدأ اللعبة',
                    style: AppTextStyles.largeTvBold.copyWith(
                      color: canStart ? AppColors.white : AppColors.darkGray,
                      fontSize: isMobile ? 16 : 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.router.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGray,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? AppSpacing.md : AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'رجوع',
                    style: AppTextStyles.largeTvBold.copyWith(
                      color: AppColors.darkGray,
                      fontSize: isMobile ? 16 : 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  dynamic _findSubcategory(CategoryLoaded state, String subcategoryId) {
    for (final subcategories in _categorySubcategories.values) {
      try {
        return subcategories.firstWhere((sub) => sub.id == subcategoryId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  dynamic _findCategoryForSubcategory(
      CategoryLoaded state, String subcategoryId) {
    for (final entry in _categorySubcategories.entries) {
      final hasSubcategory = entry.value.any((sub) => sub.id == subcategoryId);
      if (hasSubcategory) {
        try {
          return state.mainCategories.firstWhere((cat) => cat.id == entry.key);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  void _navigateToGameSetup(BuildContext context, CategoryLoaded state) {
    context.router.push(
      GameSetupRoute(
        selectedSubcategories: state.selectedSubcategoryIds,
      ),
    );
  }
}
