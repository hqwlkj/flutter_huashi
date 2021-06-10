import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page_v6.dart';
import 'pages/result_page.dart';

import 'pages/device_page.dart';

void main() {
  runZonedGuarded(() {
    runApp(MyApp());
  }, (dynamic error, dynamic stack) {
    print(error);
    print(stack);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Color(0xff2762D9),
          appBarTheme: AppBarTheme(
              brightness: Brightness.dark, // light为黑色 dark为白色
              centerTitle: true,
              color: Color(0xff2762D9),
              elevation: 0)),
      home: new HomePage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => HomePage(),
        '/result': (BuildContext context) => ResultPage(),
        '/device': (BuildContext context) => DevicePage()
      },
    );
  }
}
