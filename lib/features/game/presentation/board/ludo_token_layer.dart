import 'package:flutter/material.dart';

import '../../domain/models/player_color.dart';
import '../../domain/models/token.dart';
import 'board_geometry.dart';
import 'ludo_token.dart';
import 'ludo_token_visual_state.dart';
import 'token_coordinate_mapper.dart';

/// Positions dynamic Ludo tokens above the static board.
///
/// This layer reads immutable token state and converts it into presentation
/// coordinates. It displays caller-supplied selectability and forwards token
/// presses, but never determines legal moves, captures, or dice outcomes.
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
  /// forwarding the press. Legal-move enforcement belongs to the authoritative
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
        final tokenDimension = geometry.cellSize * 1.35;
        final yardSlotIndices = _yardSlotIndices();

        return RepaintBoundary(
          key: repaintBoundaryKey,
          child: SizedBox.square(
            dimension: boardSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final token in tokens)
                  _positionedToken(
                    token: token,
                    geometry: geometry,
                    tokenDimension: tokenDimension,
                    yardSlotIndex: yardSlotIndices[token.id],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Creates one token widget centered on its responsive board coordinate.
  Widget _positionedToken({
    required Token token,
    required BoardGeometry geometry,
    required double tokenDimension,
    required int? yardSlotIndex,
  }) {
    final center = TokenCoordinateMapper.centerFor(
      token: token,
      geometry: geometry,
      yardSlotIndex: yardSlotIndex,
    );

    final visualState = visualStates[token.id] ?? LudoTokenVisualState.idle;

    return Positioned(
      key: ValueKey<String>('ludo-token-position-${token.id}'),
      left: center.dx - tokenDimension / 2,
      top: center.dy - tokenDimension / 2,
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
