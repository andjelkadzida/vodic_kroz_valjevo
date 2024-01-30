import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'hotels_and_restaurants/hotels.dart';
import 'hotels_and_restaurants/restaurants.dart';
import '../navigation/navigation_drawer.dart' as nav_drawer;
import '../localization/supported_languages.dart';
import '../styles/common_styles.dart';

class HotelsAndRestaurants extends StatefulWidget {
  const HotelsAndRestaurants({Key? key}) : super(key: key);

  @override
  _HotelsAndRestaurants createState() => _HotelsAndRestaurants();
}

class _HotelsAndRestaurants extends State<HotelsAndRestaurants> {
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: localization(context).restaurantsAndHotels,
          child: Text(
            localization(context).restaurantsAndHotels,
            style: AppStyles.defaultAppBarTextStyle(
                MediaQuery.of(context).textScaler),
          ),
        ),
        excludeHeaderSemantics: true,
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const nav_drawer.NavigationDrawer(),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildItem(
              context,
              label: localization(context).hotels,
              icon: Icons.hotel,
              lottieAsset: 'animations/hotels.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Hotels()),
                );
                HapticFeedback.selectionClick();
              },
            ),
            const SizedBox(height: 20),
            _buildItem(
              context,
              label: localization(context).restaurants,
              icon: Icons.restaurant,
              lottieAsset: 'animations/restaurants.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Restaurants()),
                );
                HapticFeedback.selectionClick();
              },
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
    final textScaler = MediaQuery.textScalerOf(context);
    return Semantics(
      label: localization(context).tapToView + label,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset(lottieAsset, width: 100, height: 100),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: AppStyles.hotelsAndRestaurantsStyle(textScaler),
                ),
                Icon(icon, size: textScaler.scale(35)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
