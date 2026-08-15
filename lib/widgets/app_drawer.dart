import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:trivia_game/routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onLoginTap;

  const AppDrawer({super.key, this.onLoginTap});

  static const _links = [
    'إبدأ اللعب',
    'الباقات',
    'ألعابي السابقة',
    'تواصل معنا',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: AppColors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo_full.png',
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close,
                          color: AppColors.navbarDark, size: 24),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 8),
              // Nav links
              ..._links.map((label) => _drawerLink(context, label)),
              const Spacer(),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              // Login button
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.router.push(const LoginRoute());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'تسجيل الدخول',
                      style: AppTextStyles.mediumBold.copyWith(
                        color: AppColors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerLink(BuildContext context, String label) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          label,
          style: AppTextStyles.mediumRegular.copyWith(
            color: AppColors.navbarDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
