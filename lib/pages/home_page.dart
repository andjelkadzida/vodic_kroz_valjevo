import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/supported_languages.dart';
import '../localization/language.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('images/pogled.jpg'), context);
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
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
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: screenHeight * 0.1,
                    ),
                    Semantics(
                      label: localization(context).sloganLabel,
                      child: Text(
                        localization(context).slogan,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.05,
                0,
                screenWidth * 0.05,
                screenHeight * 0.02,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Semantics(
                  button: true,
                  label: localization(context).getStarted,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      showLanguageMenuIfNeeded(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                    child: Text(
                      localization(context).getStarted,
                      style: TextStyle(fontSize: screenWidth * 0.05),
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
