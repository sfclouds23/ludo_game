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
    bool useRiveRenderer = false,
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
            useRiveRenderer: useRiveRenderer,
            onRollRequested: onRollRequested,
            onRollAnimationCompleted: onRollAnimationCompleted,
          ),
        ),
      ),
    );
  }

  Finder diceCustomPaintFinder() {
    return find.descendant(
      of: find.byType(LudoDice),
      matching: find.byType(CustomPaint),
    );
  }

  LudoDicePainter currentPainter(WidgetTester tester) {
    final customPaint = tester.widget<CustomPaint>(diceCustomPaintFinder());

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

    testWidgets('forwards a resting result to the fallback painter', (
      tester,
    ) async {
      final result = DiceResult(5);

      await tester.pumpWidget(buildDice(result: result));

      expect(currentPainter(tester).result, result);
    });

    testWidgets('updates a resting fallback face when result changes', (
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

    testWidgets('uses the procedural renderer when Rive is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildDice(result: DiceResult(4), useRiveRenderer: false),
      );

      expect(diceCustomPaintFinder(), findsOneWidget);
      expect(currentPainter(tester).result, DiceResult(4));
    });
  });

  group('LudoDice roll requests', () {
    testWidgets('forwards a roll request when caller permits it', (
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

  group('LudoDice animation sequencing', () {
    testWidgets('changes fallback transform during animation', (tester) async {
      await tester.pumpWidget(
        buildDice(result: DiceResult(4), isRolling: true),
      );

      final initialTransform = currentTransformValues(tester);

      await tester.pump(const Duration(milliseconds: 350));

      final animatedTransform = currentTransformValues(tester);

      expect(animatedTransform, isNot(initialTransform));
    });

    testWidgets('cycles temporary fallback faces while rolling', (
      tester,
    ) async {
      await tester.pumpWidget(buildDice(result: DiceResult(2)));

      await tester.pumpWidget(
        buildDice(result: DiceResult(6), isRolling: true),
      );

      final firstTemporaryFace = currentPainter(tester).result;

      await tester.pump(const Duration(milliseconds: 180));

      final secondTemporaryFace = currentPainter(tester).result;

      expect(firstTemporaryFace, isNot(DiceResult(6)));
      expect(secondTemporaryFace, isNot(firstTemporaryFace));
    });

    testWidgets('hides fallback result until landing', (tester) async {
      final previousResult = DiceResult(2);
      final finalResult = DiceResult(5);

      await tester.pumpWidget(buildDice(result: previousResult));

      await tester.pumpWidget(buildDice(result: finalResult, isRolling: true));

      expect(currentPainter(tester).result, isNot(finalResult));

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();

      expect(currentPainter(tester).result, finalResult);
    });

    testWidgets('returns fallback to resting transform', (tester) async {
      await tester.pumpWidget(
        buildDice(result: DiceResult(3), isRolling: true),
      );

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();

      expect(currentTransform(tester).transform, equals(Matrix4.identity()));
    });

    testWidgets('reports supplied result after animation completes', (
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

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();

      expect(completedResult, same(result));
      expect(currentPainter(tester).result, same(result));
    });

    testWidgets('reports completion only once per roll', (tester) async {
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

      await tester.pump(const Duration(milliseconds: 1300));
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

      await tester.pump();

      expect(currentTransform(tester).transform, equals(Matrix4.identity()));
      expect(currentPainter(tester).result, same(result));
      expect(completedResult, same(result));
    });

    testWidgets('restarts hidden fallback when result changes', (tester) async {
      final replacementResult = DiceResult(5);

      await tester.pumpWidget(
        buildDice(result: DiceResult(2), isRolling: true),
      );

      await tester.pump(const Duration(milliseconds: 700));

      await tester.pumpWidget(
        buildDice(result: replacementResult, isRolling: true),
      );

      final restartedTransform = currentTransformValues(tester);

      expect(currentPainter(tester).result, isNot(replacementResult));

      await tester.pump(const Duration(milliseconds: 250));

      final animatedTransform = currentTransformValues(tester);

      expect(animatedTransform, isNot(restartedTransform));
      expect(currentPainter(tester).result, isNot(replacementResult));

      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump();

      expect(currentPainter(tester).result, replacementResult);
    });
  });
}
