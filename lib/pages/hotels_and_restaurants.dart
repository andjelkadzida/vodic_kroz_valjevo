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
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: customAppBar(
            context,
            localization(context).restaurantsAndHotels,
            const Color.fromRGBO(11, 20, 32, 1),
          ),
          bottomNavigationBar: const CustomBottomNavigationBar(
            unselectedColor: Color.fromRGBO(11, 20, 32, 1),
          ),
          body: Padding(
            padding: EdgeInsets.all(constraints.maxWidth * 0.05),
            child: ListView(
              children: [
                _buildItem(
                  context,
                  label: localization(context).hotels,
                  icon: Icons.hotel,
                  lottieAsset: 'animations/hotels_restaurants.json',
                  onTap: () => navigateTo(context, const Hotels()),
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
                _buildItem(
                  context,
                  label: localization(context).restaurants,
                  icon: Icons.restaurant,
                  lottieAsset: 'animations/hotels_restaurants.json',
                  onTap: () => navigateTo(context, const Restaurants()),
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String lottieAsset,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return Semantics(
      label: localization(context).buttonFor(label),
      button: true,
      enabled: true,
      onTap: onTap,
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: height * 0.01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Lottie.asset(
                  lottieAsset,
                  width: width * 0.35,
                  height: width * 0.35,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: width * 0.05),
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
                    size: width * 0.08,
                    applyTextScaling: true,
                    color: Colors.teal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
