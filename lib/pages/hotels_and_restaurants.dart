import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/custom_app_bar.dart';
import '../navigation/navigation_helper.dart';
import 'hotels/hotels.dart';
import 'restaurants/restaurants.dart';

class HotelsAndRestaurants extends StatelessWidget {
  const HotelsAndRestaurants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const color = Color.fromRGBO(11, 20, 32, 1);
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).restaurantsAndHotels,
        color,
      ),
      bottomNavigationBar:
          const CustomBottomNavigationBar(unselectedColor: color),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'images/backgroundAndCoverImages/hotelsBackground.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final padding = (constraints.maxWidth * 0.05).clamp(16.0, 40.0);
              final width =
                  min(520.0, max(0.0, constraints.maxWidth - 2 * padding));
              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: max(0, constraints.maxHeight - 2 * padding),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildItem(
                            context,
                            label: localization(context).hotels,
                            icon: Icons.hotel,
                            onTap: () => navigateTo(context, const Hotels()),
                          ),
                          _buildItem(
                            context,
                            label: localization(context).restaurants,
                            icon: Icons.restaurant,
                            onTap: () =>
                                navigateTo(context, const Restaurants()),
                          ),
                        ],
                      ),
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

  Widget _buildItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: localization(context).buttonFor(label),
      button: true,
      enabled: true,
      onTap: onTap,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 128),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    'animations/menu_item.json',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    animate: !MediaQuery.disableAnimationsOf(context),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon,
                              size: 28,
                              color: const Color.fromRGBO(11, 20, 32, 1)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: const Color.fromRGBO(11, 20, 32, 1),
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
