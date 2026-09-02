import 'dart:ui';

import 'board_geometry.dart';

/// Identifies one row and column in the board's normalized 15 × 15 grid.
///
/// This is a presentation-layer coordinate. It does not represent token
/// progress, movement distance, or any other gameplay rule.
class BoardGridPosition {
  /// Creates a visual grid position.
  const BoardGridPosition({required this.row, required this.column})
    : assert(
        row >= 0 &&
            row < BoardGeometry.gridDimension &&
            column >= 0 &&
            column < BoardGeometry.gridDimension,
        'Board grid positions must remain inside the 15 × 15 grid.',
      );

  /// Zero-based visual row, measured from the top of the board.
  final int row;

  /// Zero-based visual column, measured from the left of the board.
  final int column;

  /// Converts this normalized position into a responsive pixel center.
  Offset centerIn(BoardGeometry geometry) {
    return geometry.cellCenter(row: row, column: column);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is BoardGridPosition &&
        other.row == row &&
        other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() {
    return 'BoardGridPosition(row: $row, column: $column)';
  }
}
