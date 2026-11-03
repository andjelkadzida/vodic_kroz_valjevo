import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../text_to_speech/text_to_speech_config.dart';
import 'supported_languages.dart';

class LocaleController extends ChangeNotifier {
  Locale? _locale;
  bool _disposed = false;
  int _revision = 0;

  Locale? get locale => _locale;

  Future<void> load() async {
    final revision = _revision;
    final value = await getLocale();
    if (!_disposed && revision == _revision) _apply(value);
  }

  Future<void> select(String scriptCode) async {
    final revision = ++_revision;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
    final value = await setLocale(scriptCode);
    if (!_disposed && revision == _revision) _apply(value);
  }

  void _apply(Locale value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
    TextToSpeechConfig.instance.setLanguage(value.languageCode);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    Key? key,
    required LocaleController controller,
    required Widget child,
  }) : super(key: key, notifier: controller, child: child);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    final controller = scope?.notifier;
    if (controller == null) {
      throw FlutterError('LocaleScope is missing from the widget tree.');
    }
    return controller;
  }
}
