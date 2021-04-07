import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_huashi/flutter_huashi.dart' as FlutterHuashi;
import 'package:flutter_huashi_example/utils/net_utils.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  StreamSubscription<Map> _flutterHuashi;
  String _platformVersion = 'Unknown';
  String _cardInfo = '';
  String _scanInfo = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterHuashi.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  void dispose(){
    _flutterHuashi?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NetUtils.init();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
        elevation: 0,
      ),
      body: Container(
        child: Column(
          children: [
            Text(_platformVersion),
            OutlinedButton(
              onPressed: () async {
                setState(() {
                  _cardInfo = '读取中...';
                });
                await FlutterHuashi.stopScanCode;
                Map<String, dynamic> result = await FlutterHuashi.openCardInfo();
                print(result.toString());
                setState(() {
                  _cardInfo = result.toString() ?? '读取失败';
                });
              },
              child: Text('读取身份证'),
            ),
            Container(
              height: 180,
              width: double.infinity,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffff4400)),
                borderRadius: BorderRadius.all(Radius.circular(4))
              ),
              child: SingleChildScrollView(
                child: Text(_cardInfo),
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                setState(() {
                  _scanInfo = '扫码中...';
                });
                await FlutterHuashi.stopReadCard;
                Map<String, dynamic> result = await FlutterHuashi.openScanCode();
                print(result.toString());
                setState(() {
                  _scanInfo = result.toString() ?? '扫码失败';
                });
              },
              child: Text('扫描二维码'),
            ),
            Container(
              height: 180,
              width: double.infinity,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffff4400)),
                  borderRadius: BorderRadius.all(Radius.circular(4))
              ),
              child: SingleChildScrollView(
                child: Text(_scanInfo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
