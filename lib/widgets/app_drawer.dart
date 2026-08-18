import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/routes/app_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/user/user_state.dart';
import '../bloc/user/user_bloc.dart';
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
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isAuthenticated = authState is Authenticated;
              return BlocBuilder<UserBloc, UserState>(
                builder: (context, userState) {
                  final userLoaded =
                      userState is UserLoaded ? userState : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
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
                      // Profile section (authenticated only)
                      if (isAuthenticated && userLoaded != null) ...[
                        _profileSection(userLoaded),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ],
                      const SizedBox(height: 8),
                      // Nav links
                      if (isAuthenticated) ...[
                        _drawerActionLink(
                          context,
                          Icons.add_circle_outline,
                          'إنشاء لعبة',
                          () => context.router
                              .push(const CategorySelectionRoute()),
                        ),
                        _drawerActionLink(
                          context,
                          Icons.emoji_events_outlined,
                          'ألعابي',
                          () => context.router.push(const MyGamesRoute()),
                        ),
                        _drawerActionLink(
                          context,
                          Icons.sports_esports_outlined,
                          'لوحة الألعاب',
                          () => context.router.push(const LandingRoute()),
                        ),
                        _drawerLink(context, 'تواصل معنا'),
                      ] else ...[
                        ..._links.map((label) => _drawerLink(context, label)),
                      ],
                      const Spacer(),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: isAuthenticated
                            ? _logoutButton(context)
                            : _loginButton(context),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _profileSection(UserLoaded userState) {
    final balance = userState.userProfile.trialsRemaining +
        userState.userProfile.availableGames;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryRed, width: 1.5),
            ),
            child: const Icon(Icons.person,
                color: AppColors.primaryRed, size: 26),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userState.userProfile.name,
                style: AppTextStyles.mediumBold.copyWith(
                  color: AppColors.navbarDark,
                  fontSize: 15,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 2),
              Text(
                'رصيد ألعابك : $balance',
                style: AppTextStyles.mediumRegular.copyWith(
                  color: const Color(0xFF888888),
                  fontSize: 13,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        context.read<AuthBloc>().add(const LogoutEvent());
        context.router.replace(const HomeRoute());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Color(0xFF888888), size: 18),
            const SizedBox(width: 8),
            Text(
              'الخروج',
              style: AppTextStyles.mediumBold.copyWith(
                color: const Color(0xFF888888),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return GestureDetector(
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
    );
  }

  Widget _drawerActionLink(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryRed, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.mediumRegular.copyWith(
                color: AppColors.navbarDark,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
