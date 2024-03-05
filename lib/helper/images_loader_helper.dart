import 'package:flutter/material.dart';

Future<void> precacheImages(BuildContext context, List<String> images) async {
  await Future.wait(
    images.map((image) => precacheImage(AssetImage(image), context)).toList(),
  );
}
