import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:trivia_game/routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppNavbar extends StatelessWidget {
  final VoidCallback? onLoginTap;
  final VoidCallback? onBackTap;

  const AppNavbar({super.key, this.onLoginTap, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    return isDesktop ? _desktop(context) : _mobile(context);
  }

  Widget _desktop(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _logo(large: true),
              const SizedBox(width: 40),
              _navLink('إبدأ اللعب'),
              const SizedBox(width: 32),
              _navLink('الباقات'),
              const SizedBox(width: 32),
              _navLink('ألعابي السابقة'),
              const SizedBox(width: 32),
              _navLink('تواصل معنا'),
              const Spacer(),
              _loginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobile(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (onBackTap != null)
              GestureDetector(
                onTap: onBackTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward,
                      color: AppColors.white, size: 20),
                ),
              )
            else
              const SizedBox(width: 40),
            const Spacer(),
            GestureDetector(
                onTap: () => context.router.replace(const HomeRoute()),
                child: _logo()),
            const Spacer(),
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child:
                  const Icon(Icons.menu, color: AppColors.primaryRed, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo({bool large = false}) {
    return Image.asset(
      'assets/images/logo_full.png',
      height: large ? 52.0 : 40.0,
      fit: BoxFit.contain,
    );
  }

  Widget _navLink(String label) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        label,
        style: AppTextStyles.mediumRegular.copyWith(
          color: AppColors.navbarDark,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _loginButton() {
    return GestureDetector(
      onTap: onLoginTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'تسجيل الدخول',
          style: AppTextStyles.mediumBold.copyWith(
            color: AppColors.white,
            fontSize: 14,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
