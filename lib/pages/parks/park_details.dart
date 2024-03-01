import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../helper/images_loader_helper.dart';
import '../../localization/supported_languages.dart';
import '../../maps_navigation/map_screen.dart';
import '../../navigation/bottom_navigation.dart';
import '../../navigation/cutom_app_bar.dart';
import '../../text_to_speech/text_to_speech_config.dart';

class ParkDetailsPage extends StatelessWidget {
  final Map<String, dynamic> parkData;

  const ParkDetailsPage({Key? key, required this.parkData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MapScreen mapScreen = MapScreen();

    List<String> images = [
      parkData['park_image_path'],
      parkData['park_image_path2'],
      parkData['park_image_path3'],
    ];
    precacheImages(context, images);
    return Scaffold(
      appBar: customAppBar(
        context,
        parkData['title'],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(constraints.maxWidth * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      image: true,
                      label:
                          localization(context).imageOfSight(parkData['title']),
                      child: Container(
                        color: Colors.transparent,
                        height: constraints.maxWidth * 0.6,
                        child: PhotoViewGallery.builder(
                          itemCount: images.length,
                          builder: (context, index) {
                            return PhotoViewGalleryPageOptions(
                              imageProvider: AssetImage(images[index]),
                              maxScale: PhotoViewComputedScale.contained * 5,
                              minScale: PhotoViewComputedScale.contained,
                              initialScale: PhotoViewComputedScale.contained,
                              basePosition: Alignment.center,
                              filterQuality: FilterQuality.high,
                              heroAttributes: PhotoViewHeroAttributes(
                                tag: images[index],
                                transitionOnUserGestures: true,
                              ),
                            );
                          },
                          scrollPhysics: const BouncingScrollPhysics(),
                          backgroundDecoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                          ),
                          loadingBuilder: (context, event) => Center(
                            child: Tooltip(
                              message: localization(context).loading,
                              child: CircularProgressIndicator(
                                semanticsLabel: localization(context).loading,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                    SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        button: true,
                        label: localization(context).startNavigation,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: constraints.maxWidth * 0.015,
                            ),
                          ),
                          child: Text(
                            localization(context).startNavigation,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: constraints.maxWidth * 0.05,
                                    ),
                          ),
                          onPressed: () {
                            mapScreen.navigateToDestination(
                                parkData['latitude'], parkData['longitude']);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                    ExpansionTile(
                      expandedAlignment: Alignment.bottomCenter,
                      enableFeedback: true,
                      initiallyExpanded: false,
                      title: Row(
                        children: [
                          Text(
                            localization(context).description,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontSize: constraints.maxWidth * 0.06,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          SizedBox(
                            width: max(constraints.maxWidth * 0.06, 50),
                            height: max(constraints.maxWidth * 0.06, 50),
                            child: GestureDetector(
                              onDoubleTap: () =>
                                  TextToSpeechConfig.instance.stopSpeaking(),
                              child: IconButton(
                                onPressed: () => TextToSpeechConfig.instance
                                    .speak(parkData['description']),
                                tooltip: localization(context).tapToHearDetails,
                                icon: Icon(
                                  Icons.volume_up,
                                  semanticLabel:
                                      localization(context).tapToHearDetails,
                                  size: constraints.maxWidth * 0.065,
                                  applyTextScaling: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Text(
                          parkData['description'],
                          textAlign: TextAlign.left,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.black,
                                  fontSize: constraints.maxWidth * 0.05,
                                  fontWeight: FontWeight.w400),
                        ),
                      ],
                    )
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
