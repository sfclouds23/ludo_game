import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/core/config/app_config.dart';
import 'package:ludo_game/core/config/app_environment.dart';
import 'package:ludo_game/main.dart';

void main() {
  testWidgets('displays development environment configuration', (
    WidgetTester tester,
  ) async {
    // Create a known configuration explicitly so this test does not depend
    // on command-line --dart-define values.
    const AppConfig config = AppConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: 'http://localhost:3000',
    );

    // Render the root Ludo application using our test configuration.
    await tester.pumpWidget(
      const LudoApp(config: config),
    );

    // Verify that the selected environment is rendered.
    expect(
      find.text('Environment: development'),
      findsOneWidget,
    );

    // Verify that the API URL comes from the supplied configuration.
    expect(
      find.text('API: http://localhost:3000'),
      findsOneWidget,
    );
  });
}