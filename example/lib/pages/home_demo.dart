import 'package:common_utils/common_utils.dart';
import 'package:flutter_huashi/flutter_huashi.dart' as FlutterHuashi;
import 'package:flutter/material.dart';

class HomeTest extends StatefulWidget {
  @override
  _HomeTestState createState() => _HomeTestState();
}

class _HomeTestState extends State<HomeTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home_demo'),
      ),
      body: Container(
        child: Column(
          children: [
            FlatButton(onPressed: () async {
              Map<String, dynamic> map = await FlutterHuashi.openCardInfo();
              LogUtil.e(map, tag: 'RESULT');
            }, child: Text('开始自动读卡')),
            FlatButton(onPressed: () async {
              Map<String, dynamic> map = await FlutterHuashi.openScanCode();
              LogUtil.e(map, tag: 'RESULT');
            }, child: Text('开始扫码'))
          ],
        ),
      ),
    );
  }
}
