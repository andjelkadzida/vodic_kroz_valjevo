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
    return Semantics(
      label: localization(context).menuItem(label),
      button: true,
      enabled: true,
      onTapHint: localization(context).tapToOpen(label),
      child: Card(
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 160),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Lottie.asset(
                          lottieAsset,
                          animate: !MediaQuery.disableAnimationsOf(context),
                        ),
                        Icon(
                          icon,
                          size: 44,
                          color: const Color.fromRGBO(11, 20, 32, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color.fromRGBO(11, 20, 32, 1),
                          fontWeight: FontWeight.w400,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
