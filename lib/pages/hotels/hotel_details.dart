import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../database_config/database_helper.dart';
import '../../helper/images_loader_helper.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';

class HotelDetailsPage extends StatelessWidget {
  final int hotelId;
  static final MapScreen mapScreen = MapScreen();

  const HotelDetailsPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getHotelById(hotelId, localization(context).localeName),
      builder: (context, snapshot) {
        return DatabaseHelper.buildFutureState<Map<String, dynamic>>(
          context: context,
          snapshot: snapshot,
          onData: (hotelData) {
            final images = [
              hotelData['hotel_image_path'],
              hotelData['hotel_image_path2'],
            ];
            precacheImages(context, images);

            final int noStars = hotelData['noStars'];

            return Scaffold(
              appBar: customAppBar(
                context,
                hotelData['title'],
              ),
              bottomNavigationBar: const CustomBottomNavigationBar(),
              body: OrientationBuilder(
                builder: (context, orientation) {
                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                          child: Column(
                            children: [
                              SizedBox(height: constraints.maxWidth * 0.04),
                              Semantics(
                                label: localization(context).hotelImage,
                                child: SizedBox(
                                  height: constraints.maxHeight * 0.3,
                                  child: PhotoViewGallery.builder(
                                    itemCount: images.length,
                                    builder: (context, index) {
                                      return PhotoViewGalleryPageOptions(
                                        imageProvider:
                                            AssetImage(images[index]),
                                        maxScale:
                                            PhotoViewComputedScale.contained *
                                                5,
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        initialScale:
                                            PhotoViewComputedScale.contained,
                                        basePosition: Alignment.center,
                                        filterQuality: FilterQuality.high,
                                        heroAttributes: PhotoViewHeroAttributes(
                                            tag: images[index]),
                                      );
                                    },
                                    scrollPhysics:
                                        const BouncingScrollPhysics(),
                                    backgroundDecoration: BoxDecoration(
                                      color: Theme.of(context).canvasColor,
                                    ),
                                    loadingBuilder: (context, event) => Center(
                                      child: Semantics(
                                        tooltip: localization(context).loading,
                                        child: CircularProgressIndicator(
                                          semanticsLabel:
                                              localization(context).loading,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Semantics(
                                child: SizedBox(
                                  width: max(50, constraints.maxWidth * 0.5),
                                  height: max(50, constraints.maxHeight * 0.05),
                                  child: InkWell(
                                    onTap: () {
                                      launchUrlString(hotelData['website']);
                                      HapticFeedback.selectionClick();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ExcludeSemantics(
                                          child: Icon(
                                            Icons.copyright,
                                            size: constraints.maxWidth * 0.045,
                                          ),
                                        ),
                                        SizedBox(
                                            width: constraints.maxWidth * 0.02),
                                        Flexible(
                                          child: Text(
                                            localization(context).photoSource,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.all(constraints.maxWidth * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                    SizedBox(
                                        height: constraints.maxHeight * 0.02),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: max(
                                              50, constraints.maxWidth * 0.3),
                                          height: max(
                                              50, constraints.maxHeight * 0.05),
                                          child: InkWell(
                                            onTap: () {
                                              launchUrlString(
                                                  hotelData['website']);
                                              HapticFeedback.selectionClick();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  localization(context).website,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Semantics(
                                          label: localization(context)
                                              .starCount(noStars),
                                          tooltip: localization(context)
                                              .starCount(noStars),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size:
                                                    constraints.maxWidth * 0.05,
                                              ),
                                              ExcludeSemantics(
                                                child: Text(
                                                  '$noStars',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: constraints.maxHeight * 0.03),
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
                                                    constraints.maxHeight *
                                                        0.015),
                                          ),
                                          child: Text(
                                            localization(context)
                                                .startNavigation,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontSize:
                                                      constraints.maxWidth *
                                                          0.05,
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
                                    SizedBox(
                                        height: constraints.maxWidth * 0.04),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getHotelById(
      int sightId, String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    final List<Map<String, dynamic>> queryResult = await db.rawQuery('''
    SELECT 
      hotel_image_path, 
      hotel_image_path2,
      title_$languageCode AS title, 
      website,
      noStars,
      latitude,
      longitude
    FROM Hotels
    WHERE id = ?
  ''', [sightId]);

    return queryResult.first;
  }
}
