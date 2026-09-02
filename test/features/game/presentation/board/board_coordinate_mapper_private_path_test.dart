import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/board/board_definition.dart';
import 'package:ludo_game/features/game/domain/models/board_cell.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/presentation/board/board_coordinate_mapper.dart';
import 'package:ludo_game/features/game/presentation/board/board_geometry.dart';
import 'package:ludo_game/features/game/presentation/board/board_grid_position.dart';

void main() {
  group('BoardCoordinateMapper private paths', () {
    test('maps every player home lane toward the board center', () {
      const expectedPositions = {
        PlayerColor.red: [
          BoardGridPosition(row: 7, column: 1),
          BoardGridPosition(row: 7, column: 2),
          BoardGridPosition(row: 7, column: 3),
          BoardGridPosition(row: 7, column: 4),
          BoardGridPosition(row: 7, column: 5),
        ],
        PlayerColor.green: [
          BoardGridPosition(row: 1, column: 7),
          BoardGridPosition(row: 2, column: 7),
          BoardGridPosition(row: 3, column: 7),
          BoardGridPosition(row: 4, column: 7),
          BoardGridPosition(row: 5, column: 7),
        ],
        PlayerColor.yellow: [
          BoardGridPosition(row: 7, column: 13),
          BoardGridPosition(row: 7, column: 12),
          BoardGridPosition(row: 7, column: 11),
          BoardGridPosition(row: 7, column: 10),
          BoardGridPosition(row: 7, column: 9),
        ],
        PlayerColor.blue: [
          BoardGridPosition(row: 13, column: 7),
          BoardGridPosition(row: 12, column: 7),
          BoardGridPosition(row: 11, column: 7),
          BoardGridPosition(row: 10, column: 7),
          BoardGridPosition(row: 9, column: 7),
        ],
      };

      for (final entry in expectedPositions.entries) {
        final logicalLane = BoardDefinition.homeLaneFor(entry.key);
        final mappedLane = logicalLane
            .map(BoardCoordinateMapper.gridPositionFor)
            .toList();

        expect(mappedLane, entry.value);
      }
    });

    test('maps every player finish cell to the board center', () {
      for (final playerColor in PlayerColor.values) {
        final finishCell = BoardDefinition.finishCellFor(playerColor);

        expect(
          BoardCoordinateMapper.gridPositionFor(finishCell),
          BoardCoordinateMapper.finishPosition,
        );
      }
    });

    test('generic mapper continues to support main-track cells', () {
      final mainCell = BoardDefinition.mainTrackCells.first;

      expect(
        BoardCoordinateMapper.gridPositionFor(mainCell),
        const BoardGridPosition(row: 6, column: 1),
      );
    });

    test('scales private-path pixel centers responsively', () {
      final homeLaneCell = BoardDefinition.homeLaneFor(PlayerColor.yellow)
          .first;

      final smallCenter = BoardCoordinateMapper.pixelCenterFor(
        homeLaneCell,
        BoardGeometry(300),
      );
      final largeCenter = BoardCoordinateMapper.pixelCenterFor(
        homeLaneCell,
        BoardGeometry(600),
      );

      expect(largeCenter, smallCenter * 2);
    });

    test('rejects yard cells without token-slot coordinates', () {
      const yardCell = BoardCell(id: 'red_home', type: BoardCellType.home);

      expect(
        () => BoardCoordinateMapper.gridPositionFor(yardCell),
        throwsUnsupportedError,
      );
    });

    test('rejects an invalid home-lane identifier', () {
      const invalidCell = BoardCell(
        id: 'red_home_lane_5',
        type: BoardCellType.homeLane,
      );

      expect(
        () => BoardCoordinateMapper.gridPositionFor(invalidCell),
        throwsArgumentError,
      );
    });

    test('rejects an invalid finish identifier', () {
      const invalidCell = BoardCell(
        id: 'purple_finish',
        type: BoardCellType.finish,
      );

      expect(
        () => BoardCoordinateMapper.gridPositionFor(invalidCell),
        throwsArgumentError,
      );
    });
  });
}
