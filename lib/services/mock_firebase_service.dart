import '../models/main_category.dart';
import '../models/sub_category.dart';
import '../models/question.dart';
import '../models/user_profile.dart';
import '../models/game_record.dart';
import 'mock_data.dart';

class MockFirebaseService {
  String? _currentUserId;
  final Map<String, UserProfile> _users = {};
  final Map<String, List<GameRecord>> _userGames = {};

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
    required String mobile,
  }) async {
    await _simulateDelay();

    final userId = 'mock_user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserId = userId;

    final userProfile = UserProfile(
      id: userId,
      email: email,
      name: name,
      mobile: mobile,
      trialsRemaining: 1,
      createdAt: DateTime.now().toIso8601String(),
    );

    _users[userId] = userProfile;
    _userGames[userId] = [];

    return {
      'success': true,
      'userId': userId,
      'user': userProfile.toJson(),
    };
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    await _simulateDelay();

    final userId = _users.entries
        .firstWhere(
          (entry) => entry.value.email == email,
          orElse: () => MapEntry('mock_user_default', MockData.getMockUserProfile('mock_user_default')),
        )
        .key;

    _currentUserId = userId;

    if (!_users.containsKey(userId)) {
      _users[userId] = MockData.getMockUserProfile(userId);
      _userGames[userId] = MockData.getMockGameRecords(userId);
    }

    return {
      'success': true,
      'userId': userId,
      'user': _users[userId]!.toJson(),
    };
  }

  Future<void> logoutUser() async {
    await _simulateDelay();
    _currentUserId = null;
  }

  String? getCurrentUserId() {
    return _currentUserId;
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    await _simulateDelay();

    if (_users.containsKey(userId)) {
      return _users[userId];
    }

    final profile = MockData.getMockUserProfile(userId);
    _users[userId] = profile;
    return profile;
  }

  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String mobile,
  }) async {
    await _simulateDelay();

    if (_users.containsKey(userId)) {
      final current = _users[userId]!;
      _users[userId] = UserProfile(
        id: current.id,
        email: current.email,
        name: name,
        mobile: mobile,
        trialsRemaining: current.trialsRemaining,
        createdAt: current.createdAt,
      );
    }
  }

  Future<void> purchaseTrials({
    required String userId,
    required int trialsCount,
  }) async {
    await _simulateDelay();

    if (_users.containsKey(userId)) {
      final current = _users[userId]!;
      _users[userId] = UserProfile(
        id: current.id,
        email: current.email,
        name: current.name,
        mobile: current.mobile,
        trialsRemaining: current.trialsRemaining + trialsCount,
        createdAt: current.createdAt,
      );
    }
  }

  Future<void> decrementTrial(String userId) async {
    await _simulateDelay();

    if (_users.containsKey(userId)) {
      final current = _users[userId]!;
      if (current.trialsRemaining > 0) {
        _users[userId] = UserProfile(
          id: current.id,
          email: current.email,
          name: current.name,
          mobile: current.mobile,
          trialsRemaining: current.trialsRemaining - 1,
          createdAt: current.createdAt,
        );
      }
    }
  }

  Future<List<MainCategory>> getMainCategories() async {
    await _simulateDelay();
    return MockData.mainCategories;
  }

  Future<List<SubCategory>> getSubCategoriesForMainCategory(String mainCategoryId) async {
    await _simulateDelay();
    return MockData.getSubCategoriesForMainCategory(mainCategoryId);
  }

  Future<List<Question>> getQuestionsForSubCategories(List<String> subCategoryIds) async {
    await _simulateDelay();
    return MockData.getQuestionsForSubCategories(subCategoryIds);
  }

  Future<Question?> getQuestionById(String questionId) async {
    await _simulateDelay();
    return MockData.getQuestionById(questionId);
  }

  Future<String> createGame({
    required String userId,
    required String gameName,
    required String leftTeamName,
    required String rightTeamName,
    required List<String> selectedSubcategories,
  }) async {
    await _simulateDelay();

    final gameId = 'game_${DateTime.now().millisecondsSinceEpoch}';

    final game = GameRecord(
      id: gameId,
      userId: userId,
      gameName: gameName,
      leftTeamName: leftTeamName,
      rightTeamName: rightTeamName,
      leftTeamScore: 0,
      rightTeamScore: 0,
      currentTurn: 'left',
      status: 'in_progress',
      playedQuestions: [],
      selectedSubcategories: selectedSubcategories,
      playCount: 1,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    if (!_userGames.containsKey(userId)) {
      _userGames[userId] = [];
    }
    _userGames[userId]!.add(game);

    return gameId;
  }

  Future<GameRecord?> getGame(String gameId) async {
    await _simulateDelay();

    for (final games in _userGames.values) {
      try {
        return games.firstWhere((g) => g.id == gameId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  Future<List<GameRecord>> getUserGames(String userId) async {
    await _simulateDelay();

    if (_userGames.containsKey(userId)) {
      return _userGames[userId]!;
    }

    final mockGames = MockData.getMockGameRecords(userId);
    _userGames[userId] = mockGames;
    return mockGames;
  }

  Future<void> updateGameScore({
    required String gameId,
    required int leftTeamScore,
    required int rightTeamScore,
    required String currentTurn,
  }) async {
    await _simulateDelay();

    for (final userId in _userGames.keys) {
      final games = _userGames[userId]!;
      final index = games.indexWhere((g) => g.id == gameId);
      if (index != -1) {
        final game = games[index];
        games[index] = game.copyWith(
          leftTeamScore: leftTeamScore,
          rightTeamScore: rightTeamScore,
          currentTurn: currentTurn,
          updatedAt: DateTime.now().toIso8601String(),
        );
        break;
      }
    }
  }

  Future<void> addPlayedQuestion({
    required String gameId,
    required String questionId,
  }) async {
    await _simulateDelay();

    for (final userId in _userGames.keys) {
      final games = _userGames[userId]!;
      final index = games.indexWhere((g) => g.id == gameId);
      if (index != -1) {
        final game = games[index];
        final updatedQuestions = List<String>.from(game.playedQuestions)..add(questionId);
        games[index] = game.copyWith(
          playedQuestions: updatedQuestions,
          updatedAt: DateTime.now().toIso8601String(),
        );
        break;
      }
    }
  }

  Future<void> completeGame({
    required String gameId,
    String? winner,
  }) async {
    await _simulateDelay();

    for (final userId in _userGames.keys) {
      final games = _userGames[userId]!;
      final index = games.indexWhere((g) => g.id == gameId);
      if (index != -1) {
        final game = games[index];
        games[index] = game.copyWith(
          status: 'completed',
          winner: winner,
          completedAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        break;
      }
    }
  }

  Future<void> resumeGame(String gameId) async {
    await _simulateDelay();

    for (final userId in _userGames.keys) {
      final games = _userGames[userId]!;
      final index = games.indexWhere((g) => g.id == gameId);
      if (index != -1) {
        final game = games[index];
        games[index] = game.copyWith(
          status: 'in_progress',
          updatedAt: DateTime.now().toIso8601String(),
        );
        break;
      }
    }
  }

  Future<void> replayGame(String gameId) async {
    await _simulateDelay();

    for (final userId in _userGames.keys) {
      final games = _userGames[userId]!;
      final index = games.indexWhere((g) => g.id == gameId);
      if (index != -1) {
        final game = games[index];
        games[index] = game.copyWith(
          status: 'in_progress',
          leftTeamScore: 0,
          rightTeamScore: 0,
          currentTurn: 'left',
          playedQuestions: [],
          playCount: game.playCount + 1,
          completedAt: null,
          updatedAt: DateTime.now().toIso8601String(),
        );
        break;
      }
    }
  }
}
