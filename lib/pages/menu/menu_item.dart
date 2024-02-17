import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String lottieAsset;
  final VoidCallback onTap;
  final double size;

  const MenuItem({
    Key? key,
    required this.label,
    required this.icon,
    required this.lottieAsset,
    required this.onTap,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Lottie.asset(lottieAsset, width: size, height: size),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.teal,
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .fontSize,
                            letterSpacing: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  )),
              Center(
                child: Icon(
                  icon,
                  size: size * 0.2,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
