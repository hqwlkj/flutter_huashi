import 'package:flutter/material.dart';
import 'pages/reader_page.dart';
import 'pages/result_page.dart';

import 'pages/home_page_v3.dart';
import 'pages/scan_page_v3.dart';

void main() {
  runApp(MyApp());
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
          centerTitle: true,
          color: Color(0xff2762D9),
          elevation: 0
        )
      ),
      home: new HomePage(),
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => HomePage(),
        '/scan': (BuildContext context) => ScanPage(),
        '/reader': (BuildContext context) => ReaderPage(),
        '/result': (BuildContext context) => ResultPage()
      },
    );
  }
}
