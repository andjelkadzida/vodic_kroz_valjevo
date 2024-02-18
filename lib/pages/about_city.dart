import 'package:flutter/material.dart';

import '../database_config/database_helper.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/cutom_app_bar.dart';
import '../text_to_speech/text_to_speech_config.dart';

class AboutCity extends StatelessWidget {
  const AboutCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, localization(context).aboutCity),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAboutCityFromDatabase(localization(context).localeName),
        builder: (context, snapshot) {
          return DatabaseHelper.buildFutureState<List<Map<String, dynamic>>>(
            context: context,
            snapshot: snapshot,
            onData: (data) => _buildAboutCityContent(context, data),
          );
        },
      ),
    );
  }

  Widget _buildAboutCityContent(
      BuildContext context, List<Map<String, dynamic>> data) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: MediaQuery.of(context).size.width > 600 ? 20.0 : 10.0,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                Image.asset('images/vaPogled.jpg', fit: BoxFit.cover),
                const SizedBox(height: 20.0),
                _buildResponsiveDataTable(context),
                const SizedBox(height: 20.0),
                ...data.map((legend) => _buildExpansionTile(context, legend)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveDataTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
              label: Icon(
                Icons.people,
                semanticLabel: 'Indicator',
                size: MediaQuery.of(context).size.width * 0.07,
              ),
              tooltip: 'Indicator'),
          DataColumn(
              label: Icon(
                Icons.attribution,
                semanticLabel: localization(context).value,
                size: MediaQuery.of(context).size.width * 0.07,
              ),
              tooltip: localization(context).value),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('Total Population')),
            DataCell(Text('1.2 million')),
          ]),
          DataRow(cells: [
            DataCell(Text('Povrsina')),
            DataCell(Text('1.2 million')),
          ]),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
      BuildContext context, Map<String, dynamic> legend) {
    return Card(
      child: ExpansionTile(
        title: Text(
          legend['title'],
          style: Theme.of(context).textTheme.titleLarge,
        ),
        children: [
          ListTile(
            title: Text(
              legend['description'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Semantics(
              label: 'Play explanation about ${legend['title']}',
              child: GestureDetector(
                onDoubleTap: () => TextToSpeechConfig.instance.stopSpeaking(),
                child: IconButton(
                  icon: Icon(Icons.volume_up,
                      size: MediaQuery.of(context).size.width * 0.07),
                  onPressed: () {
                    TextToSpeechConfig.instance.speak(legend['description']);
                  },
                  tooltip: localization(context).tapToHearLegend,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getAboutCityFromDatabase(
      String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    return await db.rawQuery('''
      SELECT 
        legend_title_$languageCode AS title,
        legend_description_$languageCode AS description        
      FROM AboutCity
    ''');
  }
}
