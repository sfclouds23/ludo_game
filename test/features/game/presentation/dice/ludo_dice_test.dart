import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/presentation/dice/ludo_dice.dart';
import 'package:ludo_game/features/game/presentation/dice/ludo_dice_painter.dart';

void main() {
  Widget buildDice({
    DiceResult? result,
    double dimension = 96,
    bool isRolling = false,
    bool isEnabled = true,
    VoidCallback? onRollRequested,
    ValueChanged<DiceResult>? onRollAnimationCompleted,
    bool disableAnimations = false,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Center(
          child: LudoDice(
            result: result ?? DiceResult(1),
            dimension: dimension,
            isRolling: isRolling,
            isEnabled: isEnabled,
            onRollRequested: onRollRequested,
            onRollAnimationCompleted: onRollAnimationCompleted,
          ),
        ),
      ),
    );
  }

  LudoDicePainter currentPainter(WidgetTester tester) {
    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(LudoDice),
        matching: find.byType(CustomPaint),
      ),
    );

    return customPaint.painter as LudoDicePainter;
  }

  Transform currentTransform(WidgetTester tester) {
    return tester.widget<Transform>(
      find.descendant(
        of: find.byType(LudoDice),
        matching: find.byType(Transform),
      ),
    );
  }

  GestureDetector currentGestureDetector(WidgetTester tester) {
    return tester.widget<GestureDetector>(
      find.descendant(
        of: find.byType(LudoDice),
        matching: find.byType(GestureDetector),
      ),
    );
  }

  List<double> currentTransformValues(WidgetTester tester) {
    return List<double>.of(currentTransform(tester).transform.storage);
  }

  group('LudoDice rendering', () {
    testWidgets('renders at the requested square dimension', (tester) async {
      await tester.pumpWidget(buildDice(result: DiceResult(3), dimension: 112));

      final repaintBoundary = find.byKey(LudoDice.repaintBoundaryKey);

      expect(repaintBoundary, findsOneWidget);
      expect(tester.getSize(repaintBoundary), const Size.square(112));
    });

    testWidgets('forwards the supplied logical result to its painter', (
      tester,
    ) async {
      final result = DiceResult(5);

      await tester.pumpWidget(buildDice(result: result));

      expect(currentPainter(tester).result, result);
    });

    testWidgets('updates its painter when the logical result changes', (
      tester,
    ) async {
      await tester.pumpWidget(buildDice(result: DiceResult(2)));

      expect(currentPainter(tester).result, DiceResult(2));

      await tester.pumpWidget(buildDice(result: DiceResult(6)));

      expect(currentPainter(tester).result, DiceResult(6));
    });

    testWidgets('isolates dice painting behind a repaint boundary', (
      tester,
    ) async {
      await tester.pumpWidget(buildDice(result: DiceResult(4)));

      final repaintBoundary = find.byKey(LudoDice.repaintBoundaryKey);

      expect(repaintBoundary, findsOneWidget);
      expect(tester.widget(repaintBoundary), isA<RepaintBoundary>());
    });
  });

  group('LudoDice roll requests', () {
    testWidgets('forwards a roll request when the caller permits it', (
      tester,
    ) async {
      var requestCount = 0;

      await tester.pumpWidget(
        buildDice(
          onRollRequested: () {
            requestCount++;
          },
        ),
      );

      await tester.tap(find.byKey(LudoDice.repaintBoundaryKey));

      expect(requestCount, 1);
    });

    testWidgets('does not expose interaction without a callback', (
      tester,
    ) async {
      await tester.pumpWidget(buildDice());

      expect(currentGestureDetector(tester).onTap, isNull);
    });

    testWidgets('uses caller-supplied disabled state', (tester) async {
      await tester.pumpWidget(
        buildDice(isEnabled: false, onRollRequested: () {}),
      );

      // The widget consumes the restriction without determining why rolling
      // is unavailable.
      expect(currentGestureDetector(tester).onTap, isNull);
    });

    testWidgets('blocks another request while animation is active', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildDice(isRolling: true, onRollRequested: () {}),
      );

      expect(currentGestureDetector(tester).onTap, isNull);
    });
  });

  group('LudoDice animation', () {
    testWidgets('changes its transform during tumble animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildDice(result: DiceResult(4), isRolling: true),
      );

      final initialTransform = currentTransformValues(tester);

      await tester.pump(const Duration(milliseconds: 350));

      final animatedTransform = currentTransformValues(tester);

      expect(animatedTransform, isNot(initialTransform));
    });

    testWidgets('returns to its resting transform after animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildDice(result: DiceResult(3), isRolling: true),
      );

      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump();

      expect(currentTransform(tester).transform, equals(Matrix4.identity()));
    });

    testWidgets('reports the supplied result after animation completes', (
      tester,
    ) async {
      final result = DiceResult(6);
      DiceResult? completedResult;

      await tester.pumpWidget(
        buildDice(
          result: result,
          isRolling: true,
          onRollAnimationCompleted: (animationResult) {
            completedResult = animationResult;
          },
        ),
      );

      expect(completedResult, isNull);

      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump();

      expect(completedResult, same(result));
    });

    testWidgets('reports animation completion only once per roll', (
      tester,
    ) async {
      var completionCount = 0;

      await tester.pumpWidget(
        buildDice(
          result: DiceResult(2),
          isRolling: true,
          onRollAnimationCompleted: (_) {
            completionCount++;
          },
        ),
      );

      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(completionCount, 1);
    });

    testWidgets('uses completed state when animations are disabled', (
      tester,
    ) async {
      final result = DiceResult(5);
      DiceResult? completedResult;

      await tester.pumpWidget(
        buildDice(
          result: result,
          isRolling: true,
          disableAnimations: true,
          onRollAnimationCompleted: (animationResult) {
            completedResult = animationResult;
          },
        ),
      );

      // Run the completion callback scheduled after the initial build.
      await tester.pump();

      expect(currentTransform(tester).transform, equals(Matrix4.identity()));
      expect(completedResult, same(result));
    });

    testWidgets('starts a new animation when a rolling result changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildDice(result: DiceResult(2), isRolling: true),
      );

      await tester.pump(const Duration(milliseconds: 700));

      await tester.pumpWidget(
        buildDice(result: DiceResult(5), isRolling: true),
      );

      final restartedTransform = currentTransformValues(tester);

      await tester.pump(const Duration(milliseconds: 250));

      final animatedTransform = currentTransformValues(tester);

      expect(currentPainter(tester).result, DiceResult(5));
      expect(animatedTransform, isNot(restartedTransform));
    });
  });
}
