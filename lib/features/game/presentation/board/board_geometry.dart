import 'dart:ui';

/// Calculates responsive visual geometry for the Ludo board.
///
/// The rendered board uses a normalized 15 × 15 visual grid. This class
/// converts grid rows and columns into pixel rectangles and center points.
///
/// It belongs to the presentation layer and must not contain movement rules,
/// player paths, safe-cell rules, or other game-domain decisions.
class BoardGeometry {
  /// Creates geometry for a square board with the supplied [boardSize].
  BoardGeometry(this.boardSize) {
    if (!boardSize.isFinite || boardSize <= 0) {
      throw ArgumentError.value(
        boardSize,
        'boardSize',
        'Board size must be a positive finite number.',
      );
    }
  }

  /// Number of equally sized rows and columns on a conventional Ludo board.
  static const int gridDimension = 15;

  /// Width and height of the square board in logical pixels.
  final double boardSize;

  /// Width and height of one visual grid cell.
  double get cellSize => boardSize / gridDimension;

  /// Complete square occupied by the board.
  Rect get boardRect => Rect.fromLTWH(0, 0, boardSize, boardSize);

  /// Returns the pixel rectangle occupied by one visual grid cell.
  Rect cellRect({required int row, required int column}) {
    _validateGridCoordinate(row: row, column: column);

    return Rect.fromLTWH(column * cellSize, row * cellSize, cellSize, cellSize);
  }

  /// Returns the pixel center of one visual grid cell.
  Offset cellCenter({required int row, required int column}) {
    return cellRect(row: row, column: column).center;
  }

  /// Ensures callers cannot request positions outside the visual grid.
  void _validateGridCoordinate({required int row, required int column}) {
    if (row < 0 || row >= gridDimension) {
      throw RangeError.range(
        row,
        0,
        gridDimension - 1,
        'row',
        'Board row is outside the visual grid.',
      );
    }

    if (column < 0 || column >= gridDimension) {
      throw RangeError.range(
        column,
        0,
        gridDimension - 1,
        'column',
        'Board column is outside the visual grid.',
      );
    }
  }
}
