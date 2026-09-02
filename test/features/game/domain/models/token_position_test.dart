import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';

void main() {
  group('TokenPosition', () {
    group('yard', () {
      test('represents yard separately from path progress', () {
        const position = TokenPosition.yard();

        expect(position.isInYard, isTrue);
        expect(position.isOnPath, isFalse);
        expect(position.progress, isNull);
      });

      test('yard is not considered main track', () {
        const position = TokenPosition.yard();

        expect(position.isOnMainTrack, isFalse);
      });

      test('yard is not considered home lane', () {
        const position = TokenPosition.yard();

        expect(position.isInHomeLane, isFalse);
      });

      test('yard is not considered finished', () {
        const position = TokenPosition.yard();

        expect(position.isFinished, isFalse);
      });
    });

    group('shared main track', () {
      test('progress 0 represents the player start cell', () {
        final position = TokenPosition.onPath(0);

        expect(position.isInYard, isFalse);
        expect(position.isOnPath, isTrue);
        expect(position.progress, 0);
        expect(position.isOnMainTrack, isTrue);
        expect(position.isInHomeLane, isFalse);
        expect(position.isFinished, isFalse);
      });

      test('progress 50 is the final shared-track progress', () {
        final position = TokenPosition.onPath(50);

        expect(position.isOnMainTrack, isTrue);
        expect(position.isInHomeLane, isFalse);
        expect(position.isFinished, isFalse);
      });
    });

    group('private home lane', () {
      test('progress 51 is the first private home-lane position', () {
        final position = TokenPosition.onPath(51);

        expect(position.isOnMainTrack, isFalse);
        expect(position.isInHomeLane, isTrue);
        expect(position.isFinished, isFalse);
      });

      test('progress 55 is the final private home-lane position', () {
        final position = TokenPosition.onPath(55);

        expect(position.isOnMainTrack, isFalse);
        expect(position.isInHomeLane, isTrue);
        expect(position.isFinished, isFalse);
      });

      test('all progress values 51 through 55 are home-lane positions', () {
        for (int progress = 51; progress <= 55; progress++) {
          final position = TokenPosition.onPath(progress);

          expect(
            position.isInHomeLane,
            isTrue,
            reason: 'Progress $progress should belong to the home lane.',
          );
        }
      });
    });

    group('finish', () {
      test('progress 56 represents token completion', () {
        final position = TokenPosition.onPath(56);

        expect(position.isOnMainTrack, isFalse);
        expect(position.isInHomeLane, isFalse);
        expect(position.isFinished, isTrue);
      });
    });

    group('validation', () {
      test('rejects progress below zero', () {
        expect(() => TokenPosition.onPath(-1), throwsRangeError);
      });

      test('rejects progress above 56', () {
        expect(() => TokenPosition.onPath(57), throwsRangeError);
      });

      test('accepts every valid progress value from 0 through 56', () {
        for (
          int progress = TokenPosition.minimumPathProgress;
          progress <= TokenPosition.maximumPathProgress;
          progress++
        ) {
          expect(
            () => TokenPosition.onPath(progress),
            returnsNormally,
            reason: 'Progress $progress should be valid.',
          );
        }
      });
    });

    group('equality', () {
      test('two yard positions are equal', () {
        const first = TokenPosition.yard();
        const second = TokenPosition.yard();

        expect(first, second);
      });

      test('two positions with the same progress are equal', () {
        final first = TokenPosition.onPath(12);
        final second = TokenPosition.onPath(12);

        expect(first, second);
      });

      test('positions with different progress are not equal', () {
        expect(TokenPosition.onPath(12), isNot(TokenPosition.onPath(13)));
      });

      test('yard is not equal to path progress 0', () {
        expect(const TokenPosition.yard(), isNot(TokenPosition.onPath(0)));
      });
    });
  });
}
