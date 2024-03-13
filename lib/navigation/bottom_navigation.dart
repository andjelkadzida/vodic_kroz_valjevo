import 'dart:math';

import 'package:flutter/material.dart';

import '../localization/language.dart';
import '../localization/supported_languages.dart';
import '../maps_navigation/map_builder.dart';
import '../pages/bug_report.dart';
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
  final Color unselectedColor;
  const CustomBottomNavigationBar({Key? key, required this.unselectedColor})
      : super(key: key);

  @override
  CustomBottomNavigationBarState createState() =>
      CustomBottomNavigationBarState();
}

class CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late final Color unselectedColor;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    unselectedColor = widget.unselectedColor;
  }

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
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
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
          icon: SizedBox(
            width: max(50, screenWidth * 0.1),
            height: max(50, screenHeight * 0.03),
            child: Icon(
              _selectedIndex == -1 ||
                      _selectedIndex != navItems.indexOf(navItem)
                  ? navItem.icon
                  : navItem.selectedIcon,
              size: screenWidth * 0.07,
            ),
          ),
          label: navItem.title(context),
          tooltip: navItem.tooltip(context),
        );
      }).toList(),
      currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
      unselectedItemColor: unselectedColor,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      onTap: _onNavItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: screenWidth * 0.03,
      unselectedFontSize: screenWidth * 0.03,
    );
  }
}
