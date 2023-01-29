import 'package:flutter/material.dart';

class AboutCity extends StatelessWidget {
  const AboutCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("O gradu"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
    );
  }
}
