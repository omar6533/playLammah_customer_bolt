import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_text_link.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_heading.dart';
import '../widgets/primary_button.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const AppDrawer(),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.router.replace(const LandingRoute());
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            const AppNavbar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    _buildLoginCard(context, isDesktop),
                    const SizedBox(height: AppSpacing.xxl),
                    const AppFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool isDesktop) {
    final cardWidth =
        isDesktop ? 480.0 : MediaQuery.of(context).size.width - 32.0;

    return Center(
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
        child: Form(
          key: _formKey,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextLink(
                  'العودة إلى الرئيسية',
                  onTap: () => context.router.replace(const HomeRoute()),
                  trailingIcon: Icons.arrow_forward,
                ),
                const SizedBox(height: 12),
                const AuthTitle('تسجيل الدخول'),
                const SizedBox(height: 4),
                const AuthSubtitle('وصف'),
                const SizedBox(height: AppSpacing.xl),
                AuthFormField(
                  label: 'البريد الإلكتروني *',
                  hint: 'يرجى إدخال البريد الإلكتروني',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthFormField(
                  label: 'كلمة المرور *',
                  hint: 'يرجى إدخال كلمة المرور',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppTextLink(
                    'نسيت كلمة المرور',
                    onTap: () {},
                    underline: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      label: '← تسجيل الدخول',
                      onPressed: _handleLogin,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: AppTextLink(
                    'إنشاء حساب جديد',
                    onTap: () => context.router.push(const RegisterRoute()),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
