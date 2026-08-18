import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/routes/app_router.dart';
import '../theme/app_colors.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_event.dart';
import '../bloc/category/category_state.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_event.dart';
import '../bloc/game/game_state.dart';
import '../services/app_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_navbar.dart';
import '../widgets/category_card.dart';
import '../widgets/game_setup_form.dart';

@RoutePage()
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final Map<String, List<dynamic>> _categorySubcategories = {};
  final Set<String> _collapsedCategories = {};
  String _searchQuery = '';
  String? _selectedFilterCategoryId;

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

  void _startGame(
    BuildContext context,
    CategoryLoaded state,
    String gameName,
    String leftTeamName,
    String rightTeamName,
  ) {
    context.read<GameBloc>().add(
          CreateGameEvent(
            gameName: gameName,
            leftTeamName: leftTeamName,
            rightTeamName: rightTeamName,
            selectedSubcategories: state.selectedSubcategoryIds,
          ),
        );
  }

  void _selectRandomCategories(BuildContext context, CategoryLoaded state) {
    final bloc = context.read<CategoryBloc>();
    bloc.add(const ClearSubcategorySelectionsEvent());
    final all = <dynamic>[];
    for (final subs in _categorySubcategories.values) {
      all.addAll(subs);
    }
    all.shuffle();
    for (final sub in all.take(6)) {
      bloc.add(ToggleSubcategoryEvent(subcategoryId: sub.id as String));
    }
  }

  dynamic _findSubcategoryById(String id) {
    for (final subs in _categorySubcategories.values) {
      try {
        return subs.firstWhere((s) => s.id == id);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  List<dynamic> _getFilteredSubcategories(String categoryId) {
    final subs = _categorySubcategories[categoryId] ?? [];
    if (_searchQuery.isEmpty) return subs;
    return subs
        .where((s) => s.nameAr
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: isDesktop ? null : const AppDrawer(),
      body: BlocListener<GameBloc, GameState>(
        listenWhen: (previous, current) =>
            (current is GameInProgress && previous is! GameInProgress) ||
            (current is GameError && previous is! GameError),
        listener: (context, state) {
          if (state is GameInProgress) {
            context.router.replace(QuestionGridRoute(gameId: state.gameId));
          } else if (state is GameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryRed,
              ),
            );
          }
        },
        child: Column(
          children: [
            AppNavbar(onBackTap: () => context.router.pop()),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  if (categoryState is CategoryLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryRed),
                    );
                  }
                  if (categoryState is CategoryError) {
                    return Center(
                      child: Text(categoryState.message,
                          style:
                              const TextStyle(color: AppColors.primaryRed)),
                    );
                  }
                  if (categoryState is CategoryLoaded) {
                    return _buildContent(context, categoryState, isDesktop);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, CategoryLoaded state, bool isDesktop) {
    final selectedCount = state.selectedSubcategoryIds.length;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: selectedCount > 0 ? 92 : 32),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPageHeader(isDesktop),
                _buildFilterChips(state, isDesktop),
                _buildCategoryGroups(context, state, isDesktop),
                GameSetupForm(
                  selectedCount: selectedCount,
                  isDesktop: isDesktop,
                  onStart: (gameName, leftTeam, rightTeam) =>
                      _startGame(context, state, gameName, leftTeam, rightTeam),
                ),
              ],
            ),
          ),
        ),
        if (selectedCount > 0)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildSelectedBar(context, state, isDesktop),
          ),
      ],
    );
  }

  // ── Page header ───────────────────────────────────────────────────────────

  Widget _buildPageHeader(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          isDesktop ? 64 : 24, 32, isDesktop ? 64 : 24, 0),
      child: Column(
        children: [
          const Text(
            'الفئات',
            style: TextStyle(
              color: AppColors.primaryRed,
              fontSize: 44,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'تختارون 6 فئات ، وترا إجمالي الأسئلة 36، خلوها متنوعة عشان تاخذون معلومات جديدة !',
            style: TextStyle(
              color: const Color(0xFF666666),
              fontSize: isDesktop ? 16 : 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: isDesktop ? 480 : double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'ابحث باسم الفئة ، الدولة',
                  hintStyle:
                      TextStyle(color: Color(0xFF999999), fontSize: 14),
                  suffixIcon:
                      Icon(Icons.search, color: AppColors.primaryRed),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips(CategoryLoaded state, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 24,
        left: isDesktop ? 64 : 24,
        right: isDesktop ? 64 : 24,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _filterChip('أجد الفئات', null),
          ...state.mainCategories
              .map((cat) => _filterChip(cat.nameAr, cat.id)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? categoryId) {
    final isActive = categoryId == null
        ? _selectedFilterCategoryId == null
        : _selectedFilterCategoryId == categoryId;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedFilterCategoryId =
            (categoryId == null || isActive) ? null : categoryId;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFDDDDDD),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF333333),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ── Category groups ───────────────────────────────────────────────────────

  Widget _buildCategoryGroups(
      BuildContext context, CategoryLoaded state, bool isDesktop) {
    final categories = _selectedFilterCategoryId == null
        ? state.mainCategories
        : state.mainCategories
            .where((c) => c.id == _selectedFilterCategoryId)
            .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 16),
      child: Column(
        children: categories.map((category) {
          final subs = _getFilteredSubcategories(category.id);
          if (subs.isEmpty && _searchQuery.isNotEmpty) {
            return const SizedBox.shrink();
          }
          return _buildCategorySection(
              context, state, category, subs, isDesktop);
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    CategoryLoaded state,
    dynamic category,
    List<dynamic> subs,
    bool isDesktop,
  ) {
    final isCollapsed = _collapsedCategories.contains(category.id as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() {
              final id = category.id as String;
              if (isCollapsed) {
                _collapsedCategories.remove(id);
              } else {
                _collapsedCategories.add(id);
              }
            }),
            borderRadius: isCollapsed
                ? BorderRadius.circular(20)
                : const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isCollapsed ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.keyboard_arrow_up,
                          size: 18, color: Color(0xFF555555)),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    category.nameAr as String,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: subs.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                            color: AppColors.primaryRed),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 5 : 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.58,
                      ),
                      itemCount: subs.length,
                      itemBuilder: (context, index) =>
                          _buildSubcategoryCard(context, state, subs[index]),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCard(
      BuildContext context, CategoryLoaded state, dynamic subcategory) {
    final id = subcategory.id as String;
    final isSelected = state.selectedSubcategoryIds.contains(id);
    final canSelect = isSelected || state.selectedSubcategoryIds.length < 6;

    return CategoryCard(
      nameAr: (subcategory.nameAr as String?) ?? '',
      icon: (subcategory.icon as String?) ?? '🎯',
      isSelected: isSelected,
      isDisabled: !canSelect,
      onTap: () {
        if (canSelect) {
          context
              .read<CategoryBloc>()
              .add(ToggleSubcategoryEvent(subcategoryId: id));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن اختيار أكثر من 6 فئات'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  // ── Selected bar ──────────────────────────────────────────────────────────

  Widget _buildSelectedBar(
      BuildContext context, CategoryLoaded state, bool isDesktop) {
    final selected = state.selectedSubcategoryIds;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 16,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _selectRandomCategories(context, state),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shuffle_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'إختيار فئات عشوائي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            for (int i = 0; i < 6; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              i < selected.length
                  ? _selectedSlot(context, selected[i],
                      _findSubcategoryById(selected[i])?.icon as String?)
                  : _emptySlot(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _selectedSlot(
      BuildContext context, String subcategoryId, String? icon) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8EC),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryRed, width: 2),
          ),
          child: Center(
            child: Text(icon ?? '🎯', style: const TextStyle(fontSize: 20)),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () => context.read<CategoryBloc>().add(
                  ToggleSubcategoryEvent(subcategoryId: subcategoryId),
                ),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF888888),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptySlot() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
      ),
      child: const Icon(Icons.add, color: Color(0xFFCCCCCC), size: 18),
    );
  }
}
