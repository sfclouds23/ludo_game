/// Defines presentation-only motion characteristics for a dice roll.
///
/// Motion profiles may later vary by cosmetic, event, premium theme, or league.
/// They never generate dice results or modify game rules.
class DiceMotionProfile {
  /// Creates an immutable dice motion profile.
  const DiceMotionProfile({
    required this.id,
    required this.durationMilliseconds,
    required this.rotationCount,
    required this.horizontalTravelFactor,
    required this.liftFactor,
    required this.bounceFactor,
    required this.impactSquashFactor,
    required this.restingScale,
    required this.maximumRollingScale,
    required this.perspective,
    required this.temporaryFaceCycles,
  }) : assert(id != '', 'Dice motion profile ID must not be empty.'),
       assert(
         durationMilliseconds > 0,
         'Dice motion duration must be positive.',
       ),
       assert(rotationCount > 0, 'Rotation count must be positive.'),
       assert(
         horizontalTravelFactor >= 0,
         'Horizontal travel must not be negative.',
       ),
       assert(liftFactor >= 0, 'Lift factor must not be negative.'),
       assert(bounceFactor >= 0, 'Bounce factor must not be negative.'),
       assert(
         impactSquashFactor >= 0 && impactSquashFactor < 1,
         'Impact squash must be between zero and one.',
       ),
       assert(restingScale > 0, 'Resting scale must be positive.'),
       assert(
         maximumRollingScale >= restingScale,
         'Maximum rolling scale must not be smaller than resting scale.',
       ),
       assert(perspective >= 0, 'Perspective must not be negative.'),
       assert(
         temporaryFaceCycles > 0,
         'Temporary face cycles must be positive.',
       );

  /// Stable motion-style identifier.
  final String id;

  /// Total animation duration stored as a const-safe integer.
  final int durationMilliseconds;

  /// Number of complete cube rotations performed during the roll.
  final double rotationCount;

  /// Horizontal movement as a fraction of dice-control dimension.
  ///
  /// The classic profile keeps this at zero because the reference dice tumbles
  /// around its own center instead of travelling across the screen.
  final double horizontalTravelFactor;

  /// Vertical lift as a fraction of dice-control dimension.
  final double liftFactor;

  /// Landing bounce as a fraction of dice-control dimension.
  final double bounceFactor;

  /// Maximum vertical impact compression.
  final double impactSquashFactor;

  /// Scale used by the compact resting dice.
  final double restingScale;

  /// Largest scale reached by the cube during its tumble.
  final double maximumRollingScale;

  /// Perspective depth used by the three-dimensional renderer.
  final double perspective;

  /// Number of temporary face cycles displayed before landing.
  final int temporaryFaceCycles;

  /// Total duration consumed by the animation controller.
  Duration get duration {
    return Duration(milliseconds: durationMilliseconds);
  }

  /// Fixed-position roll tuned from the supplied visual reference.
  ///
  /// It uses a short animation, no horizontal travel, a restrained lift, and
  /// a temporary scale increase while the cube is tumbling.
  static const DiceMotionProfile classicRoll = DiceMotionProfile(
    id: 'classic_fixed_position_roll',
    durationMilliseconds: 720,
    rotationCount: 2.25,
    horizontalTravelFactor: 0,
    liftFactor: 0.045,
    bounceFactor: 0.035,
    impactSquashFactor: 0.06,
    restingScale: 1,
    maximumRollingScale: 1.85,
    perspective: 0.0012,
    temporaryFaceCycles: 3,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DiceMotionProfile &&
        other.id == id &&
        other.durationMilliseconds == durationMilliseconds &&
        other.rotationCount == rotationCount &&
        other.horizontalTravelFactor == horizontalTravelFactor &&
        other.liftFactor == liftFactor &&
        other.bounceFactor == bounceFactor &&
        other.impactSquashFactor == impactSquashFactor &&
        other.restingScale == restingScale &&
        other.maximumRollingScale == maximumRollingScale &&
        other.perspective == perspective &&
        other.temporaryFaceCycles == temporaryFaceCycles;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      durationMilliseconds,
      rotationCount,
      horizontalTravelFactor,
      liftFactor,
      bounceFactor,
      impactSquashFactor,
      restingScale,
      maximumRollingScale,
      perspective,
      temporaryFaceCycles,
    );
  }

  @override
  String toString() {
    return 'DiceMotionProfile('
        'id: $id, '
        'duration: $duration, '
        'rotationCount: $rotationCount, '
        'restingScale: $restingScale, '
        'maximumRollingScale: $maximumRollingScale'
        ')';
  }
}
