import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_game/features/game/presentation/board/ludo_board.dart';

void main() {
  final scenarios = [
    (
      name: 'small phone at 1x density',
      logicalSize: const Size(320, 568),
      devicePixelRatio: 1.0,
      expectedBoardSize: 320.0,
    ),
    (
      name: 'modern phone at 3x density',
      logicalSize: const Size(390, 844),
      devicePixelRatio: 3.0,
      expectedBoardSize: 390.0,
    ),
    (
      name: 'tablet at 2x density',
      logicalSize: const Size(768, 1024),
      devicePixelRatio: 2.0,
      expectedBoardSize: 720.0,
    ),
    (
      name: 'wide web viewport at 1x density',
      logicalSize: const Size(1440, 900),
      devicePixelRatio: 1.0,
      expectedBoardSize: 720.0,
    ),
  ];

  group('LudoBoard responsive QA matrix', () {
    for (final scenario in scenarios) {
      testWidgets(scenario.name, (tester) async {
        final logicalSize = scenario.logicalSize;
        final devicePixelRatio = scenario.devicePixelRatio;

        // Widget tests configure physical pixels and density independently.
        // Dividing physical size by density produces the target logical size.
        tester.view.devicePixelRatio = devicePixelRatio;
        tester.view.physicalSize = Size(
          logicalSize.width * devicePixelRatio,
          logicalSize.height * devicePixelRatio,
        );

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LudoBoard())),
        );

        final boardFinder = find.byKey(LudoBoard.repaintBoundaryKey);
        final renderedSize = tester.getSize(boardFinder);

        expect(boardFinder, findsOneWidget);
        expect(renderedSize, Size.square(scenario.expectedBoardSize));
        expect(renderedSize.width, renderedSize.height);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
