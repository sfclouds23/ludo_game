/// Represents one completed logical dice result.
///
/// This domain value contains no animation state. Presentation code may animate
/// before displaying [value], but animation must never generate or alter it.
class DiceResult {
  const DiceResult._(this.value);

  /// Lowest valid value produced by a standard six-sided die.
  static const int minimumValue = 1;

  /// Highest valid value produced by a standard six-sided die.
  static const int maximumValue = 6;

  /// Number of faces supported by the standard game die.
  static const int faceCount = maximumValue;

  /// Completed logical dice value.
  final int value;

  /// Creates a validated result between one and six.
  factory DiceResult(int value) {
    if (value < minimumValue || value > maximumValue) {
      throw RangeError.range(
        value,
        minimumValue,
        maximumValue,
        'value',
        'Dice result must be between $minimumValue and $maximumValue.',
      );
    }

    return DiceResult._(value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DiceResult && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DiceResult(value: $value)';
}
