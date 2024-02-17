import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/navigation/cutom_app_bar.dart';

import '../../localization/supported_languages.dart';
import '../about_city.dart';
import '../hotels_and_restaurants.dart';
import '../sights/sights.dart';
import '../sport_and_recreation.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/navigation_helper.dart';
import 'menu_item.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double gridPadding = 8;
    double spacing = 8;
    int crossAxisCount = 2;
    var lottieAsset = 'animations/menu_item.json';

    return Scaffold(
      appBar: customAppBar(context, localization(context).menu),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: GridView.count(
        padding: EdgeInsets.all(gridPadding),
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        children: [
          MenuItem(
            label: localization(context).aboutCity,
            icon: Icons.info_outline,
            lottieAsset: lottieAsset,
            onTap: () => navigateTo(context, const AboutCity()),
            size: MediaQuery.of(context).size.width / crossAxisCount,
          ),
          MenuItem(
            label: localization(context).sights,
            icon: Icons.location_city,
            lottieAsset: lottieAsset,
            onTap: () => navigateTo(context, Sights()),
            size: MediaQuery.of(context).size.width / crossAxisCount,
          ),
          MenuItem(
            label: localization(context).sportRecreation,
            icon: Icons.sports_gymnastics,
            lottieAsset: lottieAsset,
            onTap: () => navigateTo(context, const SportsAndRecreation()),
            size: MediaQuery.of(context).size.width / crossAxisCount,
          ),
          MenuItem(
            label: localization(context).restaurantsAndHotels,
            icon: Icons.restaurant_menu,
            lottieAsset: lottieAsset,
            onTap: () => navigateTo(context, const HotelsAndRestaurants()),
            size: MediaQuery.of(context).size.width / crossAxisCount,
          ),
        ],
      ),
    );
  }
}
