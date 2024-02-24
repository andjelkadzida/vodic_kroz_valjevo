import 'package:flutter/material.dart';
import 'package:vodic_kroz_valjevo/pages/bug_report.dart';

import '../localization/language.dart';
import '../localization/supported_languages.dart';
import '../maps_navigation/map_builder.dart';
import '../pages/home_page.dart';
import '../pages/menu/menu_page.dart';
import 'navigation_helper.dart';

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String Function(BuildContext) title;
  final String Function(BuildContext) tooltip;

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
      case 4:
        navigateTo(context, const BugReportPage());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<NavItem> navItems = [
      NavItem(
          Icons.home,
          Icons.home_filled,
          (context) => localization(context).homePage,
          (context) => localization(context).homePage),
      NavItem(
          Icons.map,
          Icons.map_outlined,
          (context) => localization(context).mapPage,
          (context) => localization(context).mapPage),
      NavItem(
          Icons.menu,
          Icons.menu_open,
          (context) => localization(context).menu,
          (context) => localization(context).menu),
      NavItem(
          Icons.language,
          Icons.language_outlined,
          (context) => localization(context).languageMenu,
          (context) => localization(context).languageMenu),
      NavItem(
          Icons.bug_report,
          Icons.bug_report_outlined,
          (context) => localization(context).bugReport,
          (context) => localization(context).bugReport),
    ];

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      items: navItems.map((NavItem navItem) {
        return BottomNavigationBarItem(
          icon: Semantics(
            label: navItem.title(context),
            child: Icon(
              _selectedIndex == -1 ||
                      _selectedIndex != navItems.indexOf(navItem)
                  ? navItem.icon
                  : navItem.selectedIcon,
              size: MediaQuery.of(context).size.width * 0.07,
            ),
          ),
          label: navItem.title(context),
          tooltip: navItem.tooltip(context),
        );
      }).toList(),
      currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
      selectedItemColor: _selectedIndex == -1 ? Colors.grey : Colors.teal,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      onTap: _onNavItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: MediaQuery.of(context).textScaler.scale(14),
      unselectedFontSize: MediaQuery.of(context).textScaler.scale(12),
    );
  }
}
