import 'package:flutter/material.dart';

import '../localization/language.dart';
import '../localization/supported_languages.dart';
import '../maps_navigation/map_builder.dart';
import '../pages/home_page.dart';
import 'menu_page.dart';
import 'navigation_helper.dart';

class NavItem {
  final IconData icon;
  final String title;

  NavItem(this.icon, this.title);
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
      NavItem(Icons.home, localization(context).homePage),
      NavItem(Icons.map, localization(context).mapPage),
      NavItem(Icons.menu, localization(context).menu),
      NavItem(Icons.language, localization(context).languageMenu),
    ];

    return BottomNavigationBar(
      items: navItems.map((NavItem navItem) {
        return BottomNavigationBarItem(
          icon: Icon(navItem.icon,
              size: MediaQuery.of(context).size.width * 0.07),
          label: navItem.title,
        );
      }).toList(),
      currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
      selectedItemColor: _selectedIndex == -1 ? Colors.grey : Colors.teal,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: false,
      showSelectedLabels: true,
      onTap: _onNavItemTapped,
    );
  }
}
