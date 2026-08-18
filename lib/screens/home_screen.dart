import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/home_cta_banner.dart';
import '../widgets/home_faq_section.dart';
import '../widgets/home_help_tools_section.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_stats_section.dart';
import '../widgets/home_steps_section.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state is Authenticated) {
      final userId = (authBloc.state as Authenticated).userId;
      context.read<UserBloc>().add(LoadUserEvent(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          AppNavbar(onLoginTap: () => context.router.push(const LoginRoute())),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeHeroSection(
                    isDesktop: isDesktop,
                    onCtaTap: () => context.router.push(const LoginRoute()),
                  ),
                  HomeStepsSection(isDesktop: isDesktop),
                  HomeCategoriesSection(
                    isDesktop: isDesktop,
                    onCategoryTap: () =>
                        context.router.push(const LoginRoute()),
                  ),
                  const HomeStatsSection(),
                  HomeHelpToolsSection(isDesktop: isDesktop),
                  HomeFaqSection(isDesktop: isDesktop),
                  HomeCtaBanner(
                    isDesktop: isDesktop,
                    onCtaTap: () => context.router.push(const RegisterRoute()),
                  ),
                  const AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
