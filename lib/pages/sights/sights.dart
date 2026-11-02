import 'dart:math';

import 'package:flutter/material.dart';

import '../../database_config/tour_data_service.dart';
import '../../helper/images_loader_helper.dart';
import '../../helper/remote_data_builder.dart';
import '../../helper/responsive_layout.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/custom_app_bar.dart';
import '../../navigation/navigation_helper.dart';
import '../../text_to_speech/speech_controls.dart';
import 'sight_details_page.dart';

class Sights extends StatelessWidget {
  Sights({Key? key}) : super(key: key);

  final MapScreen mapScreen = MapScreen();

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).sights,
        const Color.fromRGBO(87, 19, 20, 1),
        onRefresh: () =>
            TourDataService.instance.refresh(TourCollection.sights),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        unselectedColor: Color.fromRGBO(87, 19, 20, 1),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/backgroundAndCoverImages/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: RemoteDataBuilder<List<Map<String, dynamic>>>(
            queryKey: languageCode,
            load: () => TourDataService.instance
                .list(TourCollection.sights, languageCode),
            refreshSignal:
                TourDataService.instance.refreshSignal(TourCollection.sights),
            onRetry: () =>
                TourDataService.instance.refresh(TourCollection.sights),
            onData: (data) => buildSightsList(data, context),
          ),
        ),
      ),
    );
  }

  Widget buildSightsList(
      List<Map<String, dynamic>> sightsData, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        const spacing = 12.0;
        final width = min(1100.0, constraints.maxWidth);
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final columns =
            width >= 1000 ? 3 : (width >= 600 ? 2 : (textScale >= 1.5 ? 1 : 2));
        final itemWidth =
            max(1.0, (width - padding * 2 - spacing * (columns - 1)) / columns);
        final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ) ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
        final navigationStyle = Theme.of(context).textTheme.bodyLarge ??
            const TextStyle(fontSize: 16);
        final titleHeight = sightsData
            .map((item) => measureTextHeight(
                  context,
                  item['title'] as String,
                  titleStyle,
                  max(1, itemWidth - 16),
                ))
            .fold<double>(0, max);
        final navigationHeight = measureTextHeight(
          context,
          localization(context).startNavigation,
          navigationStyle,
          max(1, itemWidth - 24),
        );
        final imageHeight = (itemWidth * 0.65).clamp(150.0, 240.0);
        final extent = imageHeight +
            max(48, titleHeight) +
            16 +
            48 +
            max(48, navigationHeight + 16) +
            12;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: GridView.builder(
              padding: const EdgeInsets.all(padding),
              itemCount: sightsData.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: extent,
              ),
              itemBuilder: (context, index) => SightListItem(
                sightData: sightsData[index],
                mapScreen: mapScreen,
                cacheWidth: max(
                    1,
                    (itemWidth * MediaQuery.devicePixelRatioOf(context))
                        .ceil()),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SightListItem extends StatelessWidget {
  const SightListItem({
    Key? key,
    required this.sightData,
    required this.mapScreen,
    required this.cacheWidth,
  }) : super(key: key);

  final Map<String, dynamic> sightData;
  final MapScreen mapScreen;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    final title = sightData['title'] as String;
    void showDetails() => navigateTo(
          context,
          SightDetailsPage(sightId: sightData['id'] as String),
        );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: showDetails,
              child: Semantics(
                label: localization(context).tapToSeeSightDetails(title),
                child: TourImage(
                  image: sightData['sight_image_path'] as String,
                  cacheWidth: cacheWidth,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  button: true,
                  label: localization(context).tapToSeeSightDetails(title),
                  child: InkWell(
                    onTap: showDetails,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SpeechControls(
                    text: title,
                    readLabel: localization(context).tapToHearSightName,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            onTapHint: localization(context).tapToNavigateToSight,
            child: InkWell(
              onTap: () => mapScreen.navigateToDestination(
                  sightData['latitude'], sightData['longitude']),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localization(context).startNavigation,
                      style: Theme.of(context).textTheme.bodyLarge,
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
}
