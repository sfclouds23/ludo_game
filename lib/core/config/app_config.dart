import 'app_environment.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;

  static AppConfig fromEnvironment() {
    const environmentValue = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );

    switch (environmentValue) {
      case 'staging':
        return const AppConfig(
          environment: AppEnvironment.staging,
          apiBaseUrl: 'https://staging-api.example.com',
        );

      case 'production':
        return const AppConfig(
          environment: AppEnvironment.production,
          apiBaseUrl: 'https://api.example.com',
        );

      case 'development':
      default:
        return const AppConfig(
          environment: AppEnvironment.development,
          apiBaseUrl: 'http://localhost:3000',
        );
    }
  }
}