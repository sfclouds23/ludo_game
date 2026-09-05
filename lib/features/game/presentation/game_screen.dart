import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/dice_result.dart';
import '../domain/models/player_color.dart';
import '../domain/models/token.dart';
import '../domain/models/token_position.dart';
import '../domain/services/dice_roller.dart';
import 'board/ludo_board.dart';
import 'board/ludo_token_visual_state.dart';
import 'dice/dice_dock.dart';
import 'dice/ludo_dice.dart';

/// Hosts the production Ludo board and dice presentation.
///
/// The current tokens and visual states are controlled preview data. A later
/// authoritative GameState will supply live turn state, legal moves, and roll
/// availability.
class GameScreen extends StatefulWidget {
  /// Creates the game screen.
  const GameScreen({
    this.diceRoller,
    this.onDiceResultReady,
    this.useRiveDiceRenderer = true,
    super.key,
  });

  /// Optional logical dice generator used by this screen.
  ///
  /// Production uses [RandomDiceRoller]. Tests may inject a deterministic
  /// implementation without changing animation behavior.
  final DiceRoller? diceRoller;

  /// Optional callback receiving the result after animation completes.
  ///
  /// This is the future integration boundary for the move engine. This screen
  /// does not apply six rules or calculate legal moves.
  final ValueChanged<DiceResult>? onDiceResultReady;

  /// Whether the dice uses the configured Rive asset renderer.
  ///
  /// Production keeps this enabled. Widget tests may disable it to exercise
  /// sequencing without loading the native Rive runtime.
  final bool useRiveDiceRenderer;

  /// Demonstrates yard, track, stacking, home-lane, and finish rendering.
  static final List<Token> previewTokens = List.unmodifiable([
    const Token(
      id: 'red_token_0',
      ownerColor: PlayerColor.red,
      position: TokenPosition.yard(),
    ),
    Token(
      id: 'red_token_1',
      ownerColor: PlayerColor.red,
      position: TokenPosition.onPath(0),
    ),
    Token(
      id: 'red_token_2',
      ownerColor: PlayerColor.red,
      position: TokenPosition.onPath(0),
    ),
    const Token(
      id: 'green_token_0',
      ownerColor: PlayerColor.green,
      position: TokenPosition.yard(),
    ),
    Token(
      id: 'green_token_1',
      ownerColor: PlayerColor.green,
      position: TokenPosition.onPath(8),
    ),
    const Token(
      id: 'yellow_token_0',
      ownerColor: PlayerColor.yellow,
      position: TokenPosition.yard(),
    ),
    Token(
      id: 'yellow_token_1',
      ownerColor: PlayerColor.yellow,
      position: TokenPosition.onPath(TokenPosition.firstHomeLaneProgress),
    ),
    const Token(
      id: 'blue_token_0',
      ownerColor: PlayerColor.blue,
      position: TokenPosition.yard(),
    ),
    Token(
      id: 'blue_token_1',
      ownerColor: PlayerColor.blue,
      position: TokenPosition.onPath(TokenPosition.finishProgress),
    ),
  ]);

  /// Base presentation states supplied to the token preview.
  ///
  /// These values are not derived from dice or legal-move rules.
  static const Map<String, LudoTokenVisualState> previewVisualStates = {
    'red_token_1': LudoTokenVisualState(isMovable: true),
    'red_token_2': LudoTokenVisualState(isMovable: true),
    'green_token_1': LudoTokenVisualState(isMovable: true),
    'yellow_token_1': LudoTokenVisualState(isMoving: true),
  };

  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// Coordinates controlled board selection and dice presentation.
class _GameScreenState extends State<GameScreen> {
  late final DiceRoller _diceRoller;

  String? _selectedTokenId = 'red_token_2';
  DiceResult _diceResult = DiceResult(1);
  bool _isDiceRolling = false;

  @override
  void initState() {
    super.initState();

    _diceRoller = widget.diceRoller ?? RandomDiceRoller();
  }

  /// Builds token visual state without evaluating move legality.
  Map<String, LudoTokenVisualState> _currentVisualStates() {
    final visualStates = <String, LudoTokenVisualState>{
      ...GameScreen.previewVisualStates,
    };

    final selectedTokenId = _selectedTokenId;

    if (selectedTokenId != null) {
      final currentState =
          visualStates[selectedTokenId] ?? LudoTokenVisualState.idle;

      visualStates[selectedTokenId] = currentState.copyWith(isSelected: true);
    }

    return visualStates;
  }

  /// Updates controlled preview selection without legal-move validation.
  void _handleTokenPressed(String tokenId) {
    setState(() {
      _selectedTokenId = tokenId;
    });
  }

  /// Generates one logical result before starting its presentation.
  void _handleRollRequested() {
    if (_isDiceRolling) {
      return;
    }

    final nextResult = _diceRoller.roll();

    setState(() {
      _diceResult = nextResult;
      _isDiceRolling = true;
    });
  }

  /// Completes presentation sequencing for the active logical result.
  void _handleRollAnimationCompleted(DiceResult completedResult) {
    if (completedResult != _diceResult) {
      return;
    }

    setState(() {
      _isDiceRolling = false;
    });

    // A future move engine may consume this value. No movement or six rule is
    // implemented in this presentation screen.
    widget.onDiceResultReady?.call(completedResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Return home',
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home_outlined),
        ),
        title: const Text('Ludo Board'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const boardToControlsGap = 8.0;
              const bottomBreathingRoom = 8.0;

              final diceControlDimension = (constraints.maxWidth * 0.17)
                  .clamp(64.0, 112.0)
                  .toDouble();

              final availableBoardHeight =
                  constraints.maxHeight -
                  diceControlDimension -
                  boardToControlsGap -
                  bottomBreathingRoom;

              final boardDimension = math.min(
                constraints.maxWidth,
                availableBoardHeight,
              );

              if (!boardDimension.isFinite || boardDimension <= 0) {
                return const SizedBox.shrink();
              }

              return Center(
                child: SizedBox(
                  width: boardDimension,
                  height:
                      boardDimension +
                      boardToControlsGap +
                      diceControlDimension +
                      bottomBreathingRoom,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox.square(
                        dimension: boardDimension,
                        child: LudoBoard(
                          tokens: GameScreen.previewTokens,
                          visualStates: _currentVisualStates(),
                          onTokenPressed: _handleTokenPressed,
                        ),
                      ),
                      const SizedBox(height: boardToControlsGap),
                      DiceDock(
                        boardDimension: boardDimension,
                        diceControlDimension: diceControlDimension,
                        horizontalPositionFactor: 0.29,
                        child: LudoDice(
                          result: _diceResult,
                          dimension: diceControlDimension,
                          isRolling: _isDiceRolling,
                          isEnabled: !_isDiceRolling,
                          useRiveRenderer: widget.useRiveDiceRenderer,
                          onRollRequested: _handleRollRequested,
                          onRollAnimationCompleted:
                              _handleRollAnimationCompleted,
                        ),
                      ),
                      const SizedBox(height: bottomBreathingRoom),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
