import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/game_screen.dart';

void main() {
  group('GameScreen token preview', () {
    test('contains two preview tokens for every player', () {
      for (final playerColor in PlayerColor.values) {
        final playerTokens = GameScreen.previewTokens.where(
          (token) => token.ownerColor == playerColor,
        );

        expect(playerTokens, hasLength(2));
      }

      expect(GameScreen.previewTokens, hasLength(8));
    });

    test('keeps preview token data immutable', () {
      expect(() => GameScreen.previewTokens.clear(), throwsUnsupportedError);
    });

    testWidgets('passes preview tokens into the board', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      final board = tester.widget<LudoBoard>(find.byType(LudoBoard));

      expect(board.tokens, same(GameScreen.previewTokens));
      expect(find.byType(LudoToken), findsNWidgets(8));
    });

    testWidgets('shows the board screen title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      expect(find.text('Ludo Board'), findsOneWidget);
      expect(find.byTooltip('Return home'), findsOneWidget);
    });
  });
}
