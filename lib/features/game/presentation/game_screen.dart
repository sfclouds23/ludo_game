import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'board/ludo_board.dart';

/// Hosts the production Ludo board presentation.
///
/// Game controls, player panels, tokens, and dice will be introduced by their
/// corresponding Jira Stories without moving board-rendering logic here.
class GameScreen extends StatelessWidget {
  /// Creates the game screen.
  const GameScreen({super.key});

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
      body: const SafeArea(
        child: Padding(padding: EdgeInsets.all(16), child: LudoBoard()),
      ),
    );
  }
}
