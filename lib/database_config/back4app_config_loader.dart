import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show Parser;

import 'back4app_config.dart';

final _keyPattern = RegExp(r'^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)$');
final _quotedValuePattern = RegExp(
  r'''^(?:"((?:\\.|[^"\\])*)"|'((?:\\.|[^'\\])*)')(?:\s*(?:#.*)?)?$''',
);
final _bracedReferencePattern = RegExp(r'(\\)?\$\{([^}]*)\}?');
final _referencePattern = RegExp(r'(\\)?\$(?:\{)?([A-Za-z_]\w*)(?:\})?');
final _variableNamePattern = RegExp(r'^[A-Za-z_]\w*$');

Future<Back4AppConfig> loadBack4AppConfig({AssetBundle? bundle}) async {
  final contents = await (bundle ?? rootBundle).loadString('.env');
  final environment = <String, String>{};
  const parser = Parser();
  var lineNumber = 0;

  for (final line in const LineSplitter().convert(contents)) {
    lineNumber++;
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    final separator = trimmed.indexOf('=');
    final keyMatch = separator < 0
        ? null
        : _keyPattern.firstMatch(trimmed.substring(0, separator).trim());
    if (keyMatch == null) {
      throw FormatException('Invalid .env entry on line $lineNumber.');
    }

    final key = keyMatch.group(1)!;
    if (environment.containsKey(key)) {
      throw FormatException('Duplicate .env key on line $lineNumber: $key');
    }

    final value = trimmed.substring(separator + 1).trim();
    if (value.startsWith("'") || value.startsWith('"')) {
      final quoted = _quotedValuePattern.firstMatch(value);
      if (quoted == null) {
        throw FormatException('Invalid quoted .env value on line $lineNumber.');
      }
      if ((quoted.group(1) ?? quoted.group(2)!).isEmpty) {
        environment[key] = '';
        continue;
      }
      if (parser.getSurroundingQuoteCharacter(value) != value[0]) {
        throw FormatException(
            'Unsupported quoted .env value on line $lineNumber.');
      }
    }

    if (!value.startsWith("'")) {
      final interpolated = parser.removeSurroundingQuotes(value);
      for (final match in _bracedReferencePattern.allMatches(interpolated)) {
        if (match.group(1) == null &&
            (!match.group(0)!.endsWith('}') ||
                !_variableNamePattern.hasMatch(match.group(2)!))) {
          throw FormatException(
              'Invalid .env variable reference on line $lineNumber.');
        }
      }
      for (final match in _referencePattern.allMatches(interpolated)) {
        if (match.group(1) == null &&
            !environment.containsKey(match.group(2))) {
          throw FormatException(
              'Undefined .env variable reference on line $lineNumber.');
        }
      }
    }

    final entry = parser.parseOne(trimmed, envMap: environment);
    if (entry.length != 1 || !entry.containsKey(key)) {
      throw FormatException('Invalid .env entry on line $lineNumber.');
    }
    environment[key] = entry[key]!;
  }

  return Back4AppConfig.fromEnvironment(environment);
}
