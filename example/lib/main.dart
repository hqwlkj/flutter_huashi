import 'package:flutter/material.dart';

import 'pages/home_page.dart';

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
      },
    );
  }
}
