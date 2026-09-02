import '../models/board_cell.dart';
import '../models/player_color.dart';
import 'player_path.dart';

/// Defines the logical structure of the shared Ludo main track.
///
/// This class contains domain-level board information only. It deliberately
/// knows nothing about Flutter widgets, pixel coordinates, screen sizes,
/// animations, or rendering.
class BoardDefinition {
  BoardDefinition._();

  /// Number of logical cells in the shared circular Ludo main track.
  static const int mainTrackCellCount = 52;

  /// Global main-track index where each player's token enters the board.
  ///
  /// Start cells are separated by 13 positions around the 52-cell track.
  static const Map<PlayerColor, int> playerStartIndices = {
    PlayerColor.red: 0,
    PlayerColor.green: 13,
    PlayerColor.yellow: 26,
    PlayerColor.blue: 39,
  };

  /// All shared main-track cells in global board order.
  ///
  /// These cells are created once because the logical board definition does
  /// not change during a match.
  static final List<BoardCell> mainTrackCells = List.unmodifiable(
    List.generate(
      mainTrackCellCount,
      (index) => BoardCell(id: 'main_$index', type: BoardCellType.mainPath),
    ),
  );

  /// Returns the global main-track start index for [playerColor].
  static int startIndexFor(PlayerColor playerColor) {
    final int? startIndex = playerStartIndices[playerColor];

    // All PlayerColor values must have a defined starting cell.
    // Failing explicitly here protects us if the enum is expanded later
    // without updating the logical board definition.
    if (startIndex == null) {
      throw StateError(
        'No main-track start index configured for $playerColor.',
      );
    }

    return startIndex;
  }

  /// Returns the shared main-track cell at [relativeProgress] from a
  /// player's own starting position.
  ///
  /// Example:
  ///
  /// Red:
  /// relativeProgress 0 -> main_0
  ///
  /// Green:
  /// relativeProgress 0 -> main_13
  ///
  /// The modulo operation allows translation around the circular track.
  static BoardCell mainTrackCellAt(
    PlayerColor playerColor,
    int relativeProgress,
  ) {
    if (relativeProgress < 0 || relativeProgress >= mainTrackCellCount) {
      throw RangeError.range(
        relativeProgress,
        0,
        mainTrackCellCount - 1,
        'relativeProgress',
        'Main-track progress must reference a valid shared track cell.',
      );
    }

    final int playerStartIndex = startIndexFor(playerColor);

    final int globalCellIndex =
        (playerStartIndex + relativeProgress) % mainTrackCellCount;

    return mainTrackCells[globalCellIndex];
  }

  /// Creates a player-relative view of the complete shared main track.
  ///
  /// The returned path begins at that player's own starting cell while
  /// referencing the same shared logical BoardCell objects.
  ///
  /// This is currently the circular main-track representation only.
  /// Player-specific home lanes and final movement paths will be added in
  /// subsequent GAME-101 increments.
  static PlayerPath mainTrackFor(PlayerColor playerColor) {
    final List<BoardCell> orderedCells = List.generate(
      mainTrackCellCount,
      (relativeProgress) => mainTrackCellAt(playerColor, relativeProgress),
    );

    return PlayerPath(
      playerColor: playerColor,
      cells: List.unmodifiable(orderedCells),
    );
  }
}
