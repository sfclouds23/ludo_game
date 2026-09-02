import 'dart:ui';

import '../../domain/models/board_cell.dart';
import 'board_geometry.dart';
import 'board_grid_position.dart';

/// Maps logical GAME-101 board cells to presentation-layer coordinates.
///
/// This mapper does not calculate movement, validate legal moves, or modify
/// game state. It only describes where logical cells appear visually.
class BoardCoordinateMapper {
  const BoardCoordinateMapper._();

  /// Visual positions of `main_0` through `main_51`, in logical index order.
  ///
  /// The positions form one continuous clockwise route around the 15 × 15
  /// board. Their indexes deliberately match GAME-101 main-track indexes.
  static const List<BoardGridPosition> mainTrackPositions = [
    BoardGridPosition(row: 6, column: 1), // main_0: red start
    BoardGridPosition(row: 6, column: 2),
    BoardGridPosition(row: 6, column: 3),
    BoardGridPosition(row: 6, column: 4),
    BoardGridPosition(row: 6, column: 5),
    BoardGridPosition(row: 5, column: 6),
    BoardGridPosition(row: 4, column: 6),
    BoardGridPosition(row: 3, column: 6),
    BoardGridPosition(row: 2, column: 6), // main_8: safe
    BoardGridPosition(row: 1, column: 6),
    BoardGridPosition(row: 0, column: 6),
    BoardGridPosition(row: 0, column: 7),
    BoardGridPosition(row: 0, column: 8),
    BoardGridPosition(row: 1, column: 8), // main_13: green start
    BoardGridPosition(row: 2, column: 8),
    BoardGridPosition(row: 3, column: 8),
    BoardGridPosition(row: 4, column: 8),
    BoardGridPosition(row: 5, column: 8),
    BoardGridPosition(row: 6, column: 9),
    BoardGridPosition(row: 6, column: 10),
    BoardGridPosition(row: 6, column: 11),
    BoardGridPosition(row: 6, column: 12), // main_21: safe
    BoardGridPosition(row: 6, column: 13),
    BoardGridPosition(row: 6, column: 14),
    BoardGridPosition(row: 7, column: 14),
    BoardGridPosition(row: 8, column: 14),
    BoardGridPosition(row: 8, column: 13), // main_26: yellow start
    BoardGridPosition(row: 8, column: 12),
    BoardGridPosition(row: 8, column: 11),
    BoardGridPosition(row: 8, column: 10),
    BoardGridPosition(row: 8, column: 9),
    BoardGridPosition(row: 9, column: 8),
    BoardGridPosition(row: 10, column: 8),
    BoardGridPosition(row: 11, column: 8),
    BoardGridPosition(row: 12, column: 8), // main_34: safe
    BoardGridPosition(row: 13, column: 8),
    BoardGridPosition(row: 14, column: 8),
    BoardGridPosition(row: 14, column: 7),
    BoardGridPosition(row: 14, column: 6),
    BoardGridPosition(row: 13, column: 6), // main_39: blue start
    BoardGridPosition(row: 12, column: 6),
    BoardGridPosition(row: 11, column: 6),
    BoardGridPosition(row: 10, column: 6),
    BoardGridPosition(row: 9, column: 6),
    BoardGridPosition(row: 8, column: 5),
    BoardGridPosition(row: 8, column: 4),
    BoardGridPosition(row: 8, column: 3),
    BoardGridPosition(row: 8, column: 2), // main_47: safe
    BoardGridPosition(row: 8, column: 1),
    BoardGridPosition(row: 8, column: 0),
    BoardGridPosition(row: 7, column: 0),
    BoardGridPosition(row: 6, column: 0),
  ];

  /// Returns the normalized visual position of a shared-track [cell].
  static BoardGridPosition gridPositionForMainTrack(BoardCell cell) {
    if (cell.type != BoardCellType.mainPath || !cell.id.startsWith('main_')) {
      throw ArgumentError.value(
        cell,
        'cell',
        'Expected a valid main-track BoardCell.',
      );
    }

    final indexText = cell.id.substring('main_'.length);
    final mainTrackIndex = int.tryParse(indexText);

    if (mainTrackIndex == null ||
        mainTrackIndex < 0 ||
        mainTrackIndex >= mainTrackPositions.length) {
      throw ArgumentError.value(
        cell,
        'cell',
        'Main-track cell ID is outside the visual mapping.',
      );
    }

    return mainTrackPositions[mainTrackIndex];
  }

  /// Returns the responsive pixel center of a shared-track [cell].
  static Offset pixelCenterForMainTrack(
    BoardCell cell,
    BoardGeometry geometry,
  ) {
    return gridPositionForMainTrack(cell).centerIn(geometry);
  }
}
