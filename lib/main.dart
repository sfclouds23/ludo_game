import 'package:flutter/material.dart';

import 'core/config/app_config.dart';

void main() {
  final AppConfig config = AppConfig.fromEnvironment();

  runApp(
    LudoApp(config: config),
  );
}

class LudoApp extends StatelessWidget {
  const LudoApp({
    required this.config,
    super.key,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ludo'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Environment: ${config.environment.name}',
              ),
              const SizedBox(height: 8),
              Text(
                'API: ${config.apiBaseUrl}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}