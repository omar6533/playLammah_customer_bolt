import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Team selection card shown after the answer is revealed.
/// Matches Figma node 313-30012: white card with "من اللي جاوب؟" heading,
/// two red team buttons side-by-side, and a "ولا أحد" outlined button.
class TeamAnswerSelector extends StatelessWidget {
  final String rightTeamName;
  final String leftTeamName;
  final bool isSubmitting;
  final VoidCallback onSelectRight;
  final VoidCallback onSelectLeft;
  final VoidCallback onNobody;

  const TeamAnswerSelector({
    super.key,
    required this.rightTeamName,
    required this.leftTeamName,
    required this.isSubmitting,
    required this.onSelectRight,
    required this.onSelectLeft,
    required this.onNobody,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E0E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Text(
            'من اللي جاوب؟',
            style: TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Team buttons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // RTL first = physical RIGHT = rightTeam
                Expanded(
                  child: _TeamButton(
                    label: rightTeamName,
                    onTap: isSubmitting ? null : onSelectRight,
                  ),
                ),
                const SizedBox(width: 12),
                // RTL second = physical LEFT = leftTeam
                Expanded(
                  child: _TeamButton(
                    label: leftTeamName,
                    onTap: isSubmitting ? null : onSelectLeft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _NobodyButton(onTap: isSubmitting ? null : onNobody),
          const Spacer(),
        ],
      ),
    );
  }
}

class _TeamButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _TeamButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _NobodyButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _NobodyButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: const Text(
          'ولا أحد',
          style: TextStyle(
            color: Color(0xFF555555),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
