import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board_painter.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_layer.dart';

void main() {
  Widget buildBoard(List<Token> tokens) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.square(
            dimension: 300,
            child: LudoBoard(tokens: tokens, maximumDimension: 300),
          ),
        ),
      ),
    );
  }

  group('LudoBoard token integration', () {
    testWidgets('renders no tokens by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.square(
            dimension: 300,
            child: LudoBoard(maximumDimension: 300),
          ),
        ),
      );

      expect(find.byType(LudoToken), findsNothing);
      expect(find.byType(LudoTokenLayer), findsOneWidget);
    });

    testWidgets('passes logical tokens to the dynamic layer', (tester) async {
      const tokens = [
        Token(
          id: 'red_token_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.yard(),
        ),
        Token(
          id: 'green_token_0',
          ownerColor: PlayerColor.green,
          position: TokenPosition.yard(),
        ),
      ];

      await tester.pumpWidget(buildBoard(tokens));

      expect(find.byType(LudoToken), findsNWidgets(2));
      expect(
        find.byKey(LudoToken.repaintBoundaryKeyFor('red_token_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(LudoToken.repaintBoundaryKeyFor('green_token_0')),
        findsOneWidget,
      );
    });

    testWidgets('keeps static board and token repaint boundaries separate', (
      tester,
    ) async {
      const token = Token(
        id: 'blue_token_0',
        ownerColor: PlayerColor.blue,
        position: TokenPosition.yard(),
      );

      await tester.pumpWidget(buildBoard(const [token]));

      final boardBoundary = find.byKey(LudoBoard.repaintBoundaryKey);
      final tokenLayerBoundary = find.byKey(LudoTokenLayer.repaintBoundaryKey);

      expect(boardBoundary, findsOneWidget);
      expect(tokenLayerBoundary, findsOneWidget);
      expect(tester.widget(boardBoundary), isA<RepaintBoundary>());
      expect(tester.widget(tokenLayerBoundary), isA<RepaintBoundary>());

      // Neither repaint boundary is nested inside the other.
      expect(
        find.descendant(of: boardBoundary, matching: tokenLayerBoundary),
        findsNothing,
      );
      expect(
        find.descendant(of: tokenLayerBoundary, matching: boardBoundary),
        findsNothing,
      );
    });

    testWidgets('keeps the production board painter static', (tester) async {
      const token = Token(
        id: 'yellow_token_0',
        ownerColor: PlayerColor.yellow,
        position: TokenPosition.yard(),
      );

      await tester.pumpWidget(buildBoard(const [token]));

      final boardPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byKey(LudoBoard.repaintBoundaryKey),
          matching: find.byType(CustomPaint),
        ),
      );

      expect(boardPaint.painter, isA<LudoBoardPainter>());
      expect(
        boardPaint.painter!.shouldRepaint(const LudoBoardPainter()),
        isFalse,
      );
    });

    testWidgets('repositions a token when logical state changes', (
      tester,
    ) async {
      const yardToken = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.yard(),
      );

      await tester.pumpWidget(buildBoard(const [yardToken]));

      final positionFinder = find.byKey(
        const ValueKey<String>('ludo-token-position-red_token_0'),
      );

      final yardPosition = tester.widget<Positioned>(positionFinder);

      expect(yardPosition.left, closeTo(26.5, 0.001));
      expect(yardPosition.top, closeTo(26.5, 0.001));

      final pathToken = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.onPath(0),
      );

      await tester.pumpWidget(buildBoard([pathToken]));

      final pathPosition = tester.widget<Positioned>(positionFinder);

      // Red progress zero maps to main_0, centered at (30, 130).
      expect(pathPosition.left, closeTo(16.5, 0.001));
      expect(pathPosition.top, closeTo(116.5, 0.001));
    });
  });
}
