import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/core/config/app_config.dart';
import 'package:ludo_game/core/config/app_config_provider.dart';
import 'package:ludo_game/core/config/app_environment.dart';
import 'package:ludo_game/app/app.dart';

void main() {
  testWidgets('loads home route with development configuration', (
    WidgetTester tester,
  ) async {
    const AppConfig config = AppConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: 'http://localhost:3000',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(config)],
        child: const LudoApp(),
      ),
    );

    expect(find.text('Environment: development'), findsOneWidget);

    expect(find.text('API: http://localhost:3000'), findsOneWidget);
    expect(find.text('Ludo Home'), findsOneWidget);
  });
}
