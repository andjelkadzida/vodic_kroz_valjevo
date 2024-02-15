import 'package:flutter/material.dart';

import '../text_to_speech/text_to_speech_config.dart';
import '../localization/supported_languages.dart';
import '../styles/common_styles.dart';

class SightDetailsPage extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;

  const SightDetailsPage({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  SightDetailsPageState createState() => SightDetailsPageState();
}

class SightDetailsPageState extends State<SightDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: AppStyles.defaultAppBarTextStyle(
              MediaQuery.of(context).textScaler),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ExpansionTile(
                trailing: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: MediaQuery.of(context).textScaler.scale(35),
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
                          style: AppStyles.sightTitleStyle(
                              MediaQuery.of(context).textScaler),
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
                          size: MediaQuery.of(context).textScaler.scale(30),
                        ),
                      ),
                    ],
                  ),
                ),
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _opacityAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: Text(
                          widget.description,
                          style: AppStyles.sightTitleStyle(
                              MediaQuery.of(context).textScaler),
                          textAlign: TextAlign.justify,
                        ),
                      );
                    },
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
