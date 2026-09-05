import 'package:flutter/material.dart';

/// Positions the dice inside the local player's responsive control area.
///
/// The dock owns placement only. It does not generate dice results, control
/// rolling, enforce turns, select cosmetics, or implement game rules.
///
/// A future player panel can place an avatar, inventory-selected dice, emotes,
/// and league controls around this same presentation boundary.
class DiceDock extends StatelessWidget {
  /// Creates a responsive local-player dice dock.
  const DiceDock({
    required this.boardDimension,
    required this.diceControlDimension,
    required this.child,
    this.horizontalPositionFactor = 0.29,
    super.key,
  }) : assert(boardDimension > 0, 'Board dimension must be greater than zero.'),
       assert(
         diceControlDimension > 0,
         'Dice control dimension must be greater than zero.',
       ),
       assert(
         horizontalPositionFactor >= 0 && horizontalPositionFactor <= 1,
         'Horizontal position factor must be between zero and one.',
       );

  /// Key identifying the complete responsive dice dock.
  static const Key dockKey = ValueKey<String>('local-player-dice-dock');

  /// Key identifying the positioned dice-control area.
  static const Key positionKey = ValueKey<String>('local-player-dice-position');

  /// Width of the board used as the positioning reference.
  final double boardDimension;

  /// Width and height reserved for the complete dice control.
  final double diceControlDimension;

  /// Horizontal dice center relative to board width.
  ///
  /// The value `0.29` places the dice inside the lower-left player-control
  /// region demonstrated by the supplied reference.
  final double horizontalPositionFactor;

  /// Dice control supplied by the presentation owner.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final desiredCenter = boardDimension * horizontalPositionFactor;
    final minimumCenter = diceControlDimension / 2;
    final maximumCenter = boardDimension - diceControlDimension / 2;

    final safeCenter = desiredCenter
        .clamp(minimumCenter, maximumCenter)
        .toDouble();

    return SizedBox(
      key: dockKey,
      width: boardDimension,
      height: diceControlDimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            key: positionKey,
            left: safeCenter - diceControlDimension / 2,
            top: 0,
            width: diceControlDimension,
            height: diceControlDimension,
            child: child,
          ),
        ],
      ),
    );
  }
}
