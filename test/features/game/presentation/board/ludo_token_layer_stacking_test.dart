import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_layer.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_visual_state.dart';

void main() {
  Token createToken({required String id, int pathIndex = 0}) {
    return Token(
      id: id,
      ownerColor: PlayerColor.red,
      position: TokenPosition.onPath(pathIndex),
    );
  }

  Widget buildLayer({
    required List<Token> tokens,
    Map<String, LudoTokenVisualState> visualStates = const {},
    ValueChanged<String>? onTokenPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.square(
            dimension: 600,
            child: LudoTokenLayer(
              tokens: tokens,
              visualStates: visualStates,
              onTokenPressed: onTokenPressed,
            ),
          ),
        ),
      ),
    );
  }

  Positioned positionedToken(WidgetTester tester, String tokenId) {
    return tester.widget<Positioned>(
      find.byKey(ValueKey<String>('ludo-token-position-$tokenId')),
    );
  }

  Offset positionedCenter(WidgetTester tester, String tokenId) {
    final positioned = positionedToken(tester, tokenId);

    return Offset(
      positioned.left! + positioned.width! / 2,
      positioned.top! + positioned.height! / 2,
    );
  }

  LudoToken renderedToken(WidgetTester tester, String tokenId) {
    final repaintBoundary = find.byKey(
      LudoToken.repaintBoundaryKeyFor(tokenId),
    );

    return tester.widget<LudoToken>(
      find.ancestor(of: repaintBoundary, matching: find.byType(LudoToken)),
    );
  }

  Stack tokenStack(WidgetTester tester) {
    return tester.widget<Stack>(
      find.descendant(
        of: find.byKey(LudoTokenLayer.repaintBoundaryKey),
        matching: find.byType(Stack),
      ),
    );
  }

  group('LudoTokenLayer stacking presentation', () {
    testWidgets('keeps a single token at its full presentation size', (
      tester,
    ) async {
      final token = createToken(id: 'red_token_0');

      await tester.pumpWidget(buildLayer(tokens: [token]));

      final positioned = positionedToken(tester, token.id);

      // A 600-pixel board contains fifteen logical cells. The normal token
      // dimension is 1.35 times the resulting 40-pixel cell size.
      expect(positioned.width, closeTo(54, 0.001));
      expect(positioned.height, closeTo(54, 0.001));
      expect(renderedToken(tester, token.id).dimension, closeTo(54, 0.001));
    });

    testWidgets('separates tokens sharing one visual coordinate', (
      tester,
    ) async {
      final firstToken = createToken(id: 'red_token_0');
      final secondToken = createToken(id: 'red_token_1');

      await tester.pumpWidget(buildLayer(tokens: [firstToken, secondToken]));

      final firstCenter = positionedCenter(tester, firstToken.id);
      final secondCenter = positionedCenter(tester, secondToken.id);

      expect(firstCenter, isNot(secondCenter));
      expect(firstCenter.dx, lessThan(secondCenter.dx));
      expect(firstCenter.dy, secondCenter.dy);
    });

    testWidgets('reduces dimensions of tokens sharing one coordinate', (
      tester,
    ) async {
      final firstToken = createToken(id: 'red_token_0');
      final secondToken = createToken(id: 'red_token_1');

      await tester.pumpWidget(buildLayer(tokens: [firstToken, secondToken]));

      final firstPositioned = positionedToken(tester, firstToken.id);
      final secondPositioned = positionedToken(tester, secondToken.id);

      expect(firstPositioned.width, lessThan(54));
      expect(secondPositioned.width, firstPositioned.width);
      expect(firstPositioned.height, firstPositioned.width);
      expect(secondPositioned.height, secondPositioned.width);

      expect(
        renderedToken(tester, firstToken.id).dimension,
        firstPositioned.width,
      );
      expect(
        renderedToken(tester, secondToken.id).dimension,
        secondPositioned.width,
      );
    });

    testWidgets('does not stack tokens at different coordinates', (
      tester,
    ) async {
      final firstToken = createToken(id: 'red_token_0', pathIndex: 0);
      final secondToken = createToken(id: 'red_token_1', pathIndex: 1);

      await tester.pumpWidget(buildLayer(tokens: [firstToken, secondToken]));

      expect(positionedToken(tester, firstToken.id).width, closeTo(54, 0.001));
      expect(positionedToken(tester, secondToken.id).width, closeTo(54, 0.001));
    });

    testWidgets('keeps stack placement stable when input order changes', (
      tester,
    ) async {
      final firstToken = createToken(id: 'red_token_0');
      final secondToken = createToken(id: 'red_token_1');

      await tester.pumpWidget(buildLayer(tokens: [firstToken, secondToken]));

      final initialFirstCenter = positionedCenter(tester, firstToken.id);
      final initialSecondCenter = positionedCenter(tester, secondToken.id);

      await tester.pumpWidget(buildLayer(tokens: [secondToken, firstToken]));

      expect(positionedCenter(tester, firstToken.id), initialFirstCenter);
      expect(positionedCenter(tester, secondToken.id), initialSecondCenter);
    });

    testWidgets('paints a selected token above idle stack members', (
      tester,
    ) async {
      final selectedToken = createToken(id: 'red_token_0');
      final idleToken = createToken(id: 'red_token_1');

      await tester.pumpWidget(
        buildLayer(
          // Put the selected token first to prove that caller list order does
          // not prevent the layer from giving it the highest visual priority.
          tokens: [selectedToken, idleToken],
          visualStates: {
            selectedToken.id: const LudoTokenVisualState(isSelected: true),
          },
        ),
      );

      final positionedChildren = tokenStack(tester).children
          .whereType<Positioned>()
          .toList();

      expect(
        positionedChildren.last.key,
        ValueKey<String>('ludo-token-position-${selectedToken.id}'),
      );
    });

    testWidgets('uses selected, moving, movable, then idle paint order', (
      tester,
    ) async {
      final selectedToken = createToken(id: 'token_selected');
      final movingToken = createToken(id: 'token_moving');
      final movableToken = createToken(id: 'token_movable');
      final idleToken = createToken(id: 'token_idle');

      await tester.pumpWidget(
        buildLayer(
          tokens: [selectedToken, movingToken, movableToken, idleToken],
          visualStates: {
            selectedToken.id: const LudoTokenVisualState(isSelected: true),
            movingToken.id: const LudoTokenVisualState(isMoving: true),
            movableToken.id: const LudoTokenVisualState(isMovable: true),
          },
        ),
      );

      final positionedKeys = tokenStack(tester).children
          .whereType<Positioned>()
          .map((positioned) => positioned.key)
          .toList();

      expect(positionedKeys, [
        const ValueKey<String>('ludo-token-position-token_idle'),
        const ValueKey<String>('ludo-token-position-token_movable'),
        const ValueKey<String>('ludo-token-position-token_moving'),
        const ValueKey<String>('ludo-token-position-token_selected'),
      ]);
    });

    testWidgets('preserves callback identity for stacked tokens', (
      tester,
    ) async {
      final firstToken = createToken(id: 'red_token_0');
      final secondToken = createToken(id: 'red_token_1');
      String? pressedTokenId;

      await tester.pumpWidget(
        buildLayer(
          tokens: [firstToken, secondToken],
          onTokenPressed: (tokenId) {
            pressedTokenId = tokenId;
          },
        ),
      );

      final firstTokenFinder = find.byKey(
        LudoToken.repaintBoundaryKeyFor(firstToken.id),
      );
      final secondTokenFinder = find.byKey(
        LudoToken.repaintBoundaryKeyFor(secondToken.id),
      );

      final firstTokenRect = tester.getRect(firstTokenFinder);
      final secondTokenRect = tester.getRect(secondTokenFinder);

      // The token canvases intentionally overlap to create a compact visual
      // group. Tap the exposed left edge of the left token so the token painted
      // to its right cannot intercept the pointer.
      await tester.tapAt(
        Offset(firstTokenRect.left + 2, firstTokenRect.center.dy),
      );

      expect(pressedTokenId, firstToken.id);

      // Tap the exposed right edge of the right token for the corresponding
      // reason. This verifies that every visible stack member stays tappable.
      await tester.tapAt(
        Offset(secondTokenRect.right - 2, secondTokenRect.center.dy),
      );

      expect(pressedTokenId, secondToken.id);
    });
  });
}
