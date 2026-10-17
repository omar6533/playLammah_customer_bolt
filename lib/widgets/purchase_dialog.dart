import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../services/payment_service.dart';
import '../services/store_service.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_state.dart';
import '../routes/app_router.dart';
import 'custom_error_dialog.dart';

class PurchaseDialog {
  /// Opens the packages dialog with the app's payment configuration.
  static void showStore(BuildContext context) => show(
        context: context,
        moyasarApiKey: AppConfig.moyasarApiKey,
        callbackUrl: AppConfig.paymentCallbackUrl,
        successUrl: AppConfig.paymentSuccessUrl,
      );

  static void show({
    required BuildContext context,
    Function(GamePackage)? onPackageSelected,
    String? moyasarApiKey,
    String? callbackUrl,
    String? successUrl,
  }) {
    // Capture BLoC states and router BEFORE showing dialog
    final authState = context.read<AuthBloc>().state;
    final userState = context.read<UserBloc>().state;
    final router = context.router;

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
                    child: _PurchaseDialogBody(
                      onPurchase: (package, promo) async {
                        final success = await _handlePackagePurchase(
                          dialogContext: dialogContext,
                          package: package,
                          promo: promo,
                          authState: authState,
                          userState: userState,
                          router: router,
                          moyasarApiKey: moyasarApiKey,
                          callbackUrl: callbackUrl,
                          successUrl: successUrl,
                        );
                        if (success && context.mounted) {
                          onPackageSelected?.call(package);
                        }
                      },
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

  static Future<bool> _handlePackagePurchase({
    required BuildContext dialogContext,
    required GamePackage package,
    required PromoCode? promo,
    required AuthState authState,
    required UserState userState,
    required StackRouter router,
    String? moyasarApiKey,
    String? callbackUrl,
    String? successUrl,
  }) async {
    if (moyasarApiKey == null) {
      if (dialogContext.mounted) {
        CustomErrorDialog.show(
          context: dialogContext,
          title: 'خطأ في الدفع',
          message: 'مفتاح API غير متوفر',
        );
      }
      return false;
    }

    if (authState is! Authenticated || userState is! UserLoaded) {
      if (dialogContext.mounted) {
        CustomErrorDialog.show(
          context: dialogContext,
          title: 'خطأ في البيانات',
          message: 'خطأ في بيانات المستخدم',
        );
      }
      return false;
    }

    final userId = authState.userId;
    final userProfile = userState.userProfile;

    try {
      if (!dialogContext.mounted) return false;

      showDialog(
        context: dialogContext,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );

      // Re-check the code right before charging in case it was disabled or
      // used up while the dialog was open.
      final activePromo = promo == null
          ? null
          : await StoreService().validatePromoCode(promo.code);
      final amount =
          package.discountedHalalas(activePromo?.discountPercent ?? 0);

      final paymentService = PaymentService(apiKey: moyasarApiKey);
      final response = await paymentService.createInvoice(
        amount: amount,
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
          'price': GamePackage.formatSar(amount),
          'original_price': package.price,
          if (activePromo != null) 'promo_code': activePromo.code,
          if (activePromo != null)
            'discount_percent': activePromo.discountPercent.toString(),
        },
      );

      // Pop loading dialog, then the purchase dialog
      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
      if (dialogContext.mounted) Navigator.of(dialogContext).pop();

      router.push(
        PaymentWebviewRoute(
          paymentUrl: response.url,
          successUrlPattern: successUrl ?? 'payment-success',
          callbackUrlPattern: callbackUrl ?? 'payment-callback',
          gamesCount: package.gameCount,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('💳 Purchase error: $e');
      if (dialogContext.mounted) Navigator.of(dialogContext).pop();

      if (dialogContext.mounted) {
        CustomErrorDialog.show(
          context: dialogContext,
          title: 'عذراً، حدث خطأ',
          message: e is PromoCodeException
              ? e.message
              : 'لم نتمكن من إتمام عملية الدفع، يرجى المحاولة مرة أخرى لاحقاً',
        );
      }
      return false;
    }
  }
}

class _PurchaseDialogBody extends StatefulWidget {
  final Future<void> Function(GamePackage package, PromoCode? promo) onPurchase;

  const _PurchaseDialogBody({required this.onPurchase});

  @override
  State<_PurchaseDialogBody> createState() => _PurchaseDialogBodyState();
}

class _PurchaseDialogBodyState extends State<_PurchaseDialogBody> {
  final _store = StoreService();
  final _promoController = TextEditingController();
  late Future<List<GamePackage>> _packages = _store.getActivePackages();
  PromoCode? _promo;
  String? _promoError;
  bool _checkingPromo = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _checkingPromo = true;
      _promoError = null;
    });
    try {
      final promo = await _store.validatePromoCode(_promoController.text);
      if (mounted) setState(() => _promo = promo);
    } on PromoCodeException catch (e) {
      if (mounted) setState(() => _promoError = e.message);
    } catch (_) {
      if (mounted) setState(() => _promoError = 'تعذر التحقق من الرمز، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _checkingPromo = false);
    }
  }

  void _removePromo() {
    setState(() {
      _promo = null;
      _promoError = null;
      _promoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          const SizedBox(height: AppSpacing.md),
          _buildPromoField(),
          const SizedBox(height: AppSpacing.lg),
          FutureBuilder<List<GamePackage>>(
            future: _packages,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                );
              }
              if (snap.hasError) {
                return _buildMessage(
                  'تعذر تحميل الباقات',
                  action: TextButton(
                    onPressed: () => setState(() => _packages = _store.getActivePackages()),
                    child: const Text('إعادة المحاولة'),
                  ),
                );
              }
              final packages = snap.data ?? [];
              if (packages.isEmpty) {
                return _buildMessage('لا توجد باقات متاحة حالياً');
              }
              return Column(
                children: packages
                    .map((package) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _buildPackageButton(package),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Text(text,
              style: AppTextStyles.mediumRegular.copyWith(color: const Color(0xFF666666)),
              textAlign: TextAlign.center),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildPromoField() {
    if (_promo != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4CAF50)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تم تطبيق رمز ${_promo!.code} — خصم ${_promo!.discountPercent}%',
                style: AppTextStyles.mediumRegular.copyWith(
                  color: const Color(0xFF2E7D32),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: _removePromo,
              child: const Text('إزالة', style: TextStyle(color: Color(0xFF2E7D32))),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _applyPromo(),
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'رمز الخصم',
                  hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
                  prefixIcon: const Icon(Icons.local_offer_outlined, color: AppColors.primaryRed),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryRed),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _checkingPromo ? null : _applyPromo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _checkingPromo
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : const Text('تطبيق'),
              ),
            ),
          ],
        ),
        if (_promoError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _promoError!,
              style: AppTextStyles.mediumRegular.copyWith(color: AppColors.primaryRed, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildPackageButton(GamePackage package) {
    final discount = _promo?.discountPercent ?? 0;
    final finalPrice = GamePackage.formatSar(package.discountedHalalas(discount));
    final textStyle = AppTextStyles.extraLargeTvBold.copyWith(
      color: AppColors.white,
      fontSize: 20,
    );

    return InkWell(
      onTap: () => widget.onPurchase(package, _promo),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(finalPrice, style: textStyle),
                if (discount > 0)
                  Text(
                    package.price,
                    style: textStyle.copyWith(
                      fontSize: 13,
                      color: AppColors.white.withOpacity(0.8),
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.white,
                    ),
                  ),
              ],
            ),
            Text(package.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
