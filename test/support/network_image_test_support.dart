import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final testPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAQSURBVBhXY2Bg+P+fARkAABz1Af843v6+AAAAAElFTkSuQmCC',
);

Future<void> waitForWidgetCondition(
  WidgetTester tester,
  bool Function() condition, {
  String Function()? debug,
}) async {
  for (var attempt = 0; attempt < 120; attempt++) {
    await tester.pump();
    if (condition()) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
  }
  fail('Timed out waiting for the widget state. ${debug?.call() ?? ''}');
}

class RealHttpOverrides extends HttpOverrides {}
