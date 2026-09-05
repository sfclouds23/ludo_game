import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/domain/models/game_state.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_move_transaction.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/domain/services/capture_resolver.dart';

void main() {
  const resolver = CaptureResolver();

  group('CaptureResolver', () {
    test('captures one opponent on a non-safe shared-track destination', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 1),
        otherTokens: [_pathToken('green_0', PlayerColor.green, 40)],
      );

      final resolution = resolver.resolve(movement);

      expect(resolution.didCapture, isTrue);
      expect(resolution.capturedTokenIds, ['green_0']);
      expect(_token(resolution.gameState, 'green_0').position.isInYard, isTrue);
      expect(_token(resolution.gameState, 'red_0').position.progress, 1);
    });

    for (final safeCase in <({PlayerColor color, int progress})>[
      (color: PlayerColor.red, progress: 0),
      (color: PlayerColor.green, progress: 0),
      (color: PlayerColor.yellow, progress: 0),
      (color: PlayerColor.blue, progress: 0),
      (color: PlayerColor.red, progress: 8),
      (color: PlayerColor.green, progress: 8),
      (color: PlayerColor.yellow, progress: 8),
      (color: PlayerColor.blue, progress: 8),
    ]) {
      test(
        'safe destination for ${safeCase.color.name} progress '
        '${safeCase.progress} suppresses capture',
        () {
          final movedToken = _pathToken(
            'mover',
            safeCase.color,
            safeCase.progress,
          );
          final physicalIndex = _mainTrackIndex(
            safeCase.color,
            safeCase.progress,
          );
          final opponentColor = _differentColor(safeCase.color);
          final opponentProgress = _progressForMainTrackIndex(
            opponentColor,
            physicalIndex,
          );
          final movement = _movement(
            movedToken: movedToken,
            otherTokens: [
              _pathToken('opponent', opponentColor, opponentProgress),
            ],
          );

          final resolution = resolver.resolve(movement);

          expect(resolution.didCapture, isFalse);
          expect(resolution.capturedTokenIds, isEmpty);
          expect(
            _token(resolution.gameState, 'opponent').position.progress,
            opponentProgress,
          );
        },
      );
    }

    test('same-color token on destination is not captured', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 1),
        otherTokens: [_pathToken('red_1', PlayerColor.red, 1)],
      );

      final resolution = resolver.resolve(movement);

      expect(resolution.didCapture, isFalse);
      expect(_token(resolution.gameState, 'red_1').position.progress, 1);
    });

    test('captures every same-color opponent token on destination', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 1),
        otherTokens: [
          _pathToken('green_0', PlayerColor.green, 40),
          _pathToken('green_1', PlayerColor.green, 40),
        ],
      );

      final resolution = resolver.resolve(movement);

      expect(resolution.capturedTokenIds, ['green_0', 'green_1']);
      expect(_token(resolution.gameState, 'green_0').position.isInYard, isTrue);
      expect(_token(resolution.gameState, 'green_1').position.isInYard, isTrue);
    });

    test('captures opponents of multiple colors on destination', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 1),
        otherTokens: [
          _pathToken('green_0', PlayerColor.green, 40),
          _pathToken('yellow_0', PlayerColor.yellow, 27),
        ],
      );

      final resolution = resolver.resolve(movement);

      expect(resolution.capturedTokenIds, ['green_0', 'yellow_0']);
      expect(_token(resolution.gameState, 'green_0').position.isInYard, isTrue);
      expect(_token(resolution.gameState, 'yellow_0').position.isInYard, isTrue);
    });

    test('keeps friendly token while capturing opponent on same cell', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 1),
        otherTokens: [
          _pathToken('red_1', PlayerColor.red, 1),
          _pathToken('green_0', PlayerColor.green, 40),
        ],
      );

      final resolution = resolver.resolve(movement);

      expect(resolution.capturedTokenIds, ['green_0']);
      expect(_token(resolution.gameState, 'red_1').position.progress, 1);
      expect(_token(resolution.gameState, 'green_0').position.isInYard, isTrue);
    });

    test('ignores opponent occupying an intermediate movement cell', () {
      final movement = TokenMoveTransaction(
        gameState: GameState.withTokens(
          tokens: [
            _pathToken('red_0', PlayerColor.red, 4),
            _pathToken('green_0', PlayerColor.green, 42),
          ],
          diceResult: DiceResult(3),
        ),
        tokenId: 'red_0',
        steps: [
          TokenPosition.onPath(2),
          TokenPosition.onPath(3),
          TokenPosition.onPath(4),
        ],
      );

      final resolution = resolver.resolve(movement);

      expect(resolution.didCapture, isFalse);
      expect(_token(resolution.gameState, 'green_0').position.progress, 42);
    });

    test('private home-lane destination cannot capture opponents', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 51),
        otherTokens: [_pathToken('green_0', PlayerColor.green, 51)],
      );

      final resolution = resolver.resolve(movement);

      expect(resolution.didCapture, isFalse);
      expect(_token(resolution.gameState, 'green_0').position.progress, 51);
    });

    test('finish destination cannot capture opponents', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 56),
        otherTokens: [_pathToken('green_0', PlayerColor.green, 56)],
      );

      final resolution = resolver.resolve(movement);

      expect(resolution.didCapture, isFalse);
      expect(_token(resolution.gameState, 'green_0').position.progress, 56);
    });

    test('preserves token ordering and unrelated token identity', () {
      final moved = _pathToken('red_0', PlayerColor.red, 1);
      final captured = _pathToken('green_0', PlayerColor.green, 40);
      final unrelated = _pathToken('blue_0', PlayerColor.blue, 10);
      final movement = _movement(
        movedToken: moved,
        otherTokens: [captured, unrelated],
      );

      final resolution = resolver.resolve(movement);

      expect(resolution.gameState.tokens.map((token) => token.id), [
        'red_0',
        'green_0',
        'blue_0',
      ]);
      expect(resolution.gameState.tokens[0], same(moved));
      expect(resolution.gameState.tokens[2], same(unrelated));
      expect(resolution.gameState.tokens[1], isNot(same(captured)));
    });

    test('does not mutate movement GameState or captured token', () {
      final captured = _pathToken('green_0', PlayerColor.green, 40);
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 1),
        otherTokens: [captured],
      );

      final resolution = resolver.resolve(movement);

      expect(_token(movement.gameState, 'green_0'), same(captured));
      expect(captured.position.progress, 40);
      expect(resolution.gameState, isNot(same(movement.gameState)));
      expect(_token(resolution.gameState, 'green_0').position.isInYard, isTrue);
    });

    test('captured token IDs are immutable', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 1),
        otherTokens: [_pathToken('green_0', PlayerColor.green, 40)],
      );
      final resolution = resolver.resolve(movement);

      expect(
        () => resolution.capturedTokenIds.add('green_1'),
        throwsUnsupportedError,
      );
    });

    test('post-capture state is authoritative before presentation', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 1),
        otherTokens: [_pathToken('green_0', PlayerColor.green, 40)],
      );

      final resolution = resolver.resolve(movement);

      // Presentation may animate the impact and captured token return later.
      // The logical capture is already complete independently of animation.
      expect(resolution.didCapture, isTrue);
      expect(_token(resolution.gameState, 'green_0').position.isInYard, isTrue);
    });

    test('throws when moved token is absent from movement state', () {
      final movement = TokenMoveTransaction(
        gameState: GameState.withTokens(
          tokens: [_pathToken('green_0', PlayerColor.green, 40)],
          diceResult: DiceResult(1),
        ),
        tokenId: 'missing',
        steps: [TokenPosition.onPath(1)],
      );

      expect(() => resolver.resolve(movement), throwsStateError);
    });
  });
}

TokenMoveTransaction _movement({
  required Token movedToken,
  Iterable<Token> otherTokens = const <Token>[],
}) {
  return TokenMoveTransaction(
    gameState: GameState.withTokens(
      tokens: [movedToken, ...otherTokens],
      diceResult: DiceResult(1),
    ),
    tokenId: movedToken.id,
    steps: [movedToken.position],
  );
}

Token _token(GameState state, String tokenId) {
  return state.tokens.singleWhere((token) => token.id == tokenId);
}

Token _pathToken(String id, PlayerColor color, int progress) {
  return Token(
    id: id,
    ownerColor: color,
    position: TokenPosition.onPath(progress),
  );
}

PlayerColor _differentColor(PlayerColor color) {
  return PlayerColor.values.firstWhere((candidate) => candidate != color);
}

int _mainTrackIndex(PlayerColor color, int progress) {
  const startIndices = <PlayerColor, int>{
    PlayerColor.red: 0,
    PlayerColor.green: 13,
    PlayerColor.yellow: 26,
    PlayerColor.blue: 39,
  };

  return (startIndices[color]! + progress) % 52;
}

int _progressForMainTrackIndex(PlayerColor color, int mainTrackIndex) {
  const startIndices = <PlayerColor, int>{
    PlayerColor.red: 0,
    PlayerColor.green: 13,
    PlayerColor.yellow: 26,
    PlayerColor.blue: 39,
  };

  return (mainTrackIndex - startIndices[color]!) % 52;
}
