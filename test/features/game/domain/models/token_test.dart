import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';

void main() {
  group('Token', () {
    test('stores stable identity, owner and logical position', () {
      const token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.yard(),
      );

      expect(token.id, 'red_token_0');
      expect(token.ownerColor, PlayerColor.red);
      expect(token.position, const TokenPosition.yard());
    });

    test('can represent token occupying the player start cell', () {
      final token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.onPath(0),
      );

      expect(token.position.isInYard, isFalse);
      expect(token.position.progress, 0);
      expect(token.position.isOnMainTrack, isTrue);
    });

    test('can represent token inside the private home lane', () {
      final token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.onPath(53),
      );

      expect(token.position.isInHomeLane, isTrue);
      expect(token.position.isFinished, isFalse);
    });

    test('can represent finished token', () {
      final token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.onPath(56),
      );

      expect(token.position.isFinished, isTrue);
    });

    group('copyWith', () {
      test('creates updated token without mutating original token', () {
        const original = Token(
          id: 'red_token_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.yard(),
        );

        final moved = original.copyWith(position: TokenPosition.onPath(0));

        // Original immutable state remains unchanged.
        expect(original.position, const TokenPosition.yard());

        // Replacement state contains the new logical position.
        expect(moved.position.progress, 0);
        expect(moved.position.isOnMainTrack, isTrue);

        // Identity and ownership remain unchanged.
        expect(moved.id, original.id);
        expect(moved.ownerColor, original.ownerColor);
      });

      test('can preserve every property when nothing is supplied', () {
        final original = Token(
          id: 'yellow_token_2',
          ownerColor: PlayerColor.yellow,
          position: TokenPosition.onPath(25),
        );

        final copied = original.copyWith();

        expect(copied, original);
      });
    });

    group('equality', () {
      test('tokens with identical values are equal', () {
        const first = Token(
          id: 'blue_token_1',
          ownerColor: PlayerColor.blue,
          position: TokenPosition.yard(),
        );

        const second = Token(
          id: 'blue_token_1',
          ownerColor: PlayerColor.blue,
          position: TokenPosition.yard(),
        );

        expect(first, second);
      });

      test('tokens with different identities are not equal', () {
        const first = Token(
          id: 'green_token_0',
          ownerColor: PlayerColor.green,
          position: TokenPosition.yard(),
        );

        const second = Token(
          id: 'green_token_1',
          ownerColor: PlayerColor.green,
          position: TokenPosition.yard(),
        );

        expect(first, isNot(second));
      });

      test('same token identity at different position is different state', () {
        const yardToken = Token(
          id: 'red_token_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.yard(),
        );

        final activeToken = Token(
          id: 'red_token_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.onPath(0),
        );

        expect(yardToken, isNot(activeToken));
      });
    });
  });
}
