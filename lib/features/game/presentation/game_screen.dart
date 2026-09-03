import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/dice_result.dart';
import '../domain/models/player_color.dart';
import '../domain/models/token.dart';
import '../domain/models/token_position.dart';
import '../domain/services/dice_roller.dart';
import 'board/ludo_board.dart';
import 'board/ludo_token_visual_state.dart';
import 'dice/ludo_dice.dart';

/// Hosts the production Ludo board and dice presentation.
///
/// The current tokens and visual states are controlled preview data. A later
/// authoritative GameState will supply live turn state, legal moves, and roll
/// availability.
class GameScreen extends StatefulWidget {
  /// Creates the game screen.
  const GameScreen({this.diceRoller, this.onDiceResultReady, super.key});

  /// Optional logical dice generator used by this screen.
  ///
  /// Production uses [RandomDiceRoller]. Tests may inject a deterministic
  /// implementation without changing animation behavior.
  final DiceRoller? diceRoller;

  /// Optional callback receiving the logical result after animation completes.
  ///
  /// This is the future integration boundary for the move engine. This screen
  /// does not apply six rules or calculate legal moves.
  final ValueChanged<DiceResult>? onDiceResultReady;

  /// Demonstrates yard, shared-track, stacking, home-lane, and finish rendering.
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

  /// Requests a completed logical result before starting animation.
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

  /// Completes presentation sequencing for the supplied logical result.
  void _handleRollAnimationCompleted(DiceResult completedResult) {
    // Ignore stale completion notifications if a future owner replaces the
    // active logical result during an animation.
    if (completedResult != _diceResult) {
      return;
    }

    setState(() {
      _isDiceRolling = false;
    });

    // The future move engine may consume the result here. No move or six rule
    // is implemented by this presentation screen.
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
          child: Column(
            children: [
              Expanded(
                child: LudoBoard(
                  tokens: GameScreen.previewTokens,
                  visualStates: _currentVisualStates(),
                  onTokenPressed: _handleTokenPressed,
                ),
              ),
              const SizedBox(height: 12),
              LudoDice(
                result: _diceResult,
                dimension: 88,
                isRolling: _isDiceRolling,
                isEnabled: !_isDiceRolling,
                onRollRequested: _handleRollRequested,
                onRollAnimationCompleted: _handleRollAnimationCompleted,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
