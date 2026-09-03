/// Describes presentation-only state supplied to one Ludo token.
///
/// This class never determines whether a move is legal. A game-state or
/// application layer calculates selectability and supplies these visual flags.
class LudoTokenVisualState {
  /// Creates an immutable token visual state.
  const LudoTokenVisualState({
    this.isMovable = false,
    this.isSelected = false,
    this.isMoving = false,
  });

  /// Default visual state for a token with no interaction emphasis.
  static const LudoTokenVisualState idle = LudoTokenVisualState();

  /// Whether the authoritative caller says this token may be selected.
  final bool isMovable;

  /// Whether the authoritative caller says this token is currently selected.
  final bool isSelected;

  /// Whether the presentation is currently displaying token movement.
  final bool isMoving;

  /// Whether any interaction-related visual emphasis is active.
  bool get isEmphasized => isMovable || isSelected || isMoving;

  /// Returns a new visual state with selected values replaced.
  LudoTokenVisualState copyWith({
    bool? isMovable,
    bool? isSelected,
    bool? isMoving,
  }) {
    return LudoTokenVisualState(
      isMovable: isMovable ?? this.isMovable,
      isSelected: isSelected ?? this.isSelected,
      isMoving: isMoving ?? this.isMoving,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LudoTokenVisualState &&
        other.isMovable == isMovable &&
        other.isSelected == isSelected &&
        other.isMoving == isMoving;
  }

  @override
  int get hashCode => Object.hash(isMovable, isSelected, isMoving);

  @override
  String toString() {
    return 'LudoTokenVisualState('
        'isMovable: $isMovable, '
        'isSelected: $isSelected, '
        'isMoving: $isMoving'
        ')';
  }
}
