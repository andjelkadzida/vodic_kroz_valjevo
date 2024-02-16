import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../localization/supported_languages.dart';
import '../../../maps_navigation/locator.dart';
import '../../../navigation/bottom_navigation.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final Map<String, dynamic> restaurantData;

  const RestaurantDetailsPage({Key? key, required this.restaurantData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    final double padding = screenSize.width * 0.04;

    final String title = restaurantData['title'];
    double latitude = restaurantData['latitude'];
    double longitude = restaurantData['longitude'];

    MapScreen mapScreen = MapScreen();

    List<String> images = [
      restaurantData['restaurant_image_path'],
      restaurantData['restaurant_image_path2'],
      restaurantData['restaurant_image_path3'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(padding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CarouselSlider.builder(
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int itemIndex,
                        int pageViewIndex) {
                      return Semantics(
                          label:
                              '${localization(context).restaurantImage}"$title"',
                          child: Image.asset(images[itemIndex],
                              fit: BoxFit.cover));
                    },
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      aspectRatio: 2.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: screenSize.height * 0.015),
                            ),
                            child: Text(
                              localization(context).startNavigation,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05),
                            ),
                            onPressed: () {
                              mapScreen.navigateToDestination(
                                  latitude, longitude);
                            },
                          ),
                        ),
                        SizedBox(height: padding),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
