import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GameNavbar extends StatelessWidget {
  final String currentTeamName;
  final VoidCallback onExit;
  final VoidCallback onEndGame;
  final VoidCallback onHome;
  final String homeLabel;

  const GameNavbar({
    super.key,
    required this.currentTeamName,
    required this.onExit,
    required this.onEndGame,
    required this.onHome,
    this.homeLabel = 'الرئيسية',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0E0E6), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _TurnChip(teamName: currentTeamName),
            const Spacer(),
            TextButton(
              onPressed: onHome,
              child: Text(homeLabel,
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
            ),
            TextButton(
              onPressed: onEndGame,
              child: const Text('أنهي اللعبة',
                  style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Image.asset(
              'assets/images/logo.png',
              height: 36,
              errorBuilder: (_, __, ___) => const Text(
                'لمه وتحدي',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 20),
            _ExitButton(onTap: onExit),
          ],
        ),
      ),
    );
  }
}

class _TurnChip extends StatelessWidget {
  final String teamName;
  const _TurnChip({required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swap_horiz, color: AppColors.primaryRed, size: 16),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('دور الفريق:',
                  style: TextStyle(
                      color: Color(0xFF999999), fontSize: 10, height: 1.2)),
              Text(teamName,
                  style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      height: 1.2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExitButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ExitButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('خروج',
                style: TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            SizedBox(width: 4),
            Icon(Icons.arrow_back, size: 14, color: Color(0xFF555555)),
          ],
        ),
      ),
    );
  }
}
