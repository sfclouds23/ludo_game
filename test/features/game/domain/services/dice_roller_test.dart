import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/domain/services/dice_roller.dart';

void main() {
  group('RandomDiceRoller', () {
    test('requests a value using the six-sided face count', () {
      int? requestedUpperBound;

      final roller = RandomDiceRoller(
        nextInt: (upperBound) {
          requestedUpperBound = upperBound;
          return 0;
        },
      );

      roller.roll();

      expect(requestedUpperBound, DiceResult.faceCount);
    });

    test('maps zero-based source values to dice values one through six', () {
      for (var zeroBasedValue = 0; zeroBasedValue < 6; zeroBasedValue++) {
        final roller = RandomDiceRoller(nextInt: (_) => zeroBasedValue);

        expect(roller.roll(), DiceResult(zeroBasedValue + 1));
      }
    });

    test('returns a DiceResult rather than a presentation value', () {
      final roller = RandomDiceRoller(nextInt: (_) => 3);

      final result = roller.roll();

      expect(result, isA<DiceResult>());
      expect(result.value, 4);
    });

    test('requests a fresh source value for every roll', () {
      var sourceCallCount = 0;

      final roller = RandomDiceRoller(
        nextInt: (_) {
          final currentValue = sourceCallCount;
          sourceCallCount++;
          return currentValue;
        },
      );

      final firstResult = roller.roll();
      final secondResult = roller.roll();
      final thirdResult = roller.roll();

      expect(firstResult.value, 1);
      expect(secondResult.value, 2);
      expect(thirdResult.value, 3);
      expect(sourceCallCount, 3);
    });

    test('rejects an injected source value below the supported range', () {
      final roller = RandomDiceRoller(nextInt: (_) => -1);

      expect(roller.roll, throwsRangeError);
    });

    test('rejects an injected source value above the supported range', () {
      final roller = RandomDiceRoller(nextInt: (_) => DiceResult.faceCount);

      expect(roller.roll, throwsRangeError);
    });

    test('default source always produces valid logical values', () {
      final roller = RandomDiceRoller();

      for (var rollIndex = 0; rollIndex < 500; rollIndex++) {
        final result = roller.roll();

        expect(
          result.value,
          inInclusiveRange(DiceResult.minimumValue, DiceResult.maximumValue),
        );
      }
    });
  });
}
