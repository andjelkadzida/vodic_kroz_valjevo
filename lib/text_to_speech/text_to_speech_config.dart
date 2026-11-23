import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum SpeechState { stopped, playing, paused }

/// Jedna, deljena instanca za citanje teksta.
///
/// Nasledjuje ChangeNotifier: svaki SpeechControls na bilo kojoj stranici
/// slusa promene i sam se osvezava kada citanje pocne, pauzira se, zaustavi
/// se ili se zavrsi.
class TextToSpeechConfig extends ChangeNotifier {
  static final TextToSpeechConfig _instance = TextToSpeechConfig._internal();
  final FlutterTts flutterTts;
  final bool _isIOS;
  String? _requestedLanguage;
  String? _configuredLanguage;

  SpeechState _state = SpeechState.stopped;
  String? _currentText;

  TextToSpeechConfig._internal()
      : flutterTts = FlutterTts(),
        _isIOS = Platform.isIOS {
    _registerHandlers();
  }

  @visibleForTesting
  TextToSpeechConfig.forTesting({
    required this.flutterTts,
    required bool isIOS,
  }) : _isIOS = isIOS {
    _registerHandlers();
  }

  static TextToSpeechConfig get instance => _instance;

  SpeechState get state => _state;

  /// Text that is currently being read or is paused (null if nothing is active).
  String? get currentText => _currentText;

  bool get isPlaying => _state == SpeechState.playing;
  bool get isPaused => _state == SpeechState.paused;

  /// Something is being read or is paused.
  bool get isActive => _state != SpeechState.stopped;

  /// Whether this text is the one currently being read or paused.
  bool isCurrent(String text) => isActive && _currentText == text;

  void _registerHandlers() {
    // When the text is finished (or an error occurs), return the buttons
    // to the initial state on all pages.
    flutterTts.setCompletionHandler(() => _update(SpeechState.stopped, null));
    flutterTts.setErrorHandler((_) => _update(SpeechState.stopped, null));
  }

  void _update(SpeechState state, String? text) {
    if (_state == state && _currentText == text) return;
    _state = state;
    _currentText = text;
    notifyListeners();
  }

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
    final voiceLanguage = _isIOS && languageCode == 'sr' ? 'hr' : languageCode;
    final result = await flutterTts.setLanguage(voiceLanguage);
    if (result == 0 || result == false) {
      throw const SpeechUnavailableException();
    }
  }

  /// Plays [text] from the beginning. If another text is currently being read (or paused),
  /// e.g., from the previous page, it is stopped first.
  Future<void> speak(String text) async {
    try {
      if (isActive) {
        await flutterTts.stop();
        _update(SpeechState.stopped, null);
      }

      while (_requestedLanguage != null &&
          _configuredLanguage != _requestedLanguage) {
        final language = _requestedLanguage!;
        await _configureLanguage(language);
        if (_requestedLanguage == language) _configuredLanguage = language;
      }

      if (_isIOS) {
        final Object? categoryResult = await flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          const [
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
        if (categoryResult != 1 && categoryResult != true) {
          throw const SpeechUnavailableException();
        }
        final Object? activationResult =
            await flutterTts.setSharedInstance(true);
        if (activationResult != 1 && activationResult != true) {
          throw const SpeechUnavailableException();
        }
      }
      await flutterTts.awaitSpeakCompletion(false);
      final result = await flutterTts.speak(text);
      if (result == 0 || result == false) {
        throw const SpeechUnavailableException();
      }
      _update(SpeechState.playing, text);
    } catch (_) {
      _update(SpeechState.stopped, null);
      rethrow;
    }
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();
    _update(SpeechState.stopped, null);
  }

  Future<void> pauseSpeaking() async {
    if (!isPlaying) return;
    await flutterTts.pause();
    _update(SpeechState.paused, _currentText);
  }

  /// Continues a paused text. flutter_tts does not have a separate "resume" method:
  /// continuation is achieved by calling speak() again with the same text.
  Future<void> resumeSpeaking() async {
    final text = _currentText;
    if (!isPaused || text == null) return;
    final result = await flutterTts.speak(text);
    if (result == 0 || result == false) {
      _update(SpeechState.stopped, null);
      throw const SpeechUnavailableException();
    }
    _update(SpeechState.playing, text);
  }
}

class SpeechUnavailableException implements Exception {
  const SpeechUnavailableException();
}
