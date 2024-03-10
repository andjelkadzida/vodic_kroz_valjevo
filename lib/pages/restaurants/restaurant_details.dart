import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
                              SizedBox(
                                height: constraints.maxHeight * 0.3,
                                child: Semantics(
                                  label: localization(context).restaurantImage,
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
                              Padding(
                                padding:
                                    EdgeInsets.all(constraints.maxWidth * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Semantics(
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
                                    SizedBox(
                                        height: constraints.maxHeight * 0.02),
                                    Semantics(
                                      button: true,
                                      enabled: true,
                                      onTapHint: localization(context)
                                          .navigateToRestaurant,
                                      child: SizedBox(
                                        width: double.infinity,
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
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: constraints.maxWidth *
                                                    0.05),
                                          ),
                                          onPressed: () {
                                            mapScreen.navigateToDestination(
                                                restaurantData['latitude'],
                                                restaurantData['longitude']);
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

  Future<Map<String, dynamic>> _getRestaurantById(
      int restaurantId, String languageCode) async {
    final db = await DatabaseHelper.instance.getNamedDatabase();
    final List<Map<String, dynamic>> queryResult = await db.rawQuery('''
    SELECT 
      restaurant_image_path, 
      restaurant_image_path2,
      title_$languageCode AS title, 
      latitude,
      longitude
    FROM Restaurants
    WHERE id = ?
  ''', [restaurantId]);

    return queryResult.first;
  }
}
