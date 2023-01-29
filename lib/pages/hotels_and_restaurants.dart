import 'package:flutter/material.dart';

class HotelsAndRestaurants extends StatelessWidget {
  const HotelsAndRestaurants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restorani i prenociste"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
    );
  }
}
