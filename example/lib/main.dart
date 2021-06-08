import 'dart:async';
import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pages/result_page.dart';

import 'pages/home_page_v5.dart';

void main() {
  LogUtil.init(tag: 'HUASHI-CHS');
  runZonedGuarded(() {
    runApp(MyApp());
  }, (dynamic error, dynamic stack) {
    LogUtil.e(error);
    LogUtil.e(stack);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(800, 1280),
        builder: () => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  primaryColor: Color(0xff2762D9),
                  appBarTheme: AppBarTheme(
                      brightness: Brightness.dark, // light为黑色 dark为白色
                      centerTitle: true,
                      color: Color(0xff2762DA),
                      elevation: 0)),
              home: new HomePage(),
              routes: <String, WidgetBuilder>{
                '/home': (BuildContext context) => HomePage(),
                '/result': (BuildContext context) => ResultPage()
              },
            ));
  }
}
