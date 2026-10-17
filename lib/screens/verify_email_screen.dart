import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../routes/app_router.dart';
import '../services/app_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_text_link.dart';
import '../widgets/auth_heading.dart';
import '../widgets/primary_button.dart';

@RoutePage()
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  static const _resendCooldown = 60;
  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldown = 0;
  bool _checking = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Picks up the verification automatically once the link is clicked.
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      context.read<AuthBloc>().add(const CheckEmailVerifiedEvent(silent: true));
    });
    final state = context.read<AuthBloc>().state;
    if (state is EmailVerificationRequired && state.emailSent) _startCooldown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AuthBloc>().add(const CheckEmailVerifiedEvent(silent: true));
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = _resendCooldown);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textDirection: TextDirection.rtl),
      backgroundColor: error ? AppColors.error : AppColors.success,
    ));
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await AppService().sendEmailVerification();
      print('📧 Verification email sent');
      _snack('تم إرسال رابط التفعيل مرة أخرى');
      _startCooldown();
    } catch (e) {
      print('⚠️ Resend verification failed: $e');
      _snack(authErrorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _check() {
    setState(() => _checking = true);
    context.read<AuthBloc>().add(const CheckEmailVerifiedEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final cardWidth = isDesktop ? 480.0 : MediaQuery.of(context).size.width - 32.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            _snack('تم تفعيل حسابك بنجاح 🎉');
            context.router.replaceAll([const HomeRoute()]);
          } else if (state is Unauthenticated) {
            context.router.replaceAll([const HomeRoute()]);
          } else if (state is EmailVerificationRequired && _checking) {
            setState(() => _checking = false);
            _snack('لم يتم تفعيل البريد بعد، اضغط على الرابط المرسل إلى بريدك', error: true);
          }
        },
        builder: (context, state) {
          final email = state is EmailVerificationRequired ? state.email : '';
          final justSent = state is EmailVerificationRequired && state.emailSent;
          return Column(
            children: [
              const AppNavbar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      Center(
                        child: Container(
                          width: cardWidth,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Icon(Icons.mark_email_unread_outlined,
                                    size: 64, color: AppColors.primaryRed),
                                const SizedBox(height: AppSpacing.md),
                                const Center(child: AuthTitle('فعّل بريدك الإلكتروني')),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  justSent ? 'أرسلنا رابط التفعيل إلى' : 'حسابك غير مفعّل بعد. فعّل البريد',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColors.navbarDark,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  justSent
                                      ? 'افتح البريد واضغط على الرابط لتفعيل حسابك. إذا ما وصلك، تأكد من مجلد الرسائل غير المرغوب فيها (Spam).'
                                      : 'اضغط على «إعادة إرسال رابط التفعيل» وبعدها افتح بريدك واضغط على الرابط.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.6),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                PrimaryButton(
                                  label: 'فعّلت بريدي',
                                  onPressed: _check,
                                  isLoading: _checking,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Center(
                                  child: _cooldown > 0
                                      ? Text(
                                          'يمكنك إعادة الإرسال بعد $_cooldown ثانية',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                        )
                                      : AppTextLink(
                                          _resending ? 'جارٍ الإرسال...' : 'إعادة إرسال رابط التفعيل',
                                          onTap: _resending ? () {} : _resend,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Center(
                                  child: AppTextLink(
                                    'تسجيل الخروج',
                                    onTap: () => context.read<AuthBloc>().add(const LogoutEvent()),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
