import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> checkInitialInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

Stream<bool> hasInternetConnection() {
  return Connectivity().onConnectivityChanged.map((result) {
    return result != ConnectivityResult.none;
  });
}
