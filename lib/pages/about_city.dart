import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/cutom_app_bar.dart';

class AboutCity extends StatelessWidget {
  const AboutCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).aboutCity,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: Center(
        child: Image.asset(
          'images/grbValjeva.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
