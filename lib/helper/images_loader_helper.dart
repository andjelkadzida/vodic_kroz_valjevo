import 'package:flutter/material.dart';

void precacheImages(BuildContext context, List<String> images) {
  for (String image in images) {
    precacheImage(AssetImage(image), context);
  }
}
