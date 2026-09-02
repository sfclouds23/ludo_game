import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/board/board_definition.dart';
import '../../domain/models/player_color.dart';
import 'board_coordinate_mapper.dart';
import 'board_geometry.dart';
import 'board_grid_position.dart';
import 'board_palette.dart';

/// Paints the complete static visual structure of the Ludo board.
///
/// The painter consumes presentation coordinates derived from GAME-101 logical
/// cells. It does not determine movement, occupancy, captures, or game state.
class LudoBoardPainter extends CustomPainter {
  /// Creates the production Ludo board painter.
  const LudoBoardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = math.min(size.width, size.height);

    // A zero-sized canvas can occur briefly during layout. There is nothing
    // useful to paint until both dimensions provide visible space.
    if (!boardSize.isFinite || boardSize <= 0) {
      return;
    }

    final geometry = BoardGeometry(boardSize);
    final horizontalOffset = (size.width - boardSize) / 2;
    final verticalOffset = (size.height - boardSize) / 2;

    // Center the square board if a non-square canvas is supplied. The
    // responsive widget will normally provide a square canvas, but keeping the
    // painter defensive makes previews and tests safer.
    canvas.save();
    canvas.translate(horizontalOffset, verticalOffset);

    _paintBoardSurface(canvas, geometry);
    _paintPlayerYards(canvas, geometry);
    _paintFinishArea(canvas, geometry);
    _paintMainTrack(canvas, geometry);
    _paintHomeLanes(canvas, geometry);
    _paintSafeCellMarkers(canvas, geometry);
    _paintOuterBorder(canvas, geometry);

    canvas.restore();
  }

  /// Paints the neutral background underneath all board sections.
  void _paintBoardSurface(Canvas canvas, BoardGeometry geometry) {
    final paint = Paint()
      ..color = BoardPalette.boardSurface
      ..style = PaintingStyle.fill;

    canvas.drawRect(geometry.boardRect, paint);
  }

  /// Paints the four colored player yards.
  void _paintPlayerYards(Canvas canvas, BoardGeometry geometry) {
    _paintPlayerYard(
      canvas,
      geometry,
      row: 0,
      column: 0,
      color: BoardPalette.red,
    );
    _paintPlayerYard(
      canvas,
      geometry,
      row: 0,
      column: 9,
      color: BoardPalette.green,
    );
    _paintPlayerYard(
      canvas,
      geometry,
      row: 9,
      column: 9,
      color: BoardPalette.yellow,
    );
    _paintPlayerYard(
      canvas,
      geometry,
      row: 9,
      column: 0,
      color: BoardPalette.blue,
    );
  }

  /// Paints one 6 × 6 player yard and its four token placeholders.
  void _paintPlayerYard(
    Canvas canvas,
    BoardGeometry geometry, {
    required int row,
    required int column,
    required Color color,
  }) {
    final cellSize = geometry.cellSize;
    final yardRect = Rect.fromLTWH(
      column * cellSize,
      row * cellSize,
      6 * cellSize,
      6 * cellSize,
    );
    final innerRect = Rect.fromLTWH(
      (column + 1) * cellSize,
      (row + 1) * cellSize,
      4 * cellSize,
      4 * cellSize,
    );

    final yardPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final innerPaint = Paint()
      ..color = BoardPalette.yardSurface
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = BoardPalette.cellBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cellStrokeWidth(geometry);

    canvas.drawRect(yardRect, yardPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(cellSize * 0.35)),
      innerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(cellSize * 0.35)),
      borderPaint,
    );

    // These circles reserve the future token-home locations. Actual tokens
    // will be rendered separately by GAME-103.
    final slotCenters = [
      Offset((column + 2) * cellSize, (row + 2) * cellSize),
      Offset((column + 4) * cellSize, (row + 2) * cellSize),
      Offset((column + 2) * cellSize, (row + 4) * cellSize),
      Offset((column + 4) * cellSize, (row + 4) * cellSize),
    ];

    final slotFillPaint = Paint()
      ..color = BoardPalette.trackCell
      ..style = PaintingStyle.fill;
    final slotBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, cellSize * 0.12);

    for (final center in slotCenters) {
      canvas.drawCircle(center, cellSize * 0.58, slotFillPaint);
      canvas.drawCircle(center, cellSize * 0.58, slotBorderPaint);
    }
  }

  /// Paints the four-color triangular finish area.
  void _paintFinishArea(Canvas canvas, BoardGeometry geometry) {
    final cellSize = geometry.cellSize;
    final left = 6 * cellSize;
    final top = 6 * cellSize;
    final right = 9 * cellSize;
    final bottom = 9 * cellSize;
    final center = Offset(7.5 * cellSize, 7.5 * cellSize);

    _paintTriangle(
      canvas,
      points: [Offset(left, top), Offset(left, bottom), center],
      color: BoardPalette.red,
    );
    _paintTriangle(
      canvas,
      points: [Offset(left, top), Offset(right, top), center],
      color: BoardPalette.green,
    );
    _paintTriangle(
      canvas,
      points: [Offset(right, top), Offset(right, bottom), center],
      color: BoardPalette.yellow,
    );
    _paintTriangle(
      canvas,
      points: [Offset(left, bottom), Offset(right, bottom), center],
      color: BoardPalette.blue,
    );

    final borderPaint = Paint()
      ..color = BoardPalette.cellBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cellStrokeWidth(geometry);

    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), borderPaint);
  }

  /// Paints one colored finish triangle.
  void _paintTriangle(
    Canvas canvas, {
    required List<Offset> points,
    required Color color,
  }) {
    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = BoardPalette.cellBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  /// Paints all 52 shared-track cells.
  void _paintMainTrack(Canvas canvas, BoardGeometry geometry) {
    for (
      var index = 0;
      index < BoardCoordinateMapper.mainTrackPositions.length;
      index++
    ) {
      final position = BoardCoordinateMapper.mainTrackPositions[index];

      _paintGridCell(
        canvas,
        geometry,
        position,
        fillColor: _mainTrackColor(index),
      );
    }
  }

  /// Returns the appropriate fill for a shared-track index.
  Color _mainTrackColor(int index) {
    if (index == BoardDefinition.startIndexFor(PlayerColor.red)) {
      return BoardPalette.red;
    }
    if (index == BoardDefinition.startIndexFor(PlayerColor.green)) {
      return BoardPalette.green;
    }
    if (index == BoardDefinition.startIndexFor(PlayerColor.yellow)) {
      return BoardPalette.yellow;
    }
    if (index == BoardDefinition.startIndexFor(PlayerColor.blue)) {
      return BoardPalette.blue;
    }

    return BoardPalette.trackCell;
  }

  /// Paints all player-specific private home-lane cells.
  void _paintHomeLanes(Canvas canvas, BoardGeometry geometry) {
    for (final entry in BoardCoordinateMapper.homeLanePositions.entries) {
      final color = BoardPalette.colorFor(entry.key);

      for (final position in entry.value) {
        _paintGridCell(canvas, geometry, position, fillColor: color);
      }
    }
  }

  /// Paints one normalized grid cell with a fill and border.
  void _paintGridCell(
    Canvas canvas,
    BoardGeometry geometry,
    BoardGridPosition position, {
    required Color fillColor,
  }) {
    final rect = geometry.cellRect(row: position.row, column: position.column);
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = BoardPalette.cellBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cellStrokeWidth(geometry);

    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);
  }

  /// Paints star markers on the four additional GAME-101 safe cells.
  void _paintSafeCellMarkers(Canvas canvas, BoardGeometry geometry) {
    for (final index in BoardDefinition.additionalSafeMainTrackIndices) {
      final position = BoardCoordinateMapper.mainTrackPositions[index];
      final center = position.centerIn(geometry);

      _paintStar(
        canvas,
        center: center,
        outerRadius: geometry.cellSize * 0.32,
        innerRadius: geometry.cellSize * 0.14,
      );
    }
  }

  /// Paints a compact five-point safe-cell marker.
  void _paintStar(
    Canvas canvas, {
    required Offset center,
    required double outerRadius,
    required double innerRadius,
  }) {
    final path = Path();

    for (var pointIndex = 0; pointIndex < 10; pointIndex++) {
      final radius = pointIndex.isEven ? outerRadius : innerRadius;
      final angle = -math.pi / 2 + pointIndex * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      if (pointIndex == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();

    final fillPaint = Paint()
      ..color = BoardPalette.boardBorder
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
  }

  /// Paints the final border around the complete square board.
  void _paintOuterBorder(Canvas canvas, BoardGeometry geometry) {
    final borderPaint = Paint()
      ..color = BoardPalette.boardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, geometry.cellSize * 0.12);

    // Deflating keeps the full stroke inside the available canvas.
    final inset = borderPaint.strokeWidth / 2;
    canvas.drawRect(geometry.boardRect.deflate(inset), borderPaint);
  }

  /// Calculates a responsive but readable cell-border width.
  double _cellStrokeWidth(BoardGeometry geometry) {
    return math.max(0.75, geometry.cellSize * 0.045);
  }

  @override
  bool shouldRepaint(covariant LudoBoardPainter oldDelegate) {
    // This painter currently has no mutable visual inputs.
    return false;
  }
}
