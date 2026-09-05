import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/dice_result.dart';
import '../domain/models/game_state.dart';
import '../domain/models/player_color.dart';
import '../domain/models/token.dart';
import '../domain/models/token_position.dart';
import '../domain/services/dice_roll_service.dart';
import '../domain/services/dice_roller.dart';
import 'board/ludo_board.dart';
import 'board/ludo_token_visual_state.dart';
import 'dice/dice_dock.dart';
import 'dice/ludo_dice.dart';

/// Hosts the production Ludo board and dice presentation.
///
/// Token visual states remain controlled preview data. Dice roll availability,
/// pending logical result, rolling state, and completed result now live in
/// [GameState] and are coordinated through [DiceRollService].
class GameScreen extends StatefulWidget {
  /// Creates the game screen.
  const GameScreen({
    this.diceRoller,
    this.initialGameState = const GameState(),
    this.onDiceResultReady,
    this.useRiveDiceRenderer = true,
    super.key,
  });

  /// Optional logical dice generator used by this screen.
  ///
  /// Production uses [RandomDiceRoller]. Tests may inject a deterministic
  /// implementation without changing state transitions or animation behavior.
  final DiceRoller? diceRoller;

  /// Initial authoritative local state used by the GAME-104 integration.
  ///
  /// Later turn logic may provide a state with dice rolling disabled without
  /// changing the dice presentation itself.
  final GameState initialGameState;

  /// Optional callback receiving the completed result after animation.
  ///
  /// This remains the integration boundary for the future move engine. GAME-104
  /// does not apply six rules, release tokens, or calculate legal moves.
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

/// Coordinates controlled board selection with authoritative dice state.
class _GameScreenState extends State<GameScreen> {
  late final DiceRollService _diceRollService;
  late GameState _gameState;

  String? _selectedTokenId = 'red_token_2';

  // The dice needs a face before the first logical roll exists. This value is
  // presentation-only and is replaced by the pending logical result as soon as
  // a roll starts. Downstream game logic reads GameState.diceResult instead.
  DiceResult _displayDiceResult = DiceResult(1);

  @override
  void initState() {
    super.initState();

    _diceRollService = DefaultDiceRollService(
      widget.diceRoller ?? RandomDiceRoller(),
    );
    _gameState = widget.initialGameState;

    final initialLogicalResult =
        _gameState.pendingDiceResult ?? _gameState.diceResult;

    if (initialLogicalResult != null) {
      _displayDiceResult = initialLogicalResult;
    }
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

  /// Requests one logical result through the GAME-104 state service.
  void _handleRollRequested() {
    final nextState = _diceRollService.requestRoll(_gameState);

    // Forbidden or duplicate requests return the same state and consume no
    // random value.
    if (identical(nextState, _gameState)) {
      return;
    }

    setState(() {
      _gameState = nextState;
      _displayDiceResult = nextState.pendingDiceResult!;
    });
  }

  /// Publishes the active logical result only after presentation completes.
  void _handleRollAnimationCompleted(DiceResult completedResult) {
    final nextState = _diceRollService.completeRoll(
      _gameState,
      completedResult,
    );

    // Ignore stale completion events from a previous or mismatched animation.
    if (identical(nextState, _gameState)) {
      return;
    }

    setState(() {
      _gameState = nextState;
    });

    final readyResult = nextState.diceResult;
    if (readyResult != null) {
      widget.onDiceResultReady?.call(readyResult);
    }
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
                          result: _displayDiceResult,
                          dimension: diceControlDimension,
                          isRolling: _gameState.isDiceRolling,
                          isEnabled: _gameState.canRollDice,
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
