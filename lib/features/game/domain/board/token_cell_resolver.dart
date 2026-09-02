import '../models/board_cell.dart';
import '../models/token.dart';
import 'board_definition.dart';

/// Resolves a token's logical position to its current board cell.
///
/// This class performs read-only translation between token state and the
/// logical board topology.
///
/// It does not:
/// - determine whether a token may move;
/// - change token state;
/// - calculate dice results;
/// - perform captures;
/// - control animations.
///
/// Those responsibilities belong to later game-engine layers and Jira
/// Stories.
class TokenCellResolver {
  const TokenCellResolver._();

  /// Returns the logical [BoardCell] currently occupied by [token].
  ///
  /// Returns null when the token is still in its player's yard/base because
  /// the yard is deliberately outside the player's 0-56 movement path.
  static BoardCell? resolve(Token token) {
    final progress = token.position.progress;

    // A yard token has no movement-path progress and therefore occupies no
    // BoardCell from the player's movement path.
    if (progress == null) {
      return null;
    }

    final playerPath = BoardDefinition.movementPathFor(token.ownerColor);

    return playerPath.cellAt(progress);
  }
}
