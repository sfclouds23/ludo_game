import 'game_state.dart';
import 'token_position.dart';

/// Immutable result of committing one approved logical token move.
///
/// [gameState] is already the authoritative final logical state. [steps] exists
/// only so presentation can visit each logical position in sequence afterward.
/// Animation completion must never be required to make [gameState] correct.
class TokenMoveTransaction {
  TokenMoveTransaction({
    required this.gameState,
    required this.tokenId,
    required Iterable<TokenPosition> steps,
  }) : steps = List<TokenPosition>.unmodifiable(steps);

  /// Final authoritative state after the move has already been committed.
  final GameState gameState;

  /// Stable identity of the moved token.
  final String tokenId;

  /// Ordered logical positions presentation should visit during movement.
  ///
  /// For an on-path move this contains every intermediate step plus the final
  /// destination. Yard release contains the single start-cell destination.
  final List<TokenPosition> steps;

  /// Final logical destination of the committed move.
  TokenPosition get destination => steps.last;
}
