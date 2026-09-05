import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/capture_resolution.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/domain/models/game_state.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/presentation/capture/capture_playback.dart';

void main() {
  group('CapturePlayback', () {
    test('starts complete and unlocked when no capture occurred', () {
      final resolution = _resolution(const <String>[]);

      final playback = CapturePlayback.start(resolution);

      expect(playback.phase, CapturePlaybackPhase.complete);
      expect(playback.isComplete, isTrue);
      expect(playback.isInputLocked, isFalse);
      expect(playback.currentReturningTokenId, isNull);
    });

    test('starts with impact phase and input locked after capture', () {
      final playback = CapturePlayback.start(_resolution(['green_0']));

      expect(playback.phase, CapturePlaybackPhase.impact);
      expect(playback.isInputLocked, isTrue);
      expect(playback.returnedTokenIds, isEmpty);
    });

    test('advances from impact to first captured token return', () {
      final playback = CapturePlayback.start(
        _resolution(['green_0', 'yellow_0']),
      ).advance();

      expect(playback.phase, CapturePlaybackPhase.returningTokens);
      expect(playback.currentReturningTokenId, 'green_0');
      expect(playback.returnedTokenIds, isEmpty);
      expect(playback.isInputLocked, isTrue);
    });

    test('returns multiple captured tokens in deterministic order', () {
      var playback = CapturePlayback.start(_resolution(['green_0', 'yellow_0']))
          .advance();

      playback = playback.advance();
      expect(playback.phase, CapturePlaybackPhase.returningTokens);
      expect(playback.returnedTokenIds, ['green_0']);
      expect(playback.currentReturningTokenId, 'yellow_0');

      playback = playback.advance();
      expect(playback.phase, CapturePlaybackPhase.complete);
      expect(playback.returnedTokenIds, ['green_0', 'yellow_0']);
      expect(playback.currentReturningTokenId, isNull);
      expect(playback.isInputLocked, isFalse);
    });

    test('advancing completed playback is idempotent', () {
      final playback = CapturePlayback.start(_resolution(const <String>[]));

      expect(playback.advance(), same(playback));
    });

    test('returned token IDs view is immutable', () {
      var playback = CapturePlayback.start(_resolution(['green_0', 'yellow_0']))
          .advance();
      playback = playback.advance();

      expect(
        () => playback.returnedTokenIds.add('blue_0'),
        throwsUnsupportedError,
      );
    });

    test('logical capture state remains authoritative through playback', () {
      final resolution = _resolution(['green_0']);
      var playback = CapturePlayback.start(resolution);

      expect(_token(resolution.gameState, 'green_0').position.isInYard, isTrue);

      playback = playback.advance();
      expect(
        _token(playback.resolution.gameState, 'green_0').position.isInYard,
        isTrue,
      );

      playback = playback.advance();
      expect(playback.isComplete, isTrue);
      expect(
        _token(playback.resolution.gameState, 'green_0').position.isInYard,
        isTrue,
      );
    });
  });
}

CaptureResolution _resolution(List<String> capturedTokenIds) {
  return CaptureResolution(
    gameState: GameState.withTokens(
      tokens: [
        Token(
          id: 'red_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.onPath(1),
        ),
        Token(
          id: 'green_0',
          ownerColor: PlayerColor.green,
          position: const TokenPosition.yard(),
        ),
        Token(
          id: 'yellow_0',
          ownerColor: PlayerColor.yellow,
          position: const TokenPosition.yard(),
        ),
      ],
      diceResult: DiceResult(1),
    ),
    movedTokenId: 'red_0',
    capturedTokenIds: capturedTokenIds,
  );
}

Token _token(GameState state, String tokenId) {
  return state.tokens.singleWhere((token) => token.id == tokenId);
}
