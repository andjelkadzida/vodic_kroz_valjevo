import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/navigation/navigation_drawer.dart';
import 'package:vodic_kroz_valjevo/pages/about_city.dart';
import 'package:vodic_kroz_valjevo/pages/hotels_and_restaurants.dart';
import 'package:vodic_kroz_valjevo/pages/sights.dart';
import 'package:vodic_kroz_valjevo/pages/sport_and_recreation.dart';
import 'bottom_navigation.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double gridPadding = 8;
    double spacing = 8;
    int crossAxisCount = 2;
    double itemSize = (MediaQuery.of(context).size.width -
            gridPadding * 2 -
            spacing * (crossAxisCount - 1)) /
        crossAxisCount;

    List<Widget> gridItems = [];
    var lottieAsset = 'animations/menu_item.json';

    gridItems.add(_buildItem(
      context,
      label: localization(context).aboutCity,
      icon: Icons.info_outline,
      lottieAsset: lottieAsset,
      onTap: () => navigateTo(context, const AboutCity()),
      size: itemSize,
    ));

    gridItems.add(_buildItem(
      context,
      label: localization(context).sights,
      icon: Icons.location_city,
      lottieAsset: lottieAsset,
      onTap: () => navigateTo(context, Sights()),
      size: itemSize,
    ));

    gridItems.add(_buildItem(
      context,
      label: localization(context).sportRecreation,
      icon: Icons.sports_gymnastics,
      lottieAsset: lottieAsset,
      onTap: () => navigateTo(context, const SportsAndRecreation()),
      size: itemSize,
    ));

    gridItems.add(_buildItem(
      context,
      label: localization(context).restaurantsAndHotels,
      icon: Icons.restaurant_menu,
      lottieAsset: lottieAsset,
      onTap: () => navigateTo(context, const HotelsAndRestaurants()),
      size: itemSize,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization(context).menu,
          style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: GridView.count(
        padding: EdgeInsets.all(gridPadding),
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        children: gridItems,
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String lottieAsset,
    required VoidCallback onTap,
    required double size,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Lottie.asset(lottieAsset, width: size, height: size),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.teal,
                          fontSize:
                              Theme.of(context).textTheme.titleLarge!.fontSize,
                          letterSpacing: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                )),
            Center(
              child: Icon(
                icon,
                size: size * 0.2,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
