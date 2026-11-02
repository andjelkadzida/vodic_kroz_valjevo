import 'package:flutter/material.dart';

import '../../database_config/tour_data_service.dart';
import '../../helper/remote_data_builder.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/custom_app_bar.dart';
import '../shared/hospitality_details_content.dart';

class HotelDetailsPage extends StatelessWidget {
  const HotelDetailsPage({Key? key, required this.hotelId}) : super(key: key);

  final String hotelId;

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    return RemoteDataBuilder<Map<String, dynamic>>(
      queryKey: '$hotelId:$languageCode',
      load: () => TourDataService.instance
          .get(TourCollection.hotels, hotelId, languageCode),
      standalone: true,
      refreshSignal:
          TourDataService.instance.refreshSignal(TourCollection.hotels),
      onRetry: () => TourDataService.instance.refresh(TourCollection.hotels),
      onData: (data) {
        const color = Color.fromRGBO(11, 20, 32, 1);
        final website = data['website'] as String;
        return Scaffold(
          appBar: customAppBar(
            context,
            data['title'] as String,
            color,
            onRefresh: () =>
                TourDataService.instance.refresh(TourCollection.hotels),
          ),
          bottomNavigationBar:
              const CustomBottomNavigationBar(unselectedColor: color),
          body: HospitalityDetailsContent(
            title: data['title'] as String,
            images: [
              data['hotel_image_path'] as String,
              data['hotel_image_path2'] as String,
            ],
            imageLabel: localization(context).hotelImage,
            photoSourceUrl: website,
            website: website,
            stars: data['noStars'] as int,
            navigationHint: localization(context).tapToNavigateToHotel,
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
