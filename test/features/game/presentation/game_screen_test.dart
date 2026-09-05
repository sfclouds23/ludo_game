import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/domain/models/game_state.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/services/dice_roller.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_visual_state.dart';
import 'package:ludo_game/features/game/presentation/dice/ludo_dice.dart';
import 'package:ludo_game/features/game/presentation/dice/ludo_dice_painter.dart';
import 'package:ludo_game/features/game/presentation/game_screen.dart';

void main() {
  group('GameScreen token preview', () {
    test('contains preview tokens for every player', () {
      for (final playerColor in PlayerColor.values) {
        final playerTokens = GameScreen.previewTokens.where(
          (token) => token.ownerColor == playerColor,
        );

        expect(playerTokens, isNotEmpty);
      }

      expect(
        GameScreen.previewTokens.where(
          (token) => token.ownerColor == PlayerColor.red,
        ),
        hasLength(3),
      );
      expect(
        GameScreen.previewTokens.where(
          (token) => token.ownerColor == PlayerColor.green,
        ),
        hasLength(2),
      );
      expect(
        GameScreen.previewTokens.where(
          (token) => token.ownerColor == PlayerColor.yellow,
        ),
        hasLength(2),
      );
      expect(
        GameScreen.previewTokens.where(
          (token) => token.ownerColor == PlayerColor.blue,
        ),
        hasLength(2),
      );
      expect(GameScreen.previewTokens, hasLength(9));
    });

    test('contains two red tokens sharing one logical position', () {
      final firstStackedToken = GameScreen.previewTokens.singleWhere(
        (token) => token.id == 'red_token_1',
      );
      final secondStackedToken = GameScreen.previewTokens.singleWhere(
        (token) => token.id == 'red_token_2',
      );

      expect(firstStackedToken.position, secondStackedToken.position);
    });

    test('keeps preview token data immutable', () {
      expect(() => GameScreen.previewTokens.clear(), throwsUnsupportedError);
    });

    test('declares token visual state without calculating legal moves', () {
      expect(
        GameScreen.previewVisualStates['red_token_1'],
        const LudoTokenVisualState(isMovable: true),
      );
      expect(
        GameScreen.previewVisualStates['red_token_2'],
        const LudoTokenVisualState(isMovable: true),
      );
      expect(
        GameScreen.previewVisualStates['green_token_1'],
        const LudoTokenVisualState(isMovable: true),
      );
      expect(
        GameScreen.previewVisualStates['yellow_token_1'],
        const LudoTokenVisualState(isMoving: true),
      );
    });

    testWidgets('passes preview tokens and visual states into the board', (
      tester,
    ) async {
      await tester.pumpWidget(_testGameScreen());

      final board = tester.widget<LudoBoard>(find.byType(LudoBoard));

      expect(board.tokens, same(GameScreen.previewTokens));
      expect(board.onTokenPressed, isNotNull);
      expect(find.byType(LudoToken), findsNWidgets(9));

      expect(board.visualStates['red_token_1']?.isMovable, isTrue);
      expect(board.visualStates['red_token_1']?.isSelected, isFalse);
      expect(board.visualStates['red_token_2']?.isMovable, isTrue);
      expect(board.visualStates['red_token_2']?.isSelected, isTrue);
      expect(board.visualStates['yellow_token_1']?.isMoving, isTrue);
    });

    testWidgets('updates visual selection when a token is pressed', (
      tester,
    ) async {
      await tester.pumpWidget(_testGameScreen());

      await tester.tap(
        find.byKey(LudoToken.repaintBoundaryKeyFor('green_token_1')),
      );
      await tester.pump();

      final board = tester.widget<LudoBoard>(find.byType(LudoBoard));

      expect(board.visualStates['green_token_1']?.isMovable, isTrue);
      expect(board.visualStates['green_token_1']?.isSelected, isTrue);
      expect(board.visualStates['red_token_2']?.isSelected, isFalse);
    });

    testWidgets('allows an idle preview token to display selection', (
      tester,
    ) async {
      await tester.pumpWidget(_testGameScreen());

      await tester.tap(
        find.byKey(LudoToken.repaintBoundaryKeyFor('blue_token_0')),
      );
      await tester.pump();

      final board = tester.widget<LudoBoard>(find.byType(LudoBoard));
      final selectedState = board.visualStates['blue_token_0'];

      expect(selectedState?.isMovable, isFalse);
      expect(selectedState?.isSelected, isTrue);
    });

    testWidgets('shows the board screen title', (tester) async {
      await tester.pumpWidget(_testGameScreen());

      expect(find.text('Ludo Board'), findsOneWidget);
      expect(find.byTooltip('Return home'), findsOneWidget);
    });
  });

  group('GameScreen dice sequencing', () {
    testWidgets('renders ready dice before the first logical result', (
      tester,
    ) async {
      await tester.pumpWidget(_testGameScreen());

      expect(find.byType(LudoDice), findsOneWidget);

      final dice = tester.widget<LudoDice>(find.byType(LudoDice));
      final painter = _dicePainter(tester);

      expect(dice.result, DiceResult(1));
      expect(dice.isRolling, isFalse);
      expect(dice.isEnabled, isTrue);
      expect(dice.useRiveRenderer, isFalse);
      expect(painter.result, DiceResult(1));
    });

    testWidgets('generates logical result before starting animation', (
      tester,
    ) async {
      final roller = _FakeDiceRoller([DiceResult(5)]);

      await tester.pumpWidget(_testGameScreen(diceRoller: roller));

      await tester.tap(find.byKey(LudoDice.repaintBoundaryKey));
      await tester.pump();

      final dice = tester.widget<LudoDice>(find.byType(LudoDice));
      final painter = _dicePainter(tester);

      expect(roller.rollCount, 1);
      expect(dice.result, DiceResult(5));
      expect(dice.isRolling, isTrue);
      expect(dice.isEnabled, isFalse);
      expect(dice.useRiveRenderer, isFalse);

      // The generated logical result remains hidden until landing.
      expect(painter.result, isNot(DiceResult(5)));
    });

    testWidgets('does not generate another result during animation', (
      tester,
    ) async {
      final roller = _FakeDiceRoller([DiceResult(4), DiceResult(6)]);

      await tester.pumpWidget(_testGameScreen(diceRoller: roller));

      await tester.tap(find.byKey(LudoDice.repaintBoundaryKey));
      await tester.pump();

      final rollingDice = tester.widget<LudoDice>(find.byType(LudoDice));

      expect(rollingDice.isRolling, isTrue);
      expect(rollingDice.onRollRequested, isNotNull);

      rollingDice.onRollRequested!();
      await tester.pump();

      expect(roller.rollCount, 1);
      expect(
        tester.widget<LudoDice>(find.byType(LudoDice)).result,
        DiceResult(4),
      );
    });

    testWidgets('does not generate a result when game state forbids rolling', (
      tester,
    ) async {
      final roller = _FakeDiceRoller([DiceResult(6)]);

      await tester.pumpWidget(
        _testGameScreen(
          diceRoller: roller,
          initialGameState: const GameState(isDiceRollAllowed: false),
        ),
      );

      final dice = tester.widget<LudoDice>(find.byType(LudoDice));
      expect(dice.isEnabled, isFalse);
      expect(dice.isRolling, isFalse);

      // Exercise the callback directly as defense in depth: the service still
      // rejects the request even if presentation dispatches it unexpectedly.
      dice.onRollRequested!();
      await tester.pump();

      expect(roller.rollCount, 0);
      expect(tester.widget<LudoDice>(find.byType(LudoDice)).isEnabled, isFalse);
    });

    testWidgets('publishes the same result after animation completion', (
      tester,
    ) async {
      final logicalResult = DiceResult(6);
      final roller = _FakeDiceRoller([logicalResult]);
      DiceResult? readyResult;

      await tester.pumpWidget(
        _testGameScreen(
          diceRoller: roller,
          onDiceResultReady: (result) {
            readyResult = result;
          },
        ),
      );

      await tester.tap(find.byKey(LudoDice.repaintBoundaryKey));
      await tester.pump();

      expect(readyResult, isNull);

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();

      final dice = tester.widget<LudoDice>(find.byType(LudoDice));
      final painter = _dicePainter(tester);

      expect(readyResult, same(logicalResult));
      expect(dice.result, same(logicalResult));
      expect(painter.result, same(logicalResult));
      expect(dice.isRolling, isFalse);
      expect(dice.isEnabled, isTrue);
    });

    testWidgets('supports consecutive independent logical rolls', (
      tester,
    ) async {
      final firstResult = DiceResult(2);
      final secondResult = DiceResult(5);
      final roller = _FakeDiceRoller([firstResult, secondResult]);
      final completedResults = <DiceResult>[];

      await tester.pumpWidget(
        _testGameScreen(
          diceRoller: roller,
          onDiceResultReady: completedResults.add,
        ),
      );

      await tester.tap(find.byKey(LudoDice.repaintBoundaryKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();

      await tester.tap(find.byKey(LudoDice.repaintBoundaryKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();

      expect(roller.rollCount, 2);
      expect(completedResults, [firstResult, secondResult]);
    });
  });
}

/// Creates a GameScreen configured for deterministic widget testing.
///
/// Rive stays enabled by default in production. These widget tests use the
/// procedural renderer because Flutter's VM test process does not load the
/// native Rive runtime used by the real application.
Widget _testGameScreen({
  DiceRoller? diceRoller,
  GameState initialGameState = const GameState(),
  ValueChanged<DiceResult>? onDiceResultReady,
}) {
  return MaterialApp(
    home: GameScreen(
      diceRoller: diceRoller,
      initialGameState: initialGameState,
      onDiceResultReady: onDiceResultReady,
      useRiveDiceRenderer: false,
    ),
  );
}

/// Returns the procedural painter belonging specifically to LudoDice.
///
/// Material widgets can contain unrelated CustomPaint widgets, so this helper
/// identifies the painter by its concrete type instead of assuming only one
/// CustomPaint exists in the complete screen.
LudoDicePainter _dicePainter(WidgetTester tester) {
  final customPaintWidgets = tester
      .widgetList<CustomPaint>(
        find.descendant(
          of: find.byType(LudoDice),
          matching: find.byType(CustomPaint),
        ),
      )
      .where((widget) => widget.painter is LudoDicePainter)
      .toList();

  expect(customPaintWidgets, hasLength(1));

  return customPaintWidgets.single.painter! as LudoDicePainter;
}

/// Deterministic logical roller used independently from dice animation.
class _FakeDiceRoller implements DiceRoller {
  _FakeDiceRoller(this._results);

  final List<DiceResult> _results;
  int rollCount = 0;

  @override
  DiceResult roll() {
    if (rollCount >= _results.length) {
      throw StateError('No fake dice result remains.');
    }

    final result = _results[rollCount];
    rollCount++;

    return result;
  }
}
