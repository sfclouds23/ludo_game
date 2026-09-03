import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/dice_result.dart';
import 'ludo_dice_painter.dart';

/// Displays one responsive, animated Ludo dice.
///
/// The owning application layer supplies the logical result, availability,
/// rolling state, and callbacks. This widget never generates dice values,
/// grants extra turns, releases tokens, or calculates legal moves.
class LudoDice extends StatefulWidget {
  /// Creates an interaction-ready animated dice.
  const LudoDice({
    required this.result,
    required this.dimension,
    this.isRolling = false,
    this.isEnabled = true,
    this.onRollRequested,
    this.onRollAnimationCompleted,
    super.key,
  }) : assert(dimension > 0, 'Dice dimension must be greater than zero.');

  /// Key identifying the isolated dice repaint boundary.
  static const Key repaintBoundaryKey = ValueKey<String>(
    'ludo-dice-repaint-boundary',
  );

  /// Completed logical dice result displayed by the painter.
  final DiceResult result;

  /// Width and height of the square dice area.
  final double dimension;

  /// Whether the caller wants the roll animation displayed.
  final bool isRolling;

  /// Whether the authoritative caller currently permits a roll request.
  final bool isEnabled;

  /// Optional callback requesting a new logical dice result.
  final VoidCallback? onRollRequested;

  /// Optional callback invoked after the supplied result finishes animating.
  final ValueChanged<DiceResult>? onRollAnimationCompleted;

  @override
  State<LudoDice> createState() => _LudoDiceState();
}

/// Owns presentation timing for one dice roll.
class _LudoDiceState extends State<LudoDice>
    with SingleTickerProviderStateMixin {
  static const Duration _rollDuration = Duration(milliseconds: 1050);

  late final AnimationController _rollController;
  bool _animationsDisabled = false;
  bool _completionReported = false;
  bool _initialAnimationSynchronized = false;

  @override
  void initState() {
    super.initState();

    _rollController = AnimationController(duration: _rollDuration, vsync: this)
      ..addStatusListener(_handleAnimationStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final accessibilityChanged = animationsDisabled != _animationsDisabled;

    _animationsDisabled = animationsDisabled;

    if (!_initialAnimationSynchronized) {
      _initialAnimationSynchronized = true;

      if (widget.isRolling) {
        _startRollAnimation();
      }

      return;
    }

    if (accessibilityChanged && widget.isRolling) {
      _startRollAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant LudoDice oldWidget) {
    super.didUpdateWidget(oldWidget);

    final rollStarted = widget.isRolling && !oldWidget.isRolling;
    final rollingResultChanged =
        widget.isRolling && oldWidget.result != widget.result;

    if (rollStarted || rollingResultChanged) {
      _startRollAnimation();
      return;
    }

    if (!widget.isRolling && oldWidget.isRolling) {
      _rollController.stop();
      _rollController.value = 1;
    }
  }

  /// Starts visual sequencing for the already supplied logical result.
  void _startRollAnimation() {
    _completionReported = false;

    if (_animationsDisabled) {
      _rollController.stop();
      _rollController.value = 1;

      // Defer completion so the parent can safely update its state after the
      // current build frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.isRolling || _completionReported) {
          return;
        }

        _reportAnimationCompleted();
      });

      return;
    }

    _rollController.forward(from: 0);
  }

  /// Detects the end of the presentation-only animation.
  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed ||
        !widget.isRolling ||
        _completionReported) {
      return;
    }

    _reportAnimationCompleted();
  }

  /// Returns the same logical result originally supplied by the caller.
  void _reportAnimationCompleted() {
    _completionReported = true;
    widget.onRollAnimationCompleted?.call(widget.result);
  }

  /// Requests a roll only when the caller permits interaction.
  void _handleRollRequested() {
    if (!widget.isEnabled ||
        widget.isRolling ||
        widget.onRollRequested == null) {
      return;
    }

    widget.onRollRequested!();
  }

  /// Creates a tumble, lift, landing-bounce, and squash transform.
  Matrix4 _rollTransform(double progress) {
    // The dice starts and finishes in a stable neutral orientation. This also
    // avoids leaving perspective residue after the animation completes.
    if (progress <= 0 || progress >= 1) {
      return Matrix4.identity();
    }

    final curvedProgress = Curves.easeInOutCubic.transform(progress);

    // Rise during the first half and return during the second half.
    final verticalLift = math.sin(progress * math.pi) * widget.dimension * 0.28;

    // Add a smaller secondary bounce close to landing.
    final landingBounce = progress < 0.72
        ? 0.0
        : math.sin(((progress - 0.72) / 0.28) * math.pi) *
              widget.dimension *
              0.055;

    // Complete whole rotations so the face returns to a neutral orientation.
    final rotation = curvedProgress * math.pi * 4;
    final tiltX = math.sin(progress * math.pi * 3) * 0.42;
    final tiltY = math.sin(progress * math.pi * 2.5) * 0.36;

    // Briefly squash the dice near impact to reinforce its weight.
    final squashProgress = progress < 0.82
        ? 0.0
        : math.sin(((progress - 0.82) / 0.18) * math.pi);

    final horizontalScale = 1 + squashProgress * 0.08;
    final verticalScale = 1 - squashProgress * 0.10;

    return Matrix4.identity()
      ..setEntry(3, 2, 0.0015)
      ..translateByDouble(0, -verticalLift - landingBounce, 0, 1)
      ..rotateX(tiltX)
      ..rotateY(tiltY)
      ..rotateZ(rotation)
      ..scaleByDouble(horizontalScale, verticalScale, 1, 1);
  }

  @override
  void dispose() {
    _rollController
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canRequestRoll =
        widget.isEnabled && !widget.isRolling && widget.onRollRequested != null;

    return Semantics(
      label: 'Ludo dice',
      value: widget.isRolling ? 'Rolling' : 'Result ${widget.result.value}',
      button: widget.onRollRequested != null,
      enabled: canRequestRoll,
      liveRegion: !widget.isRolling,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: canRequestRoll ? _handleRollRequested : null,
        child: RepaintBoundary(
          key: LudoDice.repaintBoundaryKey,
          child: SizedBox.square(
            dimension: widget.dimension,
            child: AnimatedBuilder(
              animation: _rollController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: _rollTransform(_rollController.value),
                  child: CustomPaint(
                    painter: LudoDicePainter(result: widget.result),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
