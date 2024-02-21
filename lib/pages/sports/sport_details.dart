import 'package:flutter/material.dart';

class SportDetailsPage extends StatelessWidget {
  final Map<String, dynamic> sportData;

  const SportDetailsPage({Key? key, required this.sportData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sportData['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Image.asset(sportData['sport_image_path']),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
