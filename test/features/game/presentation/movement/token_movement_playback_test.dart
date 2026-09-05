import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/game_state.dart';
import 'package:ludo_game/features/game/domain/models/token_move_transaction.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/presentation/movement/token_movement_playback.dart';

void main() {
  group('TokenMovementPlayback', () {
    test('starts on the first visual step with input locked', () {
      final transaction = _transaction([11, 12, 13]);

      final playback = TokenMovementPlayback.start(transaction);

      expect(playback.stepIndex, 0);
      expect(playback.visualPosition.progress, 11);
      expect(playback.isInputLocked, isTrue);
      expect(playback.hasNextStep, isTrue);
    });

    test('advances exactly one visual cell at a time', () {
      final transaction = _transaction([11, 12, 13]);

      final first = TokenMovementPlayback.start(transaction);
      final second = first.advance();
      final third = second.advance();

      expect(first.visualPosition.progress, 11);
      expect(second.visualPosition.progress, 12);
      expect(third.visualPosition.progress, 13);
      expect(third.hasNextStep, isFalse);
    });

    test('does not advance beyond final visual step', () {
      final playback = TokenMovementPlayback.start(_transaction([11]));

      expect(playback.advance(), same(playback));
    });

    test('exposes immutable visual-position overrides', () {
      final playback = TokenMovementPlayback.start(_transaction([11, 12]));
      final overrides = playback.visualPositionOverrides;

      expect(overrides['red_0']!.progress, 11);
      expect(
        () => overrides['red_1'] = TokenPosition.onPath(20),
        throwsUnsupportedError,
      );
    });

    test('playback never changes the committed final GameState', () {
      final finalState = GameState.withTokens(tokens: const []);
      final transaction = TokenMoveTransaction(
        gameState: finalState,
        tokenId: 'red_0',
        steps: [
          TokenPosition.onPath(11),
          TokenPosition.onPath(12),
          TokenPosition.onPath(13),
        ],
      );

      final first = TokenMovementPlayback.start(transaction);
      final second = first.advance();

      expect(first.transaction.gameState, same(finalState));
      expect(second.transaction.gameState, same(finalState));
    });

    test('rejects a transaction without visual steps', () {
      final transaction = TokenMoveTransaction(
        gameState: GameState.withTokens(tokens: const []),
        tokenId: 'red_0',
        steps: const [],
      );

      expect(
        () => TokenMovementPlayback.start(transaction),
        throwsArgumentError,
      );
    });
  });
}

TokenMoveTransaction _transaction(List<int> progresses) {
  return TokenMoveTransaction(
    gameState: GameState.withTokens(tokens: const []),
    tokenId: 'red_0',
    steps: progresses.map(TokenPosition.onPath),
  );
}
