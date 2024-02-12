import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../styles/common_styles.dart';

class AboutCity extends StatelessWidget {
  const AboutCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
            label: localization(context).aboutCity,
            child: Text(localization(context).aboutCity,
                style: AppStyles.defaultAppBarTextStyle(
                    MediaQuery.of(context).textScaler))),
        excludeHeaderSemantics: true,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Color of drawer icon
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
