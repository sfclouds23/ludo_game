import 'package:flutter/material.dart';

import '../../domain/models/dice_result.dart';

/// Describes one Rive-backed dice cosmetic.
///
/// This configuration translates canonical logical dice results into the exact
/// artboard and animation identifiers stored inside a particular Rive asset.
///
/// It contains presentation metadata only. It does not generate results,
/// determine legal moves, release tokens, or grant additional turns.
class RiveDiceAsset {
  /// Creates an immutable Rive dice asset configuration.
  const RiveDiceAsset({
    required this.id,
    required this.assetPath,
    required this.artboardName,
    required this.animationNames,
    required this.playbackDuration,
    this.contentScale = 1,
    this.alignment = Alignment.center,
  }) : assert(id != '', 'Rive dice asset ID must not be empty.'),
       assert(assetPath != '', 'Rive dice asset path must not be empty.'),
       assert(artboardName != '', 'Rive artboard name must not be empty.'),
       assert(contentScale > 0, 'Rive dice content scale must be positive.');

  /// Stable identifier used by the future cosmetic inventory.
  final String id;

  /// Flutter asset-bundle path of the compiled Rive file.
  final String assetPath;

  /// Exact artboard name contained in the Rive file.
  final String artboardName;

  /// Exact Rive animation name for every canonical logical result.
  ///
  /// Asset-specific inconsistencies, including whitespace in exported timeline
  /// names, remain isolated in this map.
  final Map<int, String> animationNames;

  /// Expected visual playback duration.
  ///
  /// This controls presentation sequencing only. It does not influence the
  /// logical result generated before animation begins.
  final Duration playbackDuration;

  /// Scale applied inside the fixed and clipped dice viewport.
  ///
  /// The classic asset uses a restrained value so all rotating corners and the
  /// landing shadow remain inside the local-player control area.
  final double contentScale;

  /// Alignment applied when fitting and scaling the Rive artwork.
  final Alignment alignment;

  /// Returns the exact Rive animation associated with [result].
  String animationNameFor(DiceResult result) {
    final animationName = animationNames[result.value];

    if (animationName == null || animationName.isEmpty) {
      throw StateError(
        'Rive dice asset "$id" does not map result ${result.value}.',
      );
    }

    return animationName;
  }

  /// Current classic 3D Rive dice cosmetic.
  ///
  /// The third animation contains an intentional trailing space because that
  /// is the exact identifier exported by the supplied Rive file.
  static const RiveDiceAsset classic3d = RiveDiceAsset(
    id: 'classic_3d_rive',
    assetPath: 'assets/rive/ludo_dice_3d.riv',
    artboardName: 'Dice',
    animationNames: <int, String>{
      1: 'Roll 1',
      2: 'Roll 2',
      3: 'Roll 3 ',
      4: 'Roll 4',
      5: 'Roll 5',
      6: 'Roll 6',
    },
    playbackDuration: Duration(milliseconds: 1000),
    contentScale: 1.25,
    alignment: Alignment.bottomCenter,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is RiveDiceAsset &&
        other.id == id &&
        other.assetPath == assetPath &&
        other.artboardName == artboardName &&
        _mapsEqual(other.animationNames, animationNames) &&
        other.playbackDuration == playbackDuration &&
        other.contentScale == contentScale &&
        other.alignment == alignment;
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetPath,
    artboardName,
    Object.hashAll(
      animationNames.entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    ),
    playbackDuration,
    contentScale,
    alignment,
  );

  @override
  String toString() {
    return 'RiveDiceAsset('
        'id: $id, '
        'assetPath: $assetPath, '
        'artboardName: $artboardName'
        ')';
  }

  /// Compares two animation-name maps by key and value.
  static bool _mapsEqual(Map<int, String> left, Map<int, String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (final entry in left.entries) {
      if (right[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}
