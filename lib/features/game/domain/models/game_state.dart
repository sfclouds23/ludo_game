import 'dice_result.dart';
import 'token.dart';

/// Represents the authoritative local state needed by the current game engine.
///
/// GAME-104 owns the dice lifecycle. GAME-105 adds immutable token positions so
/// legal moves can be derived from state rather than presentation data. GAME-106
/// replaces tokens immutably when an approved move is committed. Later Stories
/// may extend GameState with turn, capture, ranking, and multiplayer state
/// without moving those rules into the dice, legal-move, or movement systems.
class GameState {
  /// Creates state without active tokens.
  ///
  /// This constructor remains const for dice-only states and tests. Use
  /// [GameState.withTokens] when token positions are part of the state.
  const GameState({
    this.diceResult,
    this.pendingDiceResult,
    this.isDiceRolling = false,
    this.isDiceRollAllowed = true,
  }) : tokens = const <Token>[],
       assert(
         isDiceRolling ? pendingDiceResult != null : pendingDiceResult == null,
         'A pending dice result must exist only while a roll is active.',
       );

  /// Creates authoritative state containing immutable token positions.
  GameState.withTokens({
    required Iterable<Token> tokens,
    this.diceResult,
    this.pendingDiceResult,
    this.isDiceRolling = false,
    this.isDiceRollAllowed = true,
  }) : tokens = List<Token>.unmodifiable(tokens) {
    assert(
      isDiceRolling ? pendingDiceResult != null : pendingDiceResult == null,
      'A pending dice result must exist only while a roll is active.',
    );
  }

  GameState._({
    required this.tokens,
    required this.diceResult,
    required this.pendingDiceResult,
    required this.isDiceRolling,
    required this.isDiceRollAllowed,
  });

  /// Current authoritative logical tokens.
  ///
  /// The collection is immutable. GAME-105 derives legal moves from these
  /// positions and GAME-106 replaces the collection transactionally when an
  /// approved move is committed.
  final List<Token> tokens;

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

    return GameState._(
      tokens: tokens,
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

    return GameState._(
      tokens: tokens,
      diceResult: result,
      pendingDiceResult: null,
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

    return GameState._(
      tokens: tokens,
      diceResult: diceResult,
      pendingDiceResult: pendingDiceResult,
      isDiceRolling: isDiceRolling,
      isDiceRollAllowed: isAllowed,
    );
  }

  /// Returns a new state containing [nextTokens] while preserving all other
  /// authoritative fields.
  ///
  /// GAME-106 uses this as the narrow immutable write boundary for an approved
  /// token movement transaction. The supplied collection is defensively copied
  /// so callers cannot mutate the resulting GameState afterward.
  GameState withTokensReplaced(Iterable<Token> nextTokens) {
    return GameState._(
      tokens: List<Token>.unmodifiable(nextTokens),
      diceResult: diceResult,
      pendingDiceResult: pendingDiceResult,
      isDiceRolling: isDiceRolling,
      isDiceRollAllowed: isDiceRollAllowed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is GameState &&
        _tokensEqual(other.tokens, tokens) &&
        other.diceResult == diceResult &&
        other.pendingDiceResult == pendingDiceResult &&
        other.isDiceRolling == isDiceRolling &&
        other.isDiceRollAllowed == isDiceRollAllowed;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(tokens),
    diceResult,
    pendingDiceResult,
    isDiceRolling,
    isDiceRollAllowed,
  );

  @override
  String toString() {
    return 'GameState('
        'tokens: $tokens, '
        'diceResult: $diceResult, '
        'pendingDiceResult: $pendingDiceResult, '
        'isDiceRolling: $isDiceRolling, '
        'isDiceRollAllowed: $isDiceRollAllowed'
        ')';
  }
}

bool _tokensEqual(List<Token> first, List<Token> second) {
  if (identical(first, second)) {
    return true;
  }

  if (first.length != second.length) {
    return false;
  }

  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) {
      return false;
    }
  }

  return true;
}
