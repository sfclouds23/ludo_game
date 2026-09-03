import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';

void main() {
  group('DiceResult', () {
    test('accepts every standard dice value', () {
      for (
        var value = DiceResult.minimumValue;
        value <= DiceResult.maximumValue;
        value++
      ) {
        expect(DiceResult(value).value, value);
      }
    });

    test('defines the expected six-sided boundaries', () {
      expect(DiceResult.minimumValue, 1);
      expect(DiceResult.maximumValue, 6);
      expect(DiceResult.faceCount, 6);
    });

    test('rejects a value below one', () {
      expect(() => DiceResult(0), throwsRangeError);
    });

    test('rejects a value above six', () {
      expect(() => DiceResult(7), throwsRangeError);
    });

    test('supports value equality', () {
      final first = DiceResult(4);
      final second = DiceResult(4);
      final different = DiceResult(5);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(different));
    });

    test('provides a readable string representation', () {
      expect(DiceResult(3).toString(), 'DiceResult(value: 3)');
    });
  });
}
