import 'dart:math';

import 'package:flutter/material.dart';

import '../database_config/tour_data_service.dart';
import '../helper/images_loader_helper.dart';
import '../helper/remote_data_builder.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/cutom_app_bar.dart';
import '../text_to_speech/speech_controls.dart';

class AboutCity extends StatelessWidget {
  const AboutCity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    const color = Color.fromRGBO(219, 33, 41, 1);
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).aboutCity,
        color,
        onRefresh: () =>
            TourDataService.instance.refresh(TourCollection.aboutCity),
      ),
      bottomNavigationBar:
          const CustomBottomNavigationBar(unselectedColor: color),
      body: SafeArea(
        top: false,
        bottom: false,
        child: RemoteDataBuilder<List<Map<String, dynamic>>>(
          queryKey: languageCode,
          load: () => TourDataService.instance
              .list(TourCollection.aboutCity, languageCode),
          refreshSignal:
              TourDataService.instance.refreshSignal(TourCollection.aboutCity),
          onRetry: () =>
              TourDataService.instance.refresh(TourCollection.aboutCity),
          onData: (data) => _AboutCityContent(data: data),
        ),
      ),
    );
  }
}

class _AboutCityContent extends StatelessWidget {
  const _AboutCityContent({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      label: localization(context).valjevoCityImage,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: LayoutBuilder(
                          builder: (context, constraints) => TourImage(
                            image:
                                data.first['about_city_image_path'] as String,
                            cacheWidth: max(
                              1,
                              (constraints.maxWidth *
                                      MediaQuery.devicePixelRatioOf(context))
                                  .ceil(),
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _CityFacts(),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: Text(localization(context).historyOfTheCity),
                      children: [
                        _NarratedText(
                          text: data.first['history'] as String,
                          tooltip: localization(context).tapToHearHistory,
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(localization(context).legendOfTheCity),
                      children: [
                        for (final legend in data)
                          Card(
                            child: ExpansionTile(
                              title: Text(legend['title'] as String),
                              children: [
                                _NarratedText(
                                  text: legend['description'] as String,
                                  tooltip:
                                      localization(context).tapToHearLegend,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CityFacts extends StatelessWidget {
  const _CityFacts();

  @override
  Widget build(BuildContext context) {
    final messages = localization(context);
    const surface = 2256;
    const elevation = 185;
    const populationDensity = 90.79;
    const population = 82541;
    const populationYear = 2022;
    final facts = <_CityFact>[
      _CityFact(
        messages.surface,
        messages.citySurfaceValue(surface),
        spokenValue: messages.citySurfaceSpoken(surface),
      ),
      _CityFact(
        messages.elevation,
        messages.cityElevationValue(elevation),
        spokenValue: messages.cityElevationSpoken(elevation),
      ),
      _CityFact(
        messages.populationDensity,
        messages.cityDensityValue(populationDensity, populationYear),
        spokenValue:
            messages.cityDensitySpoken(populationDensity, populationYear),
      ),
      _CityFact(
        messages.population,
        messages.cityPopulationValue(population, populationYear),
        spokenValue: messages.cityPopulationSpoken(population, populationYear),
      ),
      _CityFact(messages.district, messages.kolubaraDistrict),
      _CityFact(messages.cityDay, messages.cityDayDate),
      _CityFact(messages.saint, messages.saintName),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 480 ||
            MediaQuery.textScalerOf(context).scale(16) >= 24;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                messages.indicator,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final fact in facts) _buildFact(context, fact, stacked),
          ],
        );
      },
    );
  }

  Widget _buildFact(BuildContext context, _CityFact fact, bool stacked) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final label = Text(
      fact.label,
      style: textStyle?.copyWith(fontWeight: FontWeight.w500),
    );
    final value = Text(fact.value, style: textStyle);
    final description = '${fact.label}: ${fact.spokenValue}';
    final information = Semantics(
      container: true,
      label: description,
      child: ExcludeSemantics(
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [label, value],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: label),
                  const SizedBox(width: 16),
                  Expanded(child: value),
                ],
              ),
      ),
    );
    final controls = SpeechControls(
      text: description,
      readLabel: localization(context).readCityFact(fact.label),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                information,
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: controls,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: information),
                const SizedBox(width: 16),
                controls,
              ],
            ),
    );
  }
}

class _CityFact {
  const _CityFact(this.label, this.value, {String? spokenValue})
      : spokenValue = spokenValue ?? value;

  final String label;
  final String value;
  final String spokenValue;
}

class _NarratedText extends StatelessWidget {
  const _NarratedText({required this.text, required this.tooltip});

  final String text;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
          Align(
            alignment: Alignment.centerRight,
            child: SpeechControls(text: text, readLabel: tooltip),
          ),
        ],
      ),
    );
  }
}
