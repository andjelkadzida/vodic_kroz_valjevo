import 'package:flutter/material.dart';

import '../navigation/navigation_drawer.dart' as nav_drawer;
import '../localization/supported_languages.dart';
import '../styles/common_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Semantics(
              label: localization(context).homePage,
              child: Text(localization(context).homePage,
                  style: AppStyles.defaultAppBarTextStyle(
                      MediaQuery.of(context).textScaler))),
          excludeHeaderSemantics: true,
          centerTitle: true,
          backgroundColor: Colors.black,
          iconTheme:
              const IconThemeData(color: Colors.white) // Color of drawer icon
          ),
      drawer: const nav_drawer.NavigationDrawer(),
    );
  }
}
