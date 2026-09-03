import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/player_color.dart';
import '../domain/models/token.dart';
import '../domain/models/token_position.dart';
import 'board/ludo_board.dart';
import 'board/ludo_token_visual_state.dart';

/// Hosts the production Ludo board presentation.
///
/// The current token collection and visual states are controlled preview data
/// for GAME-103 verification. A later authoritative game-state provider will
/// supply live tokens, legal selections, and movement state.
class GameScreen extends StatefulWidget {
  /// Creates the game screen.
  const GameScreen({super.key});

  /// Demonstrates yard, shared-track, stacking, home-lane, and finish rendering.
  ///
  /// These values drive presentation only and do not simulate gameplay.
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

  /// Base visual states supplied to the preview.
  ///
  /// These flags are intentionally declared as presentation data. They are not
  /// calculated from dice results, turns, paths, or legal-move rules.
  static const Map<String, LudoTokenVisualState> previewVisualStates = {
    'red_token_1': LudoTokenVisualState(isMovable: true),
    'red_token_2': LudoTokenVisualState(isMovable: true),
    'green_token_1': LudoTokenVisualState(isMovable: true),
    'yellow_token_1': LudoTokenVisualState(isMoving: true),
  };

  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// Owns selection state for the controlled visual preview.
class _GameScreenState extends State<GameScreen> {
  String? _selectedTokenId = 'red_token_2';

  /// Builds visual state without evaluating whether any token can legally move.
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

  /// Updates the controlled preview selection after a token press.
  ///
  /// This method deliberately performs no legal-move validation. It only
  /// displays which token was pressed.
  void _handleTokenPressed(String tokenId) {
    setState(() {
      _selectedTokenId = tokenId;
    });
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
          child: LudoBoard(
            tokens: GameScreen.previewTokens,
            visualStates: _currentVisualStates(),
            onTokenPressed: _handleTokenPressed,
          ),
        ),
      ),
    );
  }
}
