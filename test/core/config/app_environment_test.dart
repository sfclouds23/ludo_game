import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/core/config/app_environment.dart';

void main() {
  group('AppEnvironment.fromValue', () {
    test('returns development for development value', () {
      expect(
        AppEnvironment.fromValue('development'),
        AppEnvironment.development,
      );
    });

    test('returns staging for staging value', () {
      expect(AppEnvironment.fromValue('staging'), AppEnvironment.staging);
    });

    test('returns production for production value', () {
      expect(AppEnvironment.fromValue('production'), AppEnvironment.production);
    });

    test('throws ArgumentError for unsupported environment', () {
      expect(() => AppEnvironment.fromValue('prodution'), throwsArgumentError);
    });
  });
}
