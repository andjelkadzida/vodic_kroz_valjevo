import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

import '../navigation/navigation_drawer.dart' as NavDrawer;

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Semantics(
              label: localization(context).appTitle,
              child: Text(localization(context).appTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300))),
          centerTitle: true,
          backgroundColor: Colors.black,
          iconTheme:
              const IconThemeData(color: Colors.white) // Color of drawer icon
          ),
      drawer: const NavDrawer.NavigationDrawer(),
    );
  }
}
