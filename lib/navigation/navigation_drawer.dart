import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/localization/language.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/main.dart';
import 'package:vodic_kroz_valjevo/pages/about_city.dart';
import 'package:vodic_kroz_valjevo/pages/home_page.dart';
import 'package:vodic_kroz_valjevo/pages/hotels_and_restaurants.dart';
import 'package:vodic_kroz_valjevo/pages/sights.dart';
import 'package:vodic_kroz_valjevo/pages/sport_and_recreation.dart';
import 'package:vodic_kroz_valjevo/styles/common_styles.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Material(
          color: Colors.black,
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: Column(
              children: [
                headerWidget(context),
                const Divider(
                  thickness: 1,
                  height: 10,
                  color: Colors.grey,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (BuildContext context, int index) {
                      return drawerItemWidget(context, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drawerItemWidget(BuildContext context, int index) {
    final textScaler = MediaQuery.textScalerOf(context);

    String label;
    IconData icon;
    switch (index) {
      case 0:
        label = localization(context).homePage;
        icon = Icons.home;
        break;
      case 1:
        label = localization(context).aboutCity;
        icon = Icons.info;
        break;
      case 2:
        label = localization(context).sights;
        icon = Icons.location_city;
        break;
      case 3:
        label = localization(context).sportRecreation;
        icon = Icons.sports_gymnastics;
        break;
      case 4:
        label = localization(context).restaurantsAndHotels;
        icon = Icons.restaurant_menu;
        break;
      default:
        label = localization(context).close;
        icon = Icons.close;
    }

    return Semantics(
        button: true,
        label: label,
        child: ExcludeSemantics(
          child: ListTile(
            title: Text(label,
                style: AppStyles.navigationListItemStyle(textScaler)),
            leading: Icon(
              icon,
              color: Colors.white,
            ),
            onTap: () => onItemPressed(context, index),
          ),
        ));
  }

  void onItemPressed(BuildContext context, int index) {
    Navigator.pop(context);
    // Implement navigation based on index
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
    }
  }

  Widget headerWidget(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Semantics(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                localization(context).cityName,
                style: AppStyles.headerWidgetStyle(textScaler),
                semanticsLabel: localization(context).cityName,
              ),
            ),
            languageWidget(context),
          ],
        ),
      ),
    );
  }

  Widget languageWidget(BuildContext buildContext) {
    final textScaler = MediaQuery.textScalerOf(buildContext);

    return PopupMenuButton<Language>(
      tooltip: localization(buildContext).languageMenu,
      icon: Semantics(
        label: localization(buildContext).languageMenu,
        child: const Icon(
          Icons.language,
          color: Colors.white,
          textDirection: TextDirection.ltr,
        ),
      ),
      offset: const Offset(60, 40),
      onSelected: (Language language) async {
        Locale locale = await setLocale(language.scriptCode);
        VodicKrozValjevo.setLanguage(locale);
      },
      itemBuilder: (BuildContext context) {
        return Language.languageList().map((Language e) {
          return PopupMenuItem<Language>(
            value: e,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ExcludeSemantics(
                    child: Text(
                  e.flag,
                  style: TextStyle(fontSize: textScaler.scale(20)),
                )),
                Semantics(
                  label: e.name,
                  excludeSemantics: true,
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
