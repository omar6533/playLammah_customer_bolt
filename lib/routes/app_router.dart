import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trivia_game/screens/payment_failure_screen.dart.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/category_selection_screen.dart';
import '../screens/game_setup_screen.dart';
import '../screens/question_grid_screen.dart';
import '../screens/question_display_screen.dart';
import '../screens/my_games_screen.dart';
import '../screens/purchase_games_screen.dart';
import '../screens/game_over_screen.dart';
import '../screens/payment_success_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(page: LandingRoute.page),
        AutoRoute(page: CategorySelectionRoute.page),
        AutoRoute(page: GameSetupRoute.page),
        AutoRoute(page: QuestionGridRoute.page),
        AutoRoute(page: QuestionDisplayRoute.page),
        AutoRoute(page: MyGamesRoute.page),
        AutoRoute(page: PurchaseGamesRoute.page),
        AutoRoute(page: GameOverRoute.page),
        AutoRoute(page: PaymentSuccessRoute.page),
        AutoRoute(page: PaymentFailureRoute.page),
      ];
}
