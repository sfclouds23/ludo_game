import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/domain/models/game_state.dart';
import 'package:ludo_game/features/game/domain/services/dice_roll_service.dart';
import 'package:ludo_game/features/game/domain/services/dice_roller.dart';

void main() {
  group('DefaultDiceRollService', () {
    test('generates a pending result when state permits rolling', () {
      final logicalResult = DiceResult(5);
      final roller = _FakeDiceRoller([logicalResult]);
      final service = DefaultDiceRollService(roller);

      final state = service.requestRoll(const GameState());

      expect(roller.rollCount, 1);
      expect(state.pendingDiceResult, same(logicalResult));
      expect(state.diceResult, isNull);
      expect(state.isDiceRolling, isTrue);
    });

    test('does not generate a value when state forbids rolling', () {
      final roller = _FakeDiceRoller([DiceResult(6)]);
      final service = DefaultDiceRollService(roller);
      const blockedState = GameState(isDiceRollAllowed: false);

      final state = service.requestRoll(blockedState);

      expect(state, same(blockedState));
      expect(roller.rollCount, 0);
    });

    test('does not generate another value while a roll is active', () {
      final roller = _FakeDiceRoller([DiceResult(2), DiceResult(4)]);
      final service = DefaultDiceRollService(roller);
      final rollingState = service.requestRoll(const GameState());

      final state = service.requestRoll(rollingState);

      expect(state, same(rollingState));
      expect(roller.rollCount, 1);
      expect(state.pendingDiceResult, DiceResult(2));
    });

    test('publishes result only after matching animation completion', () {
      final logicalResult = DiceResult(3);
      final service = DefaultDiceRollService(_FakeDiceRoller([logicalResult]));
      final rollingState = service.requestRoll(const GameState());

      expect(rollingState.diceResult, isNull);

      final completedState = service.completeRoll(
        rollingState,
        logicalResult,
      );

      expect(completedState.diceResult, same(logicalResult));
      expect(completedState.pendingDiceResult, isNull);
      expect(completedState.isDiceRolling, isFalse);
    });

    test('ignores stale completion without changing active roll', () {
      final service = DefaultDiceRollService(
        _FakeDiceRoller([DiceResult(4)]),
      );
      final rollingState = service.requestRoll(const GameState());

      final state = service.completeRoll(rollingState, DiceResult(1));

      expect(state, same(rollingState));
      expect(state.pendingDiceResult, DiceResult(4));
      expect(state.diceResult, isNull);
    });
  });
}

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
