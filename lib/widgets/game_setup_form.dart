import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_state.dart';
import '../theme/app_colors.dart';

/// Self-contained game setup form with VS layout.
/// Owns its own form state, controllers, and tool selections.
/// Calls [onStart] with game name + team names when the form validates.
class GameSetupForm extends StatefulWidget {
  final int selectedCount;
  final bool isDesktop;
  final void Function(
    String gameName,
    String leftTeamName,
    String rightTeamName,
  ) onStart;

  const GameSetupForm({
    super.key,
    required this.selectedCount,
    required this.isDesktop,
    required this.onStart,
  });

  @override
  State<GameSetupForm> createState() => _GameSetupFormState();
}

class _GameSetupFormState extends State<GameSetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _gameNameController = TextEditingController();
  final _leftTeamController = TextEditingController();
  final _rightTeamController = TextEditingController();
  final Set<String> _leftTeamTools = {};
  final Set<String> _rightTeamTools = {};

  static const List<Map<String, String>> _tools = [
    {'key': 'استريح', 'label': 'استريح', 'icon': '😴'},
    {'key': 'جاوب_جوابين', 'label': 'جاوب جوابين', 'icon': '✌️'},
    {'key': 'الحفرة', 'label': 'الحفرة', 'icon': '🕳️'},
    {'key': 'اتصال_بصديق', 'label': 'اتصال بصديق', 'icon': '📞'},
  ];

  bool get _canStart => widget.selectedCount >= 6;

  @override
  void dispose() {
    _gameNameController.dispose();
    _leftTeamController.dispose();
    _rightTeamController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onStart(
        _gameNameController.text.trim(),
        _leftTeamController.text.trim(),
        _rightTeamController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        widget.isDesktop ? 64 : 16,
        40,
        widget.isDesktop ? 64 : 16,
        40,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'إعداد اللعبة',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'اكتبوا اسم اللعبة واسماء الفريقين واختاروا وسائل المساعدة',
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: widget.isDesktop ? 14 : 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (!_canStart) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700)),
                ),
                child: Text(
                  'اختر ${widget.selectedCount}/6 فئات لتفعيل إعداد اللعبة',
                  style: const TextStyle(
                    color: Color(0xFF856404),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _GameNameField(
              controller: _gameNameController,
              enabled: _canStart,
            ),
            const SizedBox(height: 28),
            widget.isDesktop ? _buildDesktopVs() : _buildMobileVs(),
            const SizedBox(height: 28),
            BlocBuilder<GameBloc, GameState>(
              builder: (context, gameState) {
                final isLoading = gameState is GameLoading;
                return SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_canStart && !isLoading) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _canStart ? 4 : 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'ابدأ اللعبة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopVs() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTeamPanel(isRight: true)),
        const _VsDivider(),
        Expanded(child: _buildTeamPanel(isRight: false)),
      ],
    );
  }

  Widget _buildMobileVs() {
    return Column(
      children: [
        _buildTeamPanel(isRight: true),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: _VsDivider()),
        ),
        _buildTeamPanel(isRight: false),
      ],
    );
  }

  Widget _buildTeamPanel({required bool isRight}) {
    final controller =
        isRight ? _rightTeamController : _leftTeamController;
    final teamTools = isRight ? _rightTeamTools : _leftTeamTools;
    final accentColor =
        isRight ? AppColors.primaryRed : const Color(0xFF3B82F6);
    final bgColor = isRight
        ? const Color(0xFFFFF5F7)
        : const Color(0xFFEFF6FF);
    final label = isRight ? 'الفريق الأيمن' : 'الفريق الأيسر';

    return _TeamPanel(
      controller: controller,
      label: label,
      teamTools: teamTools,
      accentColor: accentColor,
      bgColor: bgColor,
      enabled: _canStart,
      tools: _tools,
      onToolToggle: (key) => setState(() {
        if (teamTools.contains(key)) {
          teamTools.remove(key);
        } else if (teamTools.length < 3) {
          teamTools.add(key);
        }
      }),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _GameNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _GameNameField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A)),
      validator: (v) {
        if (!enabled) return null;
        if (v == null || v.trim().isEmpty) return 'أدخل اسم اللعبة';
        if (v.trim().length < 3) return 'الاسم 3 أحرف على الأقل';
        return null;
      },
      decoration: InputDecoration(
        hintText: 'اكتبوا اسم اللعبة',
        hintStyle:
            const TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
        suffixIcon: const Icon(Icons.edit_outlined,
            color: AppColors.primaryRed, size: 20),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primaryRed, width: 2)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}

class _TeamPanel extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Set<String> teamTools;
  final Color accentColor;
  final Color bgColor;
  final bool enabled;
  final List<Map<String, String>> tools;
  final void Function(String) onToolToggle;

  const _TeamPanel({
    required this.controller,
    required this.label,
    required this.teamTools,
    required this.accentColor,
    required this.bgColor,
    required this.enabled,
    required this.tools,
    required this.onToolToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.group,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller,
            enabled: enabled,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A)),
            validator: (v) {
              if (!enabled) return null;
              if (v == null || v.trim().isEmpty) return 'أدخل اسم الفريق';
              if (v.trim().length < 2) return 'حرفين على الأقل';
              return null;
            },
            decoration: InputDecoration(
              hintText: 'اسم الفريق',
              hintStyle: const TextStyle(
                  color: Color(0xFFAAAAAA), fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: accentColor.withValues(alpha: 0.3))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: accentColor.withValues(alpha: 0.3))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: accentColor, width: 2)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFEEEEEE))),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'اختر ${teamTools.length}/3 وسائل مساعدة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: accentColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.95,
            children: tools.map((tool) {
              final key = tool['key']!;
              final isToolSelected = teamTools.contains(key);
              final canPick =
                  enabled && (isToolSelected || teamTools.length < 3);
              return _ToolCard(
                label: tool['label']!,
                icon: tool['icon']!,
                isSelected: isToolSelected,
                canSelect: canPick,
                accentColor: accentColor,
                onTap: () => onToolToggle(key),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final bool canSelect;
  final Color accentColor;
  final VoidCallback onTap;

  const _ToolCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.canSelect,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canSelect ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE0E0E0),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Opacity(
            opacity: !canSelect && !isSelected ? 0.4 : 1.0,
            child: Column(
              children: [
                Expanded(
                  flex: 65,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.12)
                        : const Color(0xFFF5F5F5),
                    child: Center(
                      child: Text(icon,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 4),
                  color: isSelected ? accentColor : Colors.white,
                  child: Center(
                    child: Text(
                      label,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VsDivider extends StatelessWidget {
  const _VsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'VS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
