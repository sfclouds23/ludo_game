import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/domain/models/player_color.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_token_visual_state.dart';
import 'package:ludo_game/features/game/presentation/game_screen.dart';

void main() {
  group('GameScreen token preview', () {
    test('contains preview tokens for every player', () {
      for (final playerColor in PlayerColor.values) {
        final playerTokens = GameScreen.previewTokens.where(
          (token) => token.ownerColor == playerColor,
        );

        expect(playerTokens, isNotEmpty);
      }

      expect(
        GameScreen.previewTokens.where(
          (token) => token.ownerColor == PlayerColor.red,
        ),
        hasLength(3),
      );

      expect(
        GameScreen.previewTokens.where(
          (token) => token.ownerColor == PlayerColor.green,
        ),
        hasLength(2),
      );

      expect(
        GameScreen.previewTokens.where(
          (token) => token.ownerColor == PlayerColor.yellow,
        ),
        hasLength(2),
      );

      expect(
        GameScreen.previewTokens.where(
          (token) => token.ownerColor == PlayerColor.blue,
        ),
        hasLength(2),
      );

      expect(GameScreen.previewTokens, hasLength(9));
    });

    test('contains two red tokens sharing one logical position', () {
      final firstStackedToken = GameScreen.previewTokens.singleWhere(
        (token) => token.id == 'red_token_1',
      );
      final secondStackedToken = GameScreen.previewTokens.singleWhere(
        (token) => token.id == 'red_token_2',
      );

      expect(firstStackedToken.position, secondStackedToken.position);
    });

    test('keeps preview token data immutable', () {
      expect(() => GameScreen.previewTokens.clear(), throwsUnsupportedError);
    });

    test('declares visual state without calculating legal moves', () {
      expect(
        GameScreen.previewVisualStates['red_token_1'],
        const LudoTokenVisualState(isMovable: true),
      );
      expect(
        GameScreen.previewVisualStates['red_token_2'],
        const LudoTokenVisualState(isMovable: true),
      );
      expect(
        GameScreen.previewVisualStates['green_token_1'],
        const LudoTokenVisualState(isMovable: true),
      );
      expect(
        GameScreen.previewVisualStates['yellow_token_1'],
        const LudoTokenVisualState(isMoving: true),
      );
    });

    testWidgets('passes preview tokens and visual states into the board', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      final board = tester.widget<LudoBoard>(find.byType(LudoBoard));

      expect(board.tokens, same(GameScreen.previewTokens));
      expect(board.onTokenPressed, isNotNull);
      expect(find.byType(LudoToken), findsNWidgets(9));

      expect(board.visualStates['red_token_1']?.isMovable, isTrue);
      expect(board.visualStates['red_token_1']?.isSelected, isFalse);

      // The preview begins with the second stacked red token selected so its
      // selection treatment and z-order can be visually inspected.
      expect(board.visualStates['red_token_2']?.isMovable, isTrue);
      expect(board.visualStates['red_token_2']?.isSelected, isTrue);

      expect(board.visualStates['yellow_token_1']?.isMoving, isTrue);
    });

    testWidgets('updates visual selection when a token is pressed', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      await tester.tap(
        find.byKey(LudoToken.repaintBoundaryKeyFor('green_token_1')),
      );
      await tester.pump();

      final board = tester.widget<LudoBoard>(find.byType(LudoBoard));

      expect(board.visualStates['green_token_1']?.isMovable, isTrue);
      expect(board.visualStates['green_token_1']?.isSelected, isTrue);
      expect(board.visualStates['red_token_2']?.isSelected, isFalse);
    });

    testWidgets('allows an idle preview token to display selection', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      await tester.tap(
        find.byKey(LudoToken.repaintBoundaryKeyFor('blue_token_0')),
      );
      await tester.pump();

      final board = tester.widget<LudoBoard>(find.byType(LudoBoard));
      final selectedState = board.visualStates['blue_token_0'];

      // Selecting an idle token proves this preview does not infer legality
      // from the movable flag. It only reflects which token was pressed.
      expect(selectedState?.isMovable, isFalse);
      expect(selectedState?.isSelected, isTrue);
    });

    testWidgets('shows the board screen title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      expect(find.text('Ludo Board'), findsOneWidget);
      expect(find.byTooltip('Return home'), findsOneWidget);
    });
  });
}
