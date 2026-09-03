import 'dart:math' as math;

import '../models/dice_result.dart';

/// Supplies a zero-based random value below the provided upper bound.
///
/// This small dependency boundary allows dice generation to be tested without
/// relying on nondeterministic system randomness.
typedef DiceValueSource = int Function(int upperBound);

/// Generates completed logical dice results.
///
/// Implementations produce domain values only. They do not start animations,
/// move tokens, grant extra turns, release tokens from yards, or calculate
/// legal moves.
abstract interface class DiceRoller {
  /// Generates the next completed logical dice result.
  DiceResult roll();
}

/// Generates standard six-sided results using an injectable random source.
class RandomDiceRoller implements DiceRoller {
  /// Creates a logical dice roller.
  ///
  /// Production callers normally omit [nextInt]. Tests may supply a
  /// deterministic source to verify range conversion and dependency usage.
  RandomDiceRoller({DiceValueSource? nextInt})
    : _nextInt = nextInt ?? math.Random().nextInt;

  /// Source that returns a zero-based value below the requested upper bound.
  final DiceValueSource _nextInt;

  @override
  DiceResult roll() {
    // Random.nextInt uses the range 0 <= value < upperBound. Adding one maps
    // that result to the standard logical die range of 1 through 6.
    final zeroBasedValue = _nextInt(DiceResult.faceCount);
    final diceValue = zeroBasedValue + DiceResult.minimumValue;

    // DiceResult performs final boundary validation. A broken injected source
    // therefore cannot silently introduce an invalid logical game value.
    return DiceResult(diceValue);
  }
}
