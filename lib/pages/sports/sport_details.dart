import 'package:flutter/material.dart';

import '../../database_config/tour_data_service.dart';
import '../../helper/remote_data_builder.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/custom_app_bar.dart';
import '../shared/guide_details_content.dart';

class SportDetailsPage extends StatelessWidget {
  const SportDetailsPage({Key? key, required this.sportId}) : super(key: key);

  final String sportId;

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    return RemoteDataBuilder<Map<String, dynamic>>(
      queryKey: '$sportId:$languageCode',
      load: () => TourDataService.instance
          .get(TourCollection.sports, sportId, languageCode),
      standalone: true,
      refreshSignal:
          TourDataService.instance.refreshSignal(TourCollection.sports),
      onRetry: () => TourDataService.instance.refresh(TourCollection.sports),
      onData: (data) {
        final title = data['title'] as String;
        const color = Color.fromRGBO(65, 89, 45, 1);
        return Scaffold(
          appBar: customAppBar(
            context,
            title,
            color,
            onRefresh: () =>
                TourDataService.instance.refresh(TourCollection.sports),
          ),
          bottomNavigationBar:
              const CustomBottomNavigationBar(unselectedColor: color),
          body: GuideDetailsContent(
            images: [
              data['sport_image_path'] as String,
              data['sport_image_path2'] as String,
              data['sport_image_path3'] as String,
            ],
            imageLabel: localization(context).image(title),
            description: data['description'] as String,
            readTooltip: localization(context).tapToHearSportDetails,
            accentColor: color,
            navigationHint: localization(context).tapToNavigateToSportField,
            onNavigate: () => MapScreen().navigateToDestination(
              data['latitude'],
              data['longitude'],
            ),
          ),
        );
      },
    );
  }
}
