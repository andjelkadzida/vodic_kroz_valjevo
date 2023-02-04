import 'package:dropdown_button2/dropdown_button2.dart';
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
  Widget headerWidget(BuildContext buildContext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          localization(buildContext).cityName,
          style: const TextStyle(fontSize: 25, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.all(1),
          child: languageWidget(buildContext),
        ),
      ],
    );
  }

  // Language dropdown widget
  Widget languageWidget(BuildContext buildContext) {
    return DropdownButton2<Language>(
      icon: const Icon(
        Icons.language,
        color: Colors.white,
        textDirection: TextDirection.ltr,
      ),
      underline: const SizedBox(),
      hint: Text(localization(buildContext).language),
      onChanged: (Language? language) async {
        if (language != null) {
          Locale locale = await setLocale(language.scriptCode);
          VodicKrozValjevo.setLanguage(buildContext, locale);
        }
      },
      dropdownDirection: DropdownDirection.left,
      scrollbarAlwaysShow: false,
      style: const TextStyle(fontSize: 15, color: Colors.black),
      items: Language.languageList()
          .map<DropdownMenuItem<Language>>(
            (e) => DropdownMenuItem<Language>(
              value: e,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    e.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(e.name)
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
