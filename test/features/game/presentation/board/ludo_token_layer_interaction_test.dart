import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_painter.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_layer.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_visual_state.dart';

void main() {
  const tokenId = 'red_token_0';

  final token = Token(
    id: tokenId,
    ownerColor: PlayerColor.red,
    position: TokenPosition.onPath(0),
  );

  Widget buildLayer({
    Map<String, LudoTokenVisualState> visualStates = const {},
    ValueChanged<String>? onTokenPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.square(
            dimension: 600,
            child: LudoTokenLayer(
              tokens: [token],
              visualStates: visualStates,
              onTokenPressed: onTokenPressed,
            ),
          ),
        ),
      ),
    );
  }

  /// Returns the single token created by the layer.
  LudoToken currentToken(WidgetTester tester) {
    return tester.widget<LudoToken>(find.byType(LudoToken));
  }

  /// Returns the painter contained inside the rendered token.
  LudoTokenPainter currentPainter(WidgetTester tester) {
    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(LudoToken),
        matching: find.byType(CustomPaint),
      ),
    );

    return customPaint.painter as LudoTokenPainter;
  }

  group('LudoTokenLayer interaction presentation', () {
    testWidgets('forwards visual state to the matching token', (tester) async {
      const visualState = LudoTokenVisualState(
        isMovable: true,
        isSelected: true,
        isMoving: true,
      );

      await tester.pumpWidget(
        buildLayer(visualStates: const {tokenId: visualState}),
      );

      expect(currentToken(tester).visualState, visualState);
      expect(currentPainter(tester).visualState, visualState);
    });

    testWidgets('uses idle state when no visual state is supplied', (
      tester,
    ) async {
      await tester.pumpWidget(buildLayer());

      expect(currentToken(tester).visualState, LudoTokenVisualState.idle);
      expect(currentPainter(tester).visualState, LudoTokenVisualState.idle);
    });

    testWidgets('ignores visual states belonging to unknown token IDs', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLayer(
          visualStates: const {
            'unknown_token': LudoTokenVisualState(isSelected: true),
          },
        ),
      );

      expect(currentToken(tester).visualState, LudoTokenVisualState.idle);
    });

    testWidgets('forwards the pressed token ID to the caller', (tester) async {
      String? pressedTokenId;

      await tester.pumpWidget(
        buildLayer(
          onTokenPressed: (selectedTokenId) {
            pressedTokenId = selectedTokenId;
          },
        ),
      );

      await tester.tap(find.byKey(LudoToken.repaintBoundaryKeyFor(tokenId)));

      expect(pressedTokenId, tokenId);
    });

    testWidgets('forwards presses even when visual state is idle', (
      tester,
    ) async {
      var pressCount = 0;

      await tester.pumpWidget(
        buildLayer(
          onTokenPressed: (_) {
            pressCount++;
          },
        ),
      );

      // The layer displays the supplied state but does not use that state to
      // decide whether the caller-provided callback is allowed to execute.
      expect(currentToken(tester).visualState.isMovable, isFalse);
      expect(currentToken(tester).onPressed, isNotNull);

      await tester.tap(find.byKey(LudoToken.repaintBoundaryKeyFor(tokenId)));

      expect(pressCount, 1);
    });

    testWidgets('does not expose token interaction without a callback', (
      tester,
    ) async {
      await tester.pumpWidget(buildLayer());

      expect(currentToken(tester).onPressed, isNull);

      final gestureDetector = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(LudoToken),
          matching: find.byType(GestureDetector),
        ),
      );

      expect(gestureDetector.onTap, isNull);
    });

    testWidgets('derives path presentation from the token position', (
      tester,
    ) async {
      await tester.pumpWidget(buildLayer());

      final renderedToken = currentToken(tester);

      expect(renderedToken.isInYard, isFalse);
      expect(renderedToken.isFinished, isFalse);
    });
  });
}
