import 'package:flutter/material.dart';

import '../../domain/models/player_color.dart';
import 'ludo_token_painter.dart';

/// Displays one isolated, responsive Ludo token.
///
/// Board positioning belongs to the parent token layer. This widget only
/// renders the visual pawn associated with a stable token identity.
class LudoToken extends StatelessWidget {
  /// Creates one visual Ludo token.
  const LudoToken({
    required this.tokenId,
    required this.playerColor,
    required this.dimension,
    super.key,
  }) : assert(tokenId != '', 'Token ID must not be empty.'),
       assert(dimension > 0, 'Token dimension must be greater than zero.');

  /// Stable logical identity of the represented token.
  final String tokenId;

  /// Player color used by the token painter.
  final PlayerColor playerColor;

  /// Width and height of the square token canvas.
  final double dimension;

  /// Returns the unique repaint-boundary key for [tokenId].
  static Key repaintBoundaryKeyFor(String tokenId) {
    return ValueKey<String>('ludo-token-repaint-boundary-$tokenId');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${playerColor.name} Ludo token',
      identifier: tokenId,
      image: true,
      child: RepaintBoundary(
        key: repaintBoundaryKeyFor(tokenId),
        child: SizedBox.square(
          dimension: dimension,
          child: CustomPaint(
            painter: LudoTokenPainter(playerColor: playerColor),
          ),
        ),
      ),
    );
  }
}
