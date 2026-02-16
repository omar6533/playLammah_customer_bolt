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
        price: 'SAR 1',
        priceInHalalas: 100,
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

    // Capture BLoC states, router, and navigator BEFORE showing dialog
    final authState = context.read<AuthBloc>().state;
    final userState = context.read<UserBloc>().state;
    final router = context.router;
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = MediaQuery.of(context).size.height * 0.9;

            return Container(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: maxHeight,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
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
                            fontSize: 24,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.white, size: 24),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'لعبة جماعية تفاعلية يختار فيها معرفتكم و ثقافتكم',
                            style: AppTextStyles.largeTvBold.copyWith(
                              color: const Color(0xFF333333),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
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
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'و لاسترجاع الألعاب السابقة، اضغط على ( ألعابي )',
                                  style: AppTextStyles.mediumRegular.copyWith(
                                    color: const Color(0xFF666666),
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ...packageList.map((package) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm),
                                child: _buildPackageButton(
                                  package: package,
                                  onTap: () async {
                                    print(
                                        '🛒 Package selected: ${package.title}');
                                    print('🛒 Calling _handlePackagePurchase');
                                    await _handlePackagePurchase(
                                      context: context,
                                      dialogContext: dialogContext,
                                      package: package,
                                      authState: authState,
                                      userState: userState,
                                      router: router,
                                      navigator: navigator,
                                      moyasarApiKey: moyasarApiKey,
                                      callbackUrl: callbackUrl,
                                      successUrl: successUrl,
                                    );
                                    print('🛒 Purchase handling completed');
                                    onPackageSelected?.call(package);
                                  },
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Future<void> _handlePackagePurchase({
    required BuildContext context,
    required BuildContext dialogContext,
    required GamePackage package,
    required AuthState authState,
    required UserState userState,
    required StackRouter router,
    required NavigatorState navigator,
    String? moyasarApiKey,
    String? callbackUrl,
    String? successUrl,
  }) async {
    print('💳 _handlePackagePurchase started');

    // Close purchase dialog first
    print('💳 Closing purchase dialog');
    Navigator.of(dialogContext).pop();

    if (moyasarApiKey == null) {
      print('💳 API key is null');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مفتاح API غير متوفر')),
        );
      }
      return;
    }

    print('💳 API key available: ${moyasarApiKey.substring(0, 10)}...');

    print('💳 Auth state: ${authState.runtimeType}');
    print('💳 User state: ${userState.runtimeType}');

    if (authState is! Authenticated || userState is! UserLoaded) {
      print('💳 User not authenticated or profile not loaded');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في بيانات المستخدم')),
        );
      }
      return;
    }

    final userId = authState.userId;
    final userProfile = userState.userProfile;

    print('💳 User ID: $userId');
    print('💳 User email: ${userProfile.email}');

    try {
      // Show loading dialog
      if (!context.mounted) {
        print('💳 Context not mounted before showing loading dialog');
        return;
      }

      print('💳 Showing loading dialog');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );

      print('💳 Creating payment service');
      final paymentService = PaymentService(apiKey: moyasarApiKey);

      print(
          '💳 Calling createInvoice API with amount: ${package.priceInHalalas}');
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

      print('💳 API response received: ${response.url}');

      // Close loading dialog
      print('💳 Closing loading dialog');
      navigator.pop();

      // Navigate to payment webview
      print('💳 Navigating to payment webview');
      router.push(
        PaymentWebviewRoute(
          paymentUrl: response.url,
          successUrlPattern: successUrl ?? 'payment-success',
          callbackUrlPattern: callbackUrl ?? 'payment-callback',
          gamesCount: package.gameCount,
        ),
      );
    } catch (e, stackTrace) {
      print('💳 Error occurred: $e');
      print('💳 Stack trace: $stackTrace');
      navigator.pop();
      if (context.mounted) {
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
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
                fontSize: 20,
              ),
            ),
            Text(
              package.title,
              style: AppTextStyles.extraLargeTvBold.copyWith(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
