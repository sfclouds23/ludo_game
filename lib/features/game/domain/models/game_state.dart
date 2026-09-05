import 'dice_result.dart';

/// Represents the authoritative local state needed by the current game engine.
///
/// GAME-104 owns only the dice portion of this model for now. Later Stories may
/// extend GameState with turn, legal-move, capture, ranking, and multiplayer
/// state without moving those rules into the dice system.
class GameState {
  /// Creates immutable local game state.
  const GameState({
    this.diceResult,
    this.pendingDiceResult,
    this.isDiceRolling = false,
    this.isDiceRollAllowed = true,
  }) : assert(
         isDiceRolling ? pendingDiceResult != null : pendingDiceResult == null,
         'A pending dice result must exist only while a roll is active.',
       );

  /// Last completed logical dice result available to downstream game logic.
  ///
  /// This value is not replaced until the presentation confirms that the
  /// corresponding roll animation has completed.
  final DiceResult? diceResult;

  /// Logical result generated for the roll currently being animated.
  ///
  /// Presentation may use this value to animate toward the predetermined
  /// result, but downstream move logic must consume [diceResult] instead.
  final DiceResult? pendingDiceResult;

  /// Whether a logical result is currently waiting for animation completion.
  final bool isDiceRolling;

  /// Whether the surrounding game state currently permits a new roll.
  ///
  /// GAME-104 deliberately does not decide turn, legal-move, timeout, or six
  /// rules. Later game-engine logic owns this input.
  final bool isDiceRollAllowed;

  /// Whether a new dice roll may start in the current state.
  bool get canRollDice => isDiceRollAllowed && !isDiceRolling;

  /// Starts presentation sequencing for an already-generated [result].
  ///
  /// If the current state forbids rolling, this instance is returned unchanged.
  GameState beginDiceRoll(DiceResult result) {
    if (!canRollDice) {
      return this;
    }

    return GameState(
      diceResult: diceResult,
      pendingDiceResult: result,
      isDiceRolling: true,
      isDiceRollAllowed: isDiceRollAllowed,
    );
  }

  /// Publishes [result] after its roll animation completes.
  ///
  /// Stale or mismatched animation callbacks are ignored so they cannot replace
  /// the logical result belonging to the active roll.
  GameState completeDiceRoll(DiceResult result) {
    if (!isDiceRolling || pendingDiceResult != result) {
      return this;
    }

    return GameState(
      diceResult: result,
      isDiceRolling: false,
      isDiceRollAllowed: isDiceRollAllowed,
    );
  }

  /// Returns state with externally controlled roll availability updated.
  ///
  /// This does not interrupt an active roll or implement any later turn rules.
  GameState withDiceRollAllowed(bool isAllowed) {
    if (isDiceRollAllowed == isAllowed) {
      return this;
    }

    return GameState(
      diceResult: diceResult,
      pendingDiceResult: pendingDiceResult,
      isDiceRolling: isDiceRolling,
      isDiceRollAllowed: isAllowed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is GameState &&
        other.diceResult == diceResult &&
        other.pendingDiceResult == pendingDiceResult &&
        other.isDiceRolling == isDiceRolling &&
        other.isDiceRollAllowed == isDiceRollAllowed;
  }

  @override
  int get hashCode => Object.hash(
    diceResult,
    pendingDiceResult,
    isDiceRolling,
    isDiceRollAllowed,
  );

  @override
  String toString() {
    return 'GameState('
        'diceResult: $diceResult, '
        'pendingDiceResult: $pendingDiceResult, '
        'isDiceRolling: $isDiceRolling, '
        'isDiceRollAllowed: $isDiceRollAllowed'
        ')';
  }
}
