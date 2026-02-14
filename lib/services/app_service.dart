import '../config/app_config.dart';
import '../models/main_category.dart';
import '../models/sub_category.dart';
import '../models/question.dart';
import '../models/user_profile.dart';
import '../models/game_record.dart';
import 'firebase_service.dart';
import 'mock_firebase_service.dart';

class AppService {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  late final FirebaseService _firebaseService = FirebaseService();
  final MockFirebaseService _mockService = MockFirebaseService();

  bool get isMockMode => AppConfig.useMockData;

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
    required String mobile,
  }) async {
    if (isMockMode) {
      return await _mockService.registerUser(
        email: email,
        password: password,
        name: name,
        mobile: mobile,
      );
    } else {
      final credential = await _firebaseService.signUp(
        email: email,
        password: password,
        name: name,
        mobile: mobile,
      );
      final profile =
          await _firebaseService.getUserProfile(credential.user!.uid);
      return {
        'success': true,
        'userId': credential.user!.uid,
        'user': profile.toJson(),
      };
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    if (isMockMode) {
      return await _mockService.loginUser(email: email, password: password);
    } else {
      final credential =
          await _firebaseService.signIn(email: email, password: password);
      final profile =
          await _firebaseService.getUserProfile(credential.user!.uid);
      return {
        'success': true,
        'userId': credential.user!.uid,
        'user': profile.toJson(),
      };
    }
  }

  Future<void> logoutUser() async {
    if (isMockMode) {
      await _mockService.logoutUser();
    } else {
      await _firebaseService.signOut();
    }
  }

  String? getCurrentUserId() {
    if (isMockMode) {
      return _mockService.getCurrentUserId();
    } else {
      return _firebaseService.getCurrentUser()?.uid;
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    if (isMockMode) {
      return await _mockService.getUserProfile(userId);
    } else {
      return await _firebaseService.getUserProfile(userId);
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String mobile,
  }) async {
    if (isMockMode) {
      await _mockService.updateUserProfile(
          userId: userId, name: name, mobile: mobile);
    } else {
      await _firebaseService.updateUserProfile(
          userId: userId, name: name, mobile: mobile);
    }
  }

  Future<void> purchaseTrials({
    required String userId,
    required int trialsCount,
  }) async {
    if (isMockMode) {
      await _mockService.purchaseTrials(
          userId: userId, trialsCount: trialsCount);
    } else {
      final profile = await _firebaseService.getUserProfile(userId);
      await _firebaseService.updateTrialsRemaining(
        userId,
        profile.trialsRemaining + trialsCount,
      );
    }
  }

  Future<void> decrementTrial(String userId) async {
    if (isMockMode) {
      await _mockService.decrementTrial(userId);
    } else {
      final profile = await _firebaseService.getUserProfile(userId);
      // First use free trials, then purchased games
      if (profile.trialsRemaining > 0) {
        await _firebaseService.updateTrialsRemaining(
          userId,
          profile.trialsRemaining - 1,
        );
      } else if (profile.availableGames > 0) {
        await _firebaseService.decrementAvailableGames(userId);
      }
    }
  }

  Future<List<MainCategory>> getMainCategories() async {
    if (isMockMode) {
      return await _mockService.getMainCategories();
    } else {
      return await _firebaseService.getMainCategories();
    }
  }

  Future<List<SubCategory>> getSubCategoriesForMainCategory(
      String mainCategoryId) async {
    if (isMockMode) {
      return await _mockService.getSubCategoriesForMainCategory(mainCategoryId);
    } else {
      return await _firebaseService
          .getSubCategoriesByMainCategory(mainCategoryId);
    }
  }

  Future<List<Question>> getQuestionsForSubCategories(
      List<String> subCategoryIds) async {
    if (isMockMode) {
      return await _mockService.getQuestionsForSubCategories(subCategoryIds);
    } else {
      final allQuestions = <Question>[];
      for (final subCategoryId in subCategoryIds) {
        final questions =
            await _firebaseService.getQuestionsBySubCategory(subCategoryId);
        allQuestions.addAll(questions);
      }
      return allQuestions;
    }
  }

  Future<Question?> getQuestionById(String questionId) async {
    if (isMockMode) {
      return await _mockService.getQuestionById(questionId);
    } else {
      return await _firebaseService.getQuestionById(questionId);
    }
  }

  Future<String> createGame({
    required String userId,
    required String gameName,
    required String leftTeamName,
    required String rightTeamName,
    required List<String> selectedSubcategories,
  }) async {
    if (isMockMode) {
      return await _mockService.createGame(
        userId: userId,
        gameName: gameName,
        leftTeamName: leftTeamName,
        rightTeamName: rightTeamName,
        selectedSubcategories: selectedSubcategories,
      );
    } else {
      return await _firebaseService.createGame(
        userId: userId,
        gameName: gameName,
        leftTeamName: leftTeamName,
        rightTeamName: rightTeamName,
        selectedSubcategories: selectedSubcategories,
      );
    }
  }

  Future<GameRecord?> getGame(String gameId) async {
    if (isMockMode) {
      return await _mockService.getGame(gameId);
    } else {
      return await _firebaseService.getGameById(gameId);
    }
  }

  Future<List<GameRecord>> getUserGames(String userId) async {
    if (isMockMode) {
      return await _mockService.getUserGames(userId);
    } else {
      return await _firebaseService.getUserGames(userId);
    }
  }

  Future<void> updateGameScore({
    required String gameId,
    required int leftTeamScore,
    required int rightTeamScore,
    required String currentTurn,
  }) async {
    if (isMockMode) {
      await _mockService.updateGameScore(
        gameId: gameId,
        leftTeamScore: leftTeamScore,
        rightTeamScore: rightTeamScore,
        currentTurn: currentTurn,
      );
    } else {
      await _firebaseService.updateGameScore(
        gameId: gameId,
        leftTeamScore: leftTeamScore,
        rightTeamScore: rightTeamScore,
        currentTurn: currentTurn,
      );
    }
  }

  Future<void> addPlayedQuestion({
    required String gameId,
    required String questionId,
  }) async {
    if (isMockMode) {
      await _mockService.addPlayedQuestion(
          gameId: gameId, questionId: questionId);
    } else {
      await _firebaseService.addPlayedQuestion(gameId, questionId);
    }
  }

  Future<void> completeGame({
    required String gameId,
    String? winner,
  }) async {
    if (isMockMode) {
      await _mockService.completeGame(gameId: gameId, winner: winner);
    } else {
      await _firebaseService.completeGame(
        gameId: gameId,
        status: 'completed',
        winner: winner,
      );
    }
  }

  Future<void> resumeGame(String gameId) async {
    if (isMockMode) {
      await _mockService.resumeGame(gameId);
    } else {
      await _firebaseService.completeGame(
        gameId: gameId,
        status: 'active',
        winner: null,
      );
    }
  }

  Future<void> replayGame(String gameId) async {
    if (isMockMode) {
      await _mockService.replayGame(gameId);
    } else {
      final game = await _firebaseService.getGameById(gameId);
      await _firebaseService.resetGameForReplay(gameId);
      await _firebaseService.updateGamePlayCount(gameId, game.playCount + 1);
    }
  }

  Future<void> addGamesToUser(String userId, int gamesToAdd) async {
    if (isMockMode) {
      await _mockService.addGamesToUser(userId, gamesToAdd);
    } else {
      await _firebaseService.addGamesToUser(userId, gamesToAdd);
    }
  }

  Future<String> recordPayment({
    required String userId,
    required String userEmail,
    required String userName,
    required String userMobile,
    required String packageId,
    required String packageTitle,
    required int gamesCount,
    required int amountInHalalas,
    required String invoiceId,
    String paymentStatus = 'completed',
    Map<String, dynamic>? metadata,
  }) async {
    if (isMockMode) {
      return await _mockService.recordPayment(
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        userMobile: userMobile,
        packageId: packageId,
        packageTitle: packageTitle,
        gamesCount: gamesCount,
        amountInHalalas: amountInHalalas,
        invoiceId: invoiceId,
        paymentStatus: paymentStatus,
        metadata: metadata,
      );
    } else {
      return await _firebaseService.recordPayment(
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        userMobile: userMobile,
        packageId: packageId,
        packageTitle: packageTitle,
        gamesCount: gamesCount,
        amountInHalalas: amountInHalalas,
        invoiceId: invoiceId,
        paymentStatus: paymentStatus,
        metadata: metadata,
      );
    }
  }
}
