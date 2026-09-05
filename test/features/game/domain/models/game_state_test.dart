import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/domain/models/game_state.dart';

void main() {
  group('GameState dice integration', () {
    test('starts ready to roll without a completed result', () {
      const state = GameState();

      expect(state.diceResult, isNull);
      expect(state.pendingDiceResult, isNull);
      expect(state.isDiceRolling, isFalse);
      expect(state.isDiceRollAllowed, isTrue);
      expect(state.canRollDice, isTrue);
    });

    test('can explicitly forbid a new roll', () {
      const state = GameState(isDiceRollAllowed: false);

      expect(state.canRollDice, isFalse);
    });

    test('beginDiceRoll stores result as pending but not completed', () {
      const state = GameState();
      final result = DiceResult(5);

      final rollingState = state.beginDiceRoll(result);

      expect(rollingState.pendingDiceResult, same(result));
      expect(rollingState.diceResult, isNull);
      expect(rollingState.isDiceRolling, isTrue);
      expect(rollingState.canRollDice, isFalse);
    });

    test('beginDiceRoll does nothing when state forbids rolling', () {
      const state = GameState(isDiceRollAllowed: false);

      final result = state.beginDiceRoll(DiceResult(4));

      expect(result, same(state));
    });

    test('beginDiceRoll does nothing while another roll is active', () {
      final rollingState = const GameState().beginDiceRoll(DiceResult(2));

      final result = rollingState.beginDiceRoll(DiceResult(6));

      expect(result, same(rollingState));
      expect(result.pendingDiceResult, DiceResult(2));
    });

    test('completeDiceRoll publishes matching pending result', () {
      final result = DiceResult(6);
      final rollingState = const GameState().beginDiceRoll(result);

      final completedState = rollingState.completeDiceRoll(result);

      expect(completedState.diceResult, same(result));
      expect(completedState.pendingDiceResult, isNull);
      expect(completedState.isDiceRolling, isFalse);
      expect(completedState.canRollDice, isTrue);
    });

    test('completeDiceRoll ignores stale or mismatched result', () {
      final rollingState = const GameState().beginDiceRoll(DiceResult(3));

      final result = rollingState.completeDiceRoll(DiceResult(4));

      expect(result, same(rollingState));
      expect(result.diceResult, isNull);
      expect(result.pendingDiceResult, DiceResult(3));
    });

    test('completed result remains available while next roll animates', () {
      final firstResult = DiceResult(2);
      final secondResult = DiceResult(5);
      final completedState = const GameState()
          .beginDiceRoll(firstResult)
          .completeDiceRoll(firstResult);

      final rollingState = completedState.beginDiceRoll(secondResult);

      expect(rollingState.diceResult, same(firstResult));
      expect(rollingState.pendingDiceResult, same(secondResult));
      expect(rollingState.isDiceRolling, isTrue);
    });

    test('roll availability can change without discarding dice state', () {
      final result = DiceResult(4);
      final completedState = const GameState()
          .beginDiceRoll(result)
          .completeDiceRoll(result);

      final blockedState = completedState.withDiceRollAllowed(false);

      expect(blockedState.diceResult, same(result));
      expect(blockedState.isDiceRollAllowed, isFalse);
      expect(blockedState.canRollDice, isFalse);
    });
  });
}
