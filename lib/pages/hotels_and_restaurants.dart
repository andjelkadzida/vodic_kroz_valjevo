import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

class HotelsAndRestaurants extends StatelessWidget {
  const HotelsAndRestaurants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Semantics(
              label: localization(context).restaurantsAndHotels,
              child: Text(localization(context).restaurantsAndHotels,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ))),
          centerTitle: true,
          backgroundColor: Colors.black,
          iconTheme:
              const IconThemeData(color: Colors.white) // Color of drawer icon
          ),
    );
  }
}
