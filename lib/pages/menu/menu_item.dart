import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../localization/supported_languages.dart';

class MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String lottieAsset;
  final VoidCallback onTap;

  const MenuItem({
    Key? key,
    required this.label,
    required this.icon,
    required this.lottieAsset,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highContrast =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Semantics(
      label: localization(context).menuItem(label),
      button: true,
      enabled: true,
      onTapHint: localization(context).tapToOpen(label),
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Lottie.asset(lottieAsset,
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.width * 0.2),
              ),
              Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: highContrast ? Colors.white : Colors.teal,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            letterSpacing: 1,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  )),
              Center(
                child: Icon(
                  icon,
                  size: MediaQuery.of(context).size.width * 0.12,
                  color: highContrast ? Colors.white : Colors.teal,
                  applyTextScaling: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
