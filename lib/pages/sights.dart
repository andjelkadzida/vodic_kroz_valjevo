import 'package:flutter/material.dart';

class Sights extends StatelessWidget {
  const Sights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Znamenitosti"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
    );
  }
}
