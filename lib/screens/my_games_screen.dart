import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import '../routes/app_router.dart';
import '../config/app_config.dart';
import '../widgets/purchase_dialog.dart';

// ── Color constants ──────────────────────────────────────────────────────────

const _kPageBg = Color(0xFFFDFDFD);
const _kCardBg = AppColors.white;
const _kCardBorder = Color(0xFFEEEEEE);
const _kGold = Color(0xFFCB9E3C);
const _kBodyText = Color(0xFF333333);
const _kSubText = Color(0xFF888888);
const _kChipBorder = Color(0xFFDDDDDD);
const _kImageBg = Color(0xFFF5E8EC);

// ── Mock data models (replace with Firebase later) ───────────────────────────

class SavedGame {
  final String id;
  final String title;
  final String leftTeamName;
  final String rightTeamName;
  final String date;
  final int timesPlayed;
  final String? imageUrl;
  final List<String> categoryNames;

  const SavedGame({
    required this.id,
    required this.title,
    required this.leftTeamName,
    required this.rightTeamName,
    required this.date,
    required this.timesPlayed,
    this.imageUrl,
    required this.categoryNames,
  });
}

List<SavedGame> _mockGames() => [
      const SavedGame(
        id: '1',
        title: 'اسم اللعبة',
        leftTeamName: 'اسم الفريق الأول',
        rightTeamName: 'اسم الفريق الثاني',
        date: '20.06.2026',
        timesPlayed: 5,
        categoryNames: ['دول', 'وكلمة', 'اسلامية', 'رمضان'],
      ),
      const SavedGame(
        id: '2',
        title: 'اسم اللعبة',
        leftTeamName: 'الفريق الثاني',
        rightTeamName: 'الفريق الأول',
        date: '20.06.2026',
        timesPlayed: 3,
        categoryNames: ['دول', 'وكلمة'],
      ),
      const SavedGame(
        id: '3',
        title: 'اسم اللعبة',
        leftTeamName: 'الفريق ب',
        rightTeamName: 'الفريق أ',
        date: '20.06.2026',
        timesPlayed: 2,
        categoryNames: ['اسلامية', 'رمضان'],
      ),
      const SavedGame(
        id: '4',
        title: 'اسم اللعبة',
        leftTeamName: 'الفريق 2',
        rightTeamName: 'الفريق 1',
        date: '20.06.2026',
        timesPlayed: 1,
        categoryNames: ['دول'],
      ),
    ];

// ── Screen ───────────────────────────────────────────────────────────────────

@RoutePage()
class MyGamesScreen extends StatelessWidget {
  const MyGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = _mockGames();
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
                      child: games.isEmpty
                          ? const _EmptyState()
                          : _GameGrid(games: games),
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
}

// ── Page header (breadcrumb + title) ─────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Breadcrumb
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ألعابي',
                style: TextStyle(color: _kSubText, fontSize: 13),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_left, color: _kSubText, size: 16),
              SizedBox(width: 4),
              Text(
                'الرئيسية',
                style: TextStyle(color: _kSubText, fontSize: 13),
              ),
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
          const Icon(
            Icons.no_sim_outlined,
            size: 80,
            color: _kChipBorder,
          ),
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
  final List<SavedGame> games;
  const _GameGrid({required this.games});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1100) {
      // Desktop: 4 columns
      return _wrapGrid(games, 4);
    } else if (width >= 768) {
      // Tablet: 2 columns
      return _wrapGrid(games, 2);
    }
    // Mobile: single column
    return Column(
      children: games
          .map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _GameCard(game: g),
              ))
          .toList(),
    );
  }

  Widget _wrapGrid(List<SavedGame> games, int columns) {
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
  final SavedGame game;
  const _GameCard({required this.game});

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
          // ── Image area ───────────────────────────────────────────────────
          Stack(
            children: [
              Container(
                height: 160,
                color: _kImageBg,
                child: game.imageUrl != null
                    ? Image.network(
                        game.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(
                        child: Icon(Icons.videogame_asset_rounded,
                            size: 56, color: Color(0xFFE8C0CC)),
                      ),
              ),
              // "مرات اللعب" badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'مرات اللعب: ${game.timesPlayed}',
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

          // ── Card body ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Game title
                Text(
                  game.title,
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                // Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      game.date,
                      style: const TextStyle(
                          color: _kSubText, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: _kSubText),
                  ],
                ),
                const SizedBox(height: 4),
                // Team names
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
                    const Icon(Icons.people_outline,
                        size: 14, color: _kSubText),
                  ],
                ),
                const SizedBox(height: 10),
                // Category chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.end,
                  children:
                      game.categoryNames.map(_buildChip).toList(),
                ),
                const SizedBox(height: 12),
                // "عرض التفاصيل" button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back, size: 14),
                    label: const Text('عرض التفاصيل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: _kChipBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _kBodyText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}
