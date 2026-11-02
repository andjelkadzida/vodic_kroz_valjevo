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
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    events.add('speak:$text');
    return 1;
  }
}
