import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Describes the presentation placement of one token in a shared board cell.
///
/// This value contains visual layout information only. It does not represent
/// a blockade, capture, legal move, or any other game rule.
class TokenStackPlacement {
  /// Creates an immutable visual token placement.
  const TokenStackPlacement({
    required this.offset,
    required this.dimensionScale,
  }) : assert(
         dimensionScale > 0 && dimensionScale <= 1,
         'Token dimension scale must be greater than zero and at most one.',
       );

  /// Offset from the center of the token's logical board cell.
  final Offset offset;

  /// Scale applied to the normal token dimension.
  final double dimensionScale;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TokenStackPlacement &&
        other.offset == offset &&
        other.dimensionScale == dimensionScale;
  }

  @override
  int get hashCode => Object.hash(offset, dimensionScale);

  @override
  String toString() {
    return 'TokenStackPlacement('
        'offset: $offset, '
        'dimensionScale: $dimensionScale'
        ')';
  }
}

/// Calculates deterministic presentation layouts for co-located tokens.
///
/// Token IDs are sorted before placement so changing the input-list order does
/// not cause tokens to jump between visual stack positions. This class only
/// arranges tokens that the caller has already identified as sharing a visual
/// coordinate; it never determines board occupancy or legal game behavior.
class TokenStackLayout {
  const TokenStackLayout._();

  /// Returns visual placements keyed by stable token ID.
  ///
  /// A single token remains centered at full size. Multiple tokens are reduced
  /// and distributed around the shared cell center using a compact grid.
  static Map<String, TokenStackPlacement> placementsFor({
    required Iterable<String> tokenIds,
    required double cellSize,
  }) {
    if (!cellSize.isFinite || cellSize <= 0) {
      throw ArgumentError.value(
        cellSize,
        'cellSize',
        'Cell size must be finite and greater than zero.',
      );
    }

    final sortedTokenIds = tokenIds.toList()..sort();

    if (sortedTokenIds.isEmpty) {
      return const {};
    }

    _validateUniqueTokenIds(sortedTokenIds);

    if (sortedTokenIds.length == 1) {
      return {
        sortedTokenIds.single: const TokenStackPlacement(
          offset: Offset.zero,
          dimensionScale: 1,
        ),
      };
    }

    final tokenCount = sortedTokenIds.length;
    final columnCount = math.sqrt(tokenCount).ceil();
    final rowCount = (tokenCount / columnCount).ceil();
    final spacing = cellSize * _spacingFactorFor(tokenCount);
    final dimensionScale = _dimensionScaleFor(tokenCount);
    final placements = <String, TokenStackPlacement>{};

    for (var index = 0; index < tokenCount; index++) {
      final row = index ~/ columnCount;
      final column = index % columnCount;

      // Center every occupied row independently. This prevents the final,
      // partially occupied row from appearing biased toward the left.
      final tokensInRow = math.min(columnCount, tokenCount - row * columnCount);

      final horizontalCenter = (tokensInRow - 1) / 2;
      final verticalCenter = (rowCount - 1) / 2;

      placements[sortedTokenIds[index]] = TokenStackPlacement(
        offset: Offset(
          (column - horizontalCenter) * spacing,
          (row - verticalCenter) * spacing,
        ),
        dimensionScale: dimensionScale,
      );
    }

    return placements;
  }

  /// Returns compact spacing appropriate for the number of visible tokens.
  static double _spacingFactorFor(int tokenCount) {
    if (tokenCount <= 4) {
      return 0.34;
    }

    if (tokenCount <= 9) {
      return 0.27;
    }

    return 0.22;
  }

  /// Returns a readable token size while keeping every stack member visible.
  static double _dimensionScaleFor(int tokenCount) {
    if (tokenCount == 2) {
      return 0.78;
    }

    if (tokenCount <= 4) {
      return 0.66;
    }

    if (tokenCount <= 9) {
      return 0.52;
    }

    return 0.44;
  }

  /// Rejects duplicate identities because each placement requires a unique key.
  static void _validateUniqueTokenIds(List<String> tokenIds) {
    final uniqueTokenIds = <String>{};

    for (final tokenId in tokenIds) {
      if (!uniqueTokenIds.add(tokenId)) {
        throw ArgumentError.value(
          tokenIds,
          'tokenIds',
          'Token IDs must be unique.',
        );
      }
    }
  }
}
