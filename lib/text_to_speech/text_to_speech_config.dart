import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechConfig {
  final FlutterTts flutterTts = FlutterTts();
  bool isPaused = false;

  Future<void> speak(String text) async {
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
