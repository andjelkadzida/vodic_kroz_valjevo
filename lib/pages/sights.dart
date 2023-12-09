import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/maps_navigation/locator.dart';

class Sights extends StatelessWidget {
  Sights({Key? key}) : super(key: key);

  final List<String> imageUrls = [
    'https://via.placeholder.com/300',
    'https://via.placeholder.com/300',
    'https://via.placeholder.com/300',
    // Add more image URLs as needed
  ];

  @override
  Widget build(BuildContext context) {
    final MapScreen mapScreen = MapScreen(); // Instantiate MapScreen

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth =
        (screenWidth / 2).floor(); // Adjust the number of items per row here

    int crossAxisCount = (screenWidth / itemWidth).floor();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization(context).aboutCity,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        itemCount: imageUrls.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return Dialog(
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(20.0),
                      minScale: 0.5,
                      maxScale: 5.0,
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.contain,
                        semanticLabel: 'Image ${index + 1}',
                      ),
                    ),
                  );
                },
              );
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: Semantics(
                      label: 'Image ${index + 1}',
                      image: true,
                      child: Image.network(
                        imageUrls[index],
                        width: itemWidth.toDouble(),
                        height: itemWidth.toDouble(),
                        fit: BoxFit.cover,
                        semanticLabel: 'Image ${index + 1}',
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Text(localization(context).imageNotAvailable);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      await mapScreen
                          .getCurrentLocation(context); // Get current location
                      await mapScreen.navigateToDestination(
                          37.7749, -122.4194); // Navigate to destination
                    },
                    child: Semantics(
                        label: localization(context).navigateToDestination,
                        button: true,
                        onTap: () async {
                          await mapScreen.getCurrentLocation(
                              context); // Get current location
                          await mapScreen.navigateToDestination(
                              37.7749, -122.4194); // Navigate to destination
                        },
                        child: Text(
                          localization(context).startNavigation,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                          ),
                        )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
