import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../text_to_speech/text_to_speech_config.dart';
import '../localization/supported_languages.dart';
import '../styles/common_styles.dart';

class SightDetailsPage extends StatelessWidget {
  final Uint8List imageBytes;
  final String title;
  final String description;

  const SightDetailsPage({
    Key? key,
    required this.imageBytes,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
            label: title,
            child: Text(title,
                style: AppStyles.defaultAppBarTextStyle(textScaler))),
        centerTitle: true,
        excludeHeaderSemantics: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.memory(imageBytes),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                description,
                style: AppStyles.sightTitleStyle(textScaler),
              ),
            ),
            GestureDetector(
                onTap: () => TextToSpeechConfig.instance.speak(description),
                onDoubleTap: () => TextToSpeechConfig.instance.pauseSpeaking(),
                child: Icon(
                  Icons.volume_up_sharp,
                  size: textScaler.scale(48),
                  semanticLabel: localization(context).tapToHearDetails,
                )),
          ],
        ),
      ),
    );
  }
}
