import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'hotels_and_restaurants/hotels.dart';
import 'hotels_and_restaurants/restaurants.dart';
import '../navigation/navigation_drawer.dart' as nav_drawer;
import '../localization/supported_languages.dart';
import '../styles/common_styles.dart';

class HotelsAndRestaurants extends StatelessWidget {
  const HotelsAndRestaurants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: localization(context).restaurantsAndHotels,
          child: Text(
            localization(context).restaurantsAndHotels,
            style: AppStyles.defaultAppBarTextStyle(textScaler),
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
        child: ListView(
          children: [
            _buildItem(
              context,
              label: localization(context).hotels,
              icon: Icons.hotel,
              lottieAsset: 'animations/hotels.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Hotels()),
                );
              },
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset(lottieAsset, width: 100, height: 100),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Icon(icon, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
