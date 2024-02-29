import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../helper/images_loader_helper.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';

class HotelDetailsPage extends StatelessWidget {
  final Map<String, dynamic> hotelData;

  const HotelDetailsPage({Key? key, required this.hotelData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int noStars = hotelData['noStars'];
    MapScreen mapScreen = MapScreen();
    List<String> images = [
      hotelData['hotel_image_path'],
      hotelData['hotel_image_path2'],
    ];
    precacheImages(context, images);
    return Scaffold(
      appBar: customAppBar(
        context,
        hotelData['title'],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      margin: EdgeInsets.all(constraints.maxWidth * 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: constraints.maxWidth * 0.04),
                          CarouselSlider.builder(
                            itemCount: images.length,
                            itemBuilder: (BuildContext context, int itemIndex,
                                int pageViewIndex) {
                              return Semantics(
                                  label:
                                      '${localization(context).hotelImage}"${hotelData['title']}',
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
                            padding:
                                EdgeInsets.all(constraints.maxWidth * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotelData['title'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: constraints.maxHeight * 0.02),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        launchUrlString(hotelData['website']);
                                        HapticFeedback.selectionClick();
                                      },
                                      child: Text(
                                        localization(context).website,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                    ),
                                    Semantics(
                                      label: localization(context)
                                          .starCount(noStars),
                                      child: Row(
                                        children: [
                                          Tooltip(
                                            message: localization(context)
                                                .starCount(noStars),
                                            child: Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: constraints.maxWidth * 0.05,
                                            ),
                                          ),
                                          Text(
                                            '$noStars',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: constraints.maxHeight * 0.03),
                                Semantics(
                                  button: true,
                                  enabled: true,
                                  onTapHint:
                                      localization(context).navigateToHotel,
                                  child: FractionallySizedBox(
                                    widthFactor: 1,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontSize:
                                                  constraints.maxWidth * 0.05,
                                            ),
                                      ),
                                      onPressed: () {
                                        mapScreen.navigateToDestination(
                                            hotelData['latitude'],
                                            hotelData['longitude']);
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: constraints.maxWidth * 0.04),
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
