/// A help tool (وسيلة مساعدة) a team can pick before the game and use once.
class HelpTool {
  /// Stored on the game document; keep stable.
  final String key;
  final String label;
  final String icon;

  const HelpTool(this.key, this.label, this.icon);
}

const List<HelpTool> kHelpTools = [
  HelpTool('استريح', 'استريح', '😴'),
  HelpTool('جاوب_جوابين', 'جاوب جوابين', '✌️'),
  HelpTool('الحفرة', 'الحفرة', '🕳️'),
  HelpTool('اتصال_بصديق', 'اتصال بصديق', '📞'),
];

HelpTool? helpToolByKey(String key) {
  for (final tool in kHelpTools) {
    if (tool.key == key) return tool;
  }
  return null;
}

/// Entry stored in a game's `used_tools`, e.g. `left:الحفرة`.
String usedToolEntry(String team, String toolKey) => '$team:$toolKey';
