import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';
import '../localization/language.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          'images/pogled.jpg',
          fit: BoxFit.contain,
          semanticLabel: localization(context).valjevoCityImage,
        ),
        Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      localization(context).slogan,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.08,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.05,
                0,
                MediaQuery.of(context).size.width * 0.05,
                MediaQuery.of(context).size.height * 0.02,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Semantics(
                  button: true,
                  label: localization(context).getStarted,
                  child: ElevatedButton(
                    onPressed: () {
                      showLanguageMenuIfNeeded(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.1,
                        vertical: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ),
                    child: Text(
                      localization(context).getStarted,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.05r),
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
