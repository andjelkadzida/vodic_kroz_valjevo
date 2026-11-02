import 'package:flutter/material.dart';

import '../../database_config/tour_data_service.dart';
import '../../helper/remote_data_builder.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_builder.dart';
import '../../navigation/custom_app_bar.dart';
import 'hotel_details.dart';

class Hotels extends StatelessWidget {
  const Hotels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = localization(context).localeName;
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).hotels,
        const Color.fromRGBO(11, 20, 32, 1),
        onRefresh: () =>
            TourDataService.instance.refresh(TourCollection.hotels),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: RemoteDataBuilder<List<Map<String, dynamic>>>(
          queryKey: languageCode,
          load: () => TourDataService.instance
              .list(TourCollection.hotels, languageCode),
          refreshSignal:
              TourDataService.instance.refreshSignal(TourCollection.hotels),
          onRetry: () =>
              TourDataService.instance.refresh(TourCollection.hotels),
          onData: (data) => buildWithMarkers(context, data,
              (hotelData) => HotelDetailsPage(hotelId: hotelData['id'])),
        ),
      ),
    );
  }
}
