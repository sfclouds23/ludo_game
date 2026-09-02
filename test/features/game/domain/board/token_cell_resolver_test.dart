import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/board/token_cell_resolver.dart';
import 'package:ludo_game/features/game/domain/models/board_cell.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/domain/models/token.dart';
import 'package:ludo_game/features/game/domain/models/token_position.dart';

void main() {
  group('TokenCellResolver', () {
    test('returns null for a token still in the yard', () {
      const token = Token(
        id: 'red_token_0',
        ownerColor: PlayerColor.red,
        position: TokenPosition.yard(),
      );

      final cell = TokenCellResolver.resolve(token);

      expect(cell, isNull);
    });

    group('player start cells', () {
      test('resolves red progress 0 to main_0', () {
        final token = Token(
          id: 'red_token_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.onPath(0),
        );

        final cell = TokenCellResolver.resolve(token);

        expect(
          cell,
          const BoardCell(id: 'main_0', type: BoardCellType.mainPath),
        );
      });

      test('resolves green progress 0 to main_13', () {
        final token = Token(
          id: 'green_token_0',
          ownerColor: PlayerColor.green,
          position: TokenPosition.onPath(0),
        );

        final cell = TokenCellResolver.resolve(token);

        expect(cell?.id, 'main_13');
        expect(cell?.type, BoardCellType.mainPath);
      });

      test('resolves yellow progress 0 to main_26', () {
        final token = Token(
          id: 'yellow_token_0',
          ownerColor: PlayerColor.yellow,
          position: TokenPosition.onPath(0),
        );

        final cell = TokenCellResolver.resolve(token);

        expect(cell?.id, 'main_26');
        expect(cell?.type, BoardCellType.mainPath);
      });

      test('resolves blue progress 0 to main_39', () {
        final token = Token(
          id: 'blue_token_0',
          ownerColor: PlayerColor.blue,
          position: TokenPosition.onPath(0),
        );

        final cell = TokenCellResolver.resolve(token);

        expect(cell?.id, 'main_39');
        expect(cell?.type, BoardCellType.mainPath);
      });
    });

    group('shared main track', () {
      test('resolves player-relative progress through board definition', () {
        final redToken = Token(
          id: 'red_token_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.onPath(13),
        );

        final greenToken = Token(
          id: 'green_token_0',
          ownerColor: PlayerColor.green,
          position: TokenPosition.onPath(0),
        );

        final redCell = TokenCellResolver.resolve(redToken);
        final greenCell = TokenCellResolver.resolve(greenToken);

        // Different player-relative progress values may refer to the same
        // shared logical board cell.
        expect(redCell, greenCell);
        expect(redCell?.id, 'main_13');
      });

      test('resolves progress 50 to final shared-track cell', () {
        final redToken = Token(
          id: 'red_token_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.onPath(50),
        );

        final cell = TokenCellResolver.resolve(redToken);

        expect(cell?.id, 'main_50');
        expect(cell?.type, BoardCellType.mainPath);
      });
    });

    group('private home lane', () {
      test('resolves progress 51 to first private home-lane cell', () {
        final token = Token(
          id: 'red_token_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.onPath(51),
        );

        final cell = TokenCellResolver.resolve(token);

        expect(cell?.id, 'red_home_lane_0');
        expect(cell?.type, BoardCellType.homeLane);
      });

      test('resolves progress 55 to final private home-lane cell', () {
        final token = Token(
          id: 'blue_token_0',
          ownerColor: PlayerColor.blue,
          position: TokenPosition.onPath(55),
        );

        final cell = TokenCellResolver.resolve(token);

        expect(cell?.id, 'blue_home_lane_4');
        expect(cell?.type, BoardCellType.homeLane);
      });

      test('keeps different player home lanes separate', () {
        final redToken = Token(
          id: 'red_token_0',
          ownerColor: PlayerColor.red,
          position: TokenPosition.onPath(51),
        );

        final greenToken = Token(
          id: 'green_token_0',
          ownerColor: PlayerColor.green,
          position: TokenPosition.onPath(51),
        );

        final redCell = TokenCellResolver.resolve(redToken);
        final greenCell = TokenCellResolver.resolve(greenToken);

        expect(redCell?.id, 'red_home_lane_0');
        expect(greenCell?.id, 'green_home_lane_0');
        expect(redCell, isNot(greenCell));
      });
    });

    group('finish', () {
      test('resolves progress 56 to player finish cell', () {
        for (final playerColor in PlayerColor.values) {
          final token = Token(
            id: '${playerColor.name}_token_0',
            ownerColor: playerColor,
            position: TokenPosition.onPath(56),
          );

          final cell = TokenCellResolver.resolve(token);

          expect(cell?.id, '${playerColor.name}_finish');

          expect(cell?.type, BoardCellType.finish);
        }
      });
    });

    test('resolves every valid progress value for every player', () {
      for (final playerColor in PlayerColor.values) {
        for (
          int progress = TokenPosition.minimumPathProgress;
          progress <= TokenPosition.maximumPathProgress;
          progress++
        ) {
          final token = Token(
            id: '${playerColor.name}_token_0',
            ownerColor: playerColor,
            position: TokenPosition.onPath(progress),
          );

          final cell = TokenCellResolver.resolve(token);

          expect(
            cell,
            isNotNull,
            reason: '${playerColor.name} progress $progress must resolve.',
          );
        }
      }
    });
  });
}
