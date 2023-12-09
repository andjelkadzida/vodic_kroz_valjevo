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
                        icon: Icon(Icons.home,
                            semanticLabel: localization(context).homePage,
                            color: Colors.white),
                        index: 0,
                      ),
                      drawerItemWidget(
                        context,
                        label: localization(context).aboutCity,
                        icon: Icon(Icons.info,
                            semanticLabel: localization(context).aboutCity,
                            color: Colors.white),
                        index: 1,
                      ),
                      drawerItemWidget(
                        context,
                        label: localization(context).sights,
                        icon: Icon(Icons.location_city,
                            semanticLabel: localization(context).sights,
                            color: Colors.white),
                        index: 2,
                      ),
                      drawerItemWidget(
                        context,
                        label: localization(context).sportRecreation,
                        icon: Icon(Icons.sports_gymnastics,
                            semanticLabel:
                                localization(context).sportRecreation,
                            color: Colors.white),
                        index: 3,
                      ),
                      drawerItemWidget(
                        context,
                        label: localization(context).restaurantsAndHotels,
                        icon: Icon(Icons.restaurant_menu,
                            semanticLabel:
                                localization(context).restaurantsAndHotels,
                            color: Colors.white),
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
      {required String label, required Icon icon, required int index}) {
    return Semantics(
      label: label,
      button: true,
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: Semantics(label: label, child: icon),
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AboutCity()));
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
        child: Icon(
          Icons.language,
          color: Colors.white,
          textDirection: TextDirection.ltr,
          semanticLabel: localization(buildContext).languageMenu,
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
                  label: e.flag,
                  child: Text(
                    e.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Semantics(
                  label: e.name,
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
