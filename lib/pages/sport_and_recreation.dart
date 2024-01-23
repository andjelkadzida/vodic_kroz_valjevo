import 'package:flutter/material.dart';

import '../navigation/navigation_drawer.dart' as nav_drawer;
import '../localization/supported_languages.dart';
import '../styles/common_styles.dart';

class SportsAndRecreation extends StatelessWidget {
  const SportsAndRecreation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
            label: localization(context).sportRecreation,
            child: Text(localization(context).sportRecreation,
                style: AppStyles.defaultAppBarTextStyle(
                    MediaQuery.of(context).textScaler))),
        excludeHeaderSemantics: true,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Color of drawer icon
      ),
      drawer: const nav_drawer.NavigationDrawer(),
    );
  }
}
