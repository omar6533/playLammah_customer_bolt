import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../routes/app_router.dart';
import '../services/app_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_heading.dart';
import '../widgets/primary_button.dart';

enum _Status { loading, ready, working, done, error }

/// Arabic handler for the links in Firebase auth emails (set as the
/// "custom action URL" in Firebase Console → Authentication → Templates).
///
/// Verification is applied on a button press, not on page load, so mail
/// scanners that pre-open links can't burn the one-time code.
@RoutePage()
class AuthActionScreen extends StatefulWidget {
  final String mode;
  final String oobCode;

  const AuthActionScreen({
    super.key,
    @QueryParam('mode') this.mode = '',
    @QueryParam('oobCode') this.oobCode = '',
  });

  @override
  State<AuthActionScreen> createState() => _AuthActionScreenState();
}

class _AuthActionScreenState extends State<AuthActionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  _Status _status = _Status.ready;
  String _error = '';
  String _resetEmail = '';

  bool get _isReset => widget.mode == 'resetPassword';

  @override
  void initState() {
    super.initState();
    if (_isReset) {
      _status = _Status.loading;
      _checkResetCode();
    } else if (widget.mode != 'verifyEmail') {
      // recoverEmail etc. — hand over to Firebase's default handler.
      WidgetsBinding.instance.addPostFrameCallback((_) => _openDefaultHandler());
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _openDefaultHandler() {
    final uri = Uri.https('allmahgame.firebaseapp.com', '/__/auth/action',
        Uri.base.queryParameters);
    launchUrl(uri, webOnlyWindowName: '_self');
  }

  Future<void> _checkResetCode() async {
    try {
      final email = await AppService().verifyPasswordResetCode(widget.oobCode);
      if (mounted) {
        setState(() {
          _resetEmail = email;
          _status = _Status.ready;
        });
      }
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> _verifyEmail() async {
    setState(() => _status = _Status.working);
    try {
      await AppService().applyActionCode(widget.oobCode);
      if (!mounted) return;
      setState(() => _status = _Status.done);
      // Lets a signed-in session on this device continue straight away.
      context.read<AuthBloc>().add(const CheckEmailVerifiedEvent(silent: true));
    } catch (e) {
      // A second click on an already-used link: treat as success if the
      // signed-in user is in fact verified.
      if (await AppService().reloadEmailVerified().catchError((_) => false)) {
        if (mounted) setState(() => _status = _Status.done);
        return;
      }
      _fail(e);
    }
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _status = _Status.working);
    try {
      await AppService()
          .confirmPasswordReset(widget.oobCode, _passwordController.text);
      if (mounted) setState(() => _status = _Status.done);
    } catch (e) {
      _fail(e);
    }
  }

  void _fail(Object e) {
    if (!mounted) return;
    setState(() {
      _status = _Status.error;
      _error = authErrorMessage(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final cardWidth =
        isDesktop ? 480.0 : MediaQuery.of(context).size.width - 32.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
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
                        child: _buildContent(),
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
      ),
    );
  }

  Widget _buildContent() {
    if (_status == _Status.loading ||
        (!_isReset && widget.mode != 'verifyEmail')) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryRed)),
      );
    }
    if (_status == _Status.error) {
      return _message(
        icon: Icons.link_off,
        title: _isReset ? 'تعذر تغيير كلمة المرور' : 'تعذر تفعيل الحساب',
        body: _isReset
            ? '$_error\nاطلب رابط استعادة جديد من صفحة تسجيل الدخول.'
            : '$_error\nسجّل دخولك وستجد زر «إعادة إرسال رابط التفعيل».',
        action: 'تسجيل الدخول',
        onAction: () => context.router.replaceAll([const LoginRoute()]),
      );
    }
    if (_status == _Status.done) {
      return _message(
        icon: Icons.verified_outlined,
        title: _isReset ? 'تم تغيير كلمة المرور' : 'تم تفعيل حسابك 🎉',
        body: _isReset
            ? 'سجّل دخولك بكلمة المرور الجديدة.'
            : 'حياك في لمّه وتحدي! سجّل دخولك وابدأ التحدي.',
        action: _isReset ? 'تسجيل الدخول' : 'ابدأ اللعب',
        // Not SplashRoute: the action query is still in the URL and would
        // route straight back here.
        onAction: () => context.router.replaceAll(
            [_isReset ? const LoginRoute() : const HomeRoute()]),
      );
    }
    return _isReset ? _resetForm() : _verifyPrompt();
  }

  Widget _verifyPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined,
            size: 64, color: AppColors.primaryRed),
        const SizedBox(height: AppSpacing.md),
        const Center(child: AuthTitle('تفعيل حسابك')),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'اضغط على الزر لتفعيل حسابك في لمّه وتحدي.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'تفعيل الحساب',
          onPressed: _verifyEmail,
          isLoading: _status == _Status.working,
        ),
      ],
    );
  }

  Widget _resetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: AuthTitle('كلمة مرور جديدة')),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _resetEmail,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthFormField(
            label: 'كلمة المرور الجديدة *',
            hint: 'يرجى إدخال كلمة المرور',
            controller: _passwordController,
            obscureText: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
            validator: (v) => (v == null || v.length < 6)
                ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthFormField(
            label: 'تأكيد كلمة المرور *',
            hint: 'أعد إدخال كلمة المرور',
            controller: _confirmController,
            obscureText: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
            validator: (v) => v != _passwordController.text
                ? 'كلمتا المرور غير متطابقتين'
                : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'حفظ كلمة المرور',
            onPressed: _resetPassword,
            isLoading: _status == _Status.working,
          ),
        ],
      ),
    );
  }

  Widget _message({
    required IconData icon,
    required String title,
    required String body,
    required String action,
    required VoidCallback onAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 64, color: AppColors.primaryRed),
        const SizedBox(height: AppSpacing.md),
        Center(child: AuthTitle(title)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey.shade700, fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(label: action, onPressed: onAction),
      ],
    );
  }
}
