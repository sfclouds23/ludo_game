import '../models/board_cell.dart';
import '../models/player_color.dart';
import 'player_path.dart';

/// Defines the immutable logical topology of the Ludo board.
///
/// This class contains domain-level board information only. It deliberately
/// knows nothing about Flutter widgets, pixel coordinates, screen sizes,
/// animations, or rendering.
///
/// Rendering code will later translate these logical cells into visual board
/// coordinates as part of GAME-102.
class BoardDefinition {
  BoardDefinition._();

  /// Number of cells forming the complete shared circular track.
  static const int mainTrackCellCount = 52;

  /// Number of shared-track cells actually travelled by one player before
  /// entering that player's private home lane.
  ///
  /// A player begins on their own start cell and leaves the shared route
  /// before wrapping back onto that start cell.
  static const int playerMainTrackCellCount = 51;

  /// Number of private cells between the shared track and the final finish
  /// position.
  ///
  /// The finish itself is represented separately rather than pretending that
  /// a home-lane cell and the completed state are the same concept.
  static const int homeLaneCellCount = 5;

  /// Total number of logical positions in one player's movement path:
  ///
  /// 51 shared cells + 5 private home-lane cells + 1 finish cell.
  static const int playerPathCellCount =
      playerMainTrackCellCount + homeLaneCellCount + 1;

  /// Global main-track index where each player's token enters the board.
  ///
  /// Start cells are evenly separated by 13 positions around the 52-cell
  /// shared track.
  static const Map<PlayerColor, int> playerStartIndices = {
    PlayerColor.red: 0,
    PlayerColor.green: 13,
    PlayerColor.yellow: 26,
    PlayerColor.blue: 39,
  };

  /// Additional protected shared-track cells.
  ///
  /// Player start cells are also safe and are combined with these positions
  /// by [safeMainTrackIndices].
  static const Set<int> additionalSafeMainTrackIndices = {8, 21, 34, 47};

  /// All logical cells forming the shared circular track.
  ///
  /// These objects are immutable and reused by every player path. This is
  /// important because two players occupying `main_13`, for example, should
  /// reference the same logical board location rather than separate copies of
  /// a visually similar cell.
  static final List<BoardCell> mainTrackCells = List.unmodifiable(
    List.generate(
      mainTrackCellCount,
      (index) => BoardCell(id: 'main_$index', type: BoardCellType.mainPath),
    ),
  );

  /// Returns every shared-track index protected from capture.
  ///
  /// The set consists of:
  /// - each player's start cell;
  /// - the four additional safe/star cells.
  static Set<int> get safeMainTrackIndices => Set.unmodifiable({
    ...playerStartIndices.values,
    ...additionalSafeMainTrackIndices,
  });

  /// Returns the global shared-track start index for [playerColor].
  static int startIndexFor(PlayerColor playerColor) {
    final int? startIndex = playerStartIndices[playerColor];

    // Every supported PlayerColor must have a corresponding logical start.
    // Keeping this validation explicit protects the board model if another
    // color is ever added without updating the topology.
    if (startIndex == null) {
      throw StateError(
        'No main-track start index configured for $playerColor.',
      );
    }

    return startIndex;
  }

  /// Returns the shared-track cell at [relativeProgress] from a player's own
  /// starting position.
  ///
  /// This method represents translation around the complete 52-cell circular
  /// track. It is therefore intentionally different from [movementPathFor],
  /// which stops after the 51 shared cells a token may actually traverse
  /// before entering its home lane.
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

    // Rotate the global 52-cell track so relative progress 0 always means
    // "this player's starting cell".
    final int globalCellIndex =
        (playerStartIndex + relativeProgress) % mainTrackCellCount;

    return mainTrackCells[globalCellIndex];
  }

  /// Returns a player-relative representation of the complete circular track.
  ///
  /// This helper is useful when reasoning about the physical shared board
  /// topology. It includes all 52 shared cells and should not be confused with
  /// the actual token movement route returned by [movementPathFor].
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

  /// Returns the private home-lane cells belonging to [playerColor].
  ///
  /// Home-lane cells are intentionally player-specific because opponents
  /// cannot occupy another player's home lane.
  static List<BoardCell> homeLaneFor(PlayerColor playerColor) {
    final String colorName = playerColor.name;

    return List.unmodifiable(
      List.generate(
        homeLaneCellCount,
        (index) => BoardCell(
          id: '${colorName}_home_lane_$index',
          type: BoardCellType.homeLane,
        ),
      ),
    );
  }

  /// Returns the final logical finish position for [playerColor].
  ///
  /// Finish positions are player-specific and are distinct from home-lane
  /// cells so later rule code can clearly distinguish a moving token from a
  /// completed token.
  static BoardCell finishCellFor(PlayerColor playerColor) {
    return BoardCell(
      id: '${playerColor.name}_finish',
      type: BoardCellType.finish,
    );
  }

  /// Returns whether [cell] is protected from capture.
  ///
  /// All private home-lane and finish cells are inherently protected because
  /// opponents cannot legally occupy those paths. For shared-track cells, the
  /// protection is determined by [safeMainTrackIndices].
  static bool isSafeCell(BoardCell cell) {
    if (cell.type == BoardCellType.homeLane ||
        cell.type == BoardCellType.finish) {
      return true;
    }

    if (cell.type != BoardCellType.mainPath) {
      return false;
    }

    // Shared-track IDs are generated internally in the form `main_<index>`.
    // If an unexpected identifier reaches this method, treating it as unsafe
    // is preferable to incorrectly granting capture protection.
    final String indexText = cell.id.replaceFirst('main_', '');
    final int? mainTrackIndex = int.tryParse(indexText);

    if (mainTrackIndex == null) {
      return false;
    }

    return safeMainTrackIndices.contains(mainTrackIndex);
  }

  /// Creates the complete deterministic movement path for [playerColor].
  ///
  /// The path consists of:
  ///
  /// 1. 51 shared-track cells beginning at the player's own starting cell;
  /// 2. 5 player-specific home-lane cells;
  /// 3. 1 player-specific finish cell.
  ///
  /// This ordered representation allows future movement logic to work only
  /// with player-relative progress rather than branching on player colors.
  static PlayerPath movementPathFor(PlayerColor playerColor) {
    final List<BoardCell> pathCells = [];

    // Add only the shared-track cells this player is allowed to traverse.
    // The 52nd circular cell is intentionally excluded because the token
    // enters its private home lane before returning to its own start.
    for (
      int relativeProgress = 0;
      relativeProgress < playerMainTrackCellCount;
      relativeProgress++
    ) {
      pathCells.add(mainTrackCellAt(playerColor, relativeProgress));
    }

    // After leaving the shared track, movement becomes player-specific.
    pathCells.addAll(homeLaneFor(playerColor));

    // The final position represents completion of that token's route.
    pathCells.add(finishCellFor(playerColor));

    return PlayerPath(
      playerColor: playerColor,
      cells: List.unmodifiable(pathCells),
    );
  }
}
