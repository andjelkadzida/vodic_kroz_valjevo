class Back4AppConfig {
  static const environmentKeys = [
    'KEY_APPLICATION_ID',
    'KEY_CLIENT_KEY',
    'KEY_PARSE_SERVER_URL',
  ];

  const Back4AppConfig({
    required this.applicationId,
    required this.clientKey,
    required this.serverUrl,
  });

  final String applicationId;
  final String clientKey;
  final Uri serverUrl;

  Map<String, String> toEnvironment() => {
        'KEY_APPLICATION_ID': applicationId,
        'KEY_CLIENT_KEY': clientKey,
        'KEY_PARSE_SERVER_URL': serverUrl.toString(),
      };

  factory Back4AppConfig.fromEnvironment(Map<String, String> environment) {
    if (environment.keys.any((key) => !environmentKeys.contains(key))) {
      throw const FormatException('Unexpected key in public Back4App config.');
    }

    String requiredValue(String name) {
      final value = environment[name]?.trim();
      if (value == null || value.isEmpty) {
        throw StateError('Missing Back4App configuration: $name');
      }
      return value;
    }

    final serverUrl = Uri.tryParse(requiredValue('KEY_PARSE_SERVER_URL'));
    final isLoopback = serverUrl != null &&
        (serverUrl.host == 'localhost' ||
            serverUrl.host == '127.0.0.1' ||
            serverUrl.host == '::1');
    if (serverUrl == null ||
        !serverUrl.hasAuthority ||
        serverUrl.host.isEmpty ||
        serverUrl.userInfo.isNotEmpty ||
        serverUrl.hasQuery ||
        serverUrl.hasFragment ||
        (serverUrl.scheme != 'https' &&
            !(serverUrl.scheme == 'http' && isLoopback))) {
      throw StateError(
        'KEY_PARSE_SERVER_URL must be an HTTPS URL without credentials, '
        'a query, or a fragment.',
      );
    }

    return Back4AppConfig(
      applicationId: requiredValue('KEY_APPLICATION_ID'),
      clientKey: requiredValue('KEY_CLIENT_KEY'),
      serverUrl: serverUrl,
    );
  }
}
