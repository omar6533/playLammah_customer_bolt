import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_state.dart';
import '../utils/orientation_manager.dart';
import '../widgets/game_navbar.dart';
import '../routes/app_router.dart';

const _kWinnerBg = Color(0xFFD4EE6A);
const _kPanelBg = Color(0xFF4E1028); // dark wine — right team / loser
const _kPanelLeft = Color(0xFFB52040); // bright maroon — left team in draw
const _kWinnerText = Color(0xFF3D0A1A);
const _kLoserText = Color(0xFF9A5A6A);

@RoutePage()
class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  void _goHome(BuildContext context) {
    context.router.pushAndPopUntil(
      const HomeRoute(),
      predicate: (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            if (state is! GameOver) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              );
            }
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  GameNavbar(
                    showTurnChip: false,
                    onExit: () => _goHome(context),
                    onEndGame: () => _goHome(context),
                    onHome: () => _goHome(context),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: state.leftTeamScore == state.rightTeamScore
                          ? _DrawLayout(state: state)
                          : _WinnerLayout(
                              state: state,
                              onHome: () => _goHome(context),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Winner layout ─────────────────────────────────────────────────────────────

class _WinnerLayout extends StatelessWidget {
  final GameOver state;
  final VoidCallback onHome;

  const _WinnerLayout({required this.state, required this.onHome});

  @override
  Widget build(BuildContext context) {
    final isRightWinner = state.rightTeamScore > state.leftTeamScore;

    final winnerName = isRightWinner
        ? state.gameRecord.rightTeamName
        : state.gameRecord.leftTeamName;
    final winnerScore =
        isRightWinner ? state.rightTeamScore : state.leftTeamScore;
    final loserName = isRightWinner
        ? state.gameRecord.leftTeamName
        : state.gameRecord.rightTeamName;
    final loserScore =
        isRightWinner ? state.leftTeamScore : state.rightTeamScore;

    final winner =
        _WinnerPanel(name: winnerName, score: winnerScore, onHome: onHome);
    final loser = _LoserPanel(name: loserName, score: loserScore);

    // RTL: first child = physical RIGHT, last child = physical LEFT.
    // Right-team winner → winner goes first (physical right).
    // Left-team winner  → loser goes first (physical right), winner goes last.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: isRightWinner
          ? [
              Expanded(flex: 3, child: winner),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: loser)
            ]
          : [
              Expanded(flex: 2, child: loser),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: winner)
            ],
    );
  }
}

class _WinnerPanel extends StatelessWidget {
  final String name;
  final int score;
  final VoidCallback onHome;

  const _WinnerPanel({
    required this.name,
    required this.score,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Compact mode when available height is tight (e.g. phone landscape)
      final c = constraints.maxHeight < 360;
      return Container(
        decoration: BoxDecoration(
          color: _kWinnerBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('👑', style: TextStyle(fontSize: c ? 40 : 56)),
            SizedBox(height: c ? 4 : 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'كبير هالمه',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
            SizedBox(height: c ? 8 : 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                name,
                style: TextStyle(
                    color: _kWinnerText,
                    fontWeight: FontWeight.w900,
                    fontSize: c ? 22 : 32),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: c ? 4 : 8),
            Text(
              '$score',
              style: TextStyle(
                  color: _kWinnerText,
                  fontWeight: FontWeight.w900,
                  fontSize: c ? 36 : 48),
            ),
            SizedBox(height: c ? 12 : 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined, size: 16),
              label: const Text('مشاركة النتيجة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: c ? 8 : 10),
              ),
            ),
            SizedBox(height: c ? 6 : 10),
            OutlinedButton.icon(
              onPressed: onHome,
              icon: const Icon(Icons.arrow_back, size: 14),
              label: const Text('الرئيسية'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kWinnerText,
                side: const BorderSide(color: _kWinnerText),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: c ? 8 : 10),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _LoserPanel extends StatelessWidget {
  final String name;
  final int score;

  const _LoserPanel({required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 900;
    return Container(
      decoration: BoxDecoration(
        color: _kPanelBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              name,
              style: TextStyle(
                  color: _kLoserText,
                  fontWeight: FontWeight.w700,
                  fontSize: isSmall ? 20 : 26),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$score',
            style: TextStyle(
                color: _kLoserText,
                fontWeight: FontWeight.w900,
                fontSize: isSmall ? 36 : 48),
          ),
        ],
      ),
    );
  }
}

// ── Draw layout ───────────────────────────────────────────────────────────────

class _DrawLayout extends StatelessWidget {
  final GameOver state;
  const _DrawLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        // Two equal panels — RTL: first = physical RIGHT = right team
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _DrawPanel(
                name: state.gameRecord.rightTeamName,
                score: state.rightTeamScore,
                color: _kPanelBg, // dark wine = right team
              ),
            ),
            Expanded(
              child: _DrawPanel(
                name: state.gameRecord.leftTeamName,
                score: state.leftTeamScore,
                color: _kPanelLeft, // bright maroon = left team
              ),
            ),
          ],
        ),
        // Diagonal white separator — explicit height ensures it renders
        Center(
          child: Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 36,
              height: 2000,
              color: Colors.white,
            ),
          ),
        ),
        // VS badge
        const Center(child: _VsBadge()),
      ],
    );
  }
}

class _DrawPanel extends StatelessWidget {
  final String name;
  final int score;
  final Color color;

  const _DrawPanel({
    required this.name,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 900;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              name,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: isSmall ? 24 : 32),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$score',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: isSmall ? 42 : 56),
          ),
        ],
      ),
    );
  }
}

class _VsBadge extends StatelessWidget {
  const _VsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'VS',
          style: TextStyle(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
