import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

class Sights extends StatelessWidget {
  const Sights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(localization(context).sights,
                style: const TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.black,
            iconTheme:
                const IconThemeData(color: Colors.white) // Color of drawer icon
            ),
        body: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        )));
  }
}
