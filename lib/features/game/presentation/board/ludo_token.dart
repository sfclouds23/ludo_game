import 'package:flutter/material.dart';

import '../../domain/models/player_color.dart';
import 'ludo_token_painter.dart';
import 'ludo_token_visual_state.dart';

/// Displays one isolated, responsive, interaction-ready Ludo token.
///
/// Board positioning and legal-move calculation belong to the caller. This
/// widget renders supplied state and forwards taps without deciding legality.
class LudoToken extends StatefulWidget {
  /// Creates one visual Ludo token.
  const LudoToken({
    required this.tokenId,
    required this.playerColor,
    required this.dimension,
    this.visualState = LudoTokenVisualState.idle,
    this.isInYard = false,
    this.isFinished = false,
    this.onPressed,
    super.key,
  }) : assert(tokenId != '', 'Token ID must not be empty.'),
       assert(dimension > 0, 'Token dimension must be greater than zero.');

  /// Stable logical identity of the represented token.
  final String tokenId;

  /// Player color used by the token painter.
  final PlayerColor playerColor;

  /// Width and height of the square token canvas.
  final double dimension;

  /// Presentation-only state supplied by the caller.
  final LudoTokenVisualState visualState;

  /// Whether the logical token is currently in its yard.
  final bool isInYard;

  /// Whether the logical token has completed its path.
  final bool isFinished;

  /// Optional interaction callback supplied by the owning application layer.
  ///
  /// The widget does not infer this callback from [visualState.isMovable].
  final VoidCallback? onPressed;

  /// Returns the unique repaint-boundary key for [tokenId].
  static Key repaintBoundaryKeyFor(String tokenId) {
    return ValueKey<String>('ludo-token-repaint-boundary-$tokenId');
  }

  @override
  State<LudoToken> createState() => _LudoTokenState();
}

/// Owns presentation animation timing for a single token.
class _LudoTokenState extends State<LudoToken>
    with SingleTickerProviderStateMixin {
  static const Duration _pulseDuration = Duration(milliseconds: 850);

  late final AnimationController _emphasisController;
  bool _animationsDisabled = false;

  @override
  void initState() {
    super.initState();

    _emphasisController = AnimationController(
      duration: _pulseDuration,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (_animationsDisabled != animationsDisabled) {
      _animationsDisabled = animationsDisabled;
    }

    _synchronizeAnimation();
  }

  @override
  void didUpdateWidget(covariant LudoToken oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.visualState != widget.visualState) {
      _synchronizeAnimation();
    }
  }

  /// Starts, stops, or stabilizes the presentation-only pulse.
  void _synchronizeAnimation() {
    final shouldAnimate =
        widget.visualState.isEmphasized && !_animationsDisabled;

    if (shouldAnimate) {
      if (!_emphasisController.isAnimating) {
        _emphasisController.repeat(reverse: true);
      }

      return;
    }

    _emphasisController.stop();

    // Reduced-motion mode keeps emphasized tokens clearly visible without
    // continuously changing pixels.
    _emphasisController.value = widget.visualState.isEmphasized ? 1 : 0;
  }

  @override
  void dispose() {
    _emphasisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.playerColor.name} Ludo token',
      identifier: widget.tokenId,
      image: true,
      button: widget.onPressed != null,
      selected: widget.visualState.isSelected,
      enabled: widget.onPressed != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: widget.onPressed,
        child: RepaintBoundary(
          key: LudoToken.repaintBoundaryKeyFor(widget.tokenId),
          child: SizedBox.square(
            dimension: widget.dimension,
            child: AnimatedBuilder(
              animation: _emphasisController,
              builder: (context, child) {
                final emphasisProgress = Curves.easeInOut.transform(
                  _emphasisController.value,
                );

                return CustomPaint(
                  painter: LudoTokenPainter(
                    playerColor: widget.playerColor,
                    visualState: widget.visualState,
                    isInYard: widget.isInYard,
                    isFinished: widget.isFinished,
                    emphasisProgress: emphasisProgress,
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
