import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/token.dart';
import 'ludo_board_painter.dart';
import 'ludo_token_layer.dart';
import 'ludo_token_visual_state.dart';

/// Displays the production Ludo board at a responsive square size.
///
/// Static board drawing and dynamic token rendering use separate repaint
/// boundaries so token changes do not continuously repaint the board artwork.
///
/// The board forwards caller-supplied token presentation and interaction data.
/// It does not calculate legal moves, captures, blockades, or dice outcomes.
class LudoBoard extends StatelessWidget {
  /// Creates a responsive Ludo board.
  const LudoBoard({
    this.tokens = const [],
    this.visualStates = const {},
    this.onTokenPressed,
    this.maximumDimension = 720,
    super.key,
  }) : assert(
         maximumDimension > 0,
         'Maximum board dimension must be positive.',
       );

  /// Key used to locate and verify the static board repaint boundary.
  static const Key repaintBoundaryKey = ValueKey<String>(
    'ludo-board-repaint-boundary',
  );

  /// Immutable logical tokens displayed above the board.
  final List<Token> tokens;

  /// Presentation-only state associated with each token ID.
  ///
  /// The owning application or game-state layer determines these values.
  /// Tokens without an entry are displayed using the idle visual state.
  final Map<String, LudoTokenVisualState> visualStates;

  /// Optional callback invoked with the stable ID of a pressed token.
  ///
  /// The board forwards this callback to the token layer without deciding
  /// whether the token represents a legal move.
  final ValueChanged<String>? onTokenPressed;

  /// Maximum board width and height on large tablet and web layouts.
  final double maximumDimension;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Width is normally bounded by the screen or parent content area.
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : maximumDimension;

        // If height is unbounded, width remains the safest square dimension.
        final availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : availableWidth;

        final boardSize = math.min(
          math.min(availableWidth, availableHeight),
          maximumDimension,
        );

        if (!boardSize.isFinite || boardSize <= 0) {
          return const SizedBox.shrink();
        }

        return Center(
          child: SizedBox.square(
            dimension: boardSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Static board artwork remains isolated from token animation
                // and interaction-state changes.
                const RepaintBoundary(
                  key: repaintBoundaryKey,
                  child: CustomPaint(painter: LudoBoardPainter()),
                ),

                // Dynamic tokens occupy their own widget and repaint hierarchy.
                // The board only forwards state selected by its caller.
                LudoTokenLayer(
                  tokens: tokens,
                  visualStates: visualStates,
                  onTokenPressed: onTokenPressed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
