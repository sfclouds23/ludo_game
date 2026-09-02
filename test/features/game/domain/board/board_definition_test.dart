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

      test('translation wraps around circular main track', () {
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

    group('complete circular player views', () {
      test('creates a 52-cell main-track view for every player', () {
        for (final playerColor in PlayerColor.values) {
          final path = BoardDefinition.mainTrackFor(playerColor);

          expect(path.playerColor, playerColor);

          expect(path.length, BoardDefinition.mainTrackCellCount);
        }
      });

      test('each circular view starts at player start cell', () {
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

    group('home lanes', () {
      test('creates five private home-lane cells for every player', () {
        for (final playerColor in PlayerColor.values) {
          final homeLane = BoardDefinition.homeLaneFor(playerColor);

          expect(homeLane.length, BoardDefinition.homeLaneCellCount);

          for (final cell in homeLane) {
            expect(cell.type, BoardCellType.homeLane);
          }
        }
      });

      test('creates deterministic red home-lane identifiers', () {
        final homeLane = BoardDefinition.homeLaneFor(PlayerColor.red);

        expect(homeLane.first.id, 'red_home_lane_0');

        expect(homeLane.last.id, 'red_home_lane_4');
      });

      test('keeps different player home lanes logically separate', () {
        final redHomeLane = BoardDefinition.homeLaneFor(PlayerColor.red);

        final greenHomeLane = BoardDefinition.homeLaneFor(PlayerColor.green);

        expect(redHomeLane.first, isNot(greenHomeLane.first));

        expect(redHomeLane.first.id, 'red_home_lane_0');

        expect(greenHomeLane.first.id, 'green_home_lane_0');
      });
    });

    group('finish cells', () {
      test('creates one player-specific finish cell per color', () {
        for (final playerColor in PlayerColor.values) {
          final finish = BoardDefinition.finishCellFor(playerColor);

          expect(finish.type, BoardCellType.finish);

          expect(finish.id, '${playerColor.name}_finish');
        }
      });

      test('different players do not share finish cells', () {
        expect(
          BoardDefinition.finishCellFor(PlayerColor.red),
          isNot(BoardDefinition.finishCellFor(PlayerColor.green)),
        );
      });
    });

    group('safe cells', () {
      test('contains all four player starting positions', () {
        expect(
          BoardDefinition.safeMainTrackIndices,
          containsAll([0, 13, 26, 39]),
        );
      });

      test('contains the four additional protected positions', () {
        expect(
          BoardDefinition.safeMainTrackIndices,
          containsAll([8, 21, 34, 47]),
        );
      });

      test('contains eight protected shared-track positions', () {
        expect(BoardDefinition.safeMainTrackIndices.length, 8);
      });

      test('recognizes player starts as safe', () {
        expect(
          BoardDefinition.isSafeCell(BoardDefinition.mainTrackCells[0]),
          isTrue,
        );

        expect(
          BoardDefinition.isSafeCell(BoardDefinition.mainTrackCells[13]),
          isTrue,
        );

        expect(
          BoardDefinition.isSafeCell(BoardDefinition.mainTrackCells[26]),
          isTrue,
        );

        expect(
          BoardDefinition.isSafeCell(BoardDefinition.mainTrackCells[39]),
          isTrue,
        );
      });

      test('recognizes additional safe main-track cells', () {
        expect(
          BoardDefinition.isSafeCell(BoardDefinition.mainTrackCells[8]),
          isTrue,
        );

        expect(
          BoardDefinition.isSafeCell(BoardDefinition.mainTrackCells[21]),
          isTrue,
        );
      });

      test('recognizes ordinary shared-track cells as unsafe', () {
        expect(
          BoardDefinition.isSafeCell(BoardDefinition.mainTrackCells[1]),
          isFalse,
        );

        expect(
          BoardDefinition.isSafeCell(BoardDefinition.mainTrackCells[12]),
          isFalse,
        );
      });

      test('treats private home-lane cells as safe', () {
        final homeCell = BoardDefinition.homeLaneFor(PlayerColor.red).first;

        expect(BoardDefinition.isSafeCell(homeCell), isTrue);
      });

      test('treats finish cells as safe', () {
        final finishCell = BoardDefinition.finishCellFor(PlayerColor.red);

        expect(BoardDefinition.isSafeCell(finishCell), isTrue);
      });
    });

    group('complete movement paths', () {
      test('maps player-relative progress 0 through 56 to correct path sections', () {
        for (final playerColor in PlayerColor.values) {
          final path = BoardDefinition.movementPathFor(playerColor);

          // Progress 0 is the player's shared-track start position.
          // A token still in the yard/base is represented separately and must not
          // be confused with progress 0.
          expect(path.cellAt(0).type, BoardCellType.mainPath);

          // Progress 50 is the player's final shared-track position before the
          // token enters its private home lane.
          expect(path.cellAt(50).type, BoardCellType.mainPath);

          // Progress 51 through 55 represents the five private home-lane cells.
          for (int progress = 51; progress <= 55; progress++) {
            expect(path.cellAt(progress).type, BoardCellType.homeLane);
          }

          // Progress 56 is the player's final logical finish position.
          expect(path.cellAt(56).type, BoardCellType.finish);

          // Progress outside the defined 0-56 movement range is invalid.
          expect(() => path.cellAt(-1), throwsRangeError);

          expect(() => path.cellAt(57), throwsRangeError);
        }
      });
      test('creates deterministic 57-position path for every player', () {
        for (final playerColor in PlayerColor.values) {
          final path = BoardDefinition.movementPathFor(playerColor);

          expect(path.playerColor, playerColor);

          expect(path.length, BoardDefinition.playerPathCellCount);

          expect(path.length, 57);
        }
      });

      test('every movement path begins at that player start cell', () {
        expect(
          BoardDefinition.movementPathFor(PlayerColor.red).cellAt(0).id,
          'main_0',
        );

        expect(
          BoardDefinition.movementPathFor(PlayerColor.green).cellAt(0).id,
          'main_13',
        );

        expect(
          BoardDefinition.movementPathFor(PlayerColor.yellow).cellAt(0).id,
          'main_26',
        );

        expect(
          BoardDefinition.movementPathFor(PlayerColor.blue).cellAt(0).id,
          'main_39',
        );
      });

      test('shared movement section contains exactly 51 cells', () {
        final path = BoardDefinition.movementPathFor(PlayerColor.red);

        for (
          int index = 0;
          index < BoardDefinition.playerMainTrackCellCount;
          index++
        ) {
          expect(path.cellAt(index).type, BoardCellType.mainPath);
        }

        expect(
          path.cellAt(BoardDefinition.playerMainTrackCellCount).type,
          BoardCellType.homeLane,
        );
      });

      test('red enters its private home lane after main_50', () {
        final path = BoardDefinition.movementPathFor(PlayerColor.red);

        expect(
          path.cellAt(BoardDefinition.playerMainTrackCellCount - 1).id,
          'main_50',
        );

        expect(
          path.cellAt(BoardDefinition.playerMainTrackCellCount).id,
          'red_home_lane_0',
        );
      });

      test('green enters its private home lane after main_11', () {
        final path = BoardDefinition.movementPathFor(PlayerColor.green);

        expect(
          path.cellAt(BoardDefinition.playerMainTrackCellCount - 1).id,
          'main_11',
        );

        expect(
          path.cellAt(BoardDefinition.playerMainTrackCellCount).id,
          'green_home_lane_0',
        );
      });

      test('yellow enters its private home lane after main_24', () {
        final path = BoardDefinition.movementPathFor(PlayerColor.yellow);

        expect(
          path.cellAt(BoardDefinition.playerMainTrackCellCount - 1).id,
          'main_24',
        );

        expect(
          path.cellAt(BoardDefinition.playerMainTrackCellCount).id,
          'yellow_home_lane_0',
        );
      });

      test('blue enters its private home lane after main_37', () {
        final path = BoardDefinition.movementPathFor(PlayerColor.blue);

        expect(
          path.cellAt(BoardDefinition.playerMainTrackCellCount - 1).id,
          'main_37',
        );

        expect(
          path.cellAt(BoardDefinition.playerMainTrackCellCount).id,
          'blue_home_lane_0',
        );
      });

      test('every movement path ends at player finish cell', () {
        for (final playerColor in PlayerColor.values) {
          final path = BoardDefinition.movementPathFor(playerColor);

          expect(
            path.cellAt(path.length - 1),
            BoardDefinition.finishCellFor(playerColor),
          );
        }
      });

      test('player path never loops back onto own start cell', () {
        for (final playerColor in PlayerColor.values) {
          final path = BoardDefinition.movementPathFor(playerColor);

          final startCell = path.cellAt(0);

          final remainingCells = path.cells.skip(1);

          expect(remainingCells, isNot(contains(startCell)));
        }
      });
    });

    group('invalid progress', () {
      test('rejects negative main-track progress', () {
        expect(
          () => BoardDefinition.mainTrackCellAt(PlayerColor.red, -1),
          throwsRangeError,
        );
      });

      test('rejects progress beyond complete shared track', () {
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
