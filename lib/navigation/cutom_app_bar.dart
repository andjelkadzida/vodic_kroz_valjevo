import 'package:flutter/material.dart';

AppBar customAppBar(BuildContext context, String title) {
  return AppBar(
    title: Semantics(
        label: title,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        )),
    excludeHeaderSemantics: true,
    centerTitle: true,
    backgroundColor: Colors.teal,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  );
}
