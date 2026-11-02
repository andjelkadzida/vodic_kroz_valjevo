import 'package:vodic_kroz_valjevo/database_config/tour_data_mapper.dart';

typedef TourFixtureData = Map<TourCollection, List<Map<String, dynamic>>>;

const fixtureCounts = {
  TourCollection.sights: 12,
  TourCollection.sports: 3,
  TourCollection.parks: 3,
  TourCollection.hotels: 3,
  TourCollection.restaurants: 5,
  TourCollection.aboutCity: 4,
};

TourFixtureData makeTourFixtures() => {
      for (final entry in fixtureCounts.entries)
        entry.key: List.generate(
          entry.value,
          (index) => _record(entry.key, index + 1),
        ),
    };

Map<String, dynamic> _record(TourCollection collection, int id) {
  final name = TourDataMapper.className(collection);
  final data = <String, dynamic>{'id': id};
  for (final locale in TourDataMapper.supportedLocales) {
    final language = _language(locale);
    if (collection == TourCollection.aboutCity) {
      data['legend_title_$locale'] = '$name $id $language title';
      data['legend_description_$locale'] = '$name $id $language description';
      data['history_$locale'] = '$name $language history';
    } else {
      data['title_$locale'] = '$name $id $language title';
      if (collection == TourCollection.sights ||
          collection == TourCollection.sports ||
          collection == TourCollection.parks) {
        data['description_$locale'] = '$name $id $language description';
      }
    }
  }

  const images = [
    'images/appLogo.png',
    'images/backgroundAndCoverImages/homeImage.jpg',
    'images/backgroundAndCoverImages/background.jpg',
  ];
  if (collection == TourCollection.aboutCity) {
    data['about_city_image_path'] = images.first;
    return data;
  }
  data['latitude'] = 44.0 + id / 100;
  data['longitude'] = 19.0 + id / 100;
  switch (collection) {
    case TourCollection.sights:
      data.addAll({
        'sight_image_path': images[0],
        'sight_image_path2': images[1],
        'sight_image_path3': images[2],
      });
      break;
    case TourCollection.sports:
      data.addAll({
        'sport_image_path': images[0],
        'sport_image_path2': images[1],
        'sport_image_path3': images[2],
      });
      break;
    case TourCollection.parks:
      data.addAll({
        'park_image_path': images[0],
        'park_image_path2': images[1],
        'park_image_path3': images[2],
      });
      break;
    case TourCollection.hotels:
      data.addAll({
        'hotel_image_path': images[0],
        'hotel_image_path2': images[1],
        'website': 'https://example.test/hotel',
        'noStars': 3,
      });
      break;
    case TourCollection.restaurants:
      data.addAll({
        'restaurant_image_path': images[0],
        'restaurant_image_path2': images[1],
        'restaurant_images_resource': 'https://example.test/restaurant',
      });
      break;
    case TourCollection.aboutCity:
      break;
  }
  return data;
}

String _language(String locale) {
  switch (locale) {
    case 'en':
      return 'English';
    case 'de':
      return 'Deutsch';
    case 'sr':
      return 'Srpski';
    case 'sr_Cyrl':
      return 'Ћирилица';
    case 'sr_Latn':
      return 'Latinica č';
    default:
      throw ArgumentError.value(locale, 'locale');
  }
}
