import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';
import 'text_to_speech_config.dart';

class SpeechControls extends StatelessWidget {
  const SpeechControls({
    Key? key,
    required this.text,
    required this.readLabel,
  }) : super(key: key);

  final String text;
  final String readLabel;

  Future<void> _run(
      BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('Text-to-speech failed: ${error.runtimeType}');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(localization(context).speechUnavailable),
            action: SnackBarAction(
              label: localization(context).ok,
              onPressed: () {},
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final speech = TextToSpeechConfig.instance;
    return Wrap(
      children: [
        GestureDetector(
          excludeFromSemantics: true,
          onDoubleTap: () => _run(context, speech.stopSpeaking),
          child: IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            visualDensity: VisualDensity.standard,
            tooltip: readLabel,
            onPressed: () => _run(context, () => speech.speak(text)),
            icon: Icon(Icons.volume_up, semanticLabel: readLabel),
          ),
        ),
        IconButton(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          visualDensity: VisualDensity.standard,
          tooltip: localization(context).stopReading,
          onPressed: () => _run(context, speech.stopSpeaking),
          icon: Icon(Icons.stop,
              semanticLabel: localization(context).stopReading),
        ),
      ],
    );
  }
}
