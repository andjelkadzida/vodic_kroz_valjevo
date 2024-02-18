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
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: MediaQuery.of(context).size.width > 600 ? 20.0 : 10.0,
        ),
        child: Column(
          children: [
            _buildResponsiveDataTable(context),
            const SizedBox(height: 20.0),
            ...data.map((legend) => _buildExpansionTile(context, legend)),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveDataTable(BuildContext context) {
    // Fallback to a more responsive layout for smaller screens
    if (MediaQuery.of(context).size.width < 600) {
      return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          ListTile(
            title: Text('Indicator'),
            subtitle: Text('Total Population'),
            trailing: Text('1.2 million'),
          ),
        ],
      );
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Indicator')),
        DataColumn(label: Text('Value')),
      ],
      rows: const [
        DataRow(cells: [
          DataCell(Text('Total Population')),
          DataCell(Text('1.2 million')),
        ]),
      ],
    );
  }

  Widget _buildExpansionTile(
      BuildContext context, Map<String, dynamic> legend) {
    return ExpansionTile(
      title: Text(legend['title'] as String,
          style: Theme.of(context).textTheme.subtitle1),
      children: [
        ListTile(
          title: Text(
            legend['description'] as String,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          trailing: Semantics(
            label: 'Play explanation about ${legend['title']}',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => TextToSpeechConfig.instance
                  .speak(legend['description'] as String),
              tooltip: 'Play explanation', // Tooltip for additional context
            ),
          ),
        ),
      ],
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
