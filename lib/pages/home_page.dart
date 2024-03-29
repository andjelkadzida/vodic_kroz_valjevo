import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/supported_languages.dart';
import '../localization/language.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return FutureBuilder(
      future: precacheImage(
          const AssetImage('images/backgroundAndCoverImages/homeImage.jpg'),
          context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              semanticsLabel: localization(context).loading,
            ),
          );
        } else {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                'images/backgroundAndCoverImages/homeImage.jpg',
                fit: BoxFit.cover,
                semanticLabel: localization(context).valjevoCityImage,
              ),
              Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(screenSize.width * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: screenSize.height * 0.3,
                          ),
                          Text(
                            localization(context).song,
                            style: TextStyle(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              fontSize: screenSize.width * 0.05,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: screenSize.height * 0.06,
                          ),
                          Text(
                            localization(context).songAuthor,
                            style: TextStyle(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              fontSize: screenSize.width * 0.03,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      screenSize.width * 0.05,
                      0,
                      screenSize.width * 0.05,
                      screenSize.height * 0.02,
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
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.1,
                              vertical: screenSize.height * 0.02,
                            ),
                          ),
                          child: Text(
                            localization(context).getStarted,
                            style: TextStyle(fontSize: screenSize.width * 0.05),
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
      },
    );
  }
}
