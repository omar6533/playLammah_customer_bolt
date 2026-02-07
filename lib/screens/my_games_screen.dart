import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive_helper.dart';

@RoutePage()
class MyGamesScreen extends StatelessWidget {
  const MyGamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

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
            Text(
              'ألعابي المحفوظة',
              style: AppTextStyles.largeTvBold,
            ),
            SizedBox(height: AppSpacing.md),
            _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(AppSpacing.xl),
        padding: EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.lightGray.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Column(
          children: [
            Icon(
              Icons.games_outlined,
              size: 80,
              color: AppColors.darkGray.withOpacity(0.5),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'لا توجد ألعاب محفوظة',
              style: AppTextStyles.largeTvBold.copyWith(
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'ابدأ لعبة جديدة وسيتم حفظها هنا تلقائياً',
              style: AppTextStyles.mediumRegular.copyWith(
                color: AppColors.darkGray.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
