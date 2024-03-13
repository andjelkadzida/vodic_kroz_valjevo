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
    final screenWidth = MediaQuery.of(context).size.width;
    return Semantics(
      label: localization(context).menuItem(label),
      button: true,
      enabled: true,
      onTapHint: localization(context).tapToOpen(label),
      child: Card(
        margin: EdgeInsets.all(screenWidth * 0.01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Lottie.asset(lottieAsset,
                        width: screenWidth * 0.2, height: screenWidth * 0.2),
                    Center(
                      child: Icon(
                        icon,
                        size: screenWidth * 0.17,
                        color: const Color.fromRGBO(11, 20, 32, 1),
                        applyTextScaling: true,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color.fromRGBO(11, 20, 32, 1),
                        fontSize: screenWidth * 0.05,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
