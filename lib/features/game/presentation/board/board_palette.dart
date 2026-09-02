import 'package:flutter/material.dart';

import '../../domain/models/player_color.dart';

/// Defines the visual colors used by the production Ludo board.
///
/// These values belong exclusively to the presentation layer. Domain-level
/// [PlayerColor] values remain independent from Flutter's [Color] class.
class BoardPalette {
  const BoardPalette._();

  /// Background behind track cells and player yards.
  static const Color boardSurface = Color(0xFFF8F4E8);

  /// Default fill used by shared-track cells.
  static const Color trackCell = Color(0xFFFFFDF7);

  /// Inner surface of each player's yard.
  static const Color yardSurface = Color(0xFFFFFBF2);

  /// Border surrounding the complete board.
  static const Color boardBorder = Color(0xFF292D32);

  /// Fine border separating individual board cells.
  static const Color cellBorder = Color(0xFF50555C);

  /// Visual color assigned to the red player.
  static const Color red = Color(0xFFE4473D);

  /// Visual color assigned to the green player.
  static const Color green = Color(0xFF35A865);

  /// Visual color assigned to the yellow player.
  static const Color yellow = Color(0xFFF2BE35);

  /// Visual color assigned to the blue player.
  static const Color blue = Color(0xFF3784D6);

  /// Soft shadow behind the board.
  static const Color shadow = Color(0x33000000);

  /// Returns the presentation color associated with [playerColor].
  static Color colorFor(PlayerColor playerColor) {
    return switch (playerColor) {
      PlayerColor.red => red,
      PlayerColor.green => green,
      PlayerColor.yellow => yellow,
      PlayerColor.blue => blue,
    };
  }
}
