import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/core/config/app_config.dart';
import 'package:ludo_game/core/config/app_environment.dart';

void main() {
  group('AppConfig.forEnvironment', () {
    test('creates development configuration', () {
      final AppConfig config = AppConfig.forEnvironment(
        AppEnvironment.development,
      );

      expect(config.environment, AppEnvironment.development);
      expect(config.apiBaseUrl, 'http://localhost:3000');
    });

    test('creates staging configuration', () {
      final AppConfig config = AppConfig.forEnvironment(AppEnvironment.staging);

      expect(config.environment, AppEnvironment.staging);
      expect(config.apiBaseUrl, 'https://staging-api.example.com');
    });

    test('creates production configuration', () {
      final AppConfig config = AppConfig.forEnvironment(
        AppEnvironment.production,
      );

      expect(config.environment, AppEnvironment.production);
      expect(config.apiBaseUrl, 'https://api.example.com');
    });
  });
}
