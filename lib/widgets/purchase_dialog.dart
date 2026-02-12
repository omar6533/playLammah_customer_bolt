import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../services/payment_service.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_state.dart';
import '../routes/app_router.dart';

class GamePackage {
  final String id;
  final String title;
  final String price;
  final int priceInHalalas;
  final Color color;
  final int gameCount;

  GamePackage({
    required this.id,
    required this.title,
    required this.price,
    required this.priceInHalalas,
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
        priceInHalalas: 23000,
        color: AppColors.primaryRed,
        gameCount: 10,
      ),
      GamePackage(
        id: 'pkg_5',
        title: '5 العاب',
        price: 'SAR 122',
        priceInHalalas: 12200,
        color: const Color(0xFF9C27B0),
        gameCount: 5,
      ),
      GamePackage(
        id: 'pkg_2',
        title: '2 لعاب',
        price: 'SAR 55',
        priceInHalalas: 5500,
        color: const Color(0xFF4CAF50),
        gameCount: 2,
      ),
      GamePackage(
        id: 'pkg_1',
        title: '1 لعاب',
        price: 'SAR 30',
        priceInHalalas: 3000,
        color: const Color(0xFFE91E63),
        gameCount: 1,
      ),
    ];
  }

  static void show({
    required BuildContext context,
    List<GamePackage>? packages,
    Function(GamePackage)? onPackageSelected,
    String? moyasarApiKey,
    String? callbackUrl,
    String? successUrl,
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
                            onTap: () async {
                              Navigator.of(dialogContext).pop();
                              await _handlePackagePurchase(
                                context: context,
                                package: package,
                                moyasarApiKey: moyasarApiKey,
                                callbackUrl: callbackUrl,
                                successUrl: successUrl,
                              );
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

  static Future<void> _handlePackagePurchase({
    required BuildContext context,
    required GamePackage package,
    String? moyasarApiKey,
    String? callbackUrl,
    String? successUrl,
  }) async {
    if (moyasarApiKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مفتاح API غير متوفر')),
      );
      return;
    }

    try {
      final navigator = Navigator.of(context);
      final router = context.router;
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );

      final authState = context.read<AuthBloc>().state;
      final userState = context.read<UserBloc>().state;

      if (authState is! Authenticated || userState is! UserLoaded) {
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('خطأ في بيانات المستخدم')),
        );
        return;
      }

      final userId = authState.userId;
      final userProfile = userState.userProfile;

      final paymentService = PaymentService(apiKey: moyasarApiKey);

      final response = await paymentService.createInvoice(
        amount: package.priceInHalalas,
        description: 'شراء ${package.title} - allmahgame',
        callbackUrl: callbackUrl ?? 'https://allmahgame.com/payment-callback',
        successUrl: successUrl ?? 'https://allmahgame.com/payment-success',
        metadata: {
          'user_id': userId,
          'user_email': userProfile.email,
          'user_name': userProfile.name,
          'user_mobile': userProfile.mobile,
          'package_id': package.id,
          'package_title': package.title,
          'games_count': package.gameCount.toString(),
          'price': package.price,
        },
      );

      navigator.pop();

      router.push(
        PaymentWebviewRoute(
          paymentUrl: response.url,
          successUrlPattern: successUrl ?? 'payment-success',
          callbackUrlPattern: callbackUrl ?? 'payment-callback',
          gamesCount: package.gameCount,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إنشاء الدفع: $e')),
        );
      }
    }
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
