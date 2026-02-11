class AppConfig {
  static const bool useMockData = true;

  static const String appName = 'لمة | Lammh';
  static const String appNameAr = 'لمة';

  static const int initialTrials = 1;
  static const int maxQuestionsPerGame = 25;

  static Map<int, int> get trialPackages => {
        5: 50,
        10: 90,
        20: 150,
      };

  static const String moyasarApiKey = String.fromEnvironment(
    'MOYASAR_API_KEY',
    defaultValue: 'sk_test_robGjy5X6JrL3Wn8sbwneY9Mrb2xZtu6bARVZSBS',
  );

  static const String paymentCallbackUrl =
      'https://allmahgame.com/customer/payment-callback';
  static const String paymentSuccessUrl =
      'https://playlammh.com/customer/#/payment-success-route';
}
