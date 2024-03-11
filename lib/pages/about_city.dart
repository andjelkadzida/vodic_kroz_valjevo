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
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var imagePath = data.first['about_city_image_path'];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01,
                    horizontal: screenWidth * 0.05,
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
                        SizedBox(height: screenHeight * 0.02),
                        _buildResponsiveDataTable(context),
                        SizedBox(height: screenHeight * 0.02),
                        _buildHistoryCard(context, data.first),
                        SizedBox(height: screenHeight * 0.02),
                        ExpansionTile(
                          title: Text(localization(context).legendOfTheCity,
                              style: Theme.of(context).textTheme.titleLarge),
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
    var screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: const Color.fromRGBO(219, 33, 41, 1),
          dataTableTheme: DataTableThemeData(
            dataTextStyle: TextStyle(
              fontSize: screenWidth * 0.042,
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
                  fontSize: screenWidth * 0.042,
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
                  fontSize: screenWidth * 0.042,
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
                  fontSize: screenWidth * 0.042,
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
                  fontSize: screenWidth * 0.042,
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
                  fontSize: screenWidth * 0.042,
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
                  fontSize: screenWidth * 0.042,
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
                  fontSize: screenWidth * 0.042,
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
    var screenWidth = MediaQuery.of(context).size.width;
    return Card(
      child: ExpansionTile(
        title: Text(
          aboutCityData['title'],
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.normal,
              ),
        ),
        children: [
          ListTile(
            title: Text(
              aboutCityData['description'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Semantics(
              label: localization(context).tapToHearLegend,
              child: GestureDetector(
                onDoubleTap: () => TextToSpeechConfig.instance.stopSpeaking(),
                child: SizedBox(
                  width: max(50, screenWidth * 0.1),
                  height: max(50, screenWidth * 0.1),
                  child: IconButton(
                    tooltip: localization(context).tapToHearLegend,
                    onPressed: () {
                      TextToSpeechConfig.instance
                          .speak(aboutCityData['description']);
                    },
                    icon: Icon(
                      Icons.volume_up,
                      semanticLabel: localization(context).tapToHearLegend,
                      size: screenWidth * 0.07,
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
    var screenWidth = MediaQuery.of(context).size.width;
    return ExpansionTile(
      title: Row(
        children: [
          Expanded(
            child: Semantics(
              child: Text(
                localization(context).historyOfTheCity,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Semantics(
                    child: Text(
                      aboutCityData['history'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )),
            ),
            GestureDetector(
              onDoubleTap: () => TextToSpeechConfig.instance.stopSpeaking(),
              child: SizedBox(
                width: max(50, screenWidth * 0.1),
                height: max(50, screenWidth * 0.1),
                child: IconButton(
                  icon: Icon(
                    Icons.volume_up,
                    semanticLabel: localization(context).tapToHearHistory,
                    size: screenWidth * 0.07,
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
