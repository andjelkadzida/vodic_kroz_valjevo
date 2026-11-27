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
class SpeechControls extends StatefulWidget {
  const SpeechControls({
    Key? key,
    required this.text,
    required this.readLabel,
  }) : super(key: key);

  final String text;
  final String readLabel;

  @override
  State<SpeechControls> createState() => _SpeechControlsState();
}

class _SpeechControlsState extends State<SpeechControls> {
  final FocusNode _primaryFocus = FocusNode();

  @override
  void dispose() {
    _primaryFocus.dispose();
    super.dispose();
  }

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
    FocusNode? focusNode,
  }) {
    return IconButton(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      visualDensity: VisualDensity.standard,
      tooltip: label,
      onPressed: onPressed,
      focusNode: focusNode,
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
        final isMine = speech.isCurrent(widget.text);

        IconData primaryIcon;
        String primaryLabel;
        VoidCallback primaryAction;
        if (isMine && speech.isPaused) {
          primaryIcon = Icons.play_arrow;
          primaryLabel = l10n.resumeReading;
          primaryAction = () => _run(context, speech.resumeSpeaking);
        } else if (speech.isPlaying && isMine) {
          primaryIcon = Icons.pause;
          primaryLabel = l10n.pauseReading;
          primaryAction = () => _run(context, speech.pauseSpeaking);
        } else {
          primaryIcon = Icons.play_arrow;
          primaryLabel = widget.readLabel;
          primaryAction = () => _run(context, () => speech.speak(widget.text));
        }

        return Wrap(
          children: [
            // Keep the primary action mounted so it retains focus as playback
            // changes between Read, Pause, and Resume.
            _button(
              icon: primaryIcon,
              label: primaryLabel,
              focusNode: _primaryFocus,
              onPressed: primaryAction,
            ),
            // Stop: for any active text, from this or another page.
            if (speech.isActive)
              _button(
                icon: Icons.stop,
                label: l10n.stopReading,
                onPressed: () => _run(context, () async {
                  if (mounted) _primaryFocus.requestFocus();
                  await speech.stopSpeaking();
                }),
              ),
          ],
        );
      },
    );
  }
}
