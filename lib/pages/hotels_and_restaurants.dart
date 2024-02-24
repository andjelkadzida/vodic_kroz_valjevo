import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/cutom_app_bar.dart';
import '../navigation/navigation_helper.dart';
import 'hotels/hotels.dart';
import 'restaurants/restaurants.dart';

class HotelsAndRestaurants extends StatefulWidget {
  const HotelsAndRestaurants({Key? key}) : super(key: key);

  @override
  HotelsAndRestaurantsState createState() => HotelsAndRestaurantsState();
}

class HotelsAndRestaurantsState extends State<HotelsAndRestaurants> {
  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  // Checking network connectivity
  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      AppSettings.openAppSettings(type: AppSettingsType.wireless);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).restaurantsAndHotels,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: ListView(
          children: [
            _buildItem(
              context,
              label: localization(context).hotels,
              icon: Icons.hotel,
              lottieAsset: 'animations/hotels.json',
              onTap: () => navigateTo(context, const Hotels()),
            ),
            _buildItem(
              context,
              label: localization(context).restaurants,
              icon: Icons.restaurant,
              lottieAsset: 'animations/restaurants.json',
              onTap: () => navigateTo(context, const Restaurants()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String lottieAsset,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Lottie.asset(
                lottieAsset,
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.width * 0.1,
                fit: BoxFit.contain,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.teal,
                        letterSpacing: 1,
                      ),
                ),
              ),
              Icon(icon,
                  size: MediaQuery.of(context).size.width * 0.08,
                  applyTextScaling: true,
                  color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }
}
