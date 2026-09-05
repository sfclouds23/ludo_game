import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/presentation/dice/dice_motion_profile.dart';

void main() {
  group('DiceMotionProfile', () {
    test('provides the fixed-position classic roll configuration', () {
      const profile = DiceMotionProfile.classicRoll;

      expect(profile.id, 'classic_fixed_position_roll');
      expect(profile.duration, const Duration(milliseconds: 720));
      expect(profile.rotationCount, 2.25);
      expect(profile.horizontalTravelFactor, 0);
      expect(profile.liftFactor, 0.045);
      expect(profile.bounceFactor, 0.035);
      expect(profile.impactSquashFactor, 0.06);
      expect(profile.restingScale, 1);
      expect(profile.maximumRollingScale, 1.85);
      expect(profile.perspective, 0.0012);
      expect(profile.temporaryFaceCycles, 3);
    });

    test('keeps the classic roll centered horizontally', () {
      const profile = DiceMotionProfile.classicRoll;

      // The supplied visual reference tumbles around one fixed control
      // position rather than travelling across the bottom of the board.
      expect(profile.horizontalTravelFactor, 0);
    });

    test('uses a compact resting state and enlarged rolling state', () {
      const profile = DiceMotionProfile.classicRoll;

      expect(profile.maximumRollingScale, greaterThan(profile.restingScale));
      expect(profile.maximumRollingScale, closeTo(1.85, 0.0001));
    });

    test('supports value equality', () {
      const first = DiceMotionProfile(
        id: 'test_roll',
        durationMilliseconds: 600,
        rotationCount: 2,
        horizontalTravelFactor: 0,
        liftFactor: 0.04,
        bounceFactor: 0.03,
        impactSquashFactor: 0.05,
        restingScale: 1,
        maximumRollingScale: 1.7,
        perspective: 0.001,
        temporaryFaceCycles: 3,
      );

      const second = DiceMotionProfile(
        id: 'test_roll',
        durationMilliseconds: 600,
        rotationCount: 2,
        horizontalTravelFactor: 0,
        liftFactor: 0.04,
        bounceFactor: 0.03,
        impactSquashFactor: 0.05,
        restingScale: 1,
        maximumRollingScale: 1.7,
        perspective: 0.001,
        temporaryFaceCycles: 3,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('provides a readable string representation', () {
      const profile = DiceMotionProfile.classicRoll;

      expect(profile.toString(), contains('classic_fixed_position_roll'));
      expect(profile.toString(), contains('720'));
      expect(profile.toString(), contains('1.85'));
    });

    test('rejects a non-positive duration', () {
      expect(
        () => DiceMotionProfile(
          id: 'invalid',
          durationMilliseconds: 0,
          rotationCount: 2,
          horizontalTravelFactor: 0,
          liftFactor: 0.04,
          bounceFactor: 0.03,
          impactSquashFactor: 0.05,
          restingScale: 1,
          maximumRollingScale: 1.7,
          perspective: 0.001,
          temporaryFaceCycles: 3,
        ),
        throwsAssertionError,
      );
    });

    test('rejects a non-positive resting scale', () {
      expect(
        () => DiceMotionProfile(
          id: 'invalid',
          durationMilliseconds: 600,
          rotationCount: 2,
          horizontalTravelFactor: 0,
          liftFactor: 0.04,
          bounceFactor: 0.03,
          impactSquashFactor: 0.05,
          restingScale: 0,
          maximumRollingScale: 1.7,
          perspective: 0.001,
          temporaryFaceCycles: 3,
        ),
        throwsAssertionError,
      );
    });

    test('rejects a rolling scale smaller than resting scale', () {
      expect(
        () => DiceMotionProfile(
          id: 'invalid',
          durationMilliseconds: 600,
          rotationCount: 2,
          horizontalTravelFactor: 0,
          liftFactor: 0.04,
          bounceFactor: 0.03,
          impactSquashFactor: 0.05,
          restingScale: 1,
          maximumRollingScale: 0.9,
          perspective: 0.001,
          temporaryFaceCycles: 3,
        ),
        throwsAssertionError,
      );
    });

    test('rejects a negative horizontal travel factor', () {
      expect(
        () => DiceMotionProfile(
          id: 'invalid',
          durationMilliseconds: 600,
          rotationCount: 2,
          horizontalTravelFactor: -0.01,
          liftFactor: 0.04,
          bounceFactor: 0.03,
          impactSquashFactor: 0.05,
          restingScale: 1,
          maximumRollingScale: 1.7,
          perspective: 0.001,
          temporaryFaceCycles: 3,
        ),
        throwsAssertionError,
      );
    });

    test('rejects invalid impact squash', () {
      expect(
        () => DiceMotionProfile(
          id: 'invalid',
          durationMilliseconds: 600,
          rotationCount: 2,
          horizontalTravelFactor: 0,
          liftFactor: 0.04,
          bounceFactor: 0.03,
          impactSquashFactor: 1,
          restingScale: 1,
          maximumRollingScale: 1.7,
          perspective: 0.001,
          temporaryFaceCycles: 3,
        ),
        throwsAssertionError,
      );
    });

    test('rejects zero temporary face cycles', () {
      expect(
        () => DiceMotionProfile(
          id: 'invalid',
          durationMilliseconds: 600,
          rotationCount: 2,
          horizontalTravelFactor: 0,
          liftFactor: 0.04,
          bounceFactor: 0.03,
          impactSquashFactor: 0.05,
          restingScale: 1,
          maximumRollingScale: 1.7,
          perspective: 0.001,
          temporaryFaceCycles: 0,
        ),
        throwsAssertionError,
      );
    });
  });
}
