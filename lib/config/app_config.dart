class AppConfig {
  static const bool useMockData = true;

  static const String appName = 'Play Lammah';
  static const String appNameAr = 'لعبة الأسئلة';

  static const int initialTrials = 1;
  static const int maxQuestionsPerGame = 25;

  static Map<int, int> get trialPackages => {
        5: 50,
        10: 90,
        20: 150,
      };
}
