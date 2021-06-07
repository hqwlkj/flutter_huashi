import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/result_page.dart';

import 'pages/home_page_v5.dart';

void main() {
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,

        /// 在Android环境下将状态栏的颜色设置我为透明
        // statusBarColor: Colors.amber,  /// 设置状态栏颜色，只在Android的M版本以上生效
        statusBarBrightness: Brightness.light,

        /// 状态栏亮度，只在IOS生效，只有light和dart模式
        statusBarIconBrightness: Brightness.light

        /// 状态栏Icon亮度，只在Android的M版本以上生效，只有light和dart模式，和AppBar的brightness相反
        );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
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
              brightness: Brightness.dark, // light为黑色 dark为白色
              centerTitle: true,
              color: Color(0xff2762D9),
              elevation: 0)),
      home: new HomePage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => HomePage(),
        '/result': (BuildContext context) => ResultPage()
      },
    );
  }
}
