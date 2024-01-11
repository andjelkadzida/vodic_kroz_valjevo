import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    //Check connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
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
    } else if (connectivityResult == ConnectivityResult.none) {
      //TO-DO Change toast message
      Fluttertoast.showToast(
          msg: "This is Center Short Toast",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      AppSettings.openAppSettings(type: AppSettingsType.wireless);
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
