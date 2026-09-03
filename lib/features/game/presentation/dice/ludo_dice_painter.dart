import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/dice_result.dart';

/// Paints one responsive, polished six-sided dice face.
///
/// This painter receives an already completed logical [DiceResult]. It never
/// generates a result, evaluates roll availability, applies six rules, or
/// calculates legal moves.
class LudoDicePainter extends CustomPainter {
  /// Creates a painter for the supplied logical [result].
  const LudoDicePainter({required this.result});

  /// Completed logical result displayed by this dice face.
  final DiceResult result;

  @override
  void paint(Canvas canvas, Size size) {
    final diceSize = math.min(size.width, size.height);

    if (!diceSize.isFinite || diceSize <= 0) {
      return;
    }

    final horizontalOffset = (size.width - diceSize) / 2;
    final verticalOffset = (size.height - diceSize) / 2;

    canvas.save();
    canvas.translate(horizontalOffset, verticalOffset);

    final faceRect = Rect.fromLTWH(
      diceSize * 0.08,
      diceSize * 0.06,
      diceSize * 0.84,
      diceSize * 0.84,
    );
    final cornerRadius = Radius.circular(diceSize * 0.18);
    final faceShape = RRect.fromRectAndRadius(faceRect, cornerRadius);

    _paintShadow(canvas, diceSize, faceShape);
    _paintFace(canvas, diceSize, faceShape);
    _paintEdge(canvas, diceSize, faceShape);
    _paintHighlight(canvas, diceSize, faceShape);
    _paintPips(canvas, diceSize);

    canvas.restore();
  }

  /// Paints a soft shadow below the physical dice body.
  void _paintShadow(Canvas canvas, double diceSize, RRect faceShape) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        math.max(1, diceSize * 0.065),
      );

    canvas.save();
    canvas.translate(0, diceSize * 0.07);
    canvas.drawRRect(faceShape, shadowPaint);
    canvas.restore();
  }

  /// Paints the primary ivory dice surface.
  void _paintFace(Canvas canvas, double diceSize, RRect faceShape) {
    final facePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF7F3EA), Color(0xFFE1D8C8)],
        stops: [0, 0.62, 1],
      ).createShader(Rect.fromLTWH(0, 0, diceSize, diceSize));

    canvas.drawRRect(faceShape, facePaint);
  }

  /// Paints a dark outline and lower edge for a subtle 2.5D appearance.
  void _paintEdge(Canvas canvas, double diceSize, RRect faceShape) {
    final outlinePaint = Paint()
      ..color = const Color(0xFF29252E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, diceSize * 0.035);

    canvas.drawRRect(faceShape, outlinePaint);

    final lowerEdgePaint = Paint()
      ..color = const Color(0xFF8D8274).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, diceSize * 0.045)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(
        diceSize * 0.11,
        diceSize * 0.11,
        diceSize * 0.78,
        diceSize * 0.76,
      ),
      math.pi * 0.16,
      math.pi * 0.68,
      false,
      lowerEdgePaint,
    );
  }

  /// Paints a restrained reflective accent across the upper-left surface.
  void _paintHighlight(Canvas canvas, double diceSize, RRect faceShape) {
    canvas.save();
    canvas.clipRRect(faceShape);

    final highlightPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.78),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromLTWH(
              diceSize * 0.10,
              diceSize * 0.08,
              diceSize * 0.55,
              diceSize * 0.42,
            ),
          );

    canvas.drawOval(
      Rect.fromLTWH(
        diceSize * 0.02,
        -diceSize * 0.08,
        diceSize * 0.72,
        diceSize * 0.48,
      ),
      highlightPaint,
    );

    canvas.restore();
  }

  /// Paints the pip arrangement matching the supplied logical result.
  void _paintPips(Canvas canvas, double diceSize) {
    final pipPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.35),
        radius: 0.95,
        colors: [Color(0xFF514A5A), Color(0xFF24202A), Color(0xFF121016)],
        stops: [0, 0.58, 1],
      ).createShader(Rect.fromLTWH(0, 0, diceSize, diceSize));

    final pipRadius = diceSize * 0.068;

    for (final position in _pipPositionsFor(result.value)) {
      canvas.drawCircle(
        Offset(diceSize * position.dx, diceSize * position.dy),
        pipRadius,
        pipPaint,
      );
    }
  }

  /// Returns normalized pip centers for a standard six-sided dice face.
  List<Offset> _pipPositionsFor(int value) {
    const topLeft = Offset(0.30, 0.28);
    const topRight = Offset(0.70, 0.28);
    const middleLeft = Offset(0.30, 0.48);
    const center = Offset(0.50, 0.48);
    const middleRight = Offset(0.70, 0.48);
    const bottomLeft = Offset(0.30, 0.68);
    const bottomRight = Offset(0.70, 0.68);

    return switch (value) {
      1 => const [center],
      2 => const [topLeft, bottomRight],
      3 => const [topLeft, center, bottomRight],
      4 => const [topLeft, topRight, bottomLeft, bottomRight],
      5 => const [topLeft, topRight, center, bottomLeft, bottomRight],
      6 => const [
        topLeft,
        topRight,
        middleLeft,
        middleRight,
        bottomLeft,
        bottomRight,
      ],
      _ => throw StateError('Unsupported validated dice value: $value.'),
    };
  }

  @override
  bool shouldRepaint(covariant LudoDicePainter oldDelegate) {
    return oldDelegate.result != result;
  }
}
