import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board_painter.dart';

void main() {
  group('LudoBoard', () {
    testWidgets('remains square when width is the limiting dimension', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 320, height: 500, child: LudoBoard()),
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(LudoBoard.repaintBoundaryKey)),
        const Size.square(320),
      );
    });

    testWidgets('remains square when height is the limiting dimension', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 500, height: 280, child: LudoBoard()),
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(LudoBoard.repaintBoundaryKey)),
        const Size.square(280),
      );
    });

    testWidgets('respects its maximum dimension on large layouts', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 600,
              height: 500,
              child: LudoBoard(maximumDimension: 400),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(LudoBoard.repaintBoundaryKey)),
        const Size.square(400),
      );
    });

    testWidgets('isolates the board behind a repaint boundary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.square(dimension: 300, child: LudoBoard()),
        ),
      );

      expect(find.byKey(LudoBoard.repaintBoundaryKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(LudoBoard.repaintBoundaryKey),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses the production board painter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.square(dimension: 300, child: LudoBoard()),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byKey(LudoBoard.repaintBoundaryKey),
          matching: find.byType(CustomPaint),
        ),
      );

      expect(customPaint.painter, isA<LudoBoardPainter>());
    });
  });
}
