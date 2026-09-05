import '../models/dice_result.dart';
import '../models/game_state.dart';
import 'dice_roller.dart';

/// Coordinates logical dice generation with GameState transitions.
///
/// Implementations must keep dice generation independent from presentation and
/// must not apply legal-move, token-release, capture, extra-turn, or winner
/// rules.
abstract interface class DiceRollService {
  /// Requests a new logical roll for [state].
  ///
  /// When rolling is forbidden, [state] is returned unchanged and no logical
  /// result is generated.
  GameState requestRoll(GameState state);

  /// Publishes [completedResult] after its presentation sequence completes.
  GameState completeRoll(GameState state, DiceResult completedResult);
}

/// Default GAME-104 implementation backed by an injected [DiceRoller].
class DefaultDiceRollService implements DiceRollService {
  /// Creates a dice roll service using [diceRoller] for logical generation.
  const DefaultDiceRollService(this.diceRoller);

  /// Logical result generator.
  final DiceRoller diceRoller;

  @override
  GameState requestRoll(GameState state) {
    // Check authoritative state before invoking the random source. A forbidden
    // request must not consume or generate a dice value.
    if (!state.canRollDice) {
      return state;
    }

    final result = diceRoller.roll();
    return state.beginDiceRoll(result);
  }

  @override
  GameState completeRoll(GameState state, DiceResult completedResult) {
    // GameState validates that this callback belongs to the active roll before
    // publishing the result to downstream game logic.
    return state.completeDiceRoll(completedResult);
  }
}
