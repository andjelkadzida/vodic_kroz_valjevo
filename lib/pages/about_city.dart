import 'dart:math';

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
      appBar: customAppBar(
        context,
        localization(context).aboutCity,
        const Color.fromRGBO(219, 33, 41, 1),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        unselectedColor: Color.fromRGBO(219, 33, 41, 1),
      ),
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
    final screenSize = MediaQuery.of(context).size;
    var imagePath = data.first['about_city_image_path'];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.01,
                    horizontal: screenSize.width * 0.05,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Semantics(
                          label: localization(context).valjevoCityImage,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        _buildResponsiveDataTable(context),
                        SizedBox(height: screenSize.height * 0.02),
                        _buildHistoryCard(context, data.first),
                        SizedBox(height: screenSize.height * 0.02),
                        ExpansionTile(
                          title: Text(localization(context).legendOfTheCity,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontSize: screenSize.width * 0.07,
                                    fontWeight: FontWeight.w500,
                                  )),
                          children: data
                              .map((legend) =>
                                  _buildExpansionTile(context, legend))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildResponsiveDataTable(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: const Color.fromRGBO(219, 33, 41, 1),
          dataTableTheme: DataTableThemeData(
            dataTextStyle: TextStyle(
              fontSize: screenSize.width * 0.042,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        child: DataTable(
          columns: [
            DataColumn(
                label: Icon(
                  Icons.info_outline,
                  semanticLabel: localization(context).indicator,
                  size: Theme.of(context).iconTheme.size,
                  applyTextScaling: true,
                  color: const Color.fromRGBO(219, 33, 41, 1),
                ),
                tooltip: localization(context).indicator),
            const DataColumn(
              label: Text(''),
            ),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text(
                localization(context).surface,
                style: TextStyle(
                  fontSize: screenSize.width * 0.042,
                  fontWeight: FontWeight.w500,
                ),
              )),
              const DataCell(Text(
                '2256 ha',
              )),
            ]),
            DataRow(cells: [
              DataCell(Text(
                localization(context).elevation,
                style: TextStyle(
                  fontSize: screenSize.width * 0.042,
                  fontWeight: FontWeight.w500,
                ),
              )),
              const DataCell(Text(
                '185 m',
              )),
            ]),
            DataRow(cells: [
              DataCell(Text(
                localization(context).populationDensity,
                style: TextStyle(
                  fontSize: screenSize.width * 0.042,
                  fontWeight: FontWeight.w500,
                ),
              )),
              const DataCell(Text(
                '90,79 st/km\u00B2 (2022.)',
              )),
            ]),
            DataRow(cells: [
              DataCell(Text(
                localization(context).population,
                style: TextStyle(
                  fontSize: screenSize.width * 0.042,
                  fontWeight: FontWeight.w500,
                ),
              )),
              const DataCell(Text(
                '82.541 (2022.)',
              )),
            ]),
            DataRow(cells: [
              DataCell(Text(
                localization(context).district,
                style: TextStyle(
                  fontSize: screenSize.width * 0.042,
                  fontWeight: FontWeight.w500,
                ),
              )),
              DataCell(Text(
                localization(context).kolubaraDistrict,
              )),
            ]),
            DataRow(cells: [
              DataCell(Text(
                localization(context).cityDay,
                style: TextStyle(
                  fontSize: screenSize.width * 0.042,
                  fontWeight: FontWeight.w500,
                ),
              )),
              DataCell(Text(
                localization(context).cityDayDate,
              )),
            ]),
            DataRow(cells: [
              DataCell(Text(
                localization(context).saint,
                style: TextStyle(
                  fontSize: screenSize.width * 0.042,
                  fontWeight: FontWeight.w500,
                ),
              )),
              DataCell(Text(
                localization(context).saintName,
              )),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(
      BuildContext context, Map<String, dynamic> aboutCityData) {
    final screenSize = MediaQuery.of(context).size;
    return Card(
      child: ExpansionTile(
        title: Text(
          aboutCityData['title'],
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: screenSize.width * 0.05,
                fontWeight: FontWeight.w500,
              ),
        ),
        children: [
          ListTile(
            title: Text(
              aboutCityData['description'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: screenSize.width * 0.05,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
            ),
            trailing: Semantics(
              label: localization(context).tapToHearLegend,
              child: GestureDetector(
                onDoubleTap: () => TextToSpeechConfig.instance.stopSpeaking(),
                child: SizedBox(
                  width: max(50, screenSize.width * 0.1),
                  height: max(50, screenSize.width * 0.1),
                  child: IconButton(
                    iconSize: max(50, screenSize.width * 0.1),
                    tooltip: localization(context).tapToHearLegend,
                    onPressed: () {
                      TextToSpeechConfig.instance
                          .speak(aboutCityData['description']);
                    },
                    icon: Icon(
                      Icons.volume_up,
                      semanticLabel: localization(context).tapToHearLegend,
                      size: screenSize.width * 0.07,
                      applyTextScaling: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
      BuildContext context, Map<String, dynamic> aboutCityData) {
    final screenSize = MediaQuery.of(context).size;
    return ExpansionTile(
      title: Row(
        children: [
          Expanded(
            child: Semantics(
              child: Text(
                localization(context).historyOfTheCity,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: screenSize.width * 0.07,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ],
      ),
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 3.0,
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.05),
                  child: Semantics(
                    child: Text(
                      aboutCityData['history'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: screenSize.width * 0.05,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                    ),
                  )),
            ),
            GestureDetector(
              onDoubleTap: () => TextToSpeechConfig.instance.stopSpeaking(),
              child: SizedBox(
                width: max(50, screenSize.width * 0.1),
                height: max(50, screenSize.width * 0.1),
                child: IconButton(
                  icon: Icon(
                    Icons.volume_up,
                    semanticLabel: localization(context).tapToHearHistory,
                    size: screenSize.width * 0.07,
                    applyTextScaling: true,
                  ),
                  onPressed: () {
                    TextToSpeechConfig.instance.speak(aboutCityData['history']);
                  },
                  tooltip: localization(context).tapToHearHistory,
                ),
              ),
            ),
          ],
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
        legend_description_$languageCode AS description,
        history_$languageCode AS history,
        about_city_image_path       
      FROM AboutCity
    ''');
  }
}
