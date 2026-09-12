import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/game_record.dart';
import '../services/app_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import '../routes/app_router.dart';
import '../widgets/purchase_dialog.dart';
import '../config/app_config.dart';

const _kPageBg = Color(0xFFFDFDFD);
const _kCardBg = AppColors.white;
const _kCardBorder = Color(0xFFEEEEEE);
const _kGold = Color(0xFFCB9E3C);
const _kBodyText = Color(0xFF333333);
const _kSubText = Color(0xFF888888);
const _kChipBorder = Color(0xFFDDDDDD);
const _kImageBg = Color(0xFFF5E8EC);

@RoutePage()
class MyGamesScreen extends StatefulWidget {
  const MyGamesScreen({super.key});

  @override
  State<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends State<MyGamesScreen> {
  List<GameRecord>? _games;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final userId = AppService().getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        setState(() { _games = []; _loading = false; });
        return;
      }
      final games = await AppService().getUserGames(userId);
      setState(() { _games = games; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPageBg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          AppNavbar(
            onLoginTap: () => context.router.push(const LoginRoute()),
            onBackTap: () => context.router.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _PageHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      child: _buildBody(),
                    ),
                    const AppFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'حدث خطأ أثناء تحميل الألعاب',
            style: const TextStyle(color: AppColors.primaryRed, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final games = _games ?? [];
    if (games.isEmpty) return const _EmptyState();
    return _GameGrid(games: games);
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ألعابي', style: TextStyle(color: _kSubText, fontSize: 13)),
              SizedBox(width: 4),
              Icon(Icons.chevron_left, color: _kSubText, size: 16),
              SizedBox(width: 4),
              Text('الرئيسية', style: TextStyle(color: _kSubText, fontSize: 13)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'ألعابي',
            style: TextStyle(
              color: AppColors.primaryRed,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_sim_outlined, size: 80, color: _kChipBorder),
          const SizedBox(height: 24),
          const Text(
            'لم يتم العثور على أي لعبة تم لعبها',
            style: TextStyle(
              color: AppColors.primaryRed,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'لم تلعب أي لعبة بعد. إبدأ اللعب الآن.',
            style: TextStyle(color: _kSubText, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _BuyButton(),
        ],
      ),
    );
  }
}

// ── Game cards grid ───────────────────────────────────────────────────────────

class _GameGrid extends StatelessWidget {
  final List<GameRecord> games;
  const _GameGrid({required this.games});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1100) return _wrapGrid(games, 4);
    if (width >= 768) return _wrapGrid(games, 2);
    return Column(
      children: games
          .map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _GameCard(game: g),
              ))
          .toList(),
    );
  }

  Widget _wrapGrid(List<GameRecord> games, int columns) {
    final rows = <Widget>[];
    for (int i = 0; i < games.length; i += columns) {
      final rowGames = games.sublist(i, (i + columns).clamp(0, games.length));
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowGames
                .asMap()
                .entries
                .map((e) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: e.key < rowGames.length - 1 ? 16 : 0),
                        child: _GameCard(game: e.value),
                      ),
                    ))
                .toList(),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

// ── Single game card ──────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final GameRecord game;
  const _GameCard({required this.game});

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _winnerLabel() {
    if (game.status != 'completed') return 'جارية';
    if (game.winner == 'draw') return 'تعادل';
    if (game.winner == 'left') return 'فاز: ${game.leftTeamName}';
    if (game.winner == 'right') return 'فاز: ${game.rightTeamName}';
    return 'منتهية';
  }

  Color _statusColor() {
    if (game.status != 'completed') return const Color(0xFF3B82F6);
    if (game.winner == 'draw') return _kGold;
    return AppColors.primaryRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image / score area ────────────────────────────────────────────
          Stack(
            children: [
              Container(
                height: 120,
                color: _kImageBg,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ScoreBlock(
                        name: game.leftTeamName,
                        score: game.leftTeamScore,
                        color: AppColors.primaryRed,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _ScoreBlock(
                        name: game.rightTeamName,
                        score: game.rightTeamScore,
                        color: const Color(0xFF3B82F6),
                      ),
                    ],
                  ),
                ),
              ),
              // Status badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _winnerLabel(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // Play count badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'مرات اللعب: ${game.playCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Card body ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  game.gameName,
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(game.createdAt),
                      style: const TextStyle(color: _kSubText, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: _kSubText),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        '${game.rightTeamName} - ${game.leftTeamName}',
                        style: const TextStyle(
                            color: _kBodyText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.people_outline, size: 14, color: _kSubText),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${game.selectedSubcategories.length} فئة',
                  style: const TextStyle(color: _kSubText, fontSize: 12),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  final String name;
  final int score;
  final Color color;

  const _ScoreBlock({
    required this.name,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ── Buy new game button ───────────────────────────────────────────────────────

class _BuyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => PurchaseDialog.show(
        context: context,
        moyasarApiKey: AppConfig.moyasarApiKey,
        callbackUrl: AppConfig.paymentCallbackUrl,
        successUrl: AppConfig.paymentSuccessUrl,
        onPackageSelected: (package) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم اختيار: ${package.title}')),
          );
        },
      ),
      icon: const Icon(Icons.arrow_back, size: 14),
      label: const Text('إشتر لعبة جديدة'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}
