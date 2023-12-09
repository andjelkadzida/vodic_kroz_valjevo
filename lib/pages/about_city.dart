import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

class AboutCity extends StatelessWidget {
  AboutCity({Key? key}) : super(key: key);

  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Semantics(
                label: localization(context).aboutCity,
                child: Text(localization(context).aboutCity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                    ))),
            centerTitle: true,
            backgroundColor: Colors.black,
            iconTheme:
                const IconThemeData(color: Colors.white) // Color of drawer icon
            ));
  }
}
