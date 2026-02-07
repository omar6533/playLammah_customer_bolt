import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive_helper.dart';

@RoutePage()
class PurchaseGamesScreen extends StatelessWidget {
  const PurchaseGamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('شراء ألعاب', style: AppTextStyles.largeTvBold),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.md),
            Text(
              'الألعاب المتاحة للشراء',
              style: AppTextStyles.largeTvBold,
            ),
            SizedBox(height: AppSpacing.md),
            _buildComingSoon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoon(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(AppSpacing.xl),
        padding: EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryYellow, width: 2),
        ),
        child: Column(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.primaryRed,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'قريباً!',
              style: AppTextStyles.extraLargeTvBold.copyWith(
                color: AppColors.primaryRed,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'سنضيف المزيد من الألعاب قريباً',
              style: AppTextStyles.mediumRegular.copyWith(
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
