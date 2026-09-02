import '../models/board_cell.dart';
import '../models/player_color.dart';

/// Represents the ordered logical route followed by one player's tokens.
///
/// Progress through this list is player-relative. For example, index 0 is
/// always the first playable position for [playerColor], regardless of the
/// physical location of that cell on the rendered board.
class PlayerPath {
  const PlayerPath({required this.playerColor, required this.cells});

  /// Player whose movement route this path represents.
  final PlayerColor playerColor;

  /// Ordered logical cells traversed by this player's tokens.
  ///
  /// The first element represents player-relative progress 0.
  final List<BoardCell> cells;

  /// Number of playable logical positions in this path.
  int get length => cells.length;

  /// Returns the board cell corresponding to [progress].
  ///
  /// Throws a [RangeError] when the supplied progress does not represent
  /// a valid position in this player's path.
  BoardCell cellAt(int progress) {
    // Validate the progress explicitly so invalid game state fails early
    // instead of accidentally indexing an unrelated board position.
    if (progress < 0 || progress >= cells.length) {
      throw RangeError.range(
        progress,
        0,
        cells.length - 1,
        'progress',
        'Progress is outside the player path.',
      );
    }

    return cells[progress];
  }
}
