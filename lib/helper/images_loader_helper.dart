import 'package:flutter/material.dart';

Future<void> precacheImages(BuildContext context, List<dynamic> images) async {
  await Future.wait(
    images.map((image) => precacheImage(AssetImage(image), context)).toList(),
  );
}
