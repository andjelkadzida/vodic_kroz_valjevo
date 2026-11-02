import 'package:flutter/material.dart';

import '../../database_config/tour_data_service.dart';
import '../../helper/remote_data_builder.dart';
import '../../localization/supported_languages.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/custom_app_bar.dart';
import '../shared/guide_details_content.dart';

class SightDetailsPage extends StatelessWidget {
  const SightDetailsPage({Key? key, required this.sightId}) : super(key: key);

  final String sightId;

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    return RemoteDataBuilder<Map<String, dynamic>>(
      queryKey: '$sightId:$languageCode',
      load: () => TourDataService.instance
          .get(TourCollection.sights, sightId, languageCode),
      standalone: true,
      refreshSignal:
          TourDataService.instance.refreshSignal(TourCollection.sights),
      onRetry: () => TourDataService.instance.refresh(TourCollection.sights),
      onData: (data) {
        final title = data['title'] as String;
        const color = Color.fromRGBO(87, 19, 20, 1);
        return Scaffold(
          appBar: customAppBar(
            context,
            title.split(RegExp(r'-|"|\(')).first,
            color,
            onRefresh: () =>
                TourDataService.instance.refresh(TourCollection.sights),
          ),
          bottomNavigationBar:
              const CustomBottomNavigationBar(unselectedColor: color),
          body: GuideDetailsContent(
            images: [
              data['sight_image_path'] as String,
              data['sight_image_path2'] as String,
              data['sight_image_path3'] as String,
            ],
            imageLabel: localization(context).imageOfSight(title),
            description: data['description'] as String,
            readTooltip: localization(context).tapToHearSightDetails,
            accentColor: color,
          ),
        );
      },
    );
  }
}
