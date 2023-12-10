import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

class AboutCity extends StatelessWidget {
  const AboutCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
            label: localization(context).aboutCity,
            child: Text(
              localization(context).aboutCity,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w300,
              ),
            )),
        excludeHeaderSemantics: true,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Color of drawer icon
      ),
    );
  }
}
