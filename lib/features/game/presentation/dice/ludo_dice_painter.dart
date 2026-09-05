import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/dice_result.dart';
import 'dice_skin.dart';

/// Paints a polished resting dice and a perspective cube while rolling.
///
/// The resting state is intentionally front-facing and compact. Perspective
/// surfaces appear only during the physical roll, preventing the landed dice
/// from looking like an open or distorted box.
///
/// This renderer consumes presentation data only. It never generates logical
/// results or implements movement, turn, yard, or six rules.
class LudoDicePainter extends CustomPainter {
  /// Creates the classic dice renderer.
  const LudoDicePainter({
    required this.result,
    this.skin = DiceSkin.classicIvory,
    this.rollProgress = 1,
    this.isRolling = false,
    this.rotationCount = 3.5,
    this.perspective = 0.0018,
  }) : assert(
         rollProgress >= 0 && rollProgress <= 1,
         'Roll progress must be between zero and one.',
       ),
       assert(rotationCount > 0, 'Rotation count must be positive.'),
       assert(perspective >= 0, 'Perspective must not be negative.');

  /// Temporary visual face or completed logical result.
  final DiceResult result;

  /// Cosmetic colors used by the renderer.
  final DiceSkin skin;

  /// Normalized roll progress.
  final double rollProgress;

  /// Whether the dice is currently rolling.
  final bool isRolling;

  /// Number of rotations in one roll.
  final double rotationCount;

  /// Perspective strength supplied by the motion profile.
  final double perspective;

  @override
  void paint(Canvas canvas, Size size) {
    final diceSize = math.min(size.width, size.height);

    if (!diceSize.isFinite || diceSize <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);

    // Start and finish with the clean button-like resting face. Restricting
    // perspective to the central roll prevents a malformed landed silhouette.
    final showRestingFace =
        !isRolling || rollProgress <= 0.035 || rollProgress >= 0.90;

    if (showRestingFace) {
      _paintRestingDice(canvas: canvas, center: center, diceSize: diceSize);
      return;
    }

    _paintRollingCube(canvas: canvas, center: center, diceSize: diceSize);
  }

  /// Paints the compact front-facing dice shown before and after rolling.
  void _paintRestingDice({
    required Canvas canvas,
    required Offset center,
    required double diceSize,
  }) {
    final bodySize = diceSize * 0.78;
    final bodyRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - diceSize * 0.015),
      width: bodySize,
      height: bodySize,
    );
    final cornerRadius = Radius.circular(bodySize * 0.22);
    final bodyShape = RRect.fromRectAndRadius(bodyRect, cornerRadius);

    final shadowPaint = Paint()
      ..color = skin.shadowColor
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        math.max(1, diceSize * 0.055),
      );

    canvas.save();
    canvas.translate(0, diceSize * 0.075);
    canvas.drawRRect(bodyShape, shadowPaint);
    canvas.restore();

    final lowerBevelRect = bodyRect.shift(Offset(0, diceSize * 0.035));
    final lowerBevelShape = RRect.fromRectAndRadius(
      lowerBevelRect,
      cornerRadius,
    );

    canvas.drawRRect(lowerBevelShape, Paint()..color = skin.shadedFaceColor);

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(skin.primaryFaceColor, Colors.white, 0.45)!,
          skin.primaryFaceColor,
          skin.secondaryFaceColor,
        ],
        stops: const [0, 0.48, 1],
      ).createShader(bodyRect);

    canvas.drawRRect(bodyShape, bodyPaint);

    final outlinePaint = Paint()
      ..color = skin.edgeColor.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, diceSize * 0.025);

    canvas.drawRRect(bodyShape, outlinePaint);

    // A clipped highlight gives the upper edge a soft molded appearance.
    canvas.save();
    canvas.clipRRect(bodyShape);

    final highlightPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.72),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromLTWH(
              bodyRect.left,
              bodyRect.top,
              bodyRect.width,
              bodyRect.height * 0.44,
            ),
          );

    canvas.drawOval(
      Rect.fromLTWH(
        bodyRect.left + bodyRect.width * 0.06,
        bodyRect.top - bodyRect.height * 0.18,
        bodyRect.width * 0.88,
        bodyRect.height * 0.52,
      ),
      highlightPaint,
    );

    canvas.restore();

    final pipRadius = bodySize * 0.072;

    for (final position in _pipPositionsFor(result.value)) {
      final pipCenter = Offset(
        bodyRect.left + bodyRect.width * position.dx,
        bodyRect.top + bodyRect.height * position.dy,
      );

      _paintPip(canvas: canvas, center: pipCenter, radius: pipRadius);
    }
  }

  /// Paints a rotating three-surface cube during the active roll.
  void _paintRollingCube({
    required Canvas canvas,
    required Offset center,
    required double diceSize,
  }) {
    final lift = math.sin(rollProgress * math.pi).abs();
    final shadowPaint = Paint()
      ..color = skin.shadowColor.withValues(alpha: 0.48 - lift * 0.20)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        math.max(1, diceSize * 0.06),
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + diceSize * 0.34),
        width: diceSize * (0.58 - lift * 0.14),
        height: diceSize * 0.13,
      ),
      shadowPaint,
    );

    final eased = Curves.easeInOutCubic.transform(rollProgress);
    final completeRotation = math.pi * 2 * rotationCount;

    final orientation = _DiceOrientation(
      rotationX:
          -0.30 +
          completeRotation * eased +
          math.sin(rollProgress * math.pi * 4) * 0.18,
      rotationY:
          0.34 +
          completeRotation * 0.73 * eased +
          math.sin(rollProgress * math.pi * 5) * 0.20,
      rotationZ: completeRotation * 0.22 * eased,
    );

    final projectionStrength = (perspective * diceSize)
        .clamp(0.07, 0.18)
        .toDouble();

    final faces =
        _createFaces().where((face) {
          return orientation.transform(face.normal).z > 0.02;
        }).toList()..sort((first, second) {
          return _faceDepth(
            first,
            orientation,
          ).compareTo(_faceDepth(second, orientation));
        });

    for (final face in faces) {
      _paintProjectedFace(
        canvas: canvas,
        center: center,
        diceSize: diceSize,
        face: face,
        orientation: orientation,
        projectionStrength: projectionStrength,
      );
    }
  }

  /// Paints one visible cube surface and its correctly aligned pips.
  void _paintProjectedFace({
    required Canvas canvas,
    required Offset center,
    required double diceSize,
    required _DiceFace face,
    required _DiceOrientation orientation,
    required double projectionStrength,
  }) {
    final transformedNormal = orientation.transform(face.normal);
    final corners = face.corners.map((corner) {
      return _project(
        orientation.transform(corner),
        center,
        diceSize,
        projectionStrength,
      );
    }).toList();

    final path = Path()..moveTo(corners.first.dx, corners.first.dy);

    for (var index = 1; index < corners.length; index++) {
      path.lineTo(corners[index].dx, corners[index].dy);
    }

    path.close();

    final light =
        (transformedNormal.z * 0.64 -
                transformedNormal.x * 0.12 -
                transformedNormal.y * 0.16)
            .clamp(0.0, 1.0);

    final faceColor = Color.lerp(
      skin.shadedFaceColor,
      skin.primaryFaceColor,
      light,
    )!;

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(faceColor, Colors.white, 0.24)!,
            faceColor,
            Color.lerp(faceColor, skin.secondaryFaceColor, 0.55)!,
          ],
        ).createShader(path.getBounds()),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = skin.edgeColor.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(1, diceSize * 0.018),
    );

    canvas.save();
    canvas.clipPath(path);

    for (final position in _pipPositionsFor(face.value)) {
      final horizontal = (position.dx - 0.5) * 1.12;
      final vertical = (position.dy - 0.5) * 1.12;
      final point =
          face.center +
          face.horizontalAxis * horizontal +
          face.verticalAxis * vertical;
      final transformedPoint = orientation.transform(point);
      final pipCenter = _project(
        transformedPoint,
        center,
        diceSize,
        projectionStrength,
      );
      final depthScale =
          1 / (1 - transformedPoint.z * projectionStrength).clamp(0.72, 1.32);

      _paintPip(
        canvas: canvas,
        center: pipCenter,
        radius: diceSize * 0.034 * depthScale,
      );
    }

    canvas.restore();
  }

  /// Paints one softly highlighted circular pip.
  void _paintPip({
    required Canvas canvas,
    required Offset center,
    required double radius,
  }) {
    final pipPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.34, -0.34),
        radius: 0.95,
        colors: [
          Color.lerp(skin.pipColor, skin.pipHighlightColor, 0.34)!,
          skin.pipColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, pipPaint);
  }

  /// Creates six physical surfaces with standard opposite-face pairing.
  List<_DiceFace> _createFaces() {
    final front = result.value;
    final back = 7 - front;
    final remaining = <int>[
      for (var value = 1; value <= DiceResult.faceCount; value++)
        if (value != front && value != back) value,
    ];

    final right = remaining.first;
    final left = 7 - right;
    final top = remaining.firstWhere(
      (value) => value != right && value != left,
    );
    final bottom = 7 - top;

    return [
      _DiceFace.front(front),
      _DiceFace.back(back),
      _DiceFace.right(right),
      _DiceFace.left(left),
      _DiceFace.top(top),
      _DiceFace.bottom(bottom),
    ];
  }

  /// Projects one rotated cube-space point onto the canvas.
  Offset _project(
    _DicePoint point,
    Offset center,
    double diceSize,
    double projectionStrength,
  ) {
    final depthScale = 1 / (1 - point.z * projectionStrength).clamp(0.68, 1.34);
    final scale = diceSize * 0.275;

    return Offset(
      center.dx + point.x * scale * depthScale,
      center.dy + point.y * scale * depthScale,
    );
  }

  /// Returns average transformed depth for painter ordering.
  double _faceDepth(_DiceFace face, _DiceOrientation orientation) {
    var depth = 0.0;

    for (final corner in face.corners) {
      depth += orientation.transform(corner).z;
    }

    return depth / face.corners.length;
  }

  /// Returns normalized pip centers for a conventional dice face.
  List<Offset> _pipPositionsFor(int value) {
    const low = 0.27;
    const middle = 0.50;
    const high = 0.73;

    return switch (value) {
      1 => const [Offset(middle, middle)],
      2 => const [Offset(low, low), Offset(high, high)],
      3 => const [Offset(low, low), Offset(middle, middle), Offset(high, high)],
      4 => const [
        Offset(low, low),
        Offset(high, low),
        Offset(low, high),
        Offset(high, high),
      ],
      5 => const [
        Offset(low, low),
        Offset(high, low),
        Offset(middle, middle),
        Offset(low, high),
        Offset(high, high),
      ],
      6 => const [
        Offset(low, low),
        Offset(high, low),
        Offset(low, middle),
        Offset(high, middle),
        Offset(low, high),
        Offset(high, high),
      ],
      _ => throw StateError('Unsupported validated dice value: $value.'),
    };
  }

  @override
  bool shouldRepaint(covariant LudoDicePainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.skin != skin ||
        oldDelegate.rollProgress != rollProgress ||
        oldDelegate.isRolling != isRolling ||
        oldDelegate.rotationCount != rotationCount ||
        oldDelegate.perspective != perspective;
  }
}

/// Defines one cube surface.
class _DiceFace {
  const _DiceFace({
    required this.value,
    required this.center,
    required this.normal,
    required this.horizontalAxis,
    required this.verticalAxis,
    required this.corners,
  });

  factory _DiceFace.front(int value) => _DiceFace(
    value: value,
    center: const _DicePoint(0, 0, 1),
    normal: const _DicePoint(0, 0, 1),
    horizontalAxis: const _DicePoint(1, 0, 0),
    verticalAxis: const _DicePoint(0, 1, 0),
    corners: const [
      _DicePoint(-1, -1, 1),
      _DicePoint(1, -1, 1),
      _DicePoint(1, 1, 1),
      _DicePoint(-1, 1, 1),
    ],
  );

  factory _DiceFace.back(int value) => _DiceFace(
    value: value,
    center: const _DicePoint(0, 0, -1),
    normal: const _DicePoint(0, 0, -1),
    horizontalAxis: const _DicePoint(-1, 0, 0),
    verticalAxis: const _DicePoint(0, 1, 0),
    corners: const [
      _DicePoint(1, -1, -1),
      _DicePoint(-1, -1, -1),
      _DicePoint(-1, 1, -1),
      _DicePoint(1, 1, -1),
    ],
  );

  factory _DiceFace.right(int value) => _DiceFace(
    value: value,
    center: const _DicePoint(1, 0, 0),
    normal: const _DicePoint(1, 0, 0),
    horizontalAxis: const _DicePoint(0, 0, -1),
    verticalAxis: const _DicePoint(0, 1, 0),
    corners: const [
      _DicePoint(1, -1, 1),
      _DicePoint(1, -1, -1),
      _DicePoint(1, 1, -1),
      _DicePoint(1, 1, 1),
    ],
  );

  factory _DiceFace.left(int value) => _DiceFace(
    value: value,
    center: const _DicePoint(-1, 0, 0),
    normal: const _DicePoint(-1, 0, 0),
    horizontalAxis: const _DicePoint(0, 0, 1),
    verticalAxis: const _DicePoint(0, 1, 0),
    corners: const [
      _DicePoint(-1, -1, -1),
      _DicePoint(-1, -1, 1),
      _DicePoint(-1, 1, 1),
      _DicePoint(-1, 1, -1),
    ],
  );

  factory _DiceFace.top(int value) => _DiceFace(
    value: value,
    center: const _DicePoint(0, -1, 0),
    normal: const _DicePoint(0, -1, 0),
    horizontalAxis: const _DicePoint(1, 0, 0),
    verticalAxis: const _DicePoint(0, 0, 1),
    corners: const [
      _DicePoint(-1, -1, -1),
      _DicePoint(1, -1, -1),
      _DicePoint(1, -1, 1),
      _DicePoint(-1, -1, 1),
    ],
  );

  factory _DiceFace.bottom(int value) => _DiceFace(
    value: value,
    center: const _DicePoint(0, 1, 0),
    normal: const _DicePoint(0, 1, 0),
    horizontalAxis: const _DicePoint(1, 0, 0),
    verticalAxis: const _DicePoint(0, 0, -1),
    corners: const [
      _DicePoint(-1, 1, 1),
      _DicePoint(1, 1, 1),
      _DicePoint(1, 1, -1),
      _DicePoint(-1, 1, -1),
    ],
  );

  final int value;
  final _DicePoint center;
  final _DicePoint normal;
  final _DicePoint horizontalAxis;
  final _DicePoint verticalAxis;
  final List<_DicePoint> corners;
}

/// Represents one normalized three-dimensional point.
class _DicePoint {
  const _DicePoint(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  _DicePoint operator +(_DicePoint other) {
    return _DicePoint(x + other.x, y + other.y, z + other.z);
  }

  _DicePoint operator *(double scale) {
    return _DicePoint(x * scale, y * scale, z * scale);
  }
}

/// Applies deterministic cube rotation.
class _DiceOrientation {
  const _DiceOrientation({
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
  });

  final double rotationX;
  final double rotationY;
  final double rotationZ;

  _DicePoint transform(_DicePoint point) {
    final cosineX = math.cos(rotationX);
    final sineX = math.sin(rotationX);
    final cosineY = math.cos(rotationY);
    final sineY = math.sin(rotationY);
    final cosineZ = math.cos(rotationZ);
    final sineZ = math.sin(rotationZ);

    final xAfterX = point.x;
    final yAfterX = point.y * cosineX - point.z * sineX;
    final zAfterX = point.y * sineX + point.z * cosineX;

    final xAfterY = xAfterX * cosineY + zAfterX * sineY;
    final yAfterY = yAfterX;
    final zAfterY = -xAfterX * sineY + zAfterX * cosineY;

    return _DicePoint(
      xAfterY * cosineZ - yAfterY * sineZ,
      xAfterY * sineZ + yAfterY * cosineZ,
      zAfterY,
    );
  }
}
