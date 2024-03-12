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

class RestaurantDetailsPage extends StatelessWidget {
  final int restaurantId;
  static final MapScreen mapScreen = MapScreen();

  const RestaurantDetailsPage({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future:
          _getRestaurantById(restaurantId, localization(context).localeName),
      builder: (context, snapshot) {
        return DatabaseHelper.buildFutureState<Map<String, dynamic>>(
          context: context,
          snapshot: snapshot,
          onData: (restaurantData) {
            final images = [
              restaurantData['restaurant_image_path'],
              restaurantData['restaurant_image_path2'],
            ];
            precacheImages(context, images);
            return Scaffold(
              appBar: customAppBar(
                context,
                restaurantData['title'],
                const Color.fromRGBO(11, 20, 32, 1),
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
                              SizedBox(height: constraints.maxHeight * 0.05),
                              _buildRestaurantImageGallery(
                                  context, images, constraints),
                              Semantics(
                                child: SizedBox(
                                  width: max(50, constraints.maxWidth * 0.5),
                                  height: max(50, constraints.maxHeight * 0.05),
                                  child: InkWell(
                                    onTap: () {
                                      launchUrlString(restaurantData[
                                          'restaurant_images_resource']);
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
                                                  fontWeight: FontWeight.w300,
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
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restaurantData['title'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(
                                          height: constraints.maxHeight * 0.01),
                                      Container(
                                        width: constraints.maxWidth * 0.5,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color:
                                                  Color.fromRGBO(11, 20, 32, 1),
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      _buildNavigationButton(context,
                                          restaurantData, constraints.maxWidth),
                                    ],
                                  ),
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

  Widget _buildRestaurantImageGallery(
      BuildContext context, List<dynamic> images, BoxConstraints constraints) {
    return Semantics(
      label: localization(context).hotelImage,
      child: SizedBox(
        height: constraints.maxHeight * 0.3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: PhotoViewGallery.builder(
            itemCount: images.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions.customChild(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                  ),
                ),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.5,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
            ),
            loadingBuilder: (context, event) => Center(
              child: Semantics(
                tooltip: localization(context).loading,
                child: CircularProgressIndicator(
                  semanticsLabel: localization(context).loading,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context,
      Map<String, dynamic> restaurantData, double screenWidth) {
    return SizedBox(
      width: max(50, screenWidth * 0.5),
      height: max(50, screenWidth * 0.1),
      child: Semantics(
        button: true,
        onTapHint: localization(context).tapToNavigateToRestaurant,
        child: Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => MapScreen().navigateToDestination(
                restaurantData['latitude'], restaurantData['longitude']),
            child: Text(
              localization(context).startNavigation,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w300,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getRestaurantById(
      int restaurantId, String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    final List<Map<String, dynamic>> queryResult = await db.rawQuery('''
    SELECT 
      restaurant_image_path, 
      restaurant_image_path2,
      restaurant_images_resource,
      title_$languageCode AS title, 
      latitude,
      longitude
    FROM Restaurants
    WHERE id = ?
  ''', [restaurantId]);

    return queryResult.first;
  }
}
