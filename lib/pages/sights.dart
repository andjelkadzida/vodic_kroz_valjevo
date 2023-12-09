import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/maps_navigation/locator.dart';

class Sights extends StatelessWidget {
  Sights({Key? key}) : super(key: key);

  // Lista slika znamenitosti
  final List<String> imageUrls = [
    'https://via.placeholder.com/300',
    'https://via.placeholder.com/300',
    'https://via.placeholder.com/300',
  ];

  // Lista koordinata do znamenitosti
  final List<List<double>> destinationCoordinates = [
    [44.27809742651686, 19.88519586174966], // Kula Nenadovica
  ];

  @override
  Widget build(BuildContext context) {
    final MapScreen mapScreen = MapScreen();

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth =
        (screenWidth / 2).floor(); // Adjust the number of items per row

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
                      await mapScreen.getCurrentLocation(context);
                      // Use the destination coordinates based on the index
                      if (index < destinationCoordinates.length) {
                        await mapScreen.navigateToDestination(
                            destinationCoordinates[index][0],
                            destinationCoordinates[index][1]);
                      }
                    },
                    child: Semantics(
                        label: localization(context).navigateToDestination,
                        button: true,
                        onTap: () async {
                          final MapScreen mapScreen = MapScreen();
                          await mapScreen.getCurrentLocation(context);
                          // Use the destination coordinates based on the index
                          if (index < destinationCoordinates.length) {
                            await mapScreen.navigateToDestination(
                                destinationCoordinates[index][0],
                                destinationCoordinates[index][1]);
                          }
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
