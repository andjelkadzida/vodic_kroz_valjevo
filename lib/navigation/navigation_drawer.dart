import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/language.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/main.dart';
import 'package:vodic_kroz_valjevo/navigation/drawer_item.dart';
import 'package:vodic_kroz_valjevo/pages/about_city.dart';
import 'package:vodic_kroz_valjevo/pages/home_page.dart';
import 'package:vodic_kroz_valjevo/pages/hotels_and_restaurants.dart';
import 'package:vodic_kroz_valjevo/pages/sights.dart';
import 'package:vodic_kroz_valjevo/pages/sport_and_recreation.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 80, 24, 0),
            child: Column(
              children: [
                headerWidget(context),
                const SizedBox(
                  height: 40,
                ),
                const Divider(
                  thickness: 1,
                  height: 10,
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 40,
                ),
                DrawerItem(
                    name: localization(context).homePage,
                    icon: Icons.home,
                    onPressed: () => onItemPressed(context, index: 0)),
                DrawerItem(
                    name: localization(context).aboutCity,
                    icon: Icons.info,
                    onPressed: () => onItemPressed(context, index: 1)),
                DrawerItem(
                    name: localization(context).sights,
                    icon: Icons.location_city,
                    onPressed: () => onItemPressed(context, index: 2)),
                DrawerItem(
                    name: localization(context).sportRecreation,
                    icon: Icons.sports_gymnastics,
                    onPressed: () => onItemPressed(context, index: 3)),
                DrawerItem(
                    name: localization(context).restaurantsAndHotels,
                    icon: Icons.restaurant_menu,
                    onPressed: () => onItemPressed(context, index: 4)),
              ],
            ),
          )),
    );
  }

  //Routing navigation
  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(context);

    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AboutCity()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Sights()));
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SportsAndRecreation()));
        break;
      case 4:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const HotelsAndRestaurants()));
        break;
      default:
        Navigator.pop(context);
        break;
    }
  }

  //Header widget
  Widget headerWidget(BuildContext context) {
    // const url = '';
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<Language>(
            underline: const SizedBox(),
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            onChanged: (Language? language) async {
              if (language != null) {
                Locale _locale = await setLocale(language.scriptCode);
                VodicKrozValjevo.setLanguage(context, _locale);
              }
            },
            items: Language.languageList()
                .map<DropdownMenuItem<Language>>(
                  (e) => DropdownMenuItem<Language>(
                    value: e,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          e.flag,
                          style: const TextStyle(fontSize: 30),
                        ),
                        Text(e.name)
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const CircleAvatar(
          radius: 20,
          //backgroundImage: NetworkImage(url),
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Valjevo',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        )
      ],
    );
  }
}
