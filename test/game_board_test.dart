import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_game/models/question.dart';
import 'package:trivia_game/utils/game_board.dart';

Question q(String sub, int i, int points) => Question(
      id: '$sub-$i',
      subCategoryId: sub,
      questionText: '',
      questionTextAr: '',
      answer: '',
      answerAr: '',
      points: points,
      isActive: true,
      order: i,
    );

/// A category with [perLevel] questions at each of 10 / 30 / 50 points.
List<Question> category(String sub, {int perLevel = 20}) => [
      for (final p in [10, 30, 50])
        for (var i = 0; i < perLevel; i++) q(sub, p * 100 + i, p),
    ];

void main() {
  final questions = [for (var c = 0; c < 6; c++) ...category('sub$c')];

  test('each column has one easy, one medium and one hard question', () {
    final board = buildGameBoard(questions, 'game-1');
    expect(board, hasLength(6));
    for (final c in board) {
      expect(c.left.map((q) => q.points), [10, 30, 50]);
      expect(c.right.map((q) => q.points), [10, 30, 50]);
      expect(c.questionIds.toSet(), hasLength(6));
    }
  });

  test('board is stable for a game and varies between games', () {
    final ids = (String id) => buildGameBoard(questions, id).expand((c) => c.questionIds).toList();
    expect(ids('game-1'), ids('game-1'));
    expect(ids('game-1'), isNot(ids('game-2')));
  });

  test('complete only after all 36 board questions are played', () {
    final board = buildGameBoard(questions, 'game-1');
    final all = board.expand((c) => c.questionIds).toList();
    expect(all, hasLength(36));
    expect(isBoardComplete(board, all.sublist(0, 35)), isFalse);
    expect(isBoardComplete(board, all), isTrue);
  });

  test('falls back to other questions when a level is missing', () {
    final onlyEasy = [for (var i = 0; i < 6; i++) q('x', i, 10)];
    final board = buildGameBoard(onlyEasy, 'g');
    expect(board.single.questionIds.toSet(), hasLength(6));
  });
}
