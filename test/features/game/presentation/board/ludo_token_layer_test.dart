import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_layer.dart';

void main() {
  Widget buildLayer({required List<Token> tokens, double boardSize = 300}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.square(
            dimension: boardSize,
            child: LudoTokenLayer(tokens: tokens),
          ),
        ),
      ),
    );
  }

  Finder positionedToken(String tokenId) {
    return find.byKey(ValueKey<String>('ludo-token-position-$tokenId'));
  }

  group('LudoTokenLayer', () {
    testWidgets('renders an empty isolated token layer', (tester) async {
      await tester.pumpWidget(buildLayer(tokens: const []));

      expect(find.byKey(LudoTokenLayer.repaintBoundaryKey), findsOneWidget);
      expect(find.byType(LudoToken), findsNothing);
      expect(
        tester.getSize(find.byKey(LudoTokenLayer.repaintBoundaryKey)),
        const Size.square(300),
      );
    });

    testWidgets('positions a yard token in its assigned slot', (tester) async {
      const token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.yard(),
      );

      await tester.pumpWidget(buildLayer(tokens: const [token]));

      final positioned = tester.widget<Positioned>(positionedToken(token.id));

      // A 300-pixel board has 20-pixel cells. The token dimension is
      // 20 × 1.35 = 27 and the first red yard center is (40, 40).
      expect(positioned.left, closeTo(26.5, 0.001));
      expect(positioned.top, closeTo(26.5, 0.001));
      expect(positioned.width, closeTo(27, 0.001));
      expect(positioned.height, closeTo(27, 0.001));

      expect(
        find.byKey(LudoToken.repaintBoundaryKeyFor(token.id)),
        findsOneWidget,
      );
    });

    testWidgets('positions a token on its owner-relative path', (tester) async {
      final token = Token(
        id: 'green_token_0',
        ownerColor: PlayerColor.green,
        position: TokenPosition.onPath(0),
      );

      await tester.pumpWidget(buildLayer(tokens: [token]));

      final positioned = tester.widget<Positioned>(positionedToken(token.id));

      // Green progress zero maps to main_13, centered at (170, 30).
      expect(positioned.left, closeTo(156.5, 0.001));
      expect(positioned.top, closeTo(16.5, 0.001));
    });

    testWidgets('assigns yard slots deterministically by token ID', (
      tester,
    ) async {
      const tokenOne = Token(
        id: 'red_token_1',
        ownerColor: PlayerColor.red,
        position: TokenPosition.yard(),
      );
      const tokenZero = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.yard(),
      );

      // The input is deliberately reversed. Sorted stable IDs must still put
      // token zero in slot zero and token one in slot one.
      await tester.pumpWidget(buildLayer(tokens: const [tokenOne, tokenZero]));

      final zeroPosition = tester.widget<Positioned>(
        positionedToken(tokenZero.id),
      );
      final onePosition = tester.widget<Positioned>(
        positionedToken(tokenOne.id),
      );

      expect(zeroPosition.left, closeTo(26.5, 0.001));
      expect(zeroPosition.top, closeTo(26.5, 0.001));
      expect(onePosition.left, closeTo(66.5, 0.001));
      expect(onePosition.top, closeTo(26.5, 0.001));
    });

    testWidgets('scales token placement with the board', (tester) async {
      const token = Token(
        id: 'yellow_token_0',
        ownerColor: PlayerColor.yellow,
        position: TokenPosition.yard(),
      );

      await tester.pumpWidget(
        buildLayer(tokens: const [token], boardSize: 300),
      );

      final smallPosition = tester.widget<Positioned>(
        positionedToken(token.id),
      );
      final smallLeft = smallPosition.left!;
      final smallTop = smallPosition.top!;
      final smallWidth = smallPosition.width!;

      await tester.pumpWidget(
        buildLayer(tokens: const [token], boardSize: 600),
      );

      final largePosition = tester.widget<Positioned>(
        positionedToken(token.id),
      );

      expect(largePosition.left, closeTo(smallLeft * 2, 0.001));
      expect(largePosition.top, closeTo(smallTop * 2, 0.001));
      expect(largePosition.width, closeTo(smallWidth * 2, 0.001));
    });

    testWidgets('rejects duplicate token IDs', (tester) async {
      const firstToken = Token(
        id: 'duplicate_token',
        ownerColor: PlayerColor.red,
        position: TokenPosition.yard(),
      );
      const secondToken = Token(
        id: 'duplicate_token',
        ownerColor: PlayerColor.green,
        position: TokenPosition.yard(),
      );

      await tester.pumpWidget(
        buildLayer(tokens: const [firstToken, secondToken]),
      );

      expect(tester.takeException(), isA<StateError>());
    });

    testWidgets('rejects more than four yard tokens for one player', (
      tester,
    ) async {
      const tokens = [
        Token(
          id: 'blue_token_0',
          ownerColor: PlayerColor.blue,
          position: TokenPosition.yard(),
        ),
        Token(
          id: 'blue_token_1',
          ownerColor: PlayerColor.blue,
          position: TokenPosition.yard(),
        ),
        Token(
          id: 'blue_token_2',
          ownerColor: PlayerColor.blue,
          position: TokenPosition.yard(),
        ),
        Token(
          id: 'blue_token_3',
          ownerColor: PlayerColor.blue,
          position: TokenPosition.yard(),
        ),
        Token(
          id: 'blue_token_4',
          ownerColor: PlayerColor.blue,
          position: TokenPosition.yard(),
        ),
      ];

      await tester.pumpWidget(buildLayer(tokens: tokens));

      expect(tester.takeException(), isA<StateError>());
    });
  });
}
