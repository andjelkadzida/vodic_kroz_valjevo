import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../text_to_speech/text_to_speech_config.dart';
import '../localization/supported_languages.dart';
import '../styles/common_styles.dart';

class SightDetailsPage extends StatefulWidget {
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
  _SightDetailsPageState createState() => _SightDetailsPageState();
}

class _SightDetailsPageState extends State<SightDetailsPage> {
  double opacity = 0.0;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: AppStyles.defaultAppBarTextStyle(textScaler)),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(seconds: 1),
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ExpansionTile(
                trailing: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: textScaler.scale(35),
                  color: Colors.blue,
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    isExpanded = expanded;
                  });
                },
                title: Semantics(
                  label: localization(context).description,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          localization(context).description,
                          style: AppStyles.sightTitleStyle(textScaler),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => TextToSpeechConfig.instance
                            .speak(widget.description),
                        onDoubleTap: () =>
                            TextToSpeechConfig.instance.stopSpeaking(),
                        child: Icon(
                          Icons.volume_up_sharp,
                          semanticLabel: localization(context).tapToHearDetails,
                          size: textScaler.scale(30),
                        ),
                      ),
                    ],
                  ),
                ),
                children: <Widget>[
                  AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(seconds: 1),
                    child: Text(
                      widget.description,
                      style: AppStyles.sightTitleStyle(textScaler),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
