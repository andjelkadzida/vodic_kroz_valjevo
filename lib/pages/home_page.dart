import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double fontSizeTitle = constraints.maxWidth * 0.08;
            double fontSizeSubtitle = constraints.maxWidth * 0.04;
            double padding = constraints.maxWidth * 0.05;

            return Center(
              child: Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  image: DecorationImage(
                    image: AssetImage('assets/your_background_image.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Explore.\nTravel.\nInspire.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Life is all about journey.\nFind yours.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeSubtitle,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Semantics(
                      button: true,
                      label: 'Get Started Button',
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle button press
                        },
                        child: Text('Get Started'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
