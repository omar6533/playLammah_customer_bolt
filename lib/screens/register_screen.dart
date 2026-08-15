import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_text_link.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_heading.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء الموافقة على الشروط والأحكام'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.read<AuthBloc>().add(
            RegisterEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
              mobile: _mobileController.text.trim(),
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
                    _buildCard(context, isDesktop),
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

  Widget _buildCard(BuildContext context, bool isDesktop) {
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
                  onTap: () {},
                  trailingIcon: Icons.arrow_forward,
                ),
                const SizedBox(height: 12),
                const AuthTitle('إنشاء حساب جديد'),
                const SizedBox(height: 4),
                const AuthSubtitle('وصف'),
                const SizedBox(height: AppSpacing.xl),

                // Name
                AuthFormField(
                  label: 'الاسم *',
                  hint: 'يرجى إدخال الاسم',
                  controller: _nameController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'الرجاء إدخال الاسم' : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Mobile + Email — side by side on desktop, stacked on mobile
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AuthFormField(
                          label: 'رقم الجوال *',
                          hint: 'xxxxxxxx',
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          prefixText: '+966  ',
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'الرجاء إدخال رقم الجوال'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AuthFormField(
                          label: 'البريد الإلكتروني *',
                          hint: 'يرجى إدخال البريد الإلكتروني',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            if (!v.contains('@')) {
                              return 'الرجاء إدخال بريد إلكتروني صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  )
                else ...[
                  AuthFormField(
                    label: 'رقم الجوال *',
                    hint: 'xxxxxxxx',
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    prefixText: '+966  ',
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'الرجاء إدخال رقم الجوال'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthFormField(
                    label: 'البريد الإلكتروني *',
                    hint: 'يرجى إدخال البريد الإلكتروني',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      }
                      if (!v.contains('@')) {
                        return 'الرجاء إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // Password
                AuthFormField(
                  label: 'كلمة المرور *',
                  hint: 'يرجى إدخال كلمة المرور',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (v.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Confirm password
                AuthFormField(
                  label: 'تأكيد كلمة المرور *',
                  hint: 'يرجى إدخال كلمة المرور',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onToggleObscure: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'الرجاء تأكيد كلمة المرور';
                    }
                    if (v != _passwordController.text) {
                      return 'كلمة المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Terms checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (v) =>
                          setState(() => _acceptedTerms = v ?? false),
                      activeColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          style: AppTextStyles.mediumRegular.copyWith(
                            color: AppColors.darkGray,
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(text: 'أوافق على '),
                            TextSpan(
                              text: 'الشروط والأحكام',
                              style: AppTextStyles.mediumRegular.copyWith(
                                color: AppColors.primaryRed,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Bottom row: login link | register button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppTextLink(
                          'تسجيل الدخول',
                          onTap: () => context.router.pop(),
                        ),
                        GestureDetector(
                          onTap: state is AuthLoading ? null : _handleRegister,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: state is AuthLoading
                                  ? AppColors.customGray
                                  : AppColors.primaryRed,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: state is AuthLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    '← إنشاء حساب',
                                    style: AppTextStyles.bodyBold.copyWith(
                                      color: AppColors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
