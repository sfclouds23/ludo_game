import 'package:flutter/material.dart';

import '../../domain/models/player_color.dart';
import '../../domain/models/token.dart';
import 'board_geometry.dart';
import 'ludo_token.dart';
import 'ludo_token_visual_state.dart';
import 'token_coordinate_mapper.dart';
import 'token_stack_layout.dart';

/// Positions dynamic Ludo tokens above the static board.
///
/// This layer reads immutable token state and converts it into presentation
/// coordinates. It displays caller-supplied selectability, arranges tokens
/// sharing a visual coordinate, and forwards token presses.
///
/// It does not determine legal moves, captures, blockades, dice results, or
/// whether multiple tokens are logically permitted to occupy a board cell.
class LudoTokenLayer extends StatelessWidget {
  /// Creates a token overlay for [tokens].
  const LudoTokenLayer({
    required this.tokens,
    this.visualStates = const {},
    this.onTokenPressed,
    super.key,
  });

  /// Key identifying the repaint boundary around the complete token layer.
  static const Key repaintBoundaryKey = ValueKey<String>(
    'ludo-token-layer-repaint-boundary',
  );

  /// Immutable logical tokens currently displayed on the board.
  final List<Token> tokens;

  /// Presentation-only state associated with each token ID.
  ///
  /// Tokens without an entry use [LudoTokenVisualState.idle]. The caller is
  /// responsible for deciding which tokens are movable or selected.
  final Map<String, LudoTokenVisualState> visualStates;

  /// Optional callback invoked with the pressed token's stable ID.
  ///
  /// This layer does not inspect [LudoTokenVisualState.isMovable] before
  /// forwarding a press. Legal-move enforcement belongs to the authoritative
  /// application or game-state layer.
  final ValueChanged<String>? onTokenPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.biggest.shortestSide;

        if (!boardSize.isFinite || boardSize <= 0) {
          return const SizedBox.shrink();
        }

        _validateUniqueTokenIds();

        final geometry = BoardGeometry(boardSize);
        final baseTokenDimension = geometry.cellSize * 1.35;
        final yardSlotIndices = _yardSlotIndices();
        final tokenCenters = _tokenCenters(
          geometry: geometry,
          yardSlotIndices: yardSlotIndices,
        );
        final stackPlacements = _stackPlacements(
          tokenCenters: tokenCenters,
          cellSize: geometry.cellSize,
        );
        final paintOrderedTokens = _paintOrderedTokens();

        return RepaintBoundary(
          key: repaintBoundaryKey,
          child: SizedBox.square(
            dimension: boardSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final token in paintOrderedTokens)
                  _positionedToken(
                    token: token,
                    center: tokenCenters[token.id]!,
                    baseTokenDimension: baseTokenDimension,
                    stackPlacement: stackPlacements[token.id]!,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Resolves the base visual center of every token.
  ///
  /// Yard tokens already receive separate deterministic yard-slot coordinates.
  /// Other co-located tokens resolve to the same center and are separated later
  /// by [TokenStackLayout].
  Map<String, Offset> _tokenCenters({
    required BoardGeometry geometry,
    required Map<String, int> yardSlotIndices,
  }) {
    final centers = <String, Offset>{};

    for (final token in tokens) {
      centers[token.id] = TokenCoordinateMapper.centerFor(
        token: token,
        geometry: geometry,
        yardSlotIndex: yardSlotIndices[token.id],
      );
    }

    return centers;
  }

  /// Creates deterministic visual placements for tokens sharing each center.
  ///
  /// Grouping by an already resolved presentation coordinate keeps this logic
  /// independent from occupancy, capture, blockade, and legal-move rules.
  Map<String, TokenStackPlacement> _stackPlacements({
    required Map<String, Offset> tokenCenters,
    required double cellSize,
  }) {
    final tokenIdsByCenter = <Offset, List<String>>{};

    for (final token in tokens) {
      final center = tokenCenters[token.id]!;

      tokenIdsByCenter.putIfAbsent(center, () => <String>[]).add(token.id);
    }

    final placements = <String, TokenStackPlacement>{};

    for (final tokenIds in tokenIdsByCenter.values) {
      placements.addAll(
        TokenStackLayout.placementsFor(tokenIds: tokenIds, cellSize: cellSize),
      );
    }

    return placements;
  }

  /// Returns tokens in deterministic back-to-front paint order.
  ///
  /// Stack offsets remain tied to sorted token IDs, while emphasized tokens
  /// paint later so their supplied state remains visible and tappable.
  List<Token> _paintOrderedTokens() {
    final orderedTokens = List<Token>.of(tokens);

    orderedTokens.sort((first, second) {
      final firstPriority = _paintPriorityFor(first.id);
      final secondPriority = _paintPriorityFor(second.id);
      final priorityComparison = firstPriority.compareTo(secondPriority);

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      return first.id.compareTo(second.id);
    });

    return orderedTokens;
  }

  /// Returns presentation z-order priority for a caller-supplied visual state.
  int _paintPriorityFor(String tokenId) {
    final visualState = visualStates[tokenId] ?? LudoTokenVisualState.idle;

    if (visualState.isSelected) {
      return 3;
    }

    if (visualState.isMoving) {
      return 2;
    }

    if (visualState.isMovable) {
      return 1;
    }

    return 0;
  }

  /// Creates one token widget at its responsive stacked coordinate.
  Widget _positionedToken({
    required Token token,
    required Offset center,
    required double baseTokenDimension,
    required TokenStackPlacement stackPlacement,
  }) {
    final visualState = visualStates[token.id] ?? LudoTokenVisualState.idle;
    final tokenDimension = baseTokenDimension * stackPlacement.dimensionScale;
    final stackedCenter = center + stackPlacement.offset;

    return Positioned(
      key: ValueKey<String>('ludo-token-position-${token.id}'),
      left: stackedCenter.dx - tokenDimension / 2,
      top: stackedCenter.dy - tokenDimension / 2,
      width: tokenDimension,
      height: tokenDimension,
      child: LudoToken(
        tokenId: token.id,
        playerColor: token.ownerColor,
        dimension: tokenDimension,
        visualState: visualState,
        isInYard: token.position.isInYard,
        isFinished: token.position.isFinished,
        onPressed: onTokenPressed == null
            ? null
            : () {
                onTokenPressed!(token.id);
              },
      ),
    );
  }

  /// Assigns deterministic presentation slots to tokens still in each yard.
  ///
  /// Token IDs are sorted so input-list ordering cannot move yard tokens
  /// between visual slots.
  Map<String, int> _yardSlotIndices() {
    final slotIndices = <String, int>{};

    for (final playerColor in PlayerColor.values) {
      final yardTokens =
          tokens
              .where(
                (token) =>
                    token.ownerColor == playerColor && token.position.isInYard,
              )
              .toList()
            ..sort((first, second) => first.id.compareTo(second.id));

      if (yardTokens.length > TokenCoordinateMapper.yardSlotCount) {
        throw StateError(
          '${playerColor.name} has more tokens in its yard than available '
          'visual slots.',
        );
      }

      for (var slotIndex = 0; slotIndex < yardTokens.length; slotIndex++) {
        slotIndices[yardTokens[slotIndex].id] = slotIndex;
      }
    }

    return slotIndices;
  }

  /// Prevents duplicate widget keys and ambiguous token identity.
  void _validateUniqueTokenIds() {
    final tokenIds = <String>{};

    for (final token in tokens) {
      if (!tokenIds.add(token.id)) {
        throw StateError('Duplicate token ID: ${token.id}.');
      }
    }
  }
}
