import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/domain/models/game_state.dart';
import 'package:ludo_game/features/game/domain/models/legal_move.dart';
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

      final result = resolver.resolve(movement);

      expect(result.didCapture, isTrue);
      expect(result.capturedTokenIds, ['green_0']);
      expect(_token(result.gameState, 'green_0').position.isInYard, isTrue);
      expect(_token(result.gameState, 'red_0').position.progress, 1);
    });

    for (final safeIndex in <int>[0, 8, 13, 21, 26, 34, 39, 47]) {
      test('safe main_$safeIndex prevents capture', () {
        final redProgress = _progressForMainIndex(PlayerColor.red, safeIndex);
        final greenProgress = _progressForMainIndex(
          PlayerColor.green,
          safeIndex,
        );

        final movement = _movement(
          movedToken: _pathToken('red_0', PlayerColor.red, redProgress),
          otherTokens: [
            _pathToken('green_0', PlayerColor.green, greenProgress),
          ],
        );

        final result = resolver.resolve(movement);

        expect(result.didCapture, isFalse);
        expect(result.capturedTokenIds, isEmpty);
        expect(
          _token(result.gameState, 'green_0').position.progress,
          greenProgress,
        );
        expect(result.gameState, same(movement.gameState));
      });
    }

    test('same-color tokens may coexist without capture', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 5),
        otherTokens: [_pathToken('red_1', PlayerColor.red, 5)],
      );

      final result = resolver.resolve(movement);

      expect(result.didCapture, isFalse);
      expect(_token(result.gameState, 'red_1').position.progress, 5);
      expect(result.gameState, same(movement.gameState));
    });

    test('captures every opponent token on the non-safe destination', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 5),
        otherTokens: [
          _pathToken('green_0', PlayerColor.green, 44),
          _pathToken('green_1', PlayerColor.green, 44),
        ],
      );

      final result = resolver.resolve(movement);

      expect(result.capturedTokenIds, ['green_0', 'green_1']);
      expect(_token(result.gameState, 'green_0').position.isInYard, isTrue);
      expect(_token(result.gameState, 'green_1').position.isInYard, isTrue);
    });

    test('captures all opponent colors sharing the non-safe destination', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 5),
        otherTokens: [
          _pathToken('green_0', PlayerColor.green, 44),
          _pathToken('yellow_0', PlayerColor.yellow, 31),
          _pathToken('blue_0', PlayerColor.blue, 18),
        ],
      );

      final result = resolver.resolve(movement);

      expect(result.capturedTokenIds, ['green_0', 'yellow_0', 'blue_0']);
      for (final tokenId in result.capturedTokenIds) {
        expect(_token(result.gameState, tokenId).position.isInYard, isTrue);
      }
    });

    test('captures opponents but preserves same-color stack members', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 5),
        otherTokens: [
          _pathToken('red_1', PlayerColor.red, 5),
          _pathToken('green_0', PlayerColor.green, 44),
        ],
      );

      final result = resolver.resolve(movement);

      expect(result.capturedTokenIds, ['green_0']);
      expect(_token(result.gameState, 'red_1').position.progress, 5);
      expect(_token(result.gameState, 'green_0').position.isInYard, isTrue);
    });

    test('ignores opponents occupying intermediate movement cells', () {
      final movement = TokenMoveTransaction(
        gameState: GameState.withTokens(
          tokens: [
            _pathToken('red_0', PlayerColor.red, 5),
            _pathToken('green_0', PlayerColor.green, 42),
          ],
          diceResult: DiceResult(3),
        ),
        tokenId: 'red_0',
        steps: [
          TokenPosition.onPath(3),
          TokenPosition.onPath(4),
          TokenPosition.onPath(5),
        ],
      );

      final result = resolver.resolve(movement);

      // Green progress 42 resolves to main_3, which the red token visually
      // passed through. GAME-107 evaluates only the committed final main_5.
      expect(result.didCapture, isFalse);
      expect(_token(result.gameState, 'green_0').position.progress, 42);
    });

    test('private home-lane destination cannot capture opponents', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 52),
        otherTokens: [_pathToken('green_0', PlayerColor.green, 52)],
      );

      final result = resolver.resolve(movement);

      expect(result.didCapture, isFalse);
      expect(result.gameState, same(movement.gameState));
    });

    test('finish destination cannot capture opponents', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 56),
        otherTokens: [_pathToken('green_0', PlayerColor.green, 56)],
      );

      final result = resolver.resolve(movement);

      expect(result.didCapture, isFalse);
      expect(result.gameState, same(movement.gameState));
    });

    test('preserves token ordering and unchanged token identity', () {
      final mover = _pathToken('red_0', PlayerColor.red, 5);
      final captured = _pathToken('green_0', PlayerColor.green, 44);
      final unrelated = _pathToken('yellow_0', PlayerColor.yellow, 10);
      final sameColor = _pathToken('red_1', PlayerColor.red, 12);
      final movement = _movement(
        movedToken: mover,
        otherTokens: [captured, unrelated, sameColor],
      );

      final result = resolver.resolve(movement);

      expect(result.gameState.tokens.map((token) => token.id), [
        'red_0',
        'green_0',
        'yellow_0',
        'red_1',
      ]);
      expect(result.gameState.tokens[0], same(mover));
      expect(result.gameState.tokens[2], same(unrelated));
      expect(result.gameState.tokens[3], same(sameColor));
      expect(result.gameState.tokens[1], isNot(same(captured)));
    });

    test('does not mutate the movement GameState or captured token', () {
      final captured = _pathToken('green_0', PlayerColor.green, 44);
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 5),
        otherTokens: [captured],
      );

      final result = resolver.resolve(movement);

      expect(_token(movement.gameState, 'green_0'), same(captured));
      expect(captured.position.progress, 44);
      expect(result.gameState, isNot(same(movement.gameState)));
      expect(_token(result.gameState, 'green_0').position.isInYard, isTrue);
    });

    test('captured-token ID collection is immutable', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 5),
        otherTokens: [_pathToken('green_0', PlayerColor.green, 44)],
      );
      final result = resolver.resolve(movement);

      expect(
        () => result.capturedTokenIds.add('green_1'),
        throwsUnsupportedError,
      );
    });

    test('post-capture state is authoritative before presentation', () {
      final movement = _movement(
        movedToken: _pathToken('red_0', PlayerColor.red, 5),
        otherTokens: [_pathToken('green_0', PlayerColor.green, 44)],
      );

      final result = resolver.resolve(movement);

      // Any future impact/return-home animation consumes this result. Logical
      // capture has already happened even if presentation never runs.
      expect(result.didCapture, isTrue);
      expect(_token(result.gameState, 'green_0').position.isInYard, isTrue);
    });

    test('throws when the movement state no longer contains the moved token', () {
      final movement = TokenMoveTransaction(
        gameState: GameState.withTokens(
          tokens: [_pathToken('green_0', PlayerColor.green, 20)],
          diceResult: DiceResult(2),
        ),
        tokenId: 'red_0',
        steps: [TokenPosition.onPath(5)],
      );

      expect(() => resolver.resolve(movement), throwsStateError);
    });
  });
}

TokenMoveTransaction _movement({
  required Token movedToken,
  List<Token> otherTokens = const <Token>[],
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

int _progressForMainIndex(PlayerColor color, int mainIndex) {
  const starts = <PlayerColor, int>{
    PlayerColor.red: 0,
    PlayerColor.green: 13,
    PlayerColor.yellow: 26,
    PlayerColor.blue: 39,
  };
  final relativeProgress = (mainIndex - starts[color]!) % 52;

  if (relativeProgress > 50) {
    // A player's omitted 52nd main-track cell is not part of that token's
    // legal movement path. Choose another opponent color in tests if needed.
    throw StateError('$color cannot occupy main_$mainIndex on its path.');
  }

  return relativeProgress;
}
