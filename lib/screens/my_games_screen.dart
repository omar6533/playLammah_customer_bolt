import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive_helper.dart';
import '../widgets/purchase_dialog.dart';

class SavedGame {
  final String id;
  final String title;
  final int timesPlayed;
  final List<GameCategory> categories;

  SavedGame({
    required this.id,
    required this.title,
    required this.timesPlayed,
    required this.categories,
  });
}

class GameCategory {
  final String icon;
  final String nameAr;

  GameCategory({required this.icon, required this.nameAr});
}

@RoutePage()
class MyGamesScreen extends StatefulWidget {
  const MyGamesScreen({Key? key}) : super(key: key);

  @override
  State<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends State<MyGamesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<SavedGame> _getMockGames() {
    return [
      SavedGame(
        id: 'game_1',
        title: 'لع تجريبية',
        timesPlayed: 3,
        categories: [
          GameCategory(icon: '🕌', nameAr: 'السيرة النبوية'),
          GameCategory(icon: '🕌', nameAr: 'قصص الأنبياء'),
          GameCategory(icon: '🤼', nameAr: 'مصيسطون'),
          GameCategory(icon: '🗺️', nameAr: 'ما حي الدولة'),
          GameCategory(icon: '🎨', nameAr: 'لون العورة'),
          GameCategory(icon: '💰', nameAr: 'حلا وحرمية'),
        ],
      ),
      SavedGame(
        id: 'game_2',
        title: 'Idid',
        timesPlayed: 2,
        categories: [
          GameCategory(icon: '🕌', nameAr: 'قصص الأنبياء'),
          GameCategory(icon: '🏴', nameAr: 'رفعة الدول'),
          GameCategory(icon: '🌍', nameAr: 'أعلام'),
          GameCategory(icon: '🕌', nameAr: 'السيرة النبوية'),
          GameCategory(icon: '🛡️', nameAr: 'جزاء عم'),
        ],
      ),
      SavedGame(
        id: 'game_3',
        title: 'عمر تست',
        timesPlayed: 2,
        categories: [
          GameCategory(icon: '🕌', nameAr: 'السيرة النبوية'),
          GameCategory(icon: '🕌', nameAr: 'قصص الأنبياء'),
          GameCategory(icon: '💰', nameAr: 'ولد كلمة أسي'),
          GameCategory(icon: '🗺️', nameAr: 'ما حي الدولة'),
          GameCategory(icon: '🎨', nameAr: 'لون العورة'),
          GameCategory(icon: '🕌', nameAr: 'السيرة النبوية'),
          GameCategory(icon: '🗺️', nameAr: 'ما حي الدولة'),
          GameCategory(icon: '💰', nameAr: 'ولد كلمة محفوظة'),
          GameCategory(icon: '🕌', nameAr: 'أعلم البحية'),
        ],
      ),
    ];
  }

  List<SavedGame> _getFilteredGames() {
    final allGames = _getMockGames();
    if (_searchQuery.isEmpty) {
      return allGames;
    }
    return allGames
        .where((game) =>
            game.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final filteredGames = _getFilteredGames();

    return Scaffold(
      appBar: AppBar(
        title: Text('ألعابي', style: AppTextStyles.largeTvBold),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: TextField(
                      controller: _searchController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'ابحث بالاسم',
                        hintStyle: AppTextStyles.mediumRegular.copyWith(
                          color: AppColors.white,
                        ),
                        filled: true,
                        fillColor: AppColors.primaryRed,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.white),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppColors.white),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      style: AppTextStyles.mediumBold.copyWith(
                        color: AppColors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                _buildActionButton(
                  context,
                  'اشتر لعبة جديدة',
                  Icons.shopping_cart,
                  const Color(0xFF2E7D32),
                  () => PurchaseDialog.show(
                    context: context,
                    onPackageSelected: (package) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم اختيار: ${package.title}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            if (filteredGames.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Text(
                    'لا توجد ألعاب تطابق البحث',
                    style: AppTextStyles.largeTvBold.copyWith(
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                alignment: WrapAlignment.center,
                children: filteredGames
                    .map((game) => _buildGameCard(context, game))
                    .toList(),
              ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: AppTextStyles.mediumBold.copyWith(fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, SavedGame game) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFFB8C00)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'عدد مرات اللعب: ${game.timesPlayed}',
                    style: AppTextStyles.mediumBold.copyWith(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  game.title,
                  style: AppTextStyles.extraLargeTvBold.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'اللعب',
                    style: AppTextStyles.largeTvBold.copyWith(
                      color: AppColors.primaryRed,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.sm),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: game.categories.length,
              itemBuilder: (context, index) {
                final category = game.categories[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB8C00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                      SizedBox(height: 4),
                      Text(
                        category.nameAr,
                        style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).ripple(() => _showGameDialog(context, game));
  }

  void _showGameDialog(BuildContext context, SavedGame game) {
    final leftTeamController = TextEditingController();
    final rightTeamController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'حدد معلومات الفرق',
                    style: AppTextStyles.largeTvBold.copyWith(
                      color: const Color(0xFF333333),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'الفريق الأول',
                          style: AppTextStyles.mediumBold,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: leftTeamController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'اسم الفريق الأول',
                            hintStyle: AppTextStyles.mediumRegular.copyWith(
                              color: const Color(0xFF999999),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'الرجاء إدخال اسم الفريق الأول',
                          style: AppTextStyles.smallRegular.copyWith(
                            color: AppColors.primaryRed,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'الفريق الثاني',
                          style: AppTextStyles.mediumBold,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: rightTeamController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'اسم الفريق الثاني',
                            hintStyle: AppTextStyles.mediumRegular.copyWith(
                              color: const Color(0xFF999999),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'الرجاء إدخال اسم الفريق الثاني',
                          style: AppTextStyles.smallRegular.copyWith(
                            color: AppColors.primaryRed,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'كل فريق يختار 3 وسائل مساعدة',
                style: AppTextStyles.mediumBold.copyWith(
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLifelineRow(),
                  _buildLifelineRow(),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'ابدأ اللعب',
                  style: AppTextStyles.largeTvBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifelineRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLifelineIcon(Icons.mic_none, Colors.red.shade100, Colors.red),
        SizedBox(width: 8),
        _buildLifelineIcon(
            Icons.av_timer_outlined, Colors.orange.shade100, Colors.orange),
        SizedBox(width: 8),
        _buildLifelineIcon(
            Icons.phone_outlined, Colors.green.shade100, Colors.green),
        SizedBox(width: 8),
        _buildLifelineIcon(
            Icons.people_outline, Colors.blue.shade100, Colors.blue),
      ],
    );
  }

  Widget _buildLifelineIcon(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 2),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

extension WidgetExtension on Widget {
  Widget ripple(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: this,
    );
  }
}
