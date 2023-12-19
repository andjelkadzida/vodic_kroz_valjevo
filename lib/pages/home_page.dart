import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/styles/common_styles.dart';

import '../navigation/navigation_drawer.dart' as nav_drawer;

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
          title: Semantics(
              label: localization(context).homePage,
              child: Text(localization(context).homePage,
                  style: AppStyles.defaultAppBarTextStyle(textScaler))),
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
