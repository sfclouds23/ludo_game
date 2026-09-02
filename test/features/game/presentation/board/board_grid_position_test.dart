import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/presentation/board/board_geometry.dart';
import 'package:ludo_game/features/game/presentation/board/board_grid_position.dart';

void main() {
  group('BoardGridPosition', () {
    test('stores its normalized row and column', () {
      const position = BoardGridPosition(row: 6, column: 1);

      expect(position.row, 6);
      expect(position.column, 1);
    });

    test('converts its grid location into a responsive pixel center', () {
      const position = BoardGridPosition(row: 6, column: 1);
      final geometry = BoardGeometry(300);

      expect(position.centerIn(geometry), const Offset(30, 130));
    });

    test('supports value equality', () {
      const first = BoardGridPosition(row: 6, column: 1);
      const second = BoardGridPosition(row: 6, column: 1);
      const different = BoardGridPosition(row: 6, column: 2);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(different));
    });

    test('provides a readable string representation', () {
      const position = BoardGridPosition(row: 6, column: 1);

      expect(position.toString(), 'BoardGridPosition(row: 6, column: 1)');
    });
  });
}
