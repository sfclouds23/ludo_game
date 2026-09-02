/// Describes where a Ludo token currently exists in the logical game model.
///
/// A token can either:
///
/// - remain inside its player's yard/base; or
/// - occupy one of the player's logical movement-path positions.
///
/// Yard/base is deliberately represented separately from path progress `0`.
/// Progress `0` represents the player's starting shared-track cell, not the
/// player's yard.
class TokenPosition {
  const TokenPosition._({required this.isInYard, this.progress});

  /// Lowest valid player-relative movement-path progress.
  static const int minimumPathProgress = 0;

  /// Highest valid player-relative movement-path progress.
  ///
  /// According to the current logical board definition:
  ///
  /// - 0-50 = shared main track
  /// - 51-55 = private home lane
  /// - 56 = finish
  static const int maximumPathProgress = 56;

  /// First progress value belonging to the private home lane.
  static const int firstHomeLaneProgress = 51;

  /// Last progress value belonging to the private home lane.
  static const int lastHomeLaneProgress = 55;

  /// Final player-relative progress representing token completion.
  static const int finishProgress = 56;

  /// Whether the token is still inside its player's yard/base.
  final bool isInYard;

  /// Player-relative movement-path progress.
  ///
  /// This value is null while the token remains in the yard.
  final int? progress;

  /// Creates a token position representing the player's yard/base.
  ///
  /// Yard/base is outside the player's logical 0-56 movement path.
  const TokenPosition.yard() : isInYard = true, progress = null;

  /// Creates a token position at [progress] on the player's logical path.
  ///
  /// Valid progress values are 0 through 56.
  factory TokenPosition.onPath(int progress) {
    if (progress < minimumPathProgress || progress > maximumPathProgress) {
      throw RangeError.range(
        progress,
        minimumPathProgress,
        maximumPathProgress,
        'progress',
        'Token path progress must be between '
            '$minimumPathProgress and $maximumPathProgress.',
      );
    }

    return TokenPosition._(isInYard: false, progress: progress);
  }

  /// Whether the token currently occupies the logical movement path.
  bool get isOnPath => !isInYard;

  /// Whether the token is currently on the shared main track.
  ///
  /// Shared-track progress occupies positions 0 through 50.
  bool get isOnMainTrack {
    final currentProgress = progress;

    return currentProgress != null &&
        currentProgress >= minimumPathProgress &&
        currentProgress < firstHomeLaneProgress;
  }

  /// Whether the token is currently inside its private home lane.
  ///
  /// Home-lane progress occupies positions 51 through 55.
  bool get isInHomeLane {
    final currentProgress = progress;

    return currentProgress != null &&
        currentProgress >= firstHomeLaneProgress &&
        currentProgress <= lastHomeLaneProgress;
  }

  /// Whether the token has reached its final logical finish position.
  bool get isFinished => progress == finishProgress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TokenPosition &&
        other.isInYard == isInYard &&
        other.progress == progress;
  }

  @override
  int get hashCode => Object.hash(isInYard, progress);

  @override
  String toString() {
    if (isInYard) {
      return 'TokenPosition.yard()';
    }

    return 'TokenPosition.onPath(progress: $progress)';
  }
}
