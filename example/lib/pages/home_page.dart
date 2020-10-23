import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_huashi/flutter_huashi.dart' as FlutterHuashi;
import 'package:flutter_huashi_example/utils/net_utils.dart';

import 'reader_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  StreamSubscription<Map> _flutterHuashi;
  String _platformVersion = 'Unknown';

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
        title: const Text(''),
        backgroundColor: Color(0xff2762D9),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xff2762D9),
        child: Column(
          children: [
            Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30,),
                  child: Center(
                    child: Image.asset('images/main.png'),
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(top: 35, bottom: 15),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) => new ReaderPage(type: 'card')),
                        );
                      },
                      child: Container(
                        width: 178.0,
                        child: Image.asset('images/sbsfzxx.png'),
                      ),
                    ),
                    SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        print('扫描渝康码');
                        Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) => new ReaderPage(type: 'scan')),
                        );
                      },
                      child: Container(
                        width: 178.0,
                        child: Image.asset('images/smykm.png'),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: 100.0,
              color: Color(0xff2762D9),
              padding: EdgeInsets.only(bottom: 25),
              child: Image.asset('images/logo.png', width: 100.0,),
            )
          ],
        ),
      ),
    );
  }
}
