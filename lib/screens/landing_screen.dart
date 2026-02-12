import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/bloc/auth/auth_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/purchase_dialog.dart';
import '../widgets/lammh_brand_header.dart';
import '../config/app_config.dart';

@RoutePage()
class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              if (userState is UserLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                );
              }

              if (userState is UserLoaded) {
                return SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTopNavigation(context, userState),
                        const SizedBox(height: AppSpacing.xxxl),
                        _buildHeroSection(),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildInstructionsBox(),
                        const SizedBox(height: AppSpacing.xxxl),
                        _buildActionGrid(context, userState),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                );
              }

              return const Center(
                child: Text(
                  'خطأ في تحميل البيانات',
                  style: TextStyle(color: AppColors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation(BuildContext context, UserLoaded userState) {
    final hasTrials = userState.userProfile.trialsRemaining > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    userState.userProfile.name,
                    style: AppTextStyles.mediumBold.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildNavButton(
                      'إنشاء لعبة\nجديدة',
                      Icons.add,
                      const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                      ),
                      () => context.router.push(const CategorySelectionRoute()),
                    ),
                    if (hasTrials)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${userState.userProfile.trialsRemaining}',
                            style: AppTextStyles.mediumBold.copyWith(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    _showMobileMenu(context, userState);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                userState.userProfile.name,
                style: AppTextStyles.mediumBold.copyWith(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              _buildNavButton(
                'إنشاء لعبة\nجديدة',
                Icons.add,
                const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                ),
                () => context.router.push(const CategorySelectionRoute()),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildNavButton(
                    'اشتر لعبة\nجديدة',
                    Icons.shopping_cart,
                    const LinearGradient(
                      colors: [Color(0xFFF7931E), Color(0xFFFDC830)],
                    ),
                    () => PurchaseDialog.show(
                      context: context,
                      moyasarApiKey: AppConfig.moyasarApiKey,
                      callbackUrl: AppConfig.paymentCallbackUrl,
                      successUrl: AppConfig.paymentSuccessUrl,
                      onPackageSelected: (package) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم اختيار: ${package.title}'),
                          ),
                        );
                      },
                    ),
                  ),
                  if (hasTrials)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${userState.userProfile.trialsRemaining}',
                          style: AppTextStyles.mediumBold.copyWith(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              _buildNavButton(
                'My\nGames',
                Icons.emoji_events,
                const LinearGradient(
                  colors: [Color(0xFFFDC830), Color(0xFFF9D423)],
                ),
                () => context.router.push(const MyGamesRoute()),
              ),
              _buildNavButton(
                'تواصل\nمعنا',
                Icons.phone,
                null,
                () {},
                backgroundColor: AppColors.white.withOpacity(0.2),
                textColor: AppColors.white,
              ),
              _buildNavButton(
                'الخروج',
                Icons.logout,
                null,
                () {
                  context.read<AuthBloc>().add(const LogoutEvent());
                  context.router.replace(const LoginRoute());
                },
                backgroundColor: AppColors.white,
                textColor: AppColors.primaryRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context, UserLoaded userState) {
    final hasTrials = userState.userProfile.trialsRemaining > 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF7931E), Color(0xFFFDC830)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.shopping_cart, color: AppColors.white),
                ),
                title: const Text('اشتر لعبة جديدة'),
                trailing: hasTrials
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${userState.userProfile.trialsRemaining}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  PurchaseDialog.show(
                    context: context,
                    moyasarApiKey: AppConfig.moyasarApiKey,
                    callbackUrl: AppConfig.paymentCallbackUrl,
                    successUrl: AppConfig.paymentSuccessUrl,
                    onPackageSelected: (package) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم اختيار: ${package.title}'),
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFDC830), Color(0xFFF9D423)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emoji_events, color: AppColors.white),
                ),
                title: const Text('My Games'),
                onTap: () {
                  Navigator.pop(context);
                  context.router.push(const MyGamesRoute());
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.phone, color: AppColors.primaryRed),
                ),
                title: const Text('تواصل معنا'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: AppColors.white),
                ),
                title: const Text('الخروج'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(const LogoutEvent());
                  context.router.replace(const LoginRoute());
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    String label,
    IconData icon,
    Gradient? gradient,
    VoidCallback onTap, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor ?? AppColors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.mediumBold.copyWith(
                color: textColor ?? AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        const LammhBrandHeader(
          logoSize: 100,
          logoColor: AppColors.white,
          showTagline: true,
          titleFontSize: 32,
          taglineFontSize: 18,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'إنشاع لعبة',
          style: AppTextStyles.extraLargeTvBold.copyWith(
            color: AppColors.white,
            fontSize: 64,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'لعبة جماعية تفاعلية نختبر فيها معرفتكم و ثقافتكم',
          style: AppTextStyles.largeTv.copyWith(
            color: AppColors.white,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInstructionsBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'لإنشاء لعبة جديدة اضغط على ( لعبة جديدة )',
            style: AppTextStyles.largeTv.copyWith(
              color: AppColors.white,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'و لستعراج الألعاب السابقة، اضغط على ( ألعابي )',
            style: AppTextStyles.largeTv.copyWith(
              color: AppColors.white,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, UserLoaded userState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        alignment: WrapAlignment.center,
        children: [
          _buildModernActionCard(
            'سين جيم',
            Icons.play_arrow,
            const Color(0xFF2E7BF6),
            () {
              if (userState.userProfile.trialsRemaining > 0) {
                context.router.push(const CategorySelectionRoute());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لا توجد محاولات متبقية. الرجاء شراء المزيد'),
                  ),
                );
              }
            },
          ),
          _buildModernActionCard(
            'تسع\nتسع',
            Icons.videogame_asset,
            const Color(0xFFC89620),
            () {},
          ),
          _buildModernActionCard(
            'أنشئ\nلعبتك',
            Icons.add,
            const Color(0xFFB23838),
            () => context.router.push(const CategorySelectionRoute()),
          ),
          _buildModernActionCard(
            'النتائج',
            Icons.emoji_events,
            const Color(0xFFE8E8E8),
            () => context.router.push(const MyGamesRoute()),
            textColor: const Color(0xFF666666),
            iconColor: const Color(0xFF999999),
          ),
          _buildModernActionCard(
            'تدريب',
            Icons.videogame_asset_outlined,
            const Color(0xFF1A2332),
            () {},
          ),
          _buildModernActionCard(
            'ألعابي',
            Icons.emoji_events,
            const Color(0xFF15A591),
            () => context.router.push(const MyGamesRoute()),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    Color? textColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? AppColors.white,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.largeTvBold.copyWith(
                color: textColor ?? AppColors.white,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
