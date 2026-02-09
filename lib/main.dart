import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/bloc/auth/auth_event.dart';
import 'firebase_options.dart';
import 'config/app_config.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/category/category_bloc.dart';
import 'bloc/game/game_bloc.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/question/question_bloc.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.useMockData) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const TriviaGameApp());
}

class TriviaGameApp extends StatelessWidget {
  const TriviaGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(const CheckAuthEvent()),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(),
        ),
        BlocProvider<GameBloc>(
          create: (context) => GameBloc(userId: ''),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        BlocProvider<QuestionBloc>(
          create: (context) => QuestionBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme(),
        routerConfig: appRouter.config(),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor:
                  MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
