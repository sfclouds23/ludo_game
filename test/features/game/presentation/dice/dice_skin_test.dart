import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/presentation/dice/dice_skin.dart';

void main() {
  group('DiceSkin', () {
    test('provides a stable classic cosmetic identity', () {
      const skin = DiceSkin.classicIvory;

      expect(skin.id, 'classic_ivory');
      expect(skin.displayName, 'Classic Ivory');
      expect(skin.rendererId, 'classic_3d');
    });

    test('contains independent visual color roles', () {
      const skin = DiceSkin.classicIvory;

      expect(skin.primaryFaceColor, isNot(skin.shadedFaceColor));
      expect(skin.secondaryFaceColor, isNot(skin.edgeColor));
      expect(skin.pipColor, isNot(skin.primaryFaceColor));
    });

    test('supports value equality', () {
      const first = DiceSkin.classicIvory;
      const second = DiceSkin(
        id: 'classic_ivory',
        displayName: 'Classic Ivory',
        rendererId: 'classic_3d',
        primaryFaceColor: Color(0xFFFFFFFF),
        secondaryFaceColor: Color(0xFFF3EDE3),
        shadedFaceColor: Color(0xFFC9BAA8),
        edgeColor: Color(0xFF29252E),
        pipColor: Color(0xFF211D25),
        pipHighlightColor: Color(0x66FFFFFF),
        shadowColor: Color(0x52000000),
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('provides a readable string representation', () {
      expect(
        DiceSkin.classicIvory.toString(),
        'DiceSkin('
        'id: classic_ivory, '
        'displayName: Classic Ivory, '
        'rendererId: classic_3d'
        ')',
      );
    });

    test('rejects an empty cosmetic ID', () {
      expect(
        () => DiceSkin(
          id: '',
          displayName: 'Invalid',
          rendererId: 'classic_3d',
          primaryFaceColor: const Color(0xFFFFFFFF),
          secondaryFaceColor: const Color(0xFFFFFFFF),
          shadedFaceColor: const Color(0xFFFFFFFF),
          edgeColor: const Color(0xFF000000),
          pipColor: const Color(0xFF000000),
          pipHighlightColor: const Color(0xFFFFFFFF),
          shadowColor: const Color(0xFF000000),
        ),
        throwsAssertionError,
      );
    });

    test('rejects an empty display name', () {
      expect(
        () => DiceSkin(
          id: 'invalid',
          displayName: '',
          rendererId: 'classic_3d',
          primaryFaceColor: const Color(0xFFFFFFFF),
          secondaryFaceColor: const Color(0xFFFFFFFF),
          shadedFaceColor: const Color(0xFFFFFFFF),
          edgeColor: const Color(0xFF000000),
          pipColor: const Color(0xFF000000),
          pipHighlightColor: const Color(0xFFFFFFFF),
          shadowColor: const Color(0xFF000000),
        ),
        throwsAssertionError,
      );
    });

    test('rejects an empty renderer ID', () {
      expect(
        () => DiceSkin(
          id: 'invalid',
          displayName: 'Invalid',
          rendererId: '',
          primaryFaceColor: const Color(0xFFFFFFFF),
          secondaryFaceColor: const Color(0xFFFFFFFF),
          shadedFaceColor: const Color(0xFFFFFFFF),
          edgeColor: const Color(0xFF000000),
          pipColor: const Color(0xFF000000),
          pipHighlightColor: const Color(0xFFFFFFFF),
          shadowColor: const Color(0xFF000000),
        ),
        throwsAssertionError,
      );
    });
  });
}
