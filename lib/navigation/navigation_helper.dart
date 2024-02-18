import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void navigateTo(BuildContext context, Widget page) {
  String routeName = page.runtimeType.toString();

  // Check if the current route is the same as the target route
  bool isCurrentRouteTarget = false;
  Navigator.popUntil(context, (route) {
    if (route.settings.name == routeName) {
      isCurrentRouteTarget = true;
    }
    return true;
  });

  // Only navigate if the current route is not the target route
  if (!isCurrentRouteTarget) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: routeName),
      ),
    );
  }
}

void showDetailsPage(BuildContext context, Widget page) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => page,
    ),
  );
  HapticFeedback.lightImpact();
}
