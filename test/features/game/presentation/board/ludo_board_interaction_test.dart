import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_layer.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_visual_state.dart';

void main() {
  const tokenId = 'red_token_0';

  final token = Token(
    id: tokenId,
    ownerColor: PlayerColor.red,
    position: TokenPosition.onPath(0),
  );

  Widget buildBoard({
    Map<String, LudoTokenVisualState> visualStates = const {},
    ValueChanged<String>? onTokenPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox.square(
          dimension: 600,
          child: LudoBoard(
            tokens: [token],
            visualStates: visualStates,
            onTokenPressed: onTokenPressed,
          ),
        ),
      ),
    );
  }

  LudoTokenLayer currentTokenLayer(WidgetTester tester) {
    return tester.widget<LudoTokenLayer>(find.byType(LudoTokenLayer));
  }

  LudoToken currentToken(WidgetTester tester) {
    return tester.widget<LudoToken>(find.byType(LudoToken));
  }

  group('LudoBoard interaction forwarding', () {
    testWidgets('forwards visual states to the token layer', (tester) async {
      const visualState = LudoTokenVisualState(
        isMovable: true,
        isSelected: true,
      );
      const visualStates = <String, LudoTokenVisualState>{tokenId: visualState};

      await tester.pumpWidget(buildBoard(visualStates: visualStates));

      expect(currentTokenLayer(tester).visualStates, visualStates);
      expect(currentToken(tester).visualState, visualState);
    });

    testWidgets('uses idle presentation when no state is supplied', (
      tester,
    ) async {
      await tester.pumpWidget(buildBoard());

      expect(currentTokenLayer(tester).visualStates, isEmpty);
      expect(currentToken(tester).visualState, LudoTokenVisualState.idle);
    });

    testWidgets('forwards token presses to the owning caller', (tester) async {
      String? pressedTokenId;

      await tester.pumpWidget(
        buildBoard(
          onTokenPressed: (selectedTokenId) {
            pressedTokenId = selectedTokenId;
          },
        ),
      );

      await tester.tap(find.byKey(LudoToken.repaintBoundaryKeyFor(tokenId)));

      expect(pressedTokenId, tokenId);
    });

    testWidgets('does not infer interaction from movable presentation', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(
          visualStates: const {tokenId: LudoTokenVisualState(isMovable: true)},
        ),
      );

      final renderedToken = currentToken(tester);

      // A movable appearance alone must not create an interaction callback.
      // The authoritative caller remains responsible for supplying one.
      expect(renderedToken.visualState.isMovable, isTrue);
      expect(renderedToken.onPressed, isNull);
    });

    testWidgets('forwards callbacks independently of movable presentation', (
      tester,
    ) async {
      var pressCount = 0;

      await tester.pumpWidget(
        buildBoard(
          onTokenPressed: (_) {
            pressCount++;
          },
        ),
      );

      final renderedToken = currentToken(tester);

      // An idle visual state does not suppress a callback supplied by the
      // caller. The presentation layer never performs legal-move validation.
      expect(renderedToken.visualState.isMovable, isFalse);
      expect(renderedToken.onPressed, isNotNull);

      await tester.tap(find.byKey(LudoToken.repaintBoundaryKeyFor(tokenId)));

      expect(pressCount, 1);
    });

    testWidgets('keeps static and dynamic repaint boundaries separate', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildBoard(
          visualStates: const {tokenId: LudoTokenVisualState(isSelected: true)},
        ),
      );

      expect(find.byKey(LudoBoard.repaintBoundaryKey), findsOneWidget);
      expect(find.byKey(LudoTokenLayer.repaintBoundaryKey), findsOneWidget);
      expect(
        find.byKey(LudoToken.repaintBoundaryKeyFor(tokenId)),
        findsOneWidget,
      );
    });
  });
}
