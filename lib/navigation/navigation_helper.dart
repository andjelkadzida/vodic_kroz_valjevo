import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void navigateTo(BuildContext context, Widget page) {
  String routeName = page.runtimeType.toString();

  // Check if the current route is the same as the target route
  bool isCurrentRouteTarget = false;
  if (Navigator.canPop(context)) {
    final currentRoute = ModalRoute.of(context);
    if (currentRoute?.settings.name == routeName) {
      isCurrentRouteTarget = true;
    }
  }

  // Only navigate if the current route is not the target route
  if (!isCurrentRouteTarget) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: routeName),
      ),
    );
  }
}

// Show details page
void showDetailsPage(BuildContext context, Widget page) {
  HapticFeedback.mediumImpact();
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => page,
    ),
  );
}
