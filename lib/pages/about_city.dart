import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

class AboutCity extends StatelessWidget {
  const AboutCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localization(context).aboutCity),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
    );
  }
}
