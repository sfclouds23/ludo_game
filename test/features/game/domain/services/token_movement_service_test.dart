import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/domain/models/game_state.dart';
import 'package:ludo_game/features/game/domain/models/legal_move.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/domain/services/legal_move_evaluator.dart';
import 'package:ludo_game/features/game/domain/services/token_movement_service.dart';

void main() {
  const evaluator = LegalMoveEvaluator();
  const movementService = TokenMovementService();

  group('TokenMovementService', () {
    for (var diceValue = 1; diceValue <= 6; diceValue++) {
      test('commits exactly $diceValue logical steps', () {
        final state = _state(diceValue, [_pathToken('red_0', 10)]);
        final move = evaluator
            .evaluate(state, PlayerColor.red)
            .moveForToken('red_0')!;

        final transaction = movementService.tryCommit(state, move)!;

        expect(transaction.steps, hasLength(diceValue));
        expect(
          transaction.steps.map((position) => position.progress),
          List<int>.generate(diceValue, (index) => 11 + index),
        );
        expect(
          _token(transaction.gameState, 'red_0').position.progress,
          10 + diceValue,
        );
      });
    }

    test('yard release commits progress 0 as a single visual step', () {
      final state = _state(6, [_yardToken('red_0')]);
      final move = evaluator
          .evaluate(state, PlayerColor.red)
          .moveForToken('red_0')!;

      final transaction = movementService.tryCommit(state, move)!;

      expect(transaction.steps, [TokenPosition.onPath(0)]);
      expect(_token(transaction.gameState, 'red_0').position.progress, 0);
    });

    test('crosses from shared track into home lane step by step', () {
      final state = _state(4, [_pathToken('red_0', 49)]);
      final move = evaluator
          .evaluate(state, PlayerColor.red)
          .moveForToken('red_0')!;

      final transaction = movementService.tryCommit(state, move)!;

      expect(transaction.steps.map((position) => position.progress), [
        50,
        51,
        52,
        53,
      ]);
      expect(transaction.steps[1].isInHomeLane, isTrue);
      expect(_token(transaction.gameState, 'red_0').position.progress, 53);
    });

    test('commits exact finish and includes finish as final step', () {
      final state = _state(4, [_pathToken('red_0', 52)]);
      final move = evaluator
          .evaluate(state, PlayerColor.red)
          .moveForToken('red_0')!;

      final transaction = movementService.tryCommit(state, move)!;

      expect(transaction.steps.map((position) => position.progress), [
        53,
        54,
        55,
        56,
      ]);
      expect(transaction.destination.isFinished, isTrue);
      expect(
        _token(transaction.gameState, 'red_0').position.isFinished,
        isTrue,
      );
    });

    test('replaces only the selected token and preserves ordering', () {
      final first = _pathToken('red_0', 5);
      final selected = _pathToken('red_1', 10);
      final opponent = _pathToken('green_0', 20, color: PlayerColor.green);
      final state = _state(3, [first, selected, opponent]);
      final move = evaluator
          .evaluate(state, PlayerColor.red)
          .moveForToken('red_1')!;

      final transaction = movementService.tryCommit(state, move)!;

      expect(transaction.gameState.tokens.map((token) => token.id), [
        'red_0',
        'red_1',
        'green_0',
      ]);
      expect(transaction.gameState.tokens[0], same(first));
      expect(transaction.gameState.tokens[2], same(opponent));
      expect(transaction.gameState.tokens[1], isNot(same(selected)));
      expect(transaction.gameState.tokens[1].position.progress, 13);
    });

    test('does not mutate original GameState or original token', () {
      final originalToken = _pathToken('red_0', 10);
      final state = _state(2, [originalToken]);
      final move = evaluator
          .evaluate(state, PlayerColor.red)
          .moveForToken('red_0')!;

      final transaction = movementService.tryCommit(state, move)!;

      expect(state.tokens.single, same(originalToken));
      expect(state.tokens.single.position.progress, 10);
      expect(transaction.gameState, isNot(same(state)));
      expect(transaction.gameState.tokens.single.position.progress, 12);
    });

    test('returned token and step collections are immutable', () {
      final state = _state(2, [_pathToken('red_0', 10)]);
      final move = evaluator
          .evaluate(state, PlayerColor.red)
          .moveForToken('red_0')!;
      final transaction = movementService.tryCommit(state, move)!;

      expect(
        () => transaction.gameState.tokens.add(_yardToken('red_1')),
        throwsUnsupportedError,
      );
      expect(
        () => transaction.steps.add(TokenPosition.onPath(13)),
        throwsUnsupportedError,
      );
    });

    test('preserves dice lifecycle fields during logical movement', () {
      final state = GameState.withTokens(
        tokens: [_pathToken('red_0', 10)],
        diceResult: DiceResult(2),
        isDiceRollAllowed: false,
      );
      final move = evaluator
          .evaluate(state, PlayerColor.red)
          .moveForToken('red_0')!;

      final nextState = movementService.tryCommit(state, move)!.gameState;

      expect(nextState.diceResult, state.diceResult);
      expect(nextState.pendingDiceResult, state.pendingDiceResult);
      expect(nextState.isDiceRolling, state.isDiceRolling);
      expect(nextState.isDiceRollAllowed, state.isDiceRollAllowed);
    });

    test('rejects unknown token without changing state', () {
      final state = _state(2, [_pathToken('red_0', 10)]);
      final fabricatedMove = LegalMove(
        tokenId: 'missing',
        destination: TokenPosition.onPath(12),
      );

      expect(movementService.tryCommit(state, fabricatedMove), isNull);
      expect(state.tokens.single.position.progress, 10);
    });

    test('rejects fabricated destination not approved by GAME-105', () {
      final state = _state(2, [_pathToken('red_0', 10)]);
      final fabricatedMove = LegalMove(
        tokenId: 'red_0',
        destination: TokenPosition.onPath(13),
      );

      expect(movementService.tryCommit(state, fabricatedMove), isNull);
      expect(state.tokens.single.position.progress, 10);
    });

    test('rejects stale move after authoritative token state changes', () {
      final initialState = _state(2, [_pathToken('red_0', 10)]);
      final staleMove = evaluator
          .evaluate(initialState, PlayerColor.red)
          .moveForToken('red_0')!;
      final newerState = _state(2, [_pathToken('red_0', 11)]);

      expect(movementService.tryCommit(newerState, staleMove), isNull);
      expect(newerState.tokens.single.position.progress, 11);
    });

    test('rejects movement while a new dice result is still pending', () {
      final state = GameState.withTokens(
        tokens: [_pathToken('red_0', 10)],
        diceResult: DiceResult(2),
        pendingDiceResult: DiceResult(4),
        isDiceRolling: true,
      );
      final oldMove = LegalMove(
        tokenId: 'red_0',
        destination: TokenPosition.onPath(12),
      );

      expect(movementService.tryCommit(state, oldMove), isNull);
    });

    test('final state is already correct before any step is animated', () {
      final state = _state(6, [_pathToken('red_0', 20)]);
      final move = evaluator
          .evaluate(state, PlayerColor.red)
          .moveForToken('red_0')!;

      final transaction = movementService.tryCommit(state, move)!;

      // Presentation may animate zero, one, or all of these steps. The logical
      // state has already committed the final destination independently.
      expect(transaction.steps, hasLength(6));
      expect(_token(transaction.gameState, 'red_0').position.progress, 26);
    });
  });
}

GameState _state(int diceValue, List<Token> tokens) {
  return GameState.withTokens(
    tokens: tokens,
    diceResult: DiceResult(diceValue),
  );
}

Token _token(GameState state, String tokenId) {
  return state.tokens.singleWhere((token) => token.id == tokenId);
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
