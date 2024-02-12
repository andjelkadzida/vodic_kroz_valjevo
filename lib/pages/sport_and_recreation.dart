import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../database_config/database_helper.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';

class SportsAndRecreation extends StatelessWidget {
  const SportsAndRecreation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization(context).sportRecreation,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getSportsDataFromDatabase(localization(context).localeName),
        builder: (context, snapshot) {
          return DatabaseHelper.buildFutureState<List<Map<String, dynamic>>>(
            context: context,
            snapshot: snapshot,
            onData: (data) => _buildSportsSlider(context, data),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildSportsSlider(
      BuildContext context, List<Map<String, dynamic>> data) {
    double viewportFraction =
        MediaQuery.of(context).size.width < 600 ? 0.8 : 0.5;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: PageView.builder(
        itemCount: data.length,
        controller: PageController(viewportFraction: viewportFraction),
        itemBuilder: (context, index) {
          var item = data[index];
          Uint8List imageBytes = item['sports_image_path'];
          return _buildSportsItem(context, item['title'], imageBytes);
        },
      ),
    );
  }

  Widget _buildSportsItem(
      BuildContext context, String title, Uint8List imageBytes) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal[300],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1, //Change to 2 if needed
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Getting hotel data from the database
  Future<List<Map<String, dynamic>>> _getSportsDataFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT
        sports_image_path,
        title_$languageCode AS title
      FROM SportsAndRecreation
    ''');
    return data;
  }
}
