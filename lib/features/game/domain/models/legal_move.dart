import 'token_position.dart';

/// Describes one move that GAME-105 has determined is legal.
///
/// The move contains the token identity and destination only. It does not
/// mutate GameState, resolve captures, grant bonus turns, or animate movement.
class LegalMove {
  /// Creates an immutable legal move option.
  const LegalMove({required this.tokenId, required this.destination});

  /// Stable token identity that the player may choose.
  final String tokenId;

  /// Logical destination already validated by the legal-move evaluator.
  final TokenPosition destination;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LegalMove &&
        other.tokenId == tokenId &&
        other.destination == destination;
  }

  @override
  int get hashCode => Object.hash(tokenId, destination);

  @override
  String toString() {
    return 'LegalMove(tokenId: $tokenId, destination: $destination)';
  }
}

/// Immutable result of evaluating the current dice result for one player.
class LegalMoveResult {
  /// Creates a result from [moves].
  LegalMoveResult(Iterable<LegalMove> moves)
    : moves = List<LegalMove>.unmodifiable(moves);

  /// Legal token choices in the same deterministic order as GameState.tokens.
  final List<LegalMove> moves;

  /// Whether the player has at least one legal token choice.
  bool get hasLegalMoves => moves.isNotEmpty;

  /// Stable token IDs that presentation may highlight.
  List<String> get movableTokenIds =>
      List<String>.unmodifiable(moves.map((move) => move.tokenId));

  /// Finds the legal move for [tokenId], or null when that token is not legal.
  LegalMove? moveForToken(String tokenId) {
    for (final move in moves) {
      if (move.tokenId == tokenId) {
        return move;
      }
    }

    return null;
  }
}
