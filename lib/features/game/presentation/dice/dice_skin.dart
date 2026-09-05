import 'package:flutter/material.dart';

/// Describes the visual appearance of one dice cosmetic.
///
/// This presentation model contains no ownership, price, inventory, reward, or
/// game-rule information. Future inventory systems will select an authorized
/// skin ID and supply the corresponding visual configuration.
class DiceSkin {
  /// Creates an immutable dice visual skin.
  const DiceSkin({
    required this.id,
    required this.displayName,
    required this.rendererId,
    required this.primaryFaceColor,
    required this.secondaryFaceColor,
    required this.shadedFaceColor,
    required this.edgeColor,
    required this.pipColor,
    required this.pipHighlightColor,
    required this.shadowColor,
  }) : assert(id != '', 'Dice skin ID must not be empty.'),
       assert(displayName != '', 'Dice skin name must not be empty.'),
       assert(rendererId != '', 'Dice renderer ID must not be empty.');

  /// Stable cosmetic identifier used by future inventory configuration.
  final String id;

  /// Human-readable cosmetic name.
  final String displayName;

  /// Renderer family responsible for drawing this skin.
  ///
  /// A future asset-based premium renderer can use a different identifier
  /// without changing logical dice generation or animation sequencing.
  final String rendererId;

  /// Brightest primary cube-surface color.
  final Color primaryFaceColor;

  /// Secondary cube-surface color.
  final Color secondaryFaceColor;

  /// Darker color used on surfaces facing away from the light.
  final Color shadedFaceColor;

  /// Outline and cube-seam color.
  final Color edgeColor;

  /// Main pip color.
  final Color pipColor;

  /// Small reflective pip-highlight color.
  final Color pipHighlightColor;

  /// Contact-shadow color.
  final Color shadowColor;

  /// Original default dice appearance.
  static const DiceSkin classicIvory = DiceSkin(
    id: 'classic_ivory',
    displayName: 'Classic Ivory',
    rendererId: 'classic_3d',
    primaryFaceColor: Color(0xFFFFFFFF),
    secondaryFaceColor: Color(0xFFF3EDE3),
    shadedFaceColor: Color(0xFFC9BAA8),
    edgeColor: Color(0xFF29252E),
    pipColor: Color(0xFF211D25),
    pipHighlightColor: Color(0x66FFFFFF),
    shadowColor: Color(0x52000000),
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DiceSkin &&
        other.id == id &&
        other.displayName == displayName &&
        other.rendererId == rendererId &&
        other.primaryFaceColor == primaryFaceColor &&
        other.secondaryFaceColor == secondaryFaceColor &&
        other.shadedFaceColor == shadedFaceColor &&
        other.edgeColor == edgeColor &&
        other.pipColor == pipColor &&
        other.pipHighlightColor == pipHighlightColor &&
        other.shadowColor == shadowColor;
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    rendererId,
    primaryFaceColor,
    secondaryFaceColor,
    shadedFaceColor,
    edgeColor,
    pipColor,
    pipHighlightColor,
    shadowColor,
  );

  @override
  String toString() {
    return 'DiceSkin('
        'id: $id, '
        'displayName: $displayName, '
        'rendererId: $rendererId'
        ')';
  }
}
