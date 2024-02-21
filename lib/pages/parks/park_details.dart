import 'package:flutter/material.dart';

class ParkDetailsPage extends StatelessWidget {
  final Map<String, dynamic> parkData;

  const ParkDetailsPage({Key? key, required this.parkData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parkData['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Image.asset(parkData['park_image_path']),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
