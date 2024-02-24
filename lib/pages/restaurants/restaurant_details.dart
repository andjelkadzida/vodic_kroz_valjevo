import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vodic_kroz_valjevo/helper/images_loader_helper.dart';

import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final Map<String, dynamic> restaurantData;

  const RestaurantDetailsPage({Key? key, required this.restaurantData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    MapScreen mapScreen = MapScreen();

    List<String> images = [
      restaurantData['restaurant_image_path'],
      restaurantData['restaurant_image_path2'],
    ];

    precacheImages(context, images);

    return Scaffold(
      appBar: customAppBar(
        context,
        restaurantData['title'],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double padding = constraints.maxWidth * 0.04;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      margin: EdgeInsets.all(padding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: padding),
                          CarouselSlider.builder(
                            itemCount: images.length,
                            itemBuilder: (BuildContext context, int itemIndex,
                                int pageViewIndex) {
                              return Semantics(
                                  label:
                                      '${localization(context).restaurantImage}"${restaurantData['title']}"',
                                  child: Image.asset(images[itemIndex],
                                      fit: BoxFit.cover));
                            },
                            options: CarouselOptions(
                              autoPlay: true,
                              enlargeCenterPage: true,
                              viewportFraction: 0.9,
                              aspectRatio: 2.0,
                              autoPlayAnimationDuration:
                                  const Duration(seconds: 2),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    restaurantData['title'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                SizedBox(height: constraints.maxHeight * 0.02),
                                Semantics(
                                  button: true,
                                  enabled: true,
                                  onTapHint:
                                      localization(context).startNavigation,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                constraints.maxHeight * 0.015),
                                      ),
                                      child: Text(
                                        localization(context).startNavigation,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                constraints.maxWidth * 0.05),
                                      ),
                                      onPressed: () {
                                        mapScreen.navigateToDestination(
                                            restaurantData['latitude'],
                                            restaurantData['longitude']);
                                      },
                                    ),
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
              );
            },
          );
        },
      ),
    );
  }
}
