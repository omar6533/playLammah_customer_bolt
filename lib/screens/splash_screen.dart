import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../widgets/lammh_brand_header.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          context.router.replace(const LandingRoute());
        } else {
          context.router.replace(const LoginRoute());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: const Center(
          child: LammhBrandHeader(
            logoSize: 120,
            logoColor: AppColors.white,
            showTagline: true,
            showLoadingIndicator: true,
          ),
        ),
      ),
    );
  }
}
