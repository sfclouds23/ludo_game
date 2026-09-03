import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_visual_state.dart';

void main() {
  group('LudoTokenVisualState', () {
    test('idle state contains no interaction emphasis', () {
      const state = LudoTokenVisualState.idle;

      expect(state.isMovable, isFalse);
      expect(state.isSelected, isFalse);
      expect(state.isMoving, isFalse);
      expect(state.isEmphasized, isFalse);
    });

    test('stores movable state supplied by the caller', () {
      const state = LudoTokenVisualState(isMovable: true);

      expect(state.isMovable, isTrue);
      expect(state.isSelected, isFalse);
      expect(state.isMoving, isFalse);
      expect(state.isEmphasized, isTrue);
    });

    test('stores selected state independently of legality', () {
      const state = LudoTokenVisualState(isSelected: true);

      expect(state.isMovable, isFalse);
      expect(state.isSelected, isTrue);
      expect(state.isEmphasized, isTrue);
    });

    test('supports overlapping supplied states', () {
      const state = LudoTokenVisualState(
        isMovable: true,
        isSelected: true,
        isMoving: true,
      );

      expect(state.isMovable, isTrue);
      expect(state.isSelected, isTrue);
      expect(state.isMoving, isTrue);
      expect(state.isEmphasized, isTrue);
    });

    test('copyWith replaces only supplied values', () {
      const original = LudoTokenVisualState(isMovable: true, isSelected: true);

      final updated = original.copyWith(isMoving: true);

      expect(updated.isMovable, isTrue);
      expect(updated.isSelected, isTrue);
      expect(updated.isMoving, isTrue);
    });

    test('supports value equality', () {
      const first = LudoTokenVisualState(isMovable: true, isSelected: true);
      const second = LudoTokenVisualState(isMovable: true, isSelected: true);
      const different = LudoTokenVisualState(isMoving: true);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(different));
    });

    test('provides a readable string representation', () {
      const state = LudoTokenVisualState(
        isMovable: true,
        isSelected: false,
        isMoving: true,
      );

      expect(
        state.toString(),
        'LudoTokenVisualState('
        'isMovable: true, '
        'isSelected: false, '
        'isMoving: true'
        ')',
      );
    });
  });
}
