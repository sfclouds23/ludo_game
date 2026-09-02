import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/board/board_definition.dart';
import 'package:ludo_game/features/game/domain/models/board_cell.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/presentation/board/board_coordinate_mapper.dart';
import 'package:ludo_game/features/game/presentation/board/board_geometry.dart';
import 'package:ludo_game/features/game/presentation/board/board_grid_position.dart';

void main() {
  group('BoardCoordinateMapper main track', () {
    test('contains one visual position for every GAME-101 main cell', () {
      expect(
        BoardCoordinateMapper.mainTrackPositions,
        hasLength(BoardDefinition.mainTrackCellCount),
      );
    });

    test('maps all logical main cells to unique visual positions', () {
      final mappedPositions = BoardDefinition.mainTrackCells
          .map(BoardCoordinateMapper.gridPositionForMainTrack)
          .toSet();

      expect(mappedPositions, hasLength(BoardDefinition.mainTrackCellCount));
    });

    test('keeps consecutive main-track positions visually adjacent', () {
      final positions = BoardCoordinateMapper.mainTrackPositions;

      for (var index = 0; index < positions.length; index++) {
        final current = positions[index];
        final next = positions[(index + 1) % positions.length];

        final rowDistance = (current.row - next.row).abs();
        final columnDistance = (current.column - next.column).abs();

        expect(
          rowDistance <= 1 && columnDistance <= 1,
          isTrue,
          reason:
              'main_$index must be edge-adjacent or diagonally adjacent to '
              'main_${(index + 1) % positions.length}.',
        );
      }
    });

    test('maps player start cells to their visual starting positions', () {
      const expectedStarts = {
        PlayerColor.red: BoardGridPosition(row: 6, column: 1),
        PlayerColor.green: BoardGridPosition(row: 1, column: 8),
        PlayerColor.yellow: BoardGridPosition(row: 8, column: 13),
        PlayerColor.blue: BoardGridPosition(row: 13, column: 6),
      };

      for (final entry in expectedStarts.entries) {
        final startIndex = BoardDefinition.startIndexFor(entry.key);
        final startCell = BoardDefinition.mainTrackCells[startIndex];

        expect(
          BoardCoordinateMapper.gridPositionForMainTrack(startCell),
          entry.value,
        );
      }
    });

    test('maps additional safe cells to expected visual positions', () {
      const expectedSafePositions = {
        8: BoardGridPosition(row: 2, column: 6),
        21: BoardGridPosition(row: 6, column: 12),
        34: BoardGridPosition(row: 12, column: 8),
        47: BoardGridPosition(row: 8, column: 2),
      };

      for (final entry in expectedSafePositions.entries) {
        final safeCell = BoardDefinition.mainTrackCells[entry.key];

        expect(
          BoardCoordinateMapper.gridPositionForMainTrack(safeCell),
          entry.value,
        );
      }
    });

    test('scales a logical cell center with the board geometry', () {
      final cell = BoardDefinition.mainTrackCells.first;
      final smallGeometry = BoardGeometry(300);
      final largeGeometry = BoardGeometry(600);

      final smallCenter = BoardCoordinateMapper.pixelCenterForMainTrack(
        cell,
        smallGeometry,
      );
      final largeCenter = BoardCoordinateMapper.pixelCenterForMainTrack(
        cell,
        largeGeometry,
      );

      expect(largeCenter, smallCenter * 2);
    });

    test('rejects a non-main-track cell', () {
      final homeLaneCell = BoardDefinition.homeLaneFor(PlayerColor.red).first;

      expect(
        () => BoardCoordinateMapper.gridPositionForMainTrack(homeLaneCell),
        throwsArgumentError,
      );
    });

    test('rejects a malformed main-track identifier', () {
      const malformedCell = BoardCell(
        id: 'main_invalid',
        type: BoardCellType.mainPath,
      );

      expect(
        () => BoardCoordinateMapper.gridPositionForMainTrack(malformedCell),
        throwsArgumentError,
      );
    });

    test('rejects an out-of-range main-track identifier', () {
      const outOfRangeCell = BoardCell(
        id: 'main_52',
        type: BoardCellType.mainPath,
      );

      expect(
        () => BoardCoordinateMapper.gridPositionForMainTrack(outOfRangeCell),
        throwsArgumentError,
      );
    });
  });
}
