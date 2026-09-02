import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/board/player_path.dart';
import 'package:ludo_game/features/game/domain/models/board_cell.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';

void main() {
  group('PlayerPath', () {
    // Small deterministic path used only to verify PlayerPath behavior.
    const firstCell = BoardCell(id: 'main_0', type: BoardCellType.mainPath);

    const secondCell = BoardCell(id: 'main_1', type: BoardCellType.mainPath);

    const path = PlayerPath(
      playerColor: PlayerColor.red,
      cells: [firstCell, secondCell],
    );

    test('stores the player color', () {
      expect(path.playerColor, PlayerColor.red);
    });

    test('returns the correct cell for player-relative progress', () {
      expect(path.cellAt(0), firstCell);
      expect(path.cellAt(1), secondCell);
    });

    test('reports the correct path length', () {
      expect(path.length, 2);
    });

    test('throws when progress is below zero', () {
      expect(() => path.cellAt(-1), throwsRangeError);
    });

    test('throws when progress exceeds the path', () {
      expect(() => path.cellAt(2), throwsRangeError);
    });
  });
}
