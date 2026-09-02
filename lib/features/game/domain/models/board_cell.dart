/// Describes the logical purpose of a cell on the Ludo board.
///
/// These values describe game-domain concepts and are intentionally
/// independent from visual board coordinates.
enum BoardCellType {
  /// A cell on the shared circular path used by multiple players.
  mainPath,

  /// A player-specific cell leading toward that player's finish.
  homeLane,

  /// Represents a token's home/start area before entering the board.
  home,

  /// Represents the completed position after traversing the full path.
  finish,
}

/// Represents one logical location on the Ludo board.
///
/// A [BoardCell] contains only information required by the game domain.
/// It intentionally contains no pixel coordinates or Flutter presentation
/// information.
class BoardCell {
  const BoardCell({required this.id, required this.type});

  /// Stable logical identifier for this board location.
  ///
  /// Future examples include:
  /// - main_0
  /// - main_25
  /// - red_home_lane_0
  /// - red_finish
  final String id;

  /// Logical category of this board cell.
  final BoardCellType type;

  @override
  bool operator ==(Object other) {
    // Identical objects are always equal.
    if (identical(this, other)) {
      return true;
    }

    // Two cells represent the same logical location when both their
    // stable identifier and logical type match.
    return other is BoardCell && other.id == id && other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() {
    return 'BoardCell(id: $id, type: $type)';
  }
}
