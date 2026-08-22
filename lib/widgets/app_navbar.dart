import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/routes/app_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppNavbar extends StatelessWidget {
  final VoidCallback? onLoginTap;
  final VoidCallback? onBackTap;

  const AppNavbar({super.key, this.onLoginTap, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 960;
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
              _navLink('إبدأ اللعب', onTap: () {
                final state = context.read<AuthBloc>().state;
                if (state is Authenticated) {
                  context.router.push(const CategorySelectionRoute());
                } else {
                  context.router.push(const LoginRoute());
                }
              }),
              const SizedBox(width: 32),
              _navLink('الباقات'),
              const SizedBox(width: 32),
              _navLink('ألعابي السابقة', onTap: () {
                final state = context.read<AuthBloc>().state;
                if (state is Authenticated) {
                  context.router.push(const MyGamesRoute());
                } else {
                  context.router.push(const LoginRoute());
                }
              }),
              const SizedBox(width: 32),
              _navLink('تواصل معنا'),
              const Spacer(),
              _authWidget(context),
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

  Widget _navLink(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
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

  Widget _authWidget(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          return BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              if (userState is UserLoaded) {
                return _profileWidget(context, userState);
              }
              return const SizedBox.shrink();
            },
          );
        }
        return _loginButton();
      },
    );
  }

  Widget _profileWidget(BuildContext context, UserLoaded userState) {
    final balance = userState.userProfile.trialsRemaining +
        userState.userProfile.availableGames;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "إنشاء لعبة" quick-action button
        GestureDetector(
          onTap: () => context.router.push(const CategorySelectionRoute()),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'إنشاء لعبة',
              style: AppTextStyles.mediumBold.copyWith(
                color: AppColors.white,
                fontSize: 14,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Profile card
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    userState.userProfile.name,
                    style: AppTextStyles.mediumBold.copyWith(
                      color: AppColors.navbarDark,
                      fontSize: 14,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'رصيد ألعابك : $balance',
                    style: AppTextStyles.mediumRegular.copyWith(
                      color: const Color(0xFF888888),
                      fontSize: 12,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.primaryRed, width: 1.5),
                ),
                child: const Icon(Icons.person,
                    color: AppColors.primaryRed, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Logout icon button
        GestureDetector(
          onTap: () {
            context.read<AuthBloc>().add(const LogoutEvent());
            context.router.replace(const HomeRoute());
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.logout,
                color: Color(0xFF888888), size: 18),
          ),
        ),
      ],
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
