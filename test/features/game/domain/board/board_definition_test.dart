import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/board/board_definition.dart';
import 'package:ludo_game/features/game/domain/models/board_cell.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';

void main() {
  group('BoardDefinition', () {
    group('main track', () {
      test('contains exactly 52 logical cells', () {
        expect(
          BoardDefinition.mainTrackCells.length,
          BoardDefinition.mainTrackCellCount,
        );
      });

      test('creates stable main-track cell identifiers', () {
        expect(
          BoardDefinition.mainTrackCells.first,
          const BoardCell(id: 'main_0', type: BoardCellType.mainPath),
        );

        expect(
          BoardDefinition.mainTrackCells.last,
          const BoardCell(id: 'main_51', type: BoardCellType.mainPath),
        );
      });
    });

    group('player start mappings', () {
      test('red starts at main track index 0', () {
        expect(BoardDefinition.startIndexFor(PlayerColor.red), 0);

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.red, 0).id,
          'main_0',
        );
      });

      test('green starts at main track index 13', () {
        expect(BoardDefinition.startIndexFor(PlayerColor.green), 13);

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.green, 0).id,
          'main_13',
        );
      });

      test('yellow starts at main track index 26', () {
        expect(BoardDefinition.startIndexFor(PlayerColor.yellow), 26);

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.yellow, 0).id,
          'main_26',
        );
      });

      test('blue starts at main track index 39', () {
        expect(BoardDefinition.startIndexFor(PlayerColor.blue), 39);

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.blue, 0).id,
          'main_39',
        );
      });
    });

    group('player-relative translation', () {
      test('red progress maps directly from main_0', () {
        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.red, 0).id,
          'main_0',
        );

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.red, 1).id,
          'main_1',
        );

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.red, 12).id,
          'main_12',
        );
      });

      test('green progress begins from main_13', () {
        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.green, 0).id,
          'main_13',
        );

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.green, 1).id,
          'main_14',
        );
      });

      test('yellow progress begins from main_26', () {
        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.yellow, 0).id,
          'main_26',
        );

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.yellow, 1).id,
          'main_27',
        );
      });

      test('blue progress begins from main_39', () {
        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.blue, 0).id,
          'main_39',
        );

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.blue, 1).id,
          'main_40',
        );
      });

      test('translation wraps around the circular main track', () {
        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.blue, 13).id,
          'main_0',
        );

        expect(
          BoardDefinition.mainTrackCellAt(PlayerColor.green, 39).id,
          'main_0',
        );
      });

      test(
        'different player-relative paths can reference same shared cell',
        () {
          final redCell = BoardDefinition.mainTrackCellAt(PlayerColor.red, 13);

          final greenCell = BoardDefinition.mainTrackCellAt(
            PlayerColor.green,
            0,
          );

          expect(redCell, greenCell);
          expect(redCell.id, 'main_13');
        },
      );
    });

    group('generated player paths', () {
      test('creates a 52-cell main-track path for every player', () {
        for (final playerColor in PlayerColor.values) {
          final path = BoardDefinition.mainTrackFor(playerColor);

          expect(path.playerColor, playerColor);
          expect(path.length, BoardDefinition.mainTrackCellCount);
        }
      });

      test('each generated path starts at the player start cell', () {
        expect(
          BoardDefinition.mainTrackFor(PlayerColor.red).cellAt(0).id,
          'main_0',
        );

        expect(
          BoardDefinition.mainTrackFor(PlayerColor.green).cellAt(0).id,
          'main_13',
        );

        expect(
          BoardDefinition.mainTrackFor(PlayerColor.yellow).cellAt(0).id,
          'main_26',
        );

        expect(
          BoardDefinition.mainTrackFor(PlayerColor.blue).cellAt(0).id,
          'main_39',
        );
      });
    });

    group('invalid progress', () {
      test('rejects negative main-track progress', () {
        expect(
          () => BoardDefinition.mainTrackCellAt(PlayerColor.red, -1),
          throwsRangeError,
        );
      });

      test('rejects progress beyond the shared main track', () {
        expect(
          () => BoardDefinition.mainTrackCellAt(
            PlayerColor.red,
            BoardDefinition.mainTrackCellCount,
          ),
          throwsRangeError,
        );
      });
    });
  });
}
