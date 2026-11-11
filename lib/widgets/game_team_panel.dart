import 'package:flutter/material.dart';
import '../models/help_tool.dart';
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
  final List<String> rightTeamTools;
  final List<String> leftTeamTools;
  final List<String> usedTools;

  /// Called with ('left' | 'right', toolKey) after the host confirms.
  final void Function(String team, String toolKey)? onUseTool;

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
    this.rightTeamTools = const [],
    this.leftTeamTools = const [],
    this.usedTools = const [],
    this.onUseTool,
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
              tools: rightTeamTools,
              usedTools: usedTools,
              onUseTool:
                  onUseTool == null ? null : (key) => onUseTool!('right', key),
              team: 'right',
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
              tools: leftTeamTools,
              usedTools: usedTools,
              onUseTool:
                  onUseTool == null ? null : (key) => onUseTool!('left', key),
              team: 'left',
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
  final String team;
  final List<String> tools;
  final List<String> usedTools;
  final void Function(String toolKey)? onUseTool;

  const _TeamSection({
    required this.name,
    required this.score,
    required this.isActive,
    required this.onIncrement,
    required this.onDecrement,
    required this.team,
    required this.tools,
    required this.usedTools,
    required this.onUseTool,
  });

  Future<void> _confirmUse(BuildContext context, HelpTool tool) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${tool.icon} ${tool.label}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.primaryRed, fontWeight: FontWeight.w800)),
        content: Text(
            'استخدام «${tool.label}» لفريق $name؟\nتُستخدم مرة وحدة فقط.',
            textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('استخدام',
                style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) onUseTool?.call(tool.key);
  }

  @override
  Widget build(BuildContext context) {
    // Scrollable so short phone-landscape screens never overflow.
    return Center(
      child: SingleChildScrollView(
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
            if (tools.isEmpty)
              const Text('لم تُختر وسائل',
                  style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 10))
            else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final key in tools)
                    if (helpToolByKey(key) case final tool?)
                      _HelpToolChip(
                        tool: tool,
                        used: usedTools.contains(usedToolEntry(team, key)),
                        onTap: onUseTool == null
                            ? null
                            : () => _confirmUse(context, tool),
                      ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HelpToolChip extends StatelessWidget {
  final HelpTool tool;
  final bool used;
  final VoidCallback? onTap;

  const _HelpToolChip({required this.tool, required this.used, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: used ? '${tool.label} (مستخدمة)' : tool.label,
      child: GestureDetector(
        onTap: used ? null : onTap,
        child: Opacity(
          opacity: used ? 0.4 : 1,
          child: Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              color: used ? const Color(0xFFEEEEEE) : const Color(0xFFFFD6E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(tool.icon, style: const TextStyle(fontSize: 16)),
                    if (used)
                      const Positioned(
                        right: -8,
                        top: -4,
                        child: Icon(Icons.check_circle,
                            color: Color(0xFF4CAF50), size: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  tool.label,
                  style: TextStyle(
                    color:
                        used ? const Color(0xFF888888) : AppColors.primaryRed,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    decoration: used ? TextDecoration.lineThrough : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
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
