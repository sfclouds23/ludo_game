import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/presentation/dice/rive_dice_asset.dart';
import 'package:ludo_game/features/game/presentation/dice/rive_dice_renderer.dart';

void main() {
  group('RiveDiceRenderer configuration', () {
    test('exposes supplied rendering configuration', () {
      const fallback = ColoredBox(color: Colors.red);

      final renderer = RiveDiceRenderer(
        result: DiceResult(4),
        dimension: 96,
        playbackSequence: 3,
        fallback: fallback,
      );

      expect(renderer.result, DiceResult(4));
      expect(renderer.dimension, 96);
      expect(renderer.playbackSequence, 3);
      expect(renderer.asset, RiveDiceAsset.classic3d);
      expect(renderer.fallback, same(fallback));
    });

    test('accepts a future premium asset configuration', () {
      const premiumAsset = RiveDiceAsset(
        id: 'premium_crystal',
        assetPath: 'assets/rive/premium_crystal.riv',
        artboardName: 'Crystal Dice',
        animationNames: <int, String>{
          1: 'Crystal One',
          2: 'Crystal Two',
          3: 'Crystal Three',
          4: 'Crystal Four',
          5: 'Crystal Five',
          6: 'Crystal Six',
        },
        playbackDuration: Duration(milliseconds: 850),
        contentScale: 1.3,
        alignment: Alignment(0, 0.08),
      );

      final renderer = RiveDiceRenderer(
        result: DiceResult(6),
        dimension: 104,
        playbackSequence: 7,
        fallback: const SizedBox.shrink(),
        asset: premiumAsset,
      );

      expect(renderer.asset, premiumAsset);
      expect(renderer.asset.animationNameFor(renderer.result), 'Crystal Six');
      expect(renderer.asset.contentScale, 1.3);
      expect(renderer.asset.alignment, const Alignment(0, 0.08));
    });

    test('rejects non-positive dimensions', () {
      expect(
        () => RiveDiceRenderer(
          result: DiceResult(1),
          dimension: 0,
          playbackSequence: 0,
          fallback: const SizedBox.shrink(),
        ),
        throwsAssertionError,
      );
    });

    test('uses stable keys for viewport inspection', () {
      expect(
        RiveDiceRenderer.viewportKey,
        const ValueKey<String>('rive-dice-renderer-viewport'),
      );

      expect(
        RiveDiceRenderer.contentKey,
        const ValueKey<String>('rive-dice-renderer-content'),
      );
    });

    test('maps the supplied result without generating a replacement', () {
      final renderer = RiveDiceRenderer(
        result: DiceResult(3),
        dimension: 88,
        playbackSequence: 1,
        fallback: const SizedBox.shrink(),
      );

      expect(renderer.asset.animationNameFor(renderer.result), 'Roll 3 ');
    });
  });
}
