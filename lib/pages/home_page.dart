import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';

import '../localization/language.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          'images/kulaNenadovica.jpg',
          fit: BoxFit.cover,
          semanticLabel: localization(context).valjevoCityImage,
        ),
        Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(mediaQueryData.size.width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Explore.\nTravel.\nInspire.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: mediaQueryData.size.width * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                mediaQueryData.size.width * 0.05,
                0,
                mediaQueryData.size.width * 0.05,
                mediaQueryData.size.height * 0.02,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Semantics(
                  button: true,
                  label: 'Get Started Button',
                  child: ElevatedButton(
                    onPressed: () {
                      showLanguageMenuIfNeeded(context);
                    },
                    child: Text('Get Started'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: mediaQueryData.size.width * 0.1,
                        vertical: mediaQueryData.size.height * 0.02,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
