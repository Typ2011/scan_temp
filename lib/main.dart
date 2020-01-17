import 'package:flutter/material.dart';
import 'package:scan_temp/screens/addSenorScreen.dart';
import 'package:scan_temp/screens/homepage.dart';

void main() => runApp(MaterialApp(
  title: "ScanTemp",
  routes: {
    "/home" : (context) => MyHomePage(),
    "/addSensor" : (context) => addSensorScreen(),
  },
  initialRoute: "/home",
  theme: ThemeData(
    primarySwatch: Colors.lightGreen,
  ),
));