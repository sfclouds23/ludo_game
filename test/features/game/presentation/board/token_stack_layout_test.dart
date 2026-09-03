import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/presentation/board/token_stack_layout.dart';

void main() {
  group('TokenStackPlacement', () {
    test('supports value equality', () {
      const first = TokenStackPlacement(
        offset: Offset(2, -3),
        dimensionScale: 0.75,
      );
      const second = TokenStackPlacement(
        offset: Offset(2, -3),
        dimensionScale: 0.75,
      );
      const different = TokenStackPlacement(
        offset: Offset.zero,
        dimensionScale: 1,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(different));
    });

    test('provides a readable string representation', () {
      const placement = TokenStackPlacement(
        offset: Offset(2, -3),
        dimensionScale: 0.75,
      );

      expect(
        placement.toString(),
        'TokenStackPlacement('
        'offset: Offset(2.0, -3.0), '
        'dimensionScale: 0.75'
        ')',
      );
    });

    test('rejects invalid dimension scales', () {
      expect(
        () => TokenStackPlacement(offset: Offset.zero, dimensionScale: 0),
        throwsAssertionError,
      );

      expect(
        () => TokenStackPlacement(offset: Offset.zero, dimensionScale: 1.01),
        throwsAssertionError,
      );
    });
  });

  group('TokenStackLayout', () {
    test('returns no placements for an empty collection', () {
      final placements = TokenStackLayout.placementsFor(
        tokenIds: const [],
        cellSize: 40,
      );

      expect(placements, isEmpty);
    });

    test('keeps a single token centered at full size', () {
      final placements = TokenStackLayout.placementsFor(
        tokenIds: const ['red_token_0'],
        cellSize: 40,
      );

      expect(
        placements['red_token_0'],
        const TokenStackPlacement(offset: Offset.zero, dimensionScale: 1),
      );
    });

    test('separates two tokens around the shared center', () {
      final placements = TokenStackLayout.placementsFor(
        tokenIds: const ['red_token_0', 'blue_token_0'],
        cellSize: 40,
      );

      final bluePlacement = placements['blue_token_0']!;
      final redPlacement = placements['red_token_0']!;

      expect(bluePlacement.offset.dx, lessThan(0));
      expect(redPlacement.offset.dx, greaterThan(0));
      expect(bluePlacement.offset.dy, 0);
      expect(redPlacement.offset.dy, 0);
      expect(bluePlacement.dimensionScale, 0.78);
      expect(redPlacement.dimensionScale, 0.78);
    });

    test('uses deterministic placement regardless of input ordering', () {
      final firstLayout = TokenStackLayout.placementsFor(
        tokenIds: const [
          'red_token_0',
          'green_token_0',
          'blue_token_0',
          'yellow_token_0',
        ],
        cellSize: 40,
      );

      final reorderedLayout = TokenStackLayout.placementsFor(
        tokenIds: const [
          'yellow_token_0',
          'blue_token_0',
          'red_token_0',
          'green_token_0',
        ],
        cellSize: 40,
      );

      expect(reorderedLayout, firstLayout);
    });

    test('arranges four tokens across four distinct offsets', () {
      final placements = TokenStackLayout.placementsFor(
        tokenIds: const [
          'red_token_0',
          'green_token_0',
          'blue_token_0',
          'yellow_token_0',
        ],
        cellSize: 40,
      );

      final offsets = placements.values
          .map((placement) => placement.offset)
          .toSet();

      expect(placements, hasLength(4));
      expect(offsets, hasLength(4));
      expect(
        placements.values.every(
          (placement) => placement.dimensionScale == 0.66,
        ),
        isTrue,
      );
    });

    test('centers a partially occupied final row', () {
      final placements = TokenStackLayout.placementsFor(
        tokenIds: const ['token_0', 'token_1', 'token_2', 'token_3', 'token_4'],
        cellSize: 40,
      );

      // With three columns, the last row contains two tokens. Their horizontal
      // offsets should remain balanced around the shared cell center.
      final fourthOffset = placements['token_3']!.offset;
      final fifthOffset = placements['token_4']!.offset;

      expect(fourthOffset.dx, lessThan(0));
      expect(fifthOffset.dx, greaterThan(0));
      expect(fourthOffset.dx.abs(), fifthOffset.dx.abs());
      expect(fourthOffset.dy, fifthOffset.dy);
    });

    test('supports larger presentation groups', () {
      final placements = TokenStackLayout.placementsFor(
        tokenIds: List.generate(12, (index) => 'token_$index'),
        cellSize: 40,
      );

      expect(placements, hasLength(12));
      expect(
        placements.values.every(
          (placement) => placement.dimensionScale == 0.44,
        ),
        isTrue,
      );
    });

    test('rejects duplicate token IDs', () {
      expect(
        () => TokenStackLayout.placementsFor(
          tokenIds: const ['red_token_0', 'red_token_0'],
          cellSize: 40,
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid cell sizes', () {
      expect(
        () => TokenStackLayout.placementsFor(
          tokenIds: const ['red_token_0'],
          cellSize: 0,
        ),
        throwsArgumentError,
      );

      expect(
        () => TokenStackLayout.placementsFor(
          tokenIds: const ['red_token_0'],
          cellSize: double.infinity,
        ),
        throwsArgumentError,
      );
    });
  });
}
