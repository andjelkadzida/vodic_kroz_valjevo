import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../localization/supported_languages.dart';
import '../../../maps_navigation/locator.dart';
import '../../../navigation/bottom_navigation.dart';

class HotelDetailsPage extends StatelessWidget {
  final Map<String, dynamic> hotelData;

  const HotelDetailsPage({Key? key, required this.hotelData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    final double padding = screenSize.width * 0.04;

    final String title = hotelData['title'];
    final int noStars = hotelData['noStars'];
    double latitude = hotelData['latitude'];
    double longitude = hotelData['longitude'];

    MapScreen mapScreen = MapScreen();

    List<String> images = [
      hotelData['hotel_image_path'],
      hotelData['hotel_image_path2'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                          label: '${localization(context).hotelImage}"$title"',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                launchUrlString(hotelData['website']);
                                HapticFeedback.lightImpact();
                              },
                              child: Text(
                                localization(context).website,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            Semantics(
                              label: localization(context).starCount(noStars),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: screenSize.width * 0.05,
                                  ),
                                  Text(
                                    '$noStars',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.03),
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
