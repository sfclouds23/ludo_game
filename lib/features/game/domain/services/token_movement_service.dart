import '../models/game_state.dart';
import '../models/legal_move.dart';
import '../models/token.dart';
import '../models/token_move_transaction.dart';
import '../models/token_position.dart';
import 'legal_move_evaluator.dart';

/// Commits approved GAME-105 moves into immutable authoritative GameState.
///
/// Logical state is updated before any presentation animation begins. The
/// returned [TokenMoveTransaction.steps] sequence is presentation guidance only
/// and cannot alter the already-committed logical result.
class TokenMovementService {
  /// Creates a movement service.
  const TokenMovementService({
    this.legalMoveEvaluator = const LegalMoveEvaluator(),
  });

  /// Evaluator used to reject stale or fabricated move options.
  final LegalMoveEvaluator legalMoveEvaluator;

  /// Attempts to commit [move] against the current authoritative [state].
  ///
  /// Returns null when the token no longer exists or [move] is not one of the
  /// token's currently legal options for the completed dice result. No state is
  /// mutated when the move is rejected.
  TokenMoveTransaction? tryCommit(GameState state, LegalMove move) {
    final tokenIndex = state.tokens.indexWhere(
      (token) => token.id == move.tokenId,
    );
    if (tokenIndex < 0) {
      return null;
    }

    final token = state.tokens[tokenIndex];
    final currentMove = legalMoveEvaluator
        .evaluate(state, token.ownerColor)
        .moveForToken(token.id);

    if (currentMove != move) {
      return null;
    }

    final steps = _buildSteps(token.position, move.destination);
    final movedToken = token.copyWith(position: move.destination);
    final nextTokens = List<Token>.of(state.tokens);
    nextTokens[tokenIndex] = movedToken;

    final nextState = state.withTokensReplaced(nextTokens);

    return TokenMoveTransaction(
      gameState: nextState,
      tokenId: token.id,
      steps: steps,
    );
  }

  List<TokenPosition> _buildSteps(
    TokenPosition source,
    TokenPosition destination,
  ) {
    if (source.isInYard) {
      return <TokenPosition>[destination];
    }

    final sourceProgress = source.progress!;
    final destinationProgress = destination.progress!;

    return <TokenPosition>[
      for (
        var progress = sourceProgress + 1;
        progress <= destinationProgress;
        progress++
      )
        TokenPosition.onPath(progress),
    ];
  }
}
