import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board_painter.dart';

void main() {
  group('LudoBoardPainter', () {
    test('paints supported square board sizes without throwing', () {
      const painter = LudoBoardPainter();

      for (final boardSize in [150.0, 375.0, 900.0]) {
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);

        expect(
          () => painter.paint(canvas, Size.square(boardSize)),
          returnsNormally,
        );

        recorder.endRecording();
      }
    });

    test('centers a square board inside a non-square canvas', () {
      const painter = LudoBoardPainter();
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(600, 400)),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('handles an empty canvas without throwing', () {
      const painter = LudoBoardPainter();
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, Size.zero), returnsNormally);

      recorder.endRecording();
    });

    test('does not repaint when its immutable configuration is unchanged', () {
      const painter = LudoBoardPainter();
      const previousPainter = LudoBoardPainter();

      expect(painter.shouldRepaint(previousPainter), isFalse);
    });
  });
}
