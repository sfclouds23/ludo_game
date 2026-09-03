import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_painter.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_visual_state.dart';

void main() {
  Widget buildToken({
    LudoTokenVisualState visualState = LudoTokenVisualState.idle,
    bool isInYard = false,
    bool isFinished = false,
    VoidCallback? onPressed,
    bool disableAnimations = false,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Center(
          child: LudoToken(
            tokenId: 'red_token_0',
            playerColor: PlayerColor.red,
            dimension: 64,
            visualState: visualState,
            isInYard: isInYard,
            isFinished: isFinished,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  LudoTokenPainter currentPainter(WidgetTester tester) {
    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(LudoToken.repaintBoundaryKeyFor('red_token_0')),
        matching: find.byType(CustomPaint),
      ),
    );

    return customPaint.painter as LudoTokenPainter;
  }

  group('LudoToken interaction presentation', () {
    testWidgets('forwards visual state to its painter', (tester) async {
      const visualState = LudoTokenVisualState(
        isMovable: true,
        isSelected: true,
        isMoving: true,
      );

      await tester.pumpWidget(buildToken(visualState: visualState));

      final painter = currentPainter(tester);

      expect(painter.visualState, visualState);
    });

    testWidgets('forwards home and finished state to its painter', (
      tester,
    ) async {
      await tester.pumpWidget(buildToken(isInYard: true, isFinished: true));

      final painter = currentPainter(tester);

      expect(painter.isInYard, isTrue);
      expect(painter.isFinished, isTrue);
    });

    testWidgets('animates emphasis supplied by the caller', (tester) async {
      const visualState = LudoTokenVisualState(isMovable: true);

      await tester.pumpWidget(buildToken(visualState: visualState));

      final initialProgress = currentPainter(tester).emphasisProgress;

      await tester.pump(const Duration(milliseconds: 425));

      final animatedProgress = currentPainter(tester).emphasisProgress;

      expect(initialProgress, 0);
      expect(animatedProgress, greaterThan(0));
    });

    testWidgets('stabilizes emphasis when animations are disabled', (
      tester,
    ) async {
      const visualState = LudoTokenVisualState(isSelected: true);

      await tester.pumpWidget(
        buildToken(visualState: visualState, disableAnimations: true),
      );

      expect(currentPainter(tester).emphasisProgress, 1);

      await tester.pump(const Duration(seconds: 2));

      expect(currentPainter(tester).emphasisProgress, 1);
    });

    testWidgets('stops emphasis when state returns to idle', (tester) async {
      const emphasizedState = LudoTokenVisualState(isSelected: true);

      await tester.pumpWidget(buildToken(visualState: emphasizedState));
      await tester.pump(const Duration(milliseconds: 300));

      expect(currentPainter(tester).emphasisProgress, greaterThan(0));

      await tester.pumpWidget(buildToken());

      expect(currentPainter(tester).emphasisProgress, 0);

      await tester.pump(const Duration(seconds: 1));

      expect(currentPainter(tester).emphasisProgress, 0);
    });

    testWidgets('forwards taps whenever a callback is supplied', (
      tester,
    ) async {
      var tapCount = 0;

      // Idle state is intentional. The widget must not infer legal moves from
      // visual flags or decide whether the supplied callback may execute.
      await tester.pumpWidget(
        buildToken(
          onPressed: () {
            tapCount++;
          },
        ),
      );

      await tester.tap(
        find.byKey(LudoToken.repaintBoundaryKeyFor('red_token_0')),
      );

      expect(tapCount, 1);
    });

    testWidgets('does not expose interaction without a callback', (
      tester,
    ) async {
      await tester.pumpWidget(buildToken());

      final gestureDetector = tester.widget<GestureDetector>(
        find.ancestor(
          of: find.byKey(LudoToken.repaintBoundaryKeyFor('red_token_0')),
          matching: find.byType(GestureDetector),
        ),
      );

      expect(gestureDetector.onTap, isNull);
    });
  });
}
