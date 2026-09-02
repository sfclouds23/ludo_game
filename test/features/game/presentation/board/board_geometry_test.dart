import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/presentation/board/board_geometry.dart';

void main() {
  group('BoardGeometry', () {
    test('divides the board into a 15 by 15 visual grid', () {
      final geometry = BoardGeometry(300);

      expect(geometry.cellSize, 20);
      expect(geometry.boardRect, const Rect.fromLTWH(0, 0, 300, 300));
    });

    test('calculates a cell rectangle from its row and column', () {
      final geometry = BoardGeometry(300);

      expect(
        geometry.cellRect(row: 2, column: 3),
        const Rect.fromLTWH(60, 40, 20, 20),
      );
    });

    test('calculates the center of a visual grid cell', () {
      final geometry = BoardGeometry(300);

      expect(geometry.cellCenter(row: 2, column: 3), const Offset(70, 50));
    });

    test('scales the same grid position for a larger board', () {
      final smallGeometry = BoardGeometry(300);
      final largeGeometry = BoardGeometry(600);

      expect(
        largeGeometry.cellCenter(row: 2, column: 3),
        smallGeometry.cellCenter(row: 2, column: 3) * 2,
      );
    });

    test('rejects invalid board sizes', () {
      expect(() => BoardGeometry(0), throwsArgumentError);
      expect(() => BoardGeometry(-100), throwsArgumentError);
      expect(() => BoardGeometry(double.infinity), throwsArgumentError);
    });

    test('rejects rows outside the visual grid', () {
      final geometry = BoardGeometry(300);

      expect(() => geometry.cellCenter(row: -1, column: 0), throwsRangeError);
      expect(() => geometry.cellCenter(row: 15, column: 0), throwsRangeError);
    });

    test('rejects columns outside the visual grid', () {
      final geometry = BoardGeometry(300);

      expect(() => geometry.cellCenter(row: 0, column: -1), throwsRangeError);
      expect(() => geometry.cellCenter(row: 0, column: 15), throwsRangeError);
    });
  });
}
