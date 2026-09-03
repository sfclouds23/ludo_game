import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_painter.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_visual_state.dart';

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

    test('paints movable emphasis without throwing', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      const painter = LudoTokenPainter(
        playerColor: PlayerColor.green,
        visualState: LudoTokenVisualState(isMovable: true),
        emphasisProgress: 0.5,
      );

      expect(
        () => painter.paint(canvas, const Size.square(64)),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints selected emphasis without throwing', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      const painter = LudoTokenPainter(
        playerColor: PlayerColor.yellow,
        visualState: LudoTokenVisualState(isSelected: true),
        emphasisProgress: 1,
      );

      expect(
        () => painter.paint(canvas, const Size.square(64)),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints moving lift without throwing', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      const painter = LudoTokenPainter(
        playerColor: PlayerColor.blue,
        visualState: LudoTokenVisualState(isMoving: true),
        emphasisProgress: 0.75,
      );

      expect(
        () => painter.paint(canvas, const Size.square(64)),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints home treatment without throwing', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      const painter = LudoTokenPainter(
        playerColor: PlayerColor.red,
        isInYard: true,
      );

      expect(
        () => painter.paint(canvas, const Size.square(64)),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('paints finished marker without throwing', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      const painter = LudoTokenPainter(
        playerColor: PlayerColor.green,
        isFinished: true,
      );

      expect(
        () => painter.paint(canvas, const Size.square(64)),
        returnsNormally,
      );

      recorder.endRecording();
    });

    test('supports overlapping supplied visual states', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      const painter = LudoTokenPainter(
        playerColor: PlayerColor.blue,
        visualState: LudoTokenVisualState(
          isMovable: true,
          isSelected: true,
          isMoving: true,
        ),
        isFinished: true,
        emphasisProgress: 1,
      );

      expect(
        () => painter.paint(canvas, const Size.square(80)),
        returnsNormally,
      );

      recorder.endRecording();
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

  group('LudoTokenPainter configuration', () {
    test('rejects emphasis progress below zero', () {
      expect(
        () => LudoTokenPainter(
          playerColor: PlayerColor.red,
          emphasisProgress: -0.01,
        ),
        throwsAssertionError,
      );
    });

    test('rejects emphasis progress above one', () {
      expect(
        () => LudoTokenPainter(
          playerColor: PlayerColor.red,
          emphasisProgress: 1.01,
        ),
        throwsAssertionError,
      );
    });
  });

  group('LudoTokenPainter repaint behavior', () {
    test('does not repaint when configuration is unchanged', () {
      const painter = LudoTokenPainter(
        playerColor: PlayerColor.blue,
        visualState: LudoTokenVisualState(isSelected: true),
        isFinished: true,
        emphasisProgress: 0.5,
      );

      const previousPainter = LudoTokenPainter(
        playerColor: PlayerColor.blue,
        visualState: LudoTokenVisualState(isSelected: true),
        isFinished: true,
        emphasisProgress: 0.5,
      );

      expect(painter.shouldRepaint(previousPainter), isFalse);
    });

    test('repaints when player color changes', () {
      const painter = LudoTokenPainter(playerColor: PlayerColor.red);
      const previousPainter = LudoTokenPainter(playerColor: PlayerColor.green);

      expect(painter.shouldRepaint(previousPainter), isTrue);
    });

    test('repaints when visual state changes', () {
      const painter = LudoTokenPainter(
        playerColor: PlayerColor.red,
        visualState: LudoTokenVisualState(isSelected: true),
      );
      const previousPainter = LudoTokenPainter(playerColor: PlayerColor.red);

      expect(painter.shouldRepaint(previousPainter), isTrue);
    });

    test('repaints when home state changes', () {
      const painter = LudoTokenPainter(
        playerColor: PlayerColor.red,
        isInYard: true,
      );
      const previousPainter = LudoTokenPainter(playerColor: PlayerColor.red);

      expect(painter.shouldRepaint(previousPainter), isTrue);
    });

    test('repaints when finished state changes', () {
      const painter = LudoTokenPainter(
        playerColor: PlayerColor.red,
        isFinished: true,
      );
      const previousPainter = LudoTokenPainter(playerColor: PlayerColor.red);

      expect(painter.shouldRepaint(previousPainter), isTrue);
    });

    test('repaints when emphasis progress changes', () {
      const painter = LudoTokenPainter(
        playerColor: PlayerColor.red,
        emphasisProgress: 1,
      );
      const previousPainter = LudoTokenPainter(
        playerColor: PlayerColor.red,
        emphasisProgress: 0,
      );

      expect(painter.shouldRepaint(previousPainter), isTrue);
    });
  });
}
