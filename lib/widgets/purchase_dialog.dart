import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class GamePackage {
  final String id;
  final String title;
  final String price;
  final Color color;
  final int gameCount;

  GamePackage({
    required this.id,
    required this.title,
    required this.price,
    required this.color,
    required this.gameCount,
  });
}

class PurchaseDialog {
  static List<GamePackage> getDefaultPackages() {
    return [
      GamePackage(
        id: 'pkg_10',
        title: '10 ألعاب',
        price: 'SAR 230',
        color: AppColors.primaryRed,
        gameCount: 10,
      ),
      GamePackage(
        id: 'pkg_5',
        title: '5 العاب',
        price: 'SAR 122',
        color: const Color(0xFF9C27B0),
        gameCount: 5,
      ),
      GamePackage(
        id: 'pkg_2',
        title: '2 لعاب',
        price: 'SAR 55',
        color: const Color(0xFF4CAF50),
        gameCount: 2,
      ),
      GamePackage(
        id: 'pkg_1',
        title: '1 لعاب',
        price: 'SAR 30',
        color: const Color(0xFFE91E63),
        gameCount: 1,
      ),
    ];
  }

  static void show({
    required BuildContext context,
    List<GamePackage>? packages,
    Function(GamePackage)? onPackageSelected,
  }) {
    final packageList = packages ?? getDefaultPackages();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(AppSpacing.lg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Text(
                      'إنشاء لعبة',
                      style: AppTextStyles.extraLargeTvBold.copyWith(
                        color: AppColors.white,
                        fontSize: 28,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.white, size: 28),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Text(
                      'لعبة جماعية تفاعلية يختار فيها معرفتكم و ثقافتكم',
                      style: AppTextStyles.largeTvBold.copyWith(
                        color: const Color(0xFF333333),
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'لإنشاء لعبة جديدة اضغط على ( لعبة جديدة )',
                            style: AppTextStyles.mediumRegular.copyWith(
                              color: const Color(0xFF666666),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'و لاسترجاع الألعاب السابقة، اضغط على ( ألعابي )',
                            style: AppTextStyles.mediumRegular.copyWith(
                              color: const Color(0xFF666666),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    ...packageList.map((package) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildPackageButton(
                            package: package,
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              onPackageSelected?.call(package);
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPackageButton({
    required GamePackage package,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: package.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: package.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              package.price,
              style: AppTextStyles.extraLargeTvBold.copyWith(
                color: AppColors.white,
                fontSize: 24,
              ),
            ),
            Text(
              package.title,
              style: AppTextStyles.extraLargeTvBold.copyWith(
                color: AppColors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
