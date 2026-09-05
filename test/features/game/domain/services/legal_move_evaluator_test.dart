import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/domain/models/game_state.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/domain/services/legal_move_evaluator.dart';

void main() {
  const evaluator = LegalMoveEvaluator();

  group('LegalMoveEvaluator', () {
    test('returns no moves before a completed dice result exists', () {
      final state = GameState.withTokens(tokens: [_yardToken('red_0')]);
      final result = evaluator.evaluate(state, PlayerColor.red);
      expect(result.hasLegalMoves, isFalse);
      expect(result.movableTokenIds, isEmpty);
    });

    test('ignores pending dice result while animation is active', () {
      final state = GameState.withTokens(
        tokens: [_yardToken('red_0')],
        pendingDiceResult: DiceResult(6),
        isDiceRolling: true,
      );
      expect(evaluator.evaluate(state, PlayerColor.red).hasLegalMoves, isFalse);
    });

    group('yard release', () {
      for (var diceValue = 1; diceValue <= 5; diceValue++) {
        test('dice $diceValue cannot release a yard token', () {
          final state = _state(DiceResult(diceValue), [_yardToken('red_0')]);
          expect(
            evaluator.evaluate(state, PlayerColor.red).hasLegalMoves,
            isFalse,
          );
        });
      }

      test('six releases every owned yard token to progress 0', () {
        final state = _state(DiceResult(6), [
          _yardToken('red_0'),
          _yardToken('red_1'),
          _yardToken('green_0', color: PlayerColor.green),
        ]);
        final result = evaluator.evaluate(state, PlayerColor.red);
        expect(result.movableTokenIds, ['red_0', 'red_1']);
        expect(result.moveForToken('red_0')?.destination.progress, 0);
        expect(result.moveForToken('red_1')?.destination.progress, 0);
      });

      test('six allows yard release and an existing legal token together', () {
        final state = _state(DiceResult(6), [
          _yardToken('red_yard'),
          _pathToken('red_track', 10),
        ]);
        final result = evaluator.evaluate(state, PlayerColor.red);
        expect(result.movableTokenIds, ['red_yard', 'red_track']);
        expect(result.moveForToken('red_yard')?.destination.progress, 0);
        expect(result.moveForToken('red_track')?.destination.progress, 16);
      });
    });

    group('normal and home-lane movement', () {
      test('moves exactly the rolled number of logical progress steps', () {
        final state = _state(DiceResult(4), [_pathToken('red_0', 12)]);
        final result = evaluator.evaluate(state, PlayerColor.red);
        expect(result.moveForToken('red_0')?.destination.progress, 16);
      });

      test('allows movement from shared track into private home lane', () {
        final state = _state(DiceResult(3), [_pathToken('red_0', 49)]);
        final destination = evaluator
            .evaluate(state, PlayerColor.red)
            .moveForToken('red_0')
            ?.destination;
        expect(destination?.progress, 52);
        expect(destination?.isInHomeLane, isTrue);
      });

      test('allows movement inside private home lane', () {
        final state = _state(DiceResult(2), [_pathToken('red_0', 52)]);
        final result = evaluator.evaluate(state, PlayerColor.red);
        expect(result.moveForToken('red_0')?.destination.progress, 54);
      });
    });

    group('exact finish', () {
      test('allows exact roll to finish', () {
        final state = _state(DiceResult(4), [_pathToken('red_0', 52)]);
        final destination = evaluator
            .evaluate(state, PlayerColor.red)
            .moveForToken('red_0')
            ?.destination;
        expect(destination?.progress, TokenPosition.finishProgress);
        expect(destination?.isFinished, isTrue);
      });

      test('rejects a roll that overshoots finish', () {
        final state = _state(DiceResult(5), [_pathToken('red_0', 52)]);
        expect(
          evaluator.evaluate(state, PlayerColor.red).hasLegalMoves,
          isFalse,
        );
      });

      test('finished token can never move again', () {
        final state = _state(DiceResult(1), [
          _pathToken('red_0', TokenPosition.finishProgress),
        ]);
        expect(
          evaluator.evaluate(state, PlayerColor.red).hasLegalMoves,
          isFalse,
        );
      });

      test('unusable six does not move token needing four to finish', () {
        final state = _state(DiceResult(6), [_pathToken('red_0', 52)]);
        expect(
          evaluator.evaluate(state, PlayerColor.red).hasLegalMoves,
          isFalse,
        );
      });
    });

    group('authoritative ownership and no-move outcome', () {
      test('evaluates only tokens owned by requested player', () {
        final state = _state(DiceResult(3), [
          _pathToken('red_0', 10),
          _pathToken('green_0', 10, color: PlayerColor.green),
        ]);
        expect(evaluator.evaluate(state, PlayerColor.red).movableTokenIds, [
          'red_0',
        ]);
      });

      test(
        'reports no legal moves when every owned token is blocked by rules',
        () {
          final state = _state(DiceResult(3), [
            _yardToken('red_yard'),
            _pathToken('red_near_finish', 54),
            _pathToken('red_finished', TokenPosition.finishProgress),
          ]);
          final result = evaluator.evaluate(state, PlayerColor.red);
          expect(result.hasLegalMoves, isFalse);
          expect(result.movableTokenIds, isEmpty);
        },
      );

      test('preserves GameState token order for deterministic choices', () {
        final state = _state(DiceResult(2), [
          _pathToken('red_2', 20),
          _pathToken('red_0', 0),
          _pathToken('red_1', 10),
        ]);
        expect(evaluator.evaluate(state, PlayerColor.red).movableTokenIds, [
          'red_2',
          'red_0',
          'red_1',
        ]);
      });
    });

    test('rule matrix covers progress boundary 50 through finish', () {
      for (
        var progress = 50;
        progress <= TokenPosition.finishProgress;
        progress++
      ) {
        for (var diceValue = 1; diceValue <= 6; diceValue++) {
          final state = _state(DiceResult(diceValue), [
            _pathToken('red_0', progress),
          ]);
          final result = evaluator.evaluate(state, PlayerColor.red);
          final expectedDestination = progress + diceValue;
          final shouldBeLegal =
              progress < TokenPosition.finishProgress &&
              expectedDestination <= TokenPosition.finishProgress;

          expect(
            result.hasLegalMoves,
            shouldBeLegal,
            reason: 'progress $progress with dice $diceValue',
          );

          if (shouldBeLegal) {
            expect(
              result.moveForToken('red_0')?.destination.progress,
              expectedDestination,
            );
          }
        }
      }
    });
  });
}

GameState _state(DiceResult result, List<Token> tokens) {
  return GameState.withTokens(tokens: tokens, diceResult: result);
}

Token _yardToken(String id, {PlayerColor color = PlayerColor.red}) {
  return Token(id: id, ownerColor: color, position: const TokenPosition.yard());
}

Token _pathToken(
  String id,
  int progress, {
  PlayerColor color = PlayerColor.red,
}) {
  return Token(
    id: id,
    ownerColor: color,
    position: TokenPosition.onPath(progress),
  );
}
