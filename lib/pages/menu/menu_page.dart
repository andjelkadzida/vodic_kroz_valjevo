import 'dart:math';

import 'package:flutter/material.dart';

import '../../localization/supported_languages.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../navigation/navigation_helper.dart';
import '../about_city.dart';
import '../hotels_and_restaurants.dart';
import '../sights/sights.dart';
import '../sport_and_recreation.dart';
import 'menu_item.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const color = Color.fromRGBO(11, 20, 32, 1);
    const animation = 'animations/menu_item.json';
    return Scaffold(
      appBar: customAppBar(context, localization(context).menu, color),
      bottomNavigationBar:
          const CustomBottomNavigationBar(unselectedColor: color),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/backgroundAndCoverImages/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final width = min(960.0, max(0.0, constraints.maxWidth - 32));
              final columns = width >= 720 ? 4 : (width >= 480 ? 3 : 2);
              final itemWidth =
                  max(0.0, (width - spacing * (columns - 1)) / columns);
              final items = [
                MenuItem(
                  label: localization(context).aboutCity,
                  icon: Icons.travel_explore,
                  lottieAsset: animation,
                  onTap: () => navigateTo(context, const AboutCity()),
                ),
                MenuItem(
                  label: localization(context).sights,
                  icon: Icons.location_city,
                  lottieAsset: animation,
                  onTap: () => navigateTo(context, Sights()),
                ),
                MenuItem(
                  label: localization(context).sportRecreation,
                  icon: Icons.sports_gymnastics,
                  lottieAsset: animation,
                  onTap: () => navigateTo(context, const SportsAndRecreation()),
                ),
                MenuItem(
                  label: localization(context).restaurantsAndHotels,
                  icon: Icons.restaurant_menu,
                  lottieAsset: animation,
                  onTap: () =>
                      navigateTo(context, const HotelsAndRestaurants()),
                ),
              ];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: width,
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final item in items)
                          SizedBox(width: itemWidth, child: item),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
