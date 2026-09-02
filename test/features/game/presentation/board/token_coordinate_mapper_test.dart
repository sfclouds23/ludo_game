import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';
import 'package:ludo_game/features/game/presentation/board/board_geometry.dart';
import 'package:ludo_game/features/game/presentation/board/token_coordinate_mapper.dart';

void main() {
  group('TokenCoordinateMapper yard positions', () {
    test('maps all four red yard slots', () {
      final geometry = BoardGeometry(300);

      expect(
        TokenCoordinateMapper.yardCenterFor(
          playerColor: PlayerColor.red,
          slotIndex: 0,
          geometry: geometry,
        ),
        const Offset(40, 40),
      );
      expect(
        TokenCoordinateMapper.yardCenterFor(
          playerColor: PlayerColor.red,
          slotIndex: 1,
          geometry: geometry,
        ),
        const Offset(80, 40),
      );
      expect(
        TokenCoordinateMapper.yardCenterFor(
          playerColor: PlayerColor.red,
          slotIndex: 2,
          geometry: geometry,
        ),
        const Offset(40, 80),
      );
      expect(
        TokenCoordinateMapper.yardCenterFor(
          playerColor: PlayerColor.red,
          slotIndex: 3,
          geometry: geometry,
        ),
        const Offset(80, 80),
      );
    });

    test('maps the first yard slot for every player', () {
      final geometry = BoardGeometry(300);

      const expectedCenters = {
        PlayerColor.red: Offset(40, 40),
        PlayerColor.green: Offset(220, 40),
        PlayerColor.yellow: Offset(220, 220),
        PlayerColor.blue: Offset(40, 220),
      };

      for (final entry in expectedCenters.entries) {
        expect(
          TokenCoordinateMapper.yardCenterFor(
            playerColor: entry.key,
            slotIndex: 0,
            geometry: geometry,
          ),
          entry.value,
        );
      }
    });

    test('scales yard coordinates responsively', () {
      final smallCenter = TokenCoordinateMapper.yardCenterFor(
        playerColor: PlayerColor.yellow,
        slotIndex: 3,
        geometry: BoardGeometry(300),
      );
      final largeCenter = TokenCoordinateMapper.yardCenterFor(
        playerColor: PlayerColor.yellow,
        slotIndex: 3,
        geometry: BoardGeometry(600),
      );

      expect(largeCenter, smallCenter * 2);
    });

    test('rejects a negative yard slot index', () {
      expect(
        () => TokenCoordinateMapper.yardCenterFor(
          playerColor: PlayerColor.red,
          slotIndex: -1,
          geometry: BoardGeometry(300),
        ),
        throwsRangeError,
      );
    });

    test('rejects a yard slot index beyond the fourth slot', () {
      expect(
        () => TokenCoordinateMapper.yardCenterFor(
          playerColor: PlayerColor.red,
          slotIndex: 4,
          geometry: BoardGeometry(300),
        ),
        throwsRangeError,
      );
    });
  });

  group('TokenCoordinateMapper token positions', () {
    test('maps a yard token using its presentation slot index', () {
      const token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.yard(),
      );

      expect(
        TokenCoordinateMapper.centerFor(
          token: token,
          yardSlotIndex: 2,
          geometry: BoardGeometry(300),
        ),
        const Offset(40, 80),
      );
    });

    test('requires a slot index for a yard token', () {
      const token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.yard(),
      );

      expect(
        () => TokenCoordinateMapper.centerFor(
          token: token,
          geometry: BoardGeometry(300),
        ),
        throwsArgumentError,
      );
    });

    test('maps a red token at its main-track start', () {
      final token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.onPath(0),
      );

      expect(
        TokenCoordinateMapper.centerFor(
          token: token,
          geometry: BoardGeometry(300),
        ),
        const Offset(30, 130),
      );
    });

    test('maps player-relative progress using the token owner', () {
      final token = Token(
        id: 'green_token_0',
        ownerColor: PlayerColor.green,
        position: TokenPosition.onPath(0),
      );

      expect(
        TokenCoordinateMapper.centerFor(
          token: token,
          geometry: BoardGeometry(300),
        ),
        const Offset(170, 30),
      );
    });

    test('maps a private home-lane position', () {
      final token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.onPath(TokenPosition.firstHomeLaneProgress),
      );

      expect(
        TokenCoordinateMapper.centerFor(
          token: token,
          geometry: BoardGeometry(300),
        ),
        const Offset(30, 150),
      );
    });

    test('maps a finished token to the board center', () {
      final token = Token(
        id: 'blue_token_0',
        ownerColor: PlayerColor.blue,
        position: TokenPosition.onPath(TokenPosition.finishProgress),
      );

      expect(
        TokenCoordinateMapper.centerFor(
          token: token,
          geometry: BoardGeometry(300),
        ),
        const Offset(150, 150),
      );
    });

    test('ignores yard slot index for a token on the movement path', () {
      final token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.onPath(0),
      );

      final withoutSlot = TokenCoordinateMapper.centerFor(
        token: token,
        geometry: BoardGeometry(300),
      );
      final withSlot = TokenCoordinateMapper.centerFor(
        token: token,
        yardSlotIndex: 3,
        geometry: BoardGeometry(300),
      );

      expect(withSlot, withoutSlot);
    });
  });
}
