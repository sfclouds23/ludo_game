import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/game/presentation/game_screen.dart';
import '../../features/home/presentation/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/game',
      builder: (BuildContext context, GoRouterState state) {
        return const GameScreen();
      },
    ),
  ],
);
