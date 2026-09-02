import 'dart:ui';

import '../../domain/board/token_cell_resolver.dart';
import '../../domain/models/player_color.dart';
import '../../domain/models/token.dart';
import 'board_coordinate_mapper.dart';
import 'board_geometry.dart';

/// Maps logical token state to responsive presentation coordinates.
///
/// This mapper performs visual translation only. It does not mutate tokens,
/// validate moves, calculate dice results, perform captures, or control
/// animation timing.
class TokenCoordinateMapper {
  const TokenCoordinateMapper._();

  /// Number of reserved token positions inside each player's yard.
  static const int yardSlotCount = 4;

  /// Yard-slot centers measured in normalized 15 × 15 grid units.
  ///
  /// Unlike movement-path positions, these coordinates sit at intersections
  /// inside the larger yard areas rather than at normal track-cell centers.
  static const Map<PlayerColor, List<Offset>> yardSlotGridCenters = {
    PlayerColor.red: [Offset(2, 2), Offset(4, 2), Offset(2, 4), Offset(4, 4)],
    PlayerColor.green: [
      Offset(11, 2),
      Offset(13, 2),
      Offset(11, 4),
      Offset(13, 4),
    ],
    PlayerColor.yellow: [
      Offset(11, 11),
      Offset(13, 11),
      Offset(11, 13),
      Offset(13, 13),
    ],
    PlayerColor.blue: [
      Offset(2, 11),
      Offset(4, 11),
      Offset(2, 13),
      Offset(4, 13),
    ],
  };

  /// Returns the responsive pixel center for [token].
  ///
  /// [yardSlotIndex] is required only while the token remains in its yard.
  /// The renderer supplies this presentation index independently of logical
  /// movement progress.
  static Offset centerFor({
    required Token token,
    required BoardGeometry geometry,
    int? yardSlotIndex,
  }) {
    if (token.position.isInYard) {
      if (yardSlotIndex == null) {
        throw ArgumentError.notNull('yardSlotIndex');
      }

      return yardCenterFor(
        playerColor: token.ownerColor,
        slotIndex: yardSlotIndex,
        geometry: geometry,
      );
    }

    final boardCell = TokenCellResolver.resolve(token);

    // Every non-yard token must resolve to one logical movement-path cell.
    if (boardCell == null) {
      throw StateError(
        'A token outside the yard must resolve to a logical board cell.',
      );
    }

    return BoardCoordinateMapper.pixelCenterFor(boardCell, geometry);
  }

  /// Returns one responsive yard-slot center for [playerColor].
  static Offset yardCenterFor({
    required PlayerColor playerColor,
    required int slotIndex,
    required BoardGeometry geometry,
  }) {
    if (slotIndex < 0 || slotIndex >= yardSlotCount) {
      throw RangeError.range(
        slotIndex,
        0,
        yardSlotCount - 1,
        'slotIndex',
        'Yard slot index must identify one of the four reserved positions.',
      );
    }

    final normalizedCenter = yardSlotGridCenters[playerColor]![slotIndex];

    return Offset(
      normalizedCenter.dx * geometry.cellSize,
      normalizedCenter.dy * geometry.cellSize,
    );
  }
}
