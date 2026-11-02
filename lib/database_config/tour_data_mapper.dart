enum TourCollection { sights, sports, parks, hotels, restaurants, aboutCity }

class TourDataMapper {
  static const supportedLocales = ['en', 'de', 'sr', 'sr_Cyrl', 'sr_Latn'];

  static String className(TourCollection collection) {
    switch (collection) {
      case TourCollection.sights:
        return 'Sights';
      case TourCollection.sports:
        return 'Sports';
      case TourCollection.parks:
        return 'Parks';
      case TourCollection.hotels:
        return 'Hotels';
      case TourCollection.restaurants:
        return 'Restaurants';
      case TourCollection.aboutCity:
        return 'AboutCity';
    }
  }

  static Map<String, dynamic> forLocale(
    TourCollection collection,
    Map<String, dynamic> record,
    String locale,
  ) {
    if (!supportedLocales.contains(locale)) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported language.');
    }

    final name = className(collection);
    final result = Map<String, dynamic>.from(record);
    final objectId = _requiredString(result, 'objectId', name);
    result['id'] = objectId;

    if (collection == TourCollection.aboutCity) {
      result['title'] = _requiredString(result, 'legend_title_$locale', name);
      result['description'] =
          _requiredString(result, 'legend_description_$locale', name);
      result['history'] = _requiredString(result, 'history_$locale', name);
      _requiredString(result, 'about_city_image_path', name);
      return result;
    }

    result['title'] = _requiredString(result, 'title_$locale', name);
    _requireCoordinates(result, name);

    final imageKeys = <String>[];
    switch (collection) {
      case TourCollection.sights:
        imageKeys.addAll(
            ['sight_image_path', 'sight_image_path2', 'sight_image_path3']);
        result['description'] =
            _requiredString(result, 'description_$locale', name);
        break;
      case TourCollection.sports:
        imageKeys.addAll(
            ['sport_image_path', 'sport_image_path2', 'sport_image_path3']);
        result['description'] =
            _requiredString(result, 'description_$locale', name);
        break;
      case TourCollection.parks:
        imageKeys.addAll(
            ['park_image_path', 'park_image_path2', 'park_image_path3']);
        result['description'] =
            _requiredString(result, 'description_$locale', name);
        break;
      case TourCollection.hotels:
        imageKeys.addAll(['hotel_image_path', 'hotel_image_path2']);
        _requiredString(result, 'website', name);
        final stars = result['noStars'];
        if (stars is! num ||
            !stars.isFinite ||
            stars < 0 ||
            stars.toInt() != stars) {
          throw FormatException('Invalid noStars in $name/$objectId.');
        }
        result['noStars'] = stars.toInt();
        break;
      case TourCollection.restaurants:
        imageKeys.addAll(['restaurant_image_path', 'restaurant_image_path2']);
        _requiredString(result, 'restaurant_images_resource', name);
        break;
      case TourCollection.aboutCity:
        throw StateError('AboutCity was already handled.');
    }
    for (final key in imageKeys) {
      _requiredString(result, key, name);
    }
    return result;
  }

  static String _requiredString(
      Map<String, dynamic> record, String key, String className) {
    final value = record[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing or invalid $key in $className.');
    }
    return value;
  }

  static void _requireCoordinates(
      Map<String, dynamic> record, String className) {
    for (final entry in {'latitude': 90, 'longitude': 180}.entries) {
      final value = record[entry.key];
      if (value is! num || !value.isFinite || value.abs() > entry.value) {
        throw FormatException('Invalid ${entry.key} in $className.');
      }
      record[entry.key] = value.toDouble();
    }
  }
}
