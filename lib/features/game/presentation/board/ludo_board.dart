import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ludo_board_painter.dart';

/// Displays the production Ludo board at a responsive square size.
///
/// The widget handles layout and repaint isolation. Static board drawing
/// remains the responsibility of [LudoBoardPainter].
class LudoBoard extends StatelessWidget {
  /// Creates a responsive Ludo board.
  const LudoBoard({this.maximumDimension = 720, super.key})
    : assert(maximumDimension > 0, 'Maximum board dimension must be positive.');

  /// Key used to locate and verify the isolated board repaint boundary.
  static const Key repaintBoundaryKey = ValueKey<String>(
    'ludo-board-repaint-boundary',
  );

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
          child: RepaintBoundary(
            key: repaintBoundaryKey,
            child: SizedBox.square(
              dimension: boardSize,
              child: const CustomPaint(painter: LudoBoardPainter()),
            ),
          ),
        );
      },
    );
  }
}
