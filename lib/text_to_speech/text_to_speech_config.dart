import 'package:app_settings/app_settings.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../helper/internet_connectivity.dart';

class TextToSpeechConfig {
  static final TextToSpeechConfig _instance = TextToSpeechConfig._internal();
  final FlutterTts flutterTts = FlutterTts();
  bool isPaused = false;

  TextToSpeechConfig._internal();

  static TextToSpeechConfig get instance => _instance;

  Future<void> setLanguage(String languageCode) async {
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    await flutterTts.setLanguage(languageCode);
  }

  Future<void> speak(String text) async {
    // Check internet connection
    bool isConnected = await checkInitialInternetConnection();
    if (!isConnected) {
      AppSettings.openAppSettings(type: AppSettingsType.wireless);
      return;
    }
    // Setting configurations
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
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(text);
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
