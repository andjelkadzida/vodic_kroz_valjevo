import 'package:flutter/material.dart';

AppBar customAppBar(BuildContext context, String title) {
  return AppBar(
    title: Semantics(
        label: title,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        )),
    excludeHeaderSemantics: true,
    centerTitle: true,
    backgroundColor: Colors.teal,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    elevation: (MediaQuery.of(context).size.width / 150).clamp(0.0, 6.0),
  );
}
