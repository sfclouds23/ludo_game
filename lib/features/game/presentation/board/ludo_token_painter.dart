import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/player_color.dart';
import 'board_palette.dart';

/// Paints one responsive 2.5D Ludo token.
///
/// This painter receives only visual configuration. It does not inspect or
/// modify token movement, captures, dice results, or other game logic.
class LudoTokenPainter extends CustomPainter {
  /// Creates a token painter for [playerColor].
  const LudoTokenPainter({required this.playerColor});

  /// Logical player color represented by this token.
  final PlayerColor playerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final tokenSize = math.min(size.width, size.height);

    // Empty or invalid layout constraints provide no drawable token area.
    if (!tokenSize.isFinite || tokenSize <= 0) {
      return;
    }

    final horizontalOffset = (size.width - tokenSize) / 2;
    final verticalOffset = (size.height - tokenSize) / 2;

    canvas.save();
    canvas.translate(horizontalOffset, verticalOffset);

    final tokenColor = BoardPalette.colorFor(playerColor);
    final centerX = tokenSize / 2;

    _paintGroundShadow(canvas, tokenSize, centerX);
    _paintTokenBody(canvas, tokenSize, centerX, tokenColor);
    _paintTokenHead(canvas, tokenSize, centerX, tokenColor);
    _paintHighlights(canvas, tokenSize, centerX);

    canvas.restore();
  }

  /// Paints the soft contact shadow that visually lifts the token.
  void _paintGroundShadow(Canvas canvas, double tokenSize, double centerX) {
    final shadowRect = Rect.fromCenter(
      center: Offset(centerX, tokenSize * 0.82),
      width: tokenSize * 0.62,
      height: tokenSize * 0.18,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        math.max(1, tokenSize * 0.055),
      );

    canvas.drawOval(shadowRect, shadowPaint);
  }

  /// Paints the tapered pawn body and rounded base.
  void _paintTokenBody(
    Canvas canvas,
    double tokenSize,
    double centerX,
    Color tokenColor,
  ) {
    final bodyPath = Path()
      ..moveTo(centerX - tokenSize * 0.15, tokenSize * 0.37)
      ..cubicTo(
        centerX - tokenSize * 0.13,
        tokenSize * 0.49,
        centerX - tokenSize * 0.22,
        tokenSize * 0.61,
        centerX - tokenSize * 0.31,
        tokenSize * 0.72,
      )
      ..cubicTo(
        centerX - tokenSize * 0.37,
        tokenSize * 0.79,
        centerX - tokenSize * 0.30,
        tokenSize * 0.86,
        centerX,
        tokenSize * 0.87,
      )
      ..cubicTo(
        centerX + tokenSize * 0.30,
        tokenSize * 0.86,
        centerX + tokenSize * 0.37,
        tokenSize * 0.79,
        centerX + tokenSize * 0.31,
        tokenSize * 0.72,
      )
      ..cubicTo(
        centerX + tokenSize * 0.22,
        tokenSize * 0.61,
        centerX + tokenSize * 0.13,
        tokenSize * 0.49,
        centerX + tokenSize * 0.15,
        tokenSize * 0.37,
      )
      ..close();

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _lighten(tokenColor, 0.18),
          tokenColor,
          _darken(tokenColor, 0.22),
        ],
        stops: const [0, 0.55, 1],
      ).createShader(Rect.fromLTWH(0, 0, tokenSize, tokenSize));

    final outlinePaint = Paint()
      ..color = _darken(tokenColor, 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, tokenSize * 0.035)
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    final baseHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.7, tokenSize * 0.025);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, tokenSize * 0.75),
        width: tokenSize * 0.50,
        height: tokenSize * 0.18,
      ),
      math.pi * 0.10,
      math.pi * 0.80,
      false,
      baseHighlight,
    );
  }

  /// Paints the spherical upper portion of the pawn.
  void _paintTokenHead(
    Canvas canvas,
    double tokenSize,
    double centerX,
    Color tokenColor,
  ) {
    final headCenter = Offset(centerX, tokenSize * 0.28);
    final headRadius = tokenSize * 0.22;
    final headRect = Rect.fromCircle(center: headCenter, radius: headRadius);

    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.40),
        radius: 0.95,
        colors: [
          _lighten(tokenColor, 0.30),
          tokenColor,
          _darken(tokenColor, 0.26),
        ],
        stops: const [0, 0.58, 1],
      ).createShader(headRect);

    final outlinePaint = Paint()
      ..color = _darken(tokenColor, 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, tokenSize * 0.035);

    canvas.drawCircle(headCenter, headRadius, headPaint);
    canvas.drawCircle(headCenter, headRadius, outlinePaint);
  }

  /// Paints small reflective accents that reinforce the 2.5D appearance.
  void _paintHighlights(Canvas canvas, double tokenSize, double centerX) {
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.48)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - tokenSize * 0.075, tokenSize * 0.205),
        width: tokenSize * 0.075,
        height: tokenSize * 0.11,
      ),
      highlightPaint,
    );
  }

  /// Produces a lighter visual variant without changing logical player color.
  Color _lighten(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount)!;
  }

  /// Produces a darker visual variant without changing logical player color.
  Color _darken(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount)!;
  }

  @override
  bool shouldRepaint(covariant LudoTokenPainter oldDelegate) {
    return oldDelegate.playerColor != playerColor;
  }
}
