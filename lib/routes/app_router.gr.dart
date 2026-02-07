// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CategorySelectionScreen]
class CategorySelectionRoute extends PageRouteInfo<void> {
  const CategorySelectionRoute({List<PageRouteInfo>? children})
      : super(CategorySelectionRoute.name, initialChildren: children);

  static const String name = 'CategorySelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CategorySelectionScreen();
    },
  );
}

/// generated route for
/// [GameOverScreen]
class GameOverRoute extends PageRouteInfo<void> {
  const GameOverRoute({List<PageRouteInfo>? children})
      : super(GameOverRoute.name, initialChildren: children);

  static const String name = 'GameOverRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GameOverScreen();
    },
  );
}

/// generated route for
/// [GameSetupScreen]
class GameSetupRoute extends PageRouteInfo<GameSetupRouteArgs> {
  GameSetupRoute({
    Key? key,
    required List<String> selectedSubcategories,
    List<PageRouteInfo>? children,
  }) : super(
          GameSetupRoute.name,
          args: GameSetupRouteArgs(
            key: key,
            selectedSubcategories: selectedSubcategories,
          ),
          initialChildren: children,
        );

  static const String name = 'GameSetupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GameSetupRouteArgs>();
      return GameSetupScreen(
        key: args.key,
        selectedSubcategories: args.selectedSubcategories,
      );
    },
  );
}

class GameSetupRouteArgs {
  const GameSetupRouteArgs({this.key, required this.selectedSubcategories});

  final Key? key;

  final List<String> selectedSubcategories;

  @override
  String toString() {
    return 'GameSetupRouteArgs{key: $key, selectedSubcategories: $selectedSubcategories}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameSetupRouteArgs) return false;
    return key == other.key &&
        const ListEquality<String>().equals(
          selectedSubcategories,
          other.selectedSubcategories,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^ const ListEquality<String>().hash(selectedSubcategories);
}

/// generated route for
/// [LandingScreen]
class LandingRoute extends PageRouteInfo<void> {
  const LandingRoute({List<PageRouteInfo>? children})
      : super(LandingRoute.name, initialChildren: children);

  static const String name = 'LandingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LandingScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MyGamesScreen]
class MyGamesRoute extends PageRouteInfo<void> {
  const MyGamesRoute({List<PageRouteInfo>? children})
      : super(MyGamesRoute.name, initialChildren: children);

  static const String name = 'MyGamesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyGamesScreen();
    },
  );
}

/// generated route for
/// [PurchaseGamesScreen]
class PurchaseGamesRoute extends PageRouteInfo<void> {
  const PurchaseGamesRoute({List<PageRouteInfo>? children})
      : super(PurchaseGamesRoute.name, initialChildren: children);

  static const String name = 'PurchaseGamesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PurchaseGamesScreen();
    },
  );
}

/// generated route for
/// [QuestionDisplayScreen]
class QuestionDisplayRoute extends PageRouteInfo<QuestionDisplayRouteArgs> {
  QuestionDisplayRoute({
    Key? key,
    required String gameId,
    required String questionId,
    List<PageRouteInfo>? children,
  }) : super(
          QuestionDisplayRoute.name,
          args: QuestionDisplayRouteArgs(
            key: key,
            gameId: gameId,
            questionId: questionId,
          ),
          initialChildren: children,
        );

  static const String name = 'QuestionDisplayRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuestionDisplayRouteArgs>();
      return QuestionDisplayScreen(
        key: args.key,
        gameId: args.gameId,
        questionId: args.questionId,
      );
    },
  );
}

class QuestionDisplayRouteArgs {
  const QuestionDisplayRouteArgs({
    this.key,
    required this.gameId,
    required this.questionId,
  });

  final Key? key;

  final String gameId;

  final String questionId;

  @override
  String toString() {
    return 'QuestionDisplayRouteArgs{key: $key, gameId: $gameId, questionId: $questionId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuestionDisplayRouteArgs) return false;
    return key == other.key &&
        gameId == other.gameId &&
        questionId == other.questionId;
  }

  @override
  int get hashCode => key.hashCode ^ gameId.hashCode ^ questionId.hashCode;
}

/// generated route for
/// [QuestionGridScreen]
class QuestionGridRoute extends PageRouteInfo<QuestionGridRouteArgs> {
  QuestionGridRoute({
    Key? key,
    required String gameId,
    List<PageRouteInfo>? children,
  }) : super(
          QuestionGridRoute.name,
          args: QuestionGridRouteArgs(key: key, gameId: gameId),
          initialChildren: children,
        );

  static const String name = 'QuestionGridRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuestionGridRouteArgs>();
      return QuestionGridScreen(key: args.key, gameId: args.gameId);
    },
  );
}

class QuestionGridRouteArgs {
  const QuestionGridRouteArgs({this.key, required this.gameId});

  final Key? key;

  final String gameId;

  @override
  String toString() {
    return 'QuestionGridRouteArgs{key: $key, gameId: $gameId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuestionGridRouteArgs) return false;
    return key == other.key && gameId == other.gameId;
  }

  @override
  int get hashCode => key.hashCode ^ gameId.hashCode;
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}
