import 'package:flutter/material.dart';
import 'navigation/navigation_drawer.dart';

void main() {
  runApp(const VodicKrozValjevo());
}

class VodicKrozValjevo extends StatelessWidget {
  const VodicKrozValjevo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vodič kroz Valjevo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Vodič kroz Valjevo - Početna stranica'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Vodič kroz Valjevo")),
        drawer: NavigationDrawer());
  }
}
