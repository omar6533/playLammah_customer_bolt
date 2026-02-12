import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/main_category.dart';
import '../models/sub_category.dart';
import '../models/question.dart';
import '../models/game_record.dart';
import '../models/user_profile.dart';

class FirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Auth Methods
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String mobile,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      await _firestore
          .collection('user_profiles')
          .doc(userCredential.user!.uid)
          .set({
        'id': userCredential.user!.uid,
        'email': email,
        'name': name,
        'mobile': mobile,
        'trials_remaining': 1,
        'available_games': 0,
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // User Profile Methods
  Future<UserProfile> getUserProfile(String userId) async {
    final doc = await _firestore.collection('user_profiles').doc(userId).get();

    if (!doc.exists) throw Exception('User profile not found');

    final data = doc.data()!;
    return UserProfile.fromJson({
      ...data,
      'created_at':
          (data['created_at'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String mobile,
  }) async {
    await _firestore.collection('user_profiles').doc(userId).update({
      'name': name,
      'mobile': mobile,
    });
  }

  Future<void> updateTrialsRemaining(String userId, int remaining) async {
    await _firestore.collection('user_profiles').doc(userId).update({
      'trials_remaining': remaining,
    });
  }

  Future<void> addGamesToUser(String userId, int gamesToAdd) async {
    final docRef = _firestore.collection('user_profiles').doc(userId);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentGames = doc.data()?['available_games'] as int? ?? 0;
      await docRef.update({
        'available_games': currentGames + gamesToAdd,
      });
    }
  }

  Future<void> decrementAvailableGames(String userId) async {
    final docRef = _firestore.collection('user_profiles').doc(userId);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentGames = doc.data()?['available_games'] as int? ?? 0;
      if (currentGames > 0) {
        await docRef.update({
          'available_games': currentGames - 1,
        });
      }
    }
  }

  // Category Methods
  Future<List<MainCategory>> getMainCategories() async {
    final snapshot = await _firestore
        .collection('main_categories')
        .where('is_active', isEqualTo: true)
        .orderBy('order_num')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MainCategory.fromJson({
        'id': doc.id,
        ...data,
        'order': data['order_num'] ?? 0,
      });
    }).toList();
  }

  Future<List<SubCategory>> getSubCategoriesByMainCategory(
      String mainCategoryId) async {
    final snapshot = await _firestore
        .collection('sub_categories')
        .where('main_category_id', isEqualTo: mainCategoryId)
        .where('is_active', isEqualTo: true)
        .orderBy('order_num')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SubCategory.fromJson({
        'id': doc.id,
        ...data,
        'order': data['order_num'] ?? 0,
      });
    }).toList();
  }

  // Question Methods
  Future<List<Question>> getQuestionsBySubCategory(String subCategoryId) async {
    final snapshot = await _firestore
        .collection('questions')
        .where('sub_category_id', isEqualTo: subCategoryId)
        .where('is_active', isEqualTo: true)
        .orderBy('order_num')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Question.fromJson({
        'id': doc.id,
        ...data,
        'order': data['order_num'] ?? 0,
      });
    }).toList();
  }

  Future<Question?> getQuestionById(String questionId) async {
    final doc = await _firestore.collection('questions').doc(questionId).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return Question.fromJson({
      'id': doc.id,
      ...data,
      'order': data['order_num'] ?? 0,
    });
  }

  // Game Methods
  Future<String> createGame({
    required String userId,
    required String gameName,
    required String leftTeamName,
    required String rightTeamName,
    required List<String> selectedSubcategories,
  }) async {
    final gameRef = await _firestore.collection('games').add({
      'user_id': userId,
      'game_name': gameName,
      'left_team_name': leftTeamName,
      'right_team_name': rightTeamName,
      'left_team_score': 0,
      'right_team_score': 0,
      'current_turn': 'left',
      'status': 'active',
      'winner': null,
      'played_questions': [],
      'selected_subcategories': selectedSubcategories,
      'play_count': 1,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'completed_at': null,
    });

    return gameRef.id;
  }

  Future<GameRecord> getGameById(String gameId) async {
    final doc = await _firestore.collection('games').doc(gameId).get();

    if (!doc.exists) throw Exception('Game not found');

    final data = doc.data()!;
    return GameRecord.fromJson({
      'id': doc.id,
      ...data,
      'created_at':
          (data['created_at'] as Timestamp).toDate().toIso8601String(),
      'updated_at':
          (data['updated_at'] as Timestamp).toDate().toIso8601String(),
      'completed_at': data['completed_at'] != null
          ? (data['completed_at'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  Future<List<GameRecord>> getUserGames(String userId) async {
    final snapshot = await _firestore
        .collection('games')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return GameRecord.fromJson({
        'id': doc.id,
        ...data,
        'created_at':
            (data['created_at'] as Timestamp).toDate().toIso8601String(),
        'updated_at':
            (data['updated_at'] as Timestamp).toDate().toIso8601String(),
        'completed_at': data['completed_at'] != null
            ? (data['completed_at'] as Timestamp).toDate().toIso8601String()
            : null,
      });
    }).toList();
  }

  Future<void> updateGameScore({
    required String gameId,
    required int leftTeamScore,
    required int rightTeamScore,
    required String currentTurn,
  }) async {
    await _firestore.collection('games').doc(gameId).update({
      'left_team_score': leftTeamScore,
      'right_team_score': rightTeamScore,
      'current_turn': currentTurn,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addPlayedQuestion(String gameId, String questionId) async {
    await _firestore.collection('games').doc(gameId).update({
      'played_questions': FieldValue.arrayUnion([questionId]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeGame({
    required String gameId,
    required String status,
    required String? winner,
  }) async {
    await _firestore.collection('games').doc(gameId).update({
      'status': status,
      'winner': winner,
      'completed_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGamePlayCount(String gameId, int playCount) async {
    await _firestore.collection('games').doc(gameId).update({
      'play_count': playCount,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resetGameForReplay(String gameId) async {
    await _firestore.collection('games').doc(gameId).update({
      'status': 'active',
      'left_team_score': 0,
      'right_team_score': 0,
      'current_turn': 'left',
      'played_questions': [],
      'winner': null,
      'completed_at': null,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
