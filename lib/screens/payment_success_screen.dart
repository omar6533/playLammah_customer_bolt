import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../routes/app_router.dart';

@RoutePage()
class PaymentSuccessScreen extends StatelessWidget {
  final String? invoiceId;
  final int? gamesCount;

  const PaymentSuccessScreen({
    Key? key,
    @QueryParam('id') this.invoiceId,
    @QueryParam('games') this.gamesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'تمت العملية بنجاح!',
                    style: AppTextStyles.extraLargeTvBold.copyWith(
                      color: AppColors.white,
                      fontSize: 48,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'تم إضافة ${gamesCount ?? 0} ألعاب إلى حسابك',
                    style: AppTextStyles.largeTv.copyWith(
                      color: AppColors.white,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (invoiceId != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'رقم الفاتورة: $invoiceId',
                      style: AppTextStyles.mediumRegular.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxxl),
                  ElevatedButton(
                    onPressed: () {
                      context.router.replace(const LandingRoute());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxxl,
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'العودة للصفحة الرئيسية',
                      style: AppTextStyles.largeTvBold.copyWith(
                        color: AppColors.primaryRed,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: () {
                      context.router.push(const CategorySelectionRoute());
                    },
                    child: Text(
                      'ابدأ لعبة جديدة',
                      style: AppTextStyles.largeTv.copyWith(
                        color: AppColors.white,
                        fontSize: 20,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
