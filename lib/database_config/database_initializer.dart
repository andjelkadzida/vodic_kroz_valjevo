import 'package:sqflite/sqflite.dart';

import 'about_city_repository.dart';
import 'hotels_repository.dart';
import 'sights_repository.dart';
import 'sports_repository.dart';
import 'restaurants_repository.dart';

class DatabaseInitializer {
  late SightsRepository sightsRepo;
  late SportsRepository sportsRepo;
  late HotelsRepository hotelsRepo;
  late RestaurantsRepository restaurantsRepo;
  late AboutCityRepository aboutCityRepo;

  DatabaseInitializer(Database database) {
    sightsRepo = SightsRepository(database);
    sportsRepo = SportsRepository(database);
    hotelsRepo = HotelsRepository(database);
    restaurantsRepo = RestaurantsRepository(database);
    aboutCityRepo = AboutCityRepository(database);
  }

  Future<void> initializeData() async {
    if (!(await sportsRepo.checkSportsDataExists())) {
      await sportsRepo.sportsDataInsertion();
    }

    if (!(await sightsRepo.checkSightsDataExist())) {
      await sightsRepo.sightsDataInsertion();
    }

    if (!(await hotelsRepo.checkHotelsDataExist())) {
      await hotelsRepo.hotelsDataInsertion();
    }

    if (!(await restaurantsRepo.checkRestaurantsDataExist())) {
      await restaurantsRepo.restaurantsDataInsertion();
    }

    if (!await aboutCityRepo.checkAboutCityDataExist()) {
      await aboutCityRepo.aboutCityDataInsertion();
    }
  }
}
