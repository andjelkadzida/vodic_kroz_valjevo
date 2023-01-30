import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

import '../navigation/navigation_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localization(context).appTitle),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      drawer: const NavigationDrawer(),
    );
  }
}
