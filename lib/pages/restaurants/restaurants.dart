import 'package:flutter/material.dart';

import '../../database_config/tour_data_service.dart';
import '../../helper/remote_data_builder.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_builder.dart';
import '../../navigation/cutom_app_bar.dart';
import 'restaurant_details.dart';

class Restaurants extends StatelessWidget {
  const Restaurants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).restaurants,
        const Color.fromRGBO(11, 20, 32, 1),
        onRefresh: () =>
            TourDataService.instance.refresh(TourCollection.restaurants),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: RemoteDataBuilder<List<Map<String, dynamic>>>(
          queryKey: languageCode,
          load: () => TourDataService.instance
              .list(TourCollection.restaurants, languageCode),
          refreshSignal: TourDataService.instance
              .refreshSignal(TourCollection.restaurants),
          onRetry: () =>
              TourDataService.instance.refresh(TourCollection.restaurants),
          onData: (data) => buildWithMarkers(
              context,
              data,
              (restaurantData) =>
                  RestaurantDetailsPage(restaurantId: restaurantData['id'])),
        ),
      ),
    );
  }
}
