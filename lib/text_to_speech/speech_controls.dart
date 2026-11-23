import 'package:material_ui/material_ui.dart';

import '../localization/supported_languages.dart';
import 'text_to_speech_config.dart';

/// Displays text-to-speech controls for the current page.
///
/// State of reading is shared across the entire application, so the buttons on each
/// page refresh themselves automatically:
///  - nothing is being read:                 [play]
///  - the text of this page is being read:   [pause] [stop]
///  - the text of this page is paused:       [resume] [stop]
///  - the text of another page is being read: [play this] [pause] [stop]
///  - the text of another page is paused:    [play this] [stop]
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

  Widget _button({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      visualDensity: VisualDensity.standard,
      tooltip: label,
      onPressed: onPressed,
      icon: Icon(icon, semanticLabel: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final speech = TextToSpeechConfig.instance;

    return ListenableBuilder(
      listenable: speech,
      builder: (context, _) {
        final l10n = localization(context);
        // Whether the text of this page is active (being read or paused).
        final isMine = speech.isCurrent(text);

        return Wrap(
          children: [
            // Play the text of this page. It is always shown, except when this
            // text is already active. If the text of another page is being read,
            // it is stopped and this one starts.
            if (!isMine)
              GestureDetector(
                excludeFromSemantics: true,
                onDoubleTap: () => _run(context, speech.stopSpeaking),
                child: _button(
                  icon: Icons.play_arrow,
                  label: readLabel,
                  onPressed: () => _run(context, () => speech.speak(text)),
                ),
              ),
            // Pause: for the text that is currently being read, from this or another page.
            if (speech.isPlaying)
              _button(
                icon: Icons.pause,
                label: l10n.pauseReading,
                onPressed: () => _run(context, speech.pauseSpeaking),
              ),
            // Resume: only when the text of this page is paused.
            if (isMine && speech.isPaused)
              _button(
                icon: Icons.play_arrow,
                label: l10n.resumeReading,
                onPressed: () => _run(context, speech.resumeSpeaking),
              ),
            // Stop: for any active text, from this or another page.
            if (speech.isActive)
              _button(
                icon: Icons.stop,
                label: l10n.stopReading,
                onPressed: () => _run(context, speech.stopSpeaking),
              ),
          ],
        );
      },
    );
  }
}
