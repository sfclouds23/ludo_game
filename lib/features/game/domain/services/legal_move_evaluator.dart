import '../models/game_state.dart';
import '../models/legal_move.dart';
import '../models/player_color.dart';
import '../models/token.dart';
import '../models/token_position.dart';

/// Calculates legal token choices from authoritative local GameState.
///
/// GAME-105 deliberately evaluates legality only. It does not mutate tokens,
/// resolve captures, grant extra turns, advance players, animate movement, or
/// implement multiplayer behavior.
class LegalMoveEvaluator {
  const LegalMoveEvaluator();

  /// Qualifying dice value that releases a token from the yard.
  static const int yardReleaseDiceValue = 6;

  /// Calculates legal moves for [playerColor] using the completed dice result.
  ///
  /// A pending/animating result is intentionally ignored. This preserves the
  /// GAME-104 contract that move logic consumes only a completed logical roll.
  LegalMoveResult evaluate(GameState state, PlayerColor playerColor) {
    final diceResult = state.diceResult;

    if (diceResult == null || state.isDiceRolling) {
      return LegalMoveResult(const <LegalMove>[]);
    }

    final moves = <LegalMove>[];

    for (final token in state.tokens) {
      if (token.ownerColor != playerColor) {
        continue;
      }

      final move = _evaluateToken(token, diceResult.value);
      if (move != null) {
        moves.add(move);
      }
    }

    return LegalMoveResult(moves);
  }

  /// Evaluates one owned token against the current dice value.
  LegalMove? _evaluateToken(Token token, int diceValue) {
    final position = token.position;

    // Our selected GAME-105 rule releases a yard token only on six. Releasing
    // places it on progress 0 and does not add six movement steps afterward.
    if (position.isInYard) {
      if (diceValue != yardReleaseDiceValue) {
        return null;
      }

      return LegalMove(
        tokenId: token.id,
        destination: TokenPosition.onPath(TokenPosition.minimumPathProgress),
      );
    }

    // Finished tokens have no destination beyond progress 56.
    if (position.isFinished) {
      return null;
    }

    final currentProgress = position.progress!;
    final destinationProgress = currentProgress + diceValue;

    // Exact finish is required. This single boundary also protects private
    // home-lane movement because progress 51-55 may advance only up to 56.
    if (destinationProgress > TokenPosition.finishProgress) {
      return null;
    }

    return LegalMove(
      tokenId: token.id,
      destination: TokenPosition.onPath(destinationProgress),
    );
  }
}
