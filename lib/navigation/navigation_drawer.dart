import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/language.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/main.dart';
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
      child: SafeArea(
        child: Material(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              children: [
                headerWidget(context),
                const Divider(
                  thickness: 1,
                  height: 10,
                  color: Colors.grey,
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      drawerItemWidget(
                        context,
                        label: localization(context).homePage,
                        icon: Icons.home,
                        index: 0,
                      ),
                      drawerItemWidget(
                        context,
                        label: localization(context).aboutCity,
                        icon: Icons.info,
                        index: 1,
                      ),
                      drawerItemWidget(
                        context,
                        label: localization(context).sights,
                        icon: Icons.location_city,
                        index: 2,
                      ),
                      drawerItemWidget(
                        context,
                        label: localization(context).sportRecreation,
                        icon: Icons.sports_gymnastics,
                        index: 3,
                      ),
                      drawerItemWidget(
                        context,
                        label: localization(context).restaurantsAndHotels,
                        icon: Icons.restaurant_menu,
                        index: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drawerItemWidget(BuildContext context,
      {required String label, required IconData icon, required int index}) {
    return Semantics(
      button: true,
      child: ListTile(
        title: Text(label,
            style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500)),
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        onTap: () => onItemPressed(context, index: index),
      ),
    );
  }

  // Routing navigation
  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(context);

    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AboutCity()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Sights()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SportsAndRecreation()));
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HotelsAndRestaurants()));
        break;
      default:
        Navigator.pop(context);
        break;
    }
  }

  // Header widget
  Widget headerWidget(BuildContext buildContext) {
    return Semantics(
      label: localization(buildContext).cityName,
      child: SizedBox(
        width: MediaQuery.of(buildContext).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                localization(buildContext).cityName,
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            languageWidget(buildContext),
          ],
        ),
      ),
    );
  }

  // Language dropdown widget
  Widget languageWidget(BuildContext buildContext) {
    return PopupMenuButton<Language>(
      tooltip: localization(buildContext).languageMenu, // Tooltip for the icon
      icon: Semantics(
        label: localization(buildContext).languageMenu,
        child: const Icon(
          Icons.language,
          color: Colors.white,
          textDirection: TextDirection.ltr,
        ),
      ),
      offset: const Offset(60, 40), // Adjust the vertical offset
      onSelected: (Language language) async {
        Locale locale = await setLocale(language.scriptCode);
        VodicKrozValjevo.setLanguage(buildContext, locale);
      },
      itemBuilder: (BuildContext context) {
        return Language.languageList().map((Language e) {
          return PopupMenuItem<Language>(
            value: e,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Semantics(
                  child: Text(
                    e.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Semantics(
                  child: Text(
                    e.name,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
