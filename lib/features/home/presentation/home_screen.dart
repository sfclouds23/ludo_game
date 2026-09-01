import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/app_config_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the provider makes configuration available through dependency
    // injection instead of requiring HomeScreen to construct it itself.
    final AppConfig config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ludo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ludo Home'),
            const SizedBox(height: 16),
            Text('Environment: ${config.environment.name}'),
            const SizedBox(height: 8),
            Text('API: ${config.apiBaseUrl}'),
          ],
        ),
      ),
    );
  }
}
