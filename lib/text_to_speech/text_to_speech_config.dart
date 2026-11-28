import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum SpeechState { stopped, starting, playing, paused }

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
  int _operationRevision = 0;
  int? _pendingStartRevision;
  int? _pendingStartOperation;
  int? _pendingPauseRevision;
  bool _pausedBeforeStart = false;
  bool _replacingPrevious = false;

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

  /// Text that is starting, being read, or paused (null if nothing is active).
  String? get currentText => _currentText;

  bool get isPlaying => _state == SpeechState.playing;
  bool get isPaused => _state == SpeechState.paused;
  bool get isStarting => _state == SpeechState.starting;

  /// Something is starting, being read, or paused.
  bool get isActive => _state != SpeechState.stopped;

  /// Whether this text is the one starting, being read, or paused.
  bool isCurrent(String text) => isActive && _currentText == text;

  void _registerHandlers() {
    flutterTts.setStartHandler(_handlePlaybackStarted);
    flutterTts.setContinueHandler(_handlePlaybackStarted);
    flutterTts.setPauseHandler(_handlePlaybackPaused);
    flutterTts.setCompletionHandler(_handlePlaybackEnded);
    flutterTts.setErrorHandler((error) {
      debugPrint('Text-to-speech playback failed: $error');
      _resetPlayback();
    });
  }

  void _handlePlaybackStarted() {
    if (!isStarting || _pendingStartRevision != _operationRevision) return;
    _pendingStartRevision = null;
    _replacingPrevious = false;
    _update(SpeechState.playing, _currentText);
  }

  void _handlePlaybackPaused() {
    if ((!isPlaying && !isStarting) ||
        _pendingPauseRevision != _operationRevision) {
      return;
    }
    _pendingStartRevision = null;
    _pendingPauseRevision = null;
    _replacingPrevious = false;
    _update(SpeechState.paused, _currentText);
  }

  void _handlePlaybackEnded() {
    // A previous utterance can finish while its replacement is being prepared.
    if (_pausedBeforeStart ||
        (isStarting && (_pendingStartRevision == null || _replacingPrevious))) {
      _replacingPrevious = false;
      return;
    }
    _resetPlayback();
  }

  void _resetPlayback() {
    _operationRevision++;
    _pendingStartRevision = null;
    _pendingPauseRevision = null;
    _pausedBeforeStart = false;
    _replacingPrevious = false;
    _update(SpeechState.stopped, null);
  }

  bool _isCurrentOperation(int revision) => revision == _operationRevision;

  /// Whether the start requested by [operation] is still awaited. A stop or
  /// pause request moves the pending start to its own revision, so the start
  /// stays valid if that request fails and is dropped once it succeeds.
  bool _isPendingStart(int operation) =>
      _pendingStartOperation == operation &&
      _pendingStartRevision != null &&
      _pendingStartRevision == _operationRevision;

  bool _ownsStart(int operation) =>
      _isCurrentOperation(operation) || _isPendingStart(operation);

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
    if (isStarting && _currentText == text) return;
    final wasActive = isActive;
    final operation = ++_operationRevision;
    _pendingStartRevision = null;
    _pendingPauseRevision = null;
    _pausedBeforeStart = false;
    _replacingPrevious = wasActive;
    _update(SpeechState.starting, text);
    try {
      if (wasActive) {
        await flutterTts.stop();
        if (!_isCurrentOperation(operation)) return;
      }

      while (_requestedLanguage != null &&
          _configuredLanguage != _requestedLanguage) {
        final language = _requestedLanguage!;
        await _configureLanguage(language);
        if (!_isCurrentOperation(operation)) return;
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
        if (!_isCurrentOperation(operation)) return;
        if (categoryResult != 1 && categoryResult != true) {
          throw const SpeechUnavailableException();
        }
        final Object? activationResult =
            await flutterTts.setSharedInstance(true);
        if (!_isCurrentOperation(operation)) return;
        if (activationResult != 1 && activationResult != true) {
          throw const SpeechUnavailableException();
        }
      }
      await flutterTts.awaitSpeakCompletion(false);
      if (!_isCurrentOperation(operation)) return;
      _pendingStartRevision = _pendingStartOperation = operation;
      final result = await flutterTts.speak(text);
      if (!_ownsStart(operation)) return;
      if (result == 0 || result == false) {
        throw const SpeechUnavailableException();
      }
      _handlePlaybackStarted();
    } catch (_) {
      if (_ownsStart(operation)) {
        _pendingStartRevision = _pendingPauseRevision = null;
        _replacingPrevious = false;
        _update(SpeechState.stopped, null);
      }
      rethrow;
    }
  }

  Future<void> stopSpeaking() async {
    final operation = ++_operationRevision;
    if (_pendingStartRevision != null) _pendingStartRevision = operation;
    if (_pendingPauseRevision != null) _pendingPauseRevision = operation;
    try {
      final result = await flutterTts.stop();
      if (!_isCurrentOperation(operation)) return;
      if (result == 0 || result == false) {
        throw const SpeechUnavailableException();
      }
      _pendingStartRevision = _pendingPauseRevision = null;
      _pausedBeforeStart = false;
      _replacingPrevious = false;
      _update(SpeechState.stopped, null);
    } catch (_) {
      if (_isCurrentOperation(operation) &&
          isStarting &&
          _pendingStartRevision == null) {
        _update(SpeechState.stopped, null);
      }
      rethrow;
    }
  }

  Future<void> pauseSpeaking() async {
    if ((!isPlaying && !isStarting) || _pendingPauseRevision != null) return;
    if (isStarting && _pendingStartRevision == null) {
      _operationRevision++;
      _pausedBeforeStart = true;
      _replacingPrevious = false;
      _update(SpeechState.paused, _currentText);
      return;
    }
    final operation = ++_operationRevision;
    if (_pendingStartRevision != null) _pendingStartRevision = operation;
    _pendingPauseRevision = operation;
    try {
      final result = await flutterTts.pause();
      if (!_isCurrentOperation(operation)) return;
      if (result == 0 || result == false) {
        throw const SpeechUnavailableException();
      }
      _handlePlaybackPaused();
    } catch (_) {
      if (_isCurrentOperation(operation)) _pendingPauseRevision = null;
      rethrow;
    }
  }

  /// Continues a paused text. flutter_tts does not have a separate "resume" method:
  /// continuation is achieved by calling speak() again with the same text.
  Future<void> resumeSpeaking() async {
    final text = _currentText;
    if (!isPaused || text == null) return;
    if (_pausedBeforeStart) {
      await speak(text);
      return;
    }
    final operation = ++_operationRevision;
    _pendingStartRevision = _pendingStartOperation = operation;
    _replacingPrevious = false;
    _update(SpeechState.starting, text);
    try {
      final result = await flutterTts.speak(text);
      if (!_ownsStart(operation)) return;
      if (result == 0 || result == false) {
        throw const SpeechUnavailableException();
      }
      _handlePlaybackStarted();
    } catch (_) {
      if (_ownsStart(operation)) {
        _pendingStartRevision = _pendingPauseRevision = null;
        _update(SpeechState.paused, text);
      }
      rethrow;
    }
  }
}

class SpeechUnavailableException implements Exception {
  const SpeechUnavailableException();
}
