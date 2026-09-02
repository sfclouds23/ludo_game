enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromValue(String value) {
    return switch (value) {
      'development' => AppEnvironment.development,
      'staging' => AppEnvironment.staging,
      'production' => AppEnvironment.production,
      _ => throw ArgumentError.value(
        value,
        'APP_ENV',
        'Unsupported application environment',
      ),
    };
  }
}
