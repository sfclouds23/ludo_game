import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/player_color.dart';
import '../domain/models/token.dart';
import '../domain/models/token_position.dart';
import 'board/ludo_board.dart';

/// Hosts the production Ludo board presentation.
///
/// The current token collection is controlled preview data for GAME-103 visual
/// verification. A later game-state provider will supply live token state.
class GameScreen extends StatelessWidget {
  /// Creates the game screen.
  const GameScreen({super.key});

  /// Demonstrates yard, shared-track, home-lane, and finish rendering.
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
          child: LudoBoard(tokens: previewTokens),
        ),
      ),
    );
  }
}
