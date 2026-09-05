import '../board/board_definition.dart';
import '../board/token_cell_resolver.dart';
import '../models/capture_resolution.dart';
import '../models/token.dart';
import '../models/token_move_transaction.dart';
import '../models/token_position.dart';

/// Resolves capture consequences after a GAME-106 movement transaction.
///
/// Movement remains authoritative first: this service receives a transaction
/// whose moved token is already at its final logical destination. It then
/// derives a new immutable state containing capture consequences.
///
/// Only final-destination occupancy matters. Intermediate movement cells do
/// not trigger capture, and this service deliberately owns no turn, bonus-roll,
/// blockade, ranking, multiplayer, or animation authority.
class CaptureResolver {
  const CaptureResolver();

  /// Resolves capture consequences for [movement].
  ///
  /// Opponents sharing the moved token's final non-safe shared-track cell are
  /// returned to yard. Safe cells suppress capture entirely. Same-color tokens
  /// may coexist and are never captured.
  CaptureResolution resolve(TokenMoveTransaction movement) {
    final movementState = movement.gameState;
    final movedToken = movementState.tokens.firstWhere(
      (token) => token.id == movement.tokenId,
      orElse: () => throw StateError(
        'Moved token ${movement.tokenId} is missing from movement state.',
      ),
    );

    final destinationCell = TokenCellResolver.resolve(movedToken);

    // Yard is not a valid committed movement destination. Private home lanes,
    // finish cells, and configured shared safe cells cannot produce captures.
    if (destinationCell == null ||
        BoardDefinition.isSafeCell(destinationCell)) {
      return CaptureResolution(
        gameState: movementState,
        movedTokenId: movedToken.id,
        capturedTokenIds: const <String>[],
      );
    }

    final capturedTokenIds = <String>[];
    final resolvedTokens = <Token>[];

    for (final token in movementState.tokens) {
      if (token.id == movedToken.id ||
          token.ownerColor == movedToken.ownerColor) {
        resolvedTokens.add(token);
        continue;
      }

      final tokenCell = TokenCellResolver.resolve(token);
      if (tokenCell == destinationCell) {
        capturedTokenIds.add(token.id);
        resolvedTokens.add(
          token.copyWith(position: const TokenPosition.yard()),
        );
      } else {
        resolvedTokens.add(token);
      }
    }

    if (capturedTokenIds.isEmpty) {
      return CaptureResolution(
        gameState: movementState,
        movedTokenId: movedToken.id,
        capturedTokenIds: const <String>[],
      );
    }

    return CaptureResolution(
      gameState: movementState.withTokensReplaced(resolvedTokens),
      movedTokenId: movedToken.id,
      capturedTokenIds: capturedTokenIds,
    );
  }
}
