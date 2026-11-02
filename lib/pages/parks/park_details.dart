import 'package:flutter/material.dart';

import '../../database_config/tour_data_service.dart';
import '../../helper/remote_data_builder.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../shared/guide_details_content.dart';

class ParkDetailsPage extends StatelessWidget {
  const ParkDetailsPage({Key? key, required this.parkId}) : super(key: key);

  final String parkId;

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    return RemoteDataBuilder<Map<String, dynamic>>(
      queryKey: '$parkId:$languageCode',
      load: () => TourDataService.instance
          .get(TourCollection.parks, parkId, languageCode),
      standalone: true,
      refreshSignal:
          TourDataService.instance.refreshSignal(TourCollection.parks),
      onRetry: () => TourDataService.instance.refresh(TourCollection.parks),
      onData: (data) {
        final title = data['title'] as String;
        const color = Color.fromRGBO(65, 89, 45, 1);
        return Scaffold(
          appBar: customAppBar(
            context,
            title.split(' (').first,
            color,
            onRefresh: () =>
                TourDataService.instance.refresh(TourCollection.parks),
          ),
          bottomNavigationBar:
              const CustomBottomNavigationBar(unselectedColor: color),
          body: GuideDetailsContent(
            images: [
              data['park_image_path'] as String,
              data['park_image_path2'] as String,
              data['park_image_path3'] as String,
            ],
            imageLabel: localization(context).image(title),
            description: data['description'] as String,
            readTooltip: localization(context).tapToHearParkDetails,
            accentColor: color,
            navigationHint: localization(context).tapToNavigateToPark,
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
