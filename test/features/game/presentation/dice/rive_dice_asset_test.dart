import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/dice_result.dart';
import 'package:ludo_game/features/game/presentation/dice/rive_dice_asset.dart';

void main() {
  group('RiveDiceAsset', () {
    test('provides the classic 3D asset configuration', () {
      const asset = RiveDiceAsset.classic3d;

      expect(asset.id, 'classic_3d_rive');
      expect(asset.assetPath, 'assets/rive/ludo_dice_3d.riv');
      expect(asset.artboardName, 'Dice');
      expect(asset.playbackDuration, const Duration(milliseconds: 1000));
      expect(asset.contentScale, 1.25);
      expect(asset.alignment, Alignment.bottomCenter);
    });

    test('maps every canonical logical result', () {
      const asset = RiveDiceAsset.classic3d;

      expect(asset.animationNameFor(DiceResult(1)), 'Roll 1');
      expect(asset.animationNameFor(DiceResult(2)), 'Roll 2');
      expect(asset.animationNameFor(DiceResult(3)), 'Roll 3 ');
      expect(asset.animationNameFor(DiceResult(4)), 'Roll 4');
      expect(asset.animationNameFor(DiceResult(5)), 'Roll 5');
      expect(asset.animationNameFor(DiceResult(6)), 'Roll 6');
    });

    test('preserves the exported trailing space for result three', () {
      const asset = RiveDiceAsset.classic3d;
      final animationName = asset.animationNameFor(DiceResult(3));

      expect(animationName, 'Roll 3 ');
      expect(animationName.endsWith(' '), isTrue);
      expect(animationName.length, 7);
    });

    test('throws when an asset does not map a supplied result', () {
      const asset = RiveDiceAsset(
        id: 'incomplete',
        assetPath: 'assets/rive/incomplete.riv',
        artboardName: 'Dice',
        animationNames: <int, String>{1: 'One'},
        playbackDuration: Duration(milliseconds: 500),
      );

      expect(
        () => asset.animationNameFor(DiceResult(2)),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when a mapped animation name is empty', () {
      const asset = RiveDiceAsset(
        id: 'empty_animation',
        assetPath: 'assets/rive/empty.riv',
        artboardName: 'Dice',
        animationNames: <int, String>{1: ''},
        playbackDuration: Duration(milliseconds: 500),
      );

      expect(
        () => asset.animationNameFor(DiceResult(1)),
        throwsA(isA<StateError>()),
      );
    });

    test('supports future cosmetic-specific presentation metadata', () {
      const asset = RiveDiceAsset(
        id: 'premium_gold',
        assetPath: 'assets/rive/premium_gold.riv',
        artboardName: 'Gold Dice',
        animationNames: <int, String>{
          1: 'Gold One',
          2: 'Gold Two',
          3: 'Gold Three',
          4: 'Gold Four',
          5: 'Gold Five',
          6: 'Gold Six',
        },
        playbackDuration: Duration(milliseconds: 850),
        contentScale: 1.15,
        alignment: Alignment.bottomCenter,
      );

      expect(asset.id, 'premium_gold');
      expect(asset.animationNameFor(DiceResult(6)), 'Gold Six');
      expect(asset.contentScale, 1.15);
      expect(asset.alignment, Alignment.bottomCenter);
    });

    test('compares equivalent configurations by value', () {
      const first = RiveDiceAsset(
        id: 'test',
        assetPath: 'assets/rive/test.riv',
        artboardName: 'Dice',
        animationNames: <int, String>{1: 'One'},
        playbackDuration: Duration(milliseconds: 500),
        contentScale: 1.2,
        alignment: Alignment.bottomCenter,
      );

      const second = RiveDiceAsset(
        id: 'test',
        assetPath: 'assets/rive/test.riv',
        artboardName: 'Dice',
        animationNames: <int, String>{1: 'One'},
        playbackDuration: Duration(milliseconds: 500),
        contentScale: 1.2,
        alignment: Alignment.bottomCenter,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('distinguishes configurations with different alignment', () {
      const centered = RiveDiceAsset(
        id: 'test',
        assetPath: 'assets/rive/test.riv',
        artboardName: 'Dice',
        animationNames: <int, String>{1: 'One'},
        playbackDuration: Duration(milliseconds: 500),
        alignment: Alignment.center,
      );

      const bottomAligned = RiveDiceAsset(
        id: 'test',
        assetPath: 'assets/rive/test.riv',
        artboardName: 'Dice',
        animationNames: <int, String>{1: 'One'},
        playbackDuration: Duration(milliseconds: 500),
        alignment: Alignment.bottomCenter,
      );

      expect(centered, isNot(bottomAligned));
    });

    test('provides a readable string representation', () {
      const asset = RiveDiceAsset.classic3d;

      expect(asset.toString(), contains('classic_3d_rive'));
      expect(asset.toString(), contains('assets/rive/ludo_dice_3d.riv'));
      expect(asset.toString(), contains('Dice'));
    });

    test('rejects empty asset identifiers', () {
      expect(
        () => RiveDiceAsset(
          id: '',
          assetPath: 'assets/rive/test.riv',
          artboardName: 'Dice',
          animationNames: const <int, String>{1: 'One'},
          playbackDuration: const Duration(milliseconds: 500),
        ),
        throwsAssertionError,
      );
    });
  });
}
