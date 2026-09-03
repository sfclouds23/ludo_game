import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/presentation/dice/ludo_dice_painter.dart';

void main() {
  group('LudoDicePainter rendering', () {
    test('paints every logical dice result without throwing', () {
      for (
        var value = DiceResult.minimumValue;
        value <= DiceResult.maximumValue;
        value++
      ) {
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        final painter = LudoDicePainter(result: DiceResult(value));

        expect(
          () => painter.paint(canvas, const Size.square(96)),
          returnsNormally,
        );

        recorder.endRecording();
      }
    });

    test('paints responsive dice sizes without throwing', () {
      for (final diceSize in [24.0, 48.0, 72.0, 144.0]) {
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        final painter = LudoDicePainter(result: DiceResult(5));

        expect(
          () => painter.paint(canvas, Size.square(diceSize)),
          returnsNormally,
        );

        recorder.endRecording();
      }
    });

    test('centers the dice inside a non-square canvas', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = LudoDicePainter(result: DiceResult(3));

      expect(() => painter.paint(canvas, const Size(140, 90)), returnsNormally);

      recorder.endRecording();
    });

    test('handles an empty canvas without throwing', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = LudoDicePainter(result: DiceResult(1));

      expect(() => painter.paint(canvas, Size.zero), returnsNormally);

      recorder.endRecording();
    });

    test('handles a non-finite canvas without throwing', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = LudoDicePainter(result: DiceResult(6));

      expect(
        () =>
            painter.paint(canvas, const Size(double.infinity, double.infinity)),
        returnsNormally,
      );

      recorder.endRecording();
    });
  });

  group('LudoDicePainter repaint behavior', () {
    test('does not repaint when the logical result is unchanged', () {
      final painter = LudoDicePainter(result: DiceResult(4));
      final previousPainter = LudoDicePainter(result: DiceResult(4));

      expect(painter.shouldRepaint(previousPainter), isFalse);
    });

    test('repaints when the logical result changes', () {
      final painter = LudoDicePainter(result: DiceResult(5));
      final previousPainter = LudoDicePainter(result: DiceResult(2));

      expect(painter.shouldRepaint(previousPainter), isTrue);
    });
  });
}
