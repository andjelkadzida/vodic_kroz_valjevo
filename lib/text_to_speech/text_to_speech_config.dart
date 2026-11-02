import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechConfig {
  static final TextToSpeechConfig _instance = TextToSpeechConfig._internal();
  final FlutterTts flutterTts = FlutterTts();
  bool isPaused = false;
  String? _requestedLanguage;
  String? _configuredLanguage;

  TextToSpeechConfig._internal();

  static TextToSpeechConfig get instance => _instance;

  Future<void> setEngine() async {
    if (Platform.isAndroid) {
      List<Object?> engines = await flutterTts.getEngines;
      if (engines.contains('com.google.android.tts')) {
        await flutterTts.setEngine('com.google.android.tts');
      }
    }
  }

  void setLanguage(String languageCode) {
    if (_requestedLanguage != languageCode) {
      _requestedLanguage = languageCode;
      _configuredLanguage = null;
    }
  }

  Future<void> _configureLanguage(String languageCode) async {
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    final voiceLanguage =
        Platform.isIOS && languageCode == 'sr' ? 'hr' : languageCode;
    final result = await flutterTts.setLanguage(voiceLanguage);
    if (result == 0 || result == false) {
      throw const SpeechUnavailableException();
    }
  }

  Future<void> speak(String text) async {
    while (_requestedLanguage != null &&
        _configuredLanguage != _requestedLanguage) {
      final language = _requestedLanguage!;
      await _configureLanguage(language);
      if (_requestedLanguage == language) _configuredLanguage = language;
    }
    if (Platform.isIOS) {
      await flutterTts.setSharedInstance(true);
      await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }
    await flutterTts.awaitSpeakCompletion(false);
    final result = await flutterTts.speak(text);
    if (result == 0 || result == false) {
      throw const SpeechUnavailableException();
    }
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();
    isPaused = false;
  }

  Future<void> pauseSpeaking() async {
    await flutterTts.pause();
    isPaused = true;
  }

  Future<void> resumeSpeaking() async {
    if (isPaused) {
      await flutterTts.speak("");
      isPaused = false;
    }
  }
}

class SpeechUnavailableException implements Exception {
  const SpeechUnavailableException();
}
