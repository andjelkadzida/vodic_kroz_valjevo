import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:vodic_kroz_valjevo/text_to_speech/text_to_speech_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('iOS speech configures playback and mixing before speaking', () async {
    final tts = _FakeFlutterTts();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: true);
    speech.setLanguage('sr');

    await speech.speak('First');
    await speech.speak('Second');

    expect(tts.category, IosTextToSpeechAudioCategory.playback);
    expect(tts.options, [IosTextToSpeechAudioCategoryOptions.mixWithOthers]);
    expect(tts.mode, IosTextToSpeechAudioMode.voicePrompt);
    expect(tts.events, [
      'rate:0.5',
      'volume:1.0',
      'pitch:1.0',
      'language:hr',
      'category',
      'activate:true',
      'completion:false',
      'speak:First',
      'stop',
      'category',
      'activate:true',
      'completion:false',
      'speak:Second',
    ]);
  });

  test('non-iOS speech does not change the iOS audio session', () async {
    final tts = _FakeFlutterTts();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);
    speech.setLanguage('sr');

    await speech.speak('Hello');

    expect(tts.events, [
      'rate:0.5',
      'volume:1.0',
      'pitch:1.0',
      'language:sr',
      'completion:false',
      'speak:Hello',
    ]);
  });

  test(
      'playback starts before a delayed speak result and stays stopped on completion',
      () async {
    final tts = _FakeFlutterTts()..speakCompleter = Completer<dynamic>();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    final play = speech.speak('Hello');
    await Future<void>.delayed(Duration.zero);
    expect(speech.state, SpeechState.playing);
    expect(speech.currentText, 'Hello');

    tts.completionHandler?.call();
    tts.speakCompleter!.complete(1);
    await play;
    expect(speech.state, SpeechState.stopped);
  });

  test('completion before a delayed result is honored without a start callback',
      () async {
    final tts = _FakeFlutterTts()
      ..autoStart = false
      ..speakCompleter = Completer<dynamic>();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    final play = speech.speak('Hello');
    await Future<void>.delayed(Duration.zero);
    tts.completionHandler?.call();
    tts.speakCompleter!.complete(1);
    await play;
    expect(speech.state, SpeechState.stopped);
  });

  test('play, pause and resume work without native playback callbacks',
      () async {
    final tts = _FakeFlutterTts()
      ..autoStart = false
      ..autoPause = false;
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    await speech.speak('Hello');
    expect(speech.state, SpeechState.playing);
    await speech.pauseSpeaking();
    expect(speech.state, SpeechState.paused);
    await speech.resumeSpeaking();
    expect(speech.state, SpeechState.playing);
    expect(tts.events.where((event) => event == 'speak:Hello'), hasLength(2));
    expect(tts.events, contains('pause'));
  });

  test('a previous completion does not cancel a replacement', () async {
    final tts = _FakeFlutterTts();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    await speech.speak('First');
    tts.stopCompleter = Completer<dynamic>();
    final replacement = speech.speak('Second');
    tts.completionHandler?.call();
    tts.stopCompleter!.complete(1);
    await replacement;

    expect(tts.events, contains('speak:Second'));
    expect(speech.state, SpeechState.playing);
    expect(speech.currentText, 'Second');
  });

  test('a completion while a replacement awaits its start is ignored',
      () async {
    final tts = _FakeFlutterTts();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    await speech.speak('First');
    tts
      ..autoStart = false
      ..speakCompleter = Completer<dynamic>();
    final replacement = speech.speak('Second');
    await Future<void>.delayed(Duration.zero);
    tts.completionHandler?.call();
    expect(speech.currentText, 'Second');
    expect(speech.isPlaying, isFalse);
    tts.startHandler?.call();
    expect(speech.state, SpeechState.playing);
    tts.speakCompleter!.complete(1);
    await replacement;
    tts.completionHandler?.call();
    expect(speech.state, SpeechState.stopped);
  });

  test('a repeated play while starting does not queue another utterance',
      () async {
    final tts = _FakeFlutterTts()
      ..autoStart = false
      ..speakCompleter = Completer<dynamic>();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    final play = speech.speak('Hello');
    await Future<void>.delayed(Duration.zero);
    await speech.speak('Hello');
    expect(tts.events.where((event) => event == 'speak:Hello'), hasLength(1));
    await speech.stopSpeaking();
    tts.startHandler?.call();
    tts.speakCompleter!.complete(1);
    await play;
    expect(speech.state, SpeechState.stopped);
  });

  test('a rejected stop still allows a pending start to update the controls',
      () async {
    final tts = _FakeFlutterTts()
      ..autoStart = false
      ..speakCompleter = Completer<dynamic>();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    final play = speech.speak('Hello');
    await Future<void>.delayed(Duration.zero);
    tts.stopResult = 0;
    await expectLater(
      speech.stopSpeaking(),
      throwsA(isA<SpeechUnavailableException>()),
    );
    tts.startHandler?.call();
    expect(speech.state, SpeechState.playing);
    tts.speakCompleter!.complete(1);
    await play;
  });

  test('a failed stop during preparation does not leave controls stuck',
      () async {
    final tts = _FakeFlutterTts()
      ..completionSettingCompleter = Completer<dynamic>()
      ..stopResult = 0;
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    final play = speech.speak('Hello');
    await Future<void>.delayed(Duration.zero);
    await expectLater(
      speech.stopSpeaking(),
      throwsA(isA<SpeechUnavailableException>()),
    );
    expect(speech.state, SpeechState.stopped);
    tts.completionSettingCompleter!.complete(1);
    await play;
    expect(tts.events, isNot(contains('speak:Hello')));
  });

  test('resume follows the native continue event', () async {
    final tts = _FakeFlutterTts();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: true);

    await speech.speak('Hello');
    await speech.pauseSpeaking();
    tts
      ..autoStart = false
      ..speakCompleter = Completer<dynamic>();
    final resume = speech.resumeSpeaking();
    expect(speech.isPlaying, isFalse);
    tts.continueHandler?.call();
    expect(speech.state, SpeechState.playing);
    expect(speech.currentText, 'Hello');
    tts.speakCompleter!.complete(1);
    await resume;
  });

  test('pause can complete via the native event and reports a rejected pause',
      () async {
    final tts = _FakeFlutterTts()..autoPause = false;
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    await speech.speak('Hello');
    tts.pauseResult = 0;
    await expectLater(
      speech.pauseSpeaking(),
      throwsA(isA<SpeechUnavailableException>()),
    );
    expect(speech.state, SpeechState.playing);

    tts.pauseCompleter = Completer<dynamic>();
    final pause = speech.pauseSpeaking();
    expect(speech.state, SpeechState.playing);
    tts.pauseHandler?.call();
    expect(speech.state, SpeechState.paused);
    tts.pauseCompleter!.complete(1);
    await pause;
  });

  test('pausing during preparation can resume without starting twice',
      () async {
    final tts = _FakeFlutterTts()
      ..completionSettingCompleter = Completer<dynamic>();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    final play = speech.speak('Hello');
    await Future<void>.delayed(Duration.zero);
    await speech.pauseSpeaking();
    expect(speech.state, SpeechState.paused);
    expect(tts.events, isNot(contains('pause')));

    final resume = speech.resumeSpeaking();
    tts.completionSettingCompleter!.complete(1);
    await Future.wait([play, resume]);
    expect(speech.state, SpeechState.playing);
    expect(tts.events.where((event) => event == 'speak:Hello'), hasLength(1));
  });

  test('an old completion does not cancel a pause before replacement starts',
      () async {
    final tts = _FakeFlutterTts();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    await speech.speak('First');
    tts.stopCompleter = Completer<dynamic>();
    final replacement = speech.speak('Second');
    await speech.pauseSpeaking();
    tts.completionHandler?.call();
    expect(speech.state, SpeechState.paused);
    expect(speech.currentText, 'Second');
    tts.stopCompleter!.complete(1);
    await replacement;
    await speech.resumeSpeaking();
    expect(speech.state, SpeechState.playing);
    expect(speech.currentText, 'Second');
  });

  test('delayed pause cannot restore paused state after stop', () async {
    final tts = _FakeFlutterTts();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    await speech.speak('Hello');
    tts.pauseCompleter = Completer<dynamic>();
    final pause = speech.pauseSpeaking();
    await speech.stopSpeaking();
    tts.pauseCompleter!.complete(1);
    await pause;

    expect(speech.state, SpeechState.stopped);
  });

  test('delayed resume cannot restore playing state after stop', () async {
    final tts = _FakeFlutterTts();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    await speech.speak('Hello');
    await speech.pauseSpeaking();
    tts.speakCompleter = Completer<dynamic>();
    final resume = speech.resumeSpeaking();
    await speech.stopSpeaking();
    tts.speakCompleter!.complete(1);
    await resume;

    expect(speech.state, SpeechState.stopped);
  });

  test('delayed replacement stop cannot restart after stop', () async {
    final tts = _FakeFlutterTts();
    final speech = TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: false);

    await speech.speak('First');
    tts.stopCompleter = Completer<dynamic>();
    final replacement = speech.speak('Second');
    await Future<void>.delayed(Duration.zero);
    final stop = speech.stopSpeaking();
    tts.stopCompleter!.complete(1);
    await Future.wait([replacement, stop]);

    expect(speech.state, SpeechState.stopped);
    expect(tts.events, isNot(contains('speak:Second')));
  });

  for (final failure in [0, false, null]) {
    test('iOS category setup failure $failure is reported', () async {
      final tts = _FakeFlutterTts()..categoryResult = failure;
      final speech =
          TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: true);

      await expectLater(
        speech.speak('Hello'),
        throwsA(isA<SpeechUnavailableException>()),
      );
      expect(tts.events, ['category']);
    });

    test('iOS audio activation failure $failure is reported', () async {
      final tts = _FakeFlutterTts()..activationResult = failure;
      final speech =
          TextToSpeechConfig.forTesting(flutterTts: tts, isIOS: true);

      await expectLater(
        speech.speak('Hello'),
        throwsA(isA<SpeechUnavailableException>()),
      );
      expect(tts.events, ['category', 'activate:true']);
    });
  }
}

class _FakeFlutterTts extends FlutterTts {
  final events = <String>[];
  IosTextToSpeechAudioCategory? category;
  List<IosTextToSpeechAudioCategoryOptions>? options;
  IosTextToSpeechAudioMode? mode;
  Object? categoryResult = 1;
  Object? activationResult = 1;
  Completer<dynamic>? stopCompleter;
  Completer<dynamic>? pauseCompleter;
  Completer<dynamic>? speakCompleter;
  Completer<dynamic>? completionSettingCompleter;
  bool autoStart = true;
  bool autoPause = true;
  Object? pauseResult = 1;
  Object? stopResult = 1;

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    events.add('rate:$rate');
    return 1;
  }

  @override
  Future<dynamic> setVolume(double volume) async {
    events.add('volume:$volume');
    return 1;
  }

  @override
  Future<dynamic> setPitch(double pitch) async {
    events.add('pitch:$pitch');
    return 1;
  }

  @override
  Future<dynamic> setLanguage(String language) async {
    events.add('language:$language');
    return 1;
  }

  @override
  Future<dynamic> setIosAudioCategory(
    IosTextToSpeechAudioCategory category,
    List<IosTextToSpeechAudioCategoryOptions> options, [
    IosTextToSpeechAudioMode mode = IosTextToSpeechAudioMode.defaultMode,
  ]) async {
    this.category = category;
    this.options = options;
    this.mode = mode;
    events.add('category');
    return categoryResult;
  }

  @override
  Future<dynamic> setSharedInstance(bool sharedSession) async {
    events.add('activate:$sharedSession');
    return activationResult;
  }

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async {
    events.add('completion:$awaitCompletion');
    if (completionSettingCompleter != null) {
      return completionSettingCompleter!.future;
    }
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    events.add('speak:$text');
    if (autoStart) startHandler?.call();
    if (speakCompleter != null) return speakCompleter!.future;
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    events.add('stop');
    if (stopCompleter != null) return stopCompleter!.future;
    return stopResult;
  }

  @override
  Future<dynamic> pause() async {
    events.add('pause');
    if (pauseCompleter != null) return pauseCompleter!.future;
    if (autoPause && pauseResult == 1) pauseHandler?.call();
    return pauseResult;
  }
}
