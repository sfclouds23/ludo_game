import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_painter.dart';

void main() {
  group('LudoToken', () {
    testWidgets('renders at the requested square dimension', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: LudoToken(
              tokenId: 'red_token_0',
              playerColor: PlayerColor.red,
              dimension: 48,
            ),
          ),
        ),
      );

      final repaintBoundary = find.byKey(
        LudoToken.repaintBoundaryKeyFor('red_token_0'),
      );

      expect(repaintBoundary, findsOneWidget);
      expect(tester.getSize(repaintBoundary), const Size.square(48));
    });

    testWidgets('uses the player color in its token painter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: LudoToken(
              tokenId: 'green_token_0',
              playerColor: PlayerColor.green,
              dimension: 48,
            ),
          ),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byKey(LudoToken.repaintBoundaryKeyFor('green_token_0')),
          matching: find.byType(CustomPaint),
        ),
      );

      final painter = customPaint.painter as LudoTokenPainter;

      expect(painter.playerColor, PlayerColor.green);
    });

    testWidgets('isolates each token behind a unique repaint boundary', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Row(
            children: [
              LudoToken(
                tokenId: 'blue_token_0',
                playerColor: PlayerColor.blue,
                dimension: 40,
              ),
              LudoToken(
                tokenId: 'blue_token_1',
                playerColor: PlayerColor.blue,
                dimension: 40,
              ),
            ],
          ),
        ),
      );

      final firstBoundary = find.byKey(
        LudoToken.repaintBoundaryKeyFor('blue_token_0'),
      );
      final secondBoundary = find.byKey(
        LudoToken.repaintBoundaryKeyFor('blue_token_1'),
      );

      expect(firstBoundary, findsOneWidget);
      expect(secondBoundary, findsOneWidget);
      expect(tester.widget(firstBoundary), isA<RepaintBoundary>());
      expect(tester.widget(secondBoundary), isA<RepaintBoundary>());
    });

    testWidgets('provides an accessible player-color label', (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: LudoToken(
              tokenId: 'yellow_token_0',
              playerColor: PlayerColor.yellow,
              dimension: 48,
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('yellow Ludo token'), findsOneWidget);

      // Dispose before Flutter performs its end-of-test handle verification.
      semanticsHandle.dispose();
    });

    testWidgets('updates its painter when player color changes', (
      tester,
    ) async {
      Widget buildToken(PlayerColor playerColor) {
        return MaterialApp(
          home: Center(
            child: LudoToken(
              tokenId: 'preview_token',
              playerColor: playerColor,
              dimension: 48,
            ),
          ),
        );
      }

      await tester.pumpWidget(buildToken(PlayerColor.red));
      await tester.pumpWidget(buildToken(PlayerColor.blue));

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byKey(LudoToken.repaintBoundaryKeyFor('preview_token')),
          matching: find.byType(CustomPaint),
        ),
      );

      final painter = customPaint.painter as LudoTokenPainter;

      expect(painter.playerColor, PlayerColor.blue);
    });
  });
}
