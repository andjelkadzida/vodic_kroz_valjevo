import 'package:flutter/material.dart';

import '../../database_config/tour_data_service.dart';
import '../../helper/remote_data_builder.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../shared/hospitality_details_content.dart';

class RestaurantDetailsPage extends StatelessWidget {
  const RestaurantDetailsPage({Key? key, required this.restaurantId})
      : super(key: key);

  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    return RemoteDataBuilder<Map<String, dynamic>>(
      queryKey: '$restaurantId:$languageCode',
      load: () => TourDataService.instance
          .get(TourCollection.restaurants, restaurantId, languageCode),
      standalone: true,
      refreshSignal:
          TourDataService.instance.refreshSignal(TourCollection.restaurants),
      onRetry: () =>
          TourDataService.instance.refresh(TourCollection.restaurants),
      onData: (data) {
        const color = Color.fromRGBO(11, 20, 32, 1);
        return Scaffold(
          appBar: customAppBar(
            context,
            data['title'] as String,
            color,
            onRefresh: () =>
                TourDataService.instance.refresh(TourCollection.restaurants),
          ),
          bottomNavigationBar:
              const CustomBottomNavigationBar(unselectedColor: color),
          body: HospitalityDetailsContent(
            title: data['title'] as String,
            images: [
              data['restaurant_image_path'] as String,
              data['restaurant_image_path2'] as String,
            ],
            imageLabel: localization(context).restaurantImage,
            photoSourceUrl: data['restaurant_images_resource'] as String,
            navigationHint: localization(context).tapToNavigateToRestaurant,
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
