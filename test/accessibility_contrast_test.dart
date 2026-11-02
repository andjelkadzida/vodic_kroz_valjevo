import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/helper/accessibility_theme.dart';

void main() {
  test('text and links meet WCAG AA contrast against their surfaces', () {
    final appBarColors = [
      const Color.fromRGBO(87, 19, 20, 1),
      const Color.fromRGBO(65, 89, 45, 1),
      const Color.fromRGBO(219, 33, 41, 1),
      const Color.fromRGBO(11, 20, 32, 1),
    ];
    for (final color in appBarColors) {
      expect(_contrast(Colors.white, color), greaterThanOrEqualTo(4.5));
    }
    expect(_contrast(accessibleLinkColor, Colors.white),
        greaterThanOrEqualTo(4.5));
    final brightestScrimmedPhoto =
        Color.alphaBlend(photoTextScrim, Colors.white);
    expect(_contrast(Colors.white, brightestScrimmedPhoto),
        greaterThanOrEqualTo(4.5));
  });
}

double _contrast(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}
