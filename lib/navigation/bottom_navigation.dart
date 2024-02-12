import 'package:flutter/material.dart';

import '../localization/language.dart';
import '../localization/supported_languages.dart';
import '../maps_navigation/map_builder.dart';
import '../pages/home_page.dart';
import 'menu_page.dart';
import 'navigation_helper.dart';

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final String tooltip;

  NavItem(this.icon, this.selectedIcon, this.title, this.tooltip);
}

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  CustomBottomNavigationBarState createState() =>
      CustomBottomNavigationBarState();
}

class CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = -1;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        navigateTo(context, const HomePage());
        break;
      case 1:
        navigateTo(context, const MapPage());
        break;
      case 2:
        navigateTo(context, const MenuPage());
        break;
      case 3:
        showLanguageMenu(context, calledFromNavBar: true);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<NavItem> navItems = [
      NavItem(Icons.home, Icons.home_filled, localization(context).homePage,
          localization(context).homePage),
      NavItem(Icons.map, Icons.map_outlined, localization(context).mapPage,
          localization(context).mapPage),
      NavItem(Icons.menu, Icons.menu_open, localization(context).menu,
          localization(context).menu),
      NavItem(
          Icons.language,
          Icons.language_outlined,
          localization(context).languageMenu,
          localization(context).languageMenu),
    ];

    return BottomNavigationBar(
      items: navItems
          .asMap()
          .map((index, NavItem navItem) {
            return MapEntry(
                index,
                BottomNavigationBarItem(
                  icon: Icon(
                    _selectedIndex == -1 || _selectedIndex != index
                        ? navItem.icon
                        : navItem.selectedIcon,
                    size: MediaQuery.of(context).size.width * 0.07,
                  ),
                  label: navItem.title,
                  tooltip: navItem.tooltip,
                ));
          })
          .values
          .toList(),
      currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
      selectedItemColor: _selectedIndex == -1 ? Colors.grey : Colors.teal,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      onTap: _onNavItemTapped,
    );
  }
}
