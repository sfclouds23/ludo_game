import 'player_color.dart';
import 'token_position.dart';

/// Represents one logical Ludo token owned by a player.
///
/// This model contains permanent game-domain state only.
///
/// It intentionally does not contain presentation or animation state such as:
///
/// - selected;
/// - highlighted;
/// - movable;
/// - moving;
/// - animation progress.
///
/// Those concerns belong to later application/presentation layers.
class Token {
  const Token({
    required this.id,
    required this.ownerColor,
    required this.position,
  });

  /// Stable identifier for this token.
  ///
  /// Example values could later include:
  ///
  /// - red_token_0
  /// - red_token_1
  /// - green_token_0
  ///
  /// The game engine should identify tokens using stable IDs rather than
  /// relying on visual position or list indexes.
  final String id;

  /// Player/color that owns this token.
  final PlayerColor ownerColor;

  /// Current logical location of this token.
  final TokenPosition position;

  /// Returns a new token with selected values replaced.
  ///
  /// Token is immutable so logical game-state changes can be represented by
  /// replacing state rather than mutating shared objects in-place.
  Token copyWith({
    String? id,
    PlayerColor? ownerColor,
    TokenPosition? position,
  }) {
    return Token(
      id: id ?? this.id,
      ownerColor: ownerColor ?? this.ownerColor,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Token &&
        other.id == id &&
        other.ownerColor == ownerColor &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(id, ownerColor, position);

  @override
  String toString() {
    return 'Token('
        'id: $id, '
        'ownerColor: $ownerColor, '
        'position: $position'
        ')';
  }
}
