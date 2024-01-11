import 'package:flutter/material.dart';

import '../navigation/navigation_drawer.dart' as nav_drawer;
import '../localization/supported_languages.dart';
import '../styles/common_styles.dart';

class HotelsAndRestaurants extends StatelessWidget {
  HotelsAndRestaurants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
          title: Semantics(
              label: localization(context).restaurantsAndHotels,
              child: Text(
                localization(context).restaurantsAndHotels,
                style: AppStyles.defaultAppBarTextStyle(textScaler),
              )),
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
