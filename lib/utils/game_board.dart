import 'dart:math';
import '../models/question.dart';

/// One category on the board: two columns of three cells, one cell per
/// difficulty level (easy → hard, top → bottom).
class BoardCategory {
  final String subCategoryId;
  final List<Question> left;
  final List<Question> right;

  const BoardCategory(this.subCategoryId, this.left, this.right);

  Iterable<String> get questionIds => [...left, ...right].map((q) => q.id);
}

/// Builds the 6-cell layout for every category in the game.
///
/// The pick is random per game but deterministic for a given [gameId], so the
/// board stays the same when the grid rebuilds or the game is resumed later.
List<BoardCategory> buildGameBoard(List<Question> questions, String gameId) {
  final bySub = <String, List<Question>>{};
  for (final q in questions) {
    bySub.putIfAbsent(q.subCategoryId, () => []).add(q);
  }

  return bySub.entries.map((entry) {
    final pool = [...entry.value]..sort((a, b) => a.id.compareTo(b.id));
    pool.shuffle(Random(_stableHash('$gameId|${entry.key}')));

    final levels = (pool.map((q) => q.points).toSet().toList()..sort());
    final rowPoints = List.generate(3, (i) {
      if (levels.isEmpty) return 0;
      if (levels.length >= 3) return [levels.first, levels[levels.length ~/ 2], levels.last][i];
      return levels[min(i, levels.length - 1)];
    });

    final used = <String>{};
    Question pick(int points) {
      final exact = pool.where((q) => q.points == points && !used.contains(q.id));
      final any = pool.where((q) => !used.contains(q.id));
      final q = exact.isNotEmpty ? exact.first : (any.isNotEmpty ? any.first : pool.last);
      used.add(q.id);
      return q;
    }

    final left = <Question>[];
    final right = <Question>[];
    for (final p in rowPoints) {
      left.add(pick(p));
      right.add(pick(p));
    }
    return BoardCategory(entry.key, left, right);
  }).toList();
}

/// True once every question on the board has been played.
bool isBoardComplete(List<BoardCategory> board, List<String> playedQuestions) {
  final played = playedQuestions.toSet();
  return board.isNotEmpty && board.every((c) => c.questionIds.every(played.contains));
}

// FNV-1a: String.hashCode isn't guaranteed stable across runs or platforms.
int _stableHash(String s) {
  var h = 0x811c9dc5;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h;
}
