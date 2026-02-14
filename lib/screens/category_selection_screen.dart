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
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isMobile = screenWidth < 900;

    if (isMobile && !isLandscape) {
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
          flex: isLandscape ? 3 : 2,
          child: _buildCategoriesSection(context, state),
        ),
        Container(
          width: isLandscape ? screenWidth * 0.35 : 400,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: _buildSelectedCategoriesPanel(context, state),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context, CategoryLoaded state) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isLandscape ? AppSpacing.md : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? AppSpacing.md : AppSpacing.xl,
              vertical: isLandscape ? AppSpacing.sm : AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: isLandscape ? 36 : 48,
                  height: isLandscape ? 36 : 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    color: AppColors.white,
                    size: isLandscape ? 20 : 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'اختر الفئات',
                    style: AppTextStyles.extraLargeTvBold.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isLandscape ? 18 : 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isLandscape ? AppSpacing.md : AppSpacing.xl),
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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin:
          EdgeInsets.only(bottom: isLandscape ? AppSpacing.sm : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              padding:
                  EdgeInsets.all(isLandscape ? AppSpacing.md : AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryRed, AppColors.secondaryRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                        fontSize: isLandscape ? 16 : 20,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: isLandscape ? 32 : 40,
                      height: isLandscape ? 32 : 40,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.white,
                        size: isLandscape ? 20 : 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding:
                  EdgeInsets.all(isLandscape ? AppSpacing.sm : AppSpacing.lg),
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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

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
    double aspectRatio = 1.0;

    if (isLandscape) {
      if (screenWidth < 900) {
        crossAxisCount = 4;
        aspectRatio = 1.1;
      } else {
        crossAxisCount = 5;
        aspectRatio = 1.0;
      }
    } else {
      if (screenWidth < 600) {
        crossAxisCount = 3;
        aspectRatio = 1.0;
      } else if (screenWidth < 900) {
        crossAxisCount = 3;
        aspectRatio = 0.95;
      } else {
        crossAxisCount = 4;
        aspectRatio = 0.95;
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
        childAspectRatio: aspectRatio,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryRed.withOpacity(0.1)
                  : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryRed : Colors.transparent,
                width: isSelected ? 4 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryRed.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 4 : AppSpacing.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'باقي 6 لعبة',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLandscape ? 7 : 9,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    subcategory.icon,
                                    style: TextStyle(
                                      fontSize: isLandscape ? 28 : 32,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: isLandscape ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryRed
                              : AppColors.primaryRed.withOpacity(0.9),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            subcategory.nameAr,
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isLandscape ? 9 : 11,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: isLandscape ? 12 : 16,
                      ),
                    ),
                  ),
                if (!canSelect)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isMobile = screenWidth < 900;
    final showPanel = !isMobile || isLandscape;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isLandscape
              ? AppSpacing.sm
              : (isMobile ? AppSpacing.md : AppSpacing.lg)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryRed.withOpacity(0.1),
                AppColors.primaryRed.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Text(
                'الفئات المختارة',
                style: AppTextStyles.largeTvBold.copyWith(
                  fontSize: isLandscape ? 16 : (isMobile ? 18 : 24),
                  color: AppColors.primaryRed,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selectedCount >= 6
                      ? AppColors.success
                      : AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$selectedCount/6',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isLandscape ? 14 : 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showPanel)
          Expanded(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.all(isLandscape ? AppSpacing.sm : AppSpacing.lg),
              child: Column(
                children: state.selectedSubcategoryIds.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: isLandscape ? 40 : 60,
                                color: AppColors.customGray,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'اختر الفئات من القائمة',
                                style: TextStyle(
                                  color: AppColors.customGray,
                                  fontSize: isLandscape ? 12 : 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ]
                    : state.selectedSubcategoryIds.map((subcategoryId) {
                        final subcategory =
                            _findSubcategory(state, subcategoryId);
                        final category =
                            _findCategoryForSubcategory(state, subcategoryId);
                        if (subcategory == null || category == null)
                          return const SizedBox();

                        return Container(
                          margin: EdgeInsets.only(
                              bottom:
                                  isLandscape ? AppSpacing.xs : AppSpacing.sm),
                          padding: EdgeInsets.all(
                              isLandscape ? AppSpacing.sm : AppSpacing.md),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryRed,
                                AppColors.secondaryRed,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryRed.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  subcategory.icon,
                                  style: TextStyle(
                                      fontSize: isLandscape ? 20 : 24),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.nameAr,
                                      style: TextStyle(
                                        color: AppColors.white.withOpacity(0.9),
                                        fontSize: isLandscape ? 10 : 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subcategory.nameAr,
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isLandscape ? 12 : 14,
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
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.white,
                                  size: isLandscape ? 18 : 24,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.all(isLandscape
              ? AppSpacing.sm
              : (isMobile ? AppSpacing.md : AppSpacing.lg)),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (!canStart)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'يجب اختيار 6 فئات على الأقل',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: isLandscape ? 11 : (isMobile ? 14 : 16),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                  height: isLandscape
                      ? AppSpacing.xs
                      : (isMobile ? AppSpacing.sm : AppSpacing.md)),
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
                      vertical: isLandscape
                          ? AppSpacing.sm
                          : (isMobile ? AppSpacing.md : AppSpacing.lg),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: canStart ? 4 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ابدأ اللعبة',
                        style: AppTextStyles.largeTvBold.copyWith(
                          color:
                              canStart ? AppColors.white : AppColors.darkGray,
                          fontSize: isLandscape ? 14 : (isMobile ? 16 : 20),
                        ),
                      ),
                      if (canStart) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.white,
                          size: isLandscape ? 20 : 24,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: isLandscape ? AppSpacing.xs : AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.router.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkGray,
                    side:
                        const BorderSide(color: AppColors.lightGray, width: 2),
                    padding: EdgeInsets.symmetric(
                      vertical: isLandscape
                          ? AppSpacing.sm
                          : (isMobile ? AppSpacing.md : AppSpacing.lg),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'رجوع',
                    style: AppTextStyles.largeTvBold.copyWith(
                      color: AppColors.darkGray,
                      fontSize: isLandscape ? 14 : (isMobile ? 16 : 20),
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
