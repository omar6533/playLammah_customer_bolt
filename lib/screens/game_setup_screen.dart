import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_event.dart';
import '../bloc/game/game_state.dart';
import '../utils/responsive_helper.dart';
import '../widgets/primary_button.dart';

@RoutePage()
class GameSetupScreen extends StatefulWidget {
  final List<String> selectedSubcategories;

  const GameSetupScreen({
    Key? key,
    required this.selectedSubcategories,
  }) : super(key: key);

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameNameController = TextEditingController();
  final _leftTeamController = TextEditingController();
  final _rightTeamController = TextEditingController();

  @override
  void dispose() {
    _gameNameController.dispose();
    _leftTeamController.dispose();
    _rightTeamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final isLandscape = ResponsiveHelper.isLandscape(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('إعداد اللعبة', style: AppTextStyles.largeTvBold),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
      ),
      body: BlocListener<GameBloc, GameState>(
        listenWhen: (previous, current) =>
            previous is! GameInProgress && current is GameInProgress,
        listener: (context, state) {
          if (state is GameInProgress) {
            context.router.replace(
              QuestionGridRoute(gameId: state.gameId),
            );
          } else if (state is GameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryRed,
              ),
            );
          }
        },
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: screenPadding,
              child: Form(
                key: _formKey,
                child: isLandscape
                    ? _buildLandscapeLayout(state)
                    : _buildPortraitLayout(state),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        SizedBox(height: AppSpacing.xl),
        _buildGameNameField(),
        SizedBox(height: AppSpacing.xl),
        _buildTeamsSection(),
        SizedBox(height: AppSpacing.xxl),
        _buildStartButton(state),
        SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildLandscapeLayout(GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        SizedBox(height: AppSpacing.lg),
        _buildGameNameField(),
        SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLeftTeamCard()),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: _buildRightTeamCard()),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        _buildStartButton(state),
        SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryYellow,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sports_esports,
            size: 48,
            color: AppColors.primaryRed,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'أدخل تفاصيل اللعبة',
            style: AppTextStyles.largeTvBold,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'عدد الفئات المختارة: ${widget.selectedSubcategories.length}',
            style: AppTextStyles.mediumRegular.copyWith(
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اسم اللعبة',
          style: AppTextStyles.largeTvBold,
        ),
        SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _gameNameController,
          textAlign: TextAlign.right,
          style: AppTextStyles.mediumRegular,
          decoration: InputDecoration(
            hintText: 'مثال: مباراة الأصدقاء',
            hintStyle: AppTextStyles.mediumRegular.copyWith(
              color: AppColors.darkGray.withOpacity(0.5),
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGray, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGray, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
            ),
            contentPadding: EdgeInsets.all(AppSpacing.md),
            prefixIcon: Icon(Icons.games, color: AppColors.primaryRed),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال اسم اللعبة';
            }
            if (value.trim().length < 3) {
              return 'يجب أن يكون الاسم 3 أحرف على الأقل';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTeamsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفرق المتنافسة',
          style: AppTextStyles.largeTvBold,
        ),
        SizedBox(height: AppSpacing.md),
        _buildLeftTeamCard(),
        SizedBox(height: AppSpacing.md),
        _buildRightTeamCard(),
      ],
    );
  }

  Widget _buildLeftTeamCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryRed,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.group,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'الفريق الأيسر',
                style: AppTextStyles.mediumBold.copyWith(
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _leftTeamController,
            textAlign: TextAlign.right,
            style: AppTextStyles.mediumRegular,
            decoration: InputDecoration(
              hintText: 'اسم الفريق الأيسر',
              hintStyle: AppTextStyles.mediumRegular.copyWith(
                color: AppColors.darkGray.withOpacity(0.5),
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              contentPadding: EdgeInsets.all(AppSpacing.sm),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال اسم الفريق';
              }
              if (value.trim().length < 2) {
                return 'يجب أن يكون الاسم حرفين على الأقل';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRightTeamCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryYellow,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.group,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'الفريق الأيمن',
                style: AppTextStyles.mediumBold.copyWith(
                  color: AppColors.primaryYellow,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _rightTeamController,
            textAlign: TextAlign.right,
            style: AppTextStyles.mediumRegular,
            decoration: InputDecoration(
              hintText: 'اسم الفريق الأيمن',
              hintStyle: AppTextStyles.mediumRegular.copyWith(
                color: AppColors.darkGray.withOpacity(0.5),
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              contentPadding: EdgeInsets.all(AppSpacing.sm),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال اسم الفريق';
              }
              if (value.trim().length < 2) {
                return 'يجب أن يكون الاسم حرفين على الأقل';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(GameState state) {
    final isLoading = state is GameLoading;

    return PrimaryButton(
      text: isLoading ? 'جاري الإنشاء...' : 'ابدأ اللعبة',
      onPressed: isLoading ? null : _startGame,
      icon: isLoading ? null : Icons.play_arrow,
    );
  }

  void _startGame() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<GameBloc>().add(
            CreateGameEvent(
              gameName: _gameNameController.text.trim(),
              leftTeamName: _leftTeamController.text.trim(),
              rightTeamName: _rightTeamController.text.trim(),
              selectedSubcategories: widget.selectedSubcategories,
            ),
          );
    }
  }
}
