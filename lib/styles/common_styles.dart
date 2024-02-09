import 'package:flutter/material.dart';

class AppStyles {
  static TextStyle defaultAppBarTextStyle(TextScaler textScaler) {
    return TextStyle(
      color: Colors.white,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w300,
      fontSize: textScaler.scale(20),
      letterSpacing: 1,
    );
  }

  static TextStyle navigationListItemStyle(TextScaler textScaler) {
    return TextStyle(
        fontSize: textScaler.scale(18),
        color: Colors.white,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500);
  }

  static TextStyle headerWidgetStyle(TextScaler textScaler) {
    return TextStyle(
      fontSize: textScaler.scale(25),
      color: Colors.white,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle sightDialogStyle(TextScaler textScaler) {
    return TextStyle(
      fontSize: textScaler.scale(18),
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w500,
      letterSpacing: 1.0,
    );
  }

  static TextStyle sightTitleStyle(TextScaler textScaler) {
    return TextStyle(
      color: Colors.black,
      fontFamily: 'Roboto',
      fontSize: textScaler.scale(16),
      fontWeight: FontWeight.w500,
      letterSpacing: 1.5,
    );
  }

  static TextStyle hotelsAndRestaurantsStyle(TextScaler textScaler) {
    return TextStyle(
      color: Colors.black,
      fontFamily: 'Roboto',
      fontSize: textScaler.scale(35),
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    );
  }

  static TextStyle hotelsAndRestaurantsTitleStyle(TextScaler textScaler) {
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w700,
      fontSize: textScaler.scale(20),
      color: Colors.black,
    );
  }

  static TextStyle hotelsAndRestaurantsTextStyle(TextScaler textScaler) {
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: textScaler.scale(16),
      color: Colors.black,
    );
  }

  static TextStyle locationDenialTextStyle(TextScaler textScaler) {
    return const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500);
  }
}
