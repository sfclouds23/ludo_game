import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_painter.dart';

void main() {
  group('LudoTokenPainter rendering', () {
    test('paints every player color without throwing', () {
      for (final playerColor in PlayerColor.values) {
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        final painter = LudoTokenPainter(playerColor: playerColor);

        expect(
          () => painter.paint(canvas, const Size.square(64)),
          returnsNormally,
        );

        recorder.endRecording();
      }
    });

    test('paints responsive token sizes without throwing', () {
      for (final tokenSize in [20.0, 40.0, 80.0, 160.0]) {
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        const painter = LudoTokenPainter(playerColor: PlayerColor.red);

        expect(
          () => painter.paint(canvas, Size.square(tokenSize)),
          returnsNormally,
        );

        recorder.endRecording();
      }
    });

    test('centers the token inside a non-square canvas', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const painter = LudoTokenPainter(playerColor: PlayerColor.green);

      expect(() => painter.paint(canvas, const Size(100, 60)), returnsNormally);

      recorder.endRecording();
    });

    test('handles an empty canvas without throwing', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const painter = LudoTokenPainter(playerColor: PlayerColor.yellow);

      expect(() => painter.paint(canvas, Size.zero), returnsNormally);

      recorder.endRecording();
    });
  });

  group('LudoTokenPainter repaint behavior', () {
    test('does not repaint when player color is unchanged', () {
      const painter = LudoTokenPainter(playerColor: PlayerColor.blue);
      const previousPainter = LudoTokenPainter(playerColor: PlayerColor.blue);

      expect(painter.shouldRepaint(previousPainter), isFalse);
    });

    test('repaints when player color changes', () {
      const painter = LudoTokenPainter(playerColor: PlayerColor.red);
      const previousPainter = LudoTokenPainter(playerColor: PlayerColor.green);

      expect(painter.shouldRepaint(previousPainter), isTrue);
    });
  });
}
