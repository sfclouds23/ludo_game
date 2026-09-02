import 'app_environment.dart';

class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  final AppEnvironment environment;
  final String apiBaseUrl;

  static AppConfig fromEnvironment() {
    const environmentValue = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );

    final AppEnvironment environment = AppEnvironment.fromValue(
      environmentValue,
    );

    return forEnvironment(environment);
  }

  static AppConfig forEnvironment(AppEnvironment environment) {
    return switch (environment) {
      AppEnvironment.development => const AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'http://localhost:3000',
      ),
      AppEnvironment.staging => const AppConfig(
        environment: AppEnvironment.staging,
        apiBaseUrl: 'https://staging-api.example.com',
      ),
      AppEnvironment.production => const AppConfig(
        environment: AppEnvironment.production,
        apiBaseUrl: 'https://api.example.com',
      ),
    };
  }
}
