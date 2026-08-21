import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const _kPanelBg = Color(0xFFFFF8FA);

class GameTeamPanel extends StatelessWidget {
  final String rightTeamName;
  final int rightTeamScore;
  final bool isRightActive;
  final String leftTeamName;
  final int leftTeamScore;
  final bool isLeftActive;
  final VoidCallback onIncrementRight;
  final VoidCallback onDecrementRight;
  final VoidCallback onIncrementLeft;
  final VoidCallback onDecrementLeft;

  const GameTeamPanel({
    super.key,
    required this.rightTeamName,
    required this.rightTeamScore,
    required this.isRightActive,
    required this.leftTeamName,
    required this.leftTeamScore,
    required this.isLeftActive,
    required this.onIncrementRight,
    required this.onDecrementRight,
    required this.onIncrementLeft,
    required this.onDecrementLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: _kPanelBg,
      child: Column(
        children: [
          Expanded(
            child: _TeamSection(
              name: rightTeamName,
              score: rightTeamScore,
              isActive: isRightActive,
              onIncrement: onIncrementRight,
              onDecrement: onDecrementRight,
            ),
          ),
          const Divider(height: 1, color: Color(0xFFFFCCDA)),
          Expanded(
            child: _TeamSection(
              name: leftTeamName,
              score: leftTeamScore,
              isActive: isLeftActive,
              onIncrement: onIncrementLeft,
              onDecrement: onDecrementLeft,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  final String name;
  final int score;
  final bool isActive;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _TeamSection({
    required this.name,
    required this.score,
    required this.isActive,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('دوره الآن',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600)),
            ),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ScoreButton(icon: Icons.add, onTap: onIncrement),
              const SizedBox(width: 6),
              Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primaryRed
                        : const Color(0xFFE0E0E0),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Text(
                  '$score',
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6),
              _ScoreButton(icon: Icons.remove, onTap: onDecrement),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'وسائل المساعدة',
            style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 10,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.extension_outlined,
                    color: AppColors.primaryRed, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScoreButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
