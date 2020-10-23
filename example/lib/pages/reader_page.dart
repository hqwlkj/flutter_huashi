import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_huashi/flutter_huashi.dart' as FlutterHuashi;
import 'package:flutter_huashi/flutter_huashi.dart';
import 'package:flutter_huashi_example/pages/result_page.dart';
import 'package:flutter_huashi_example/services/home_service.dart';
import 'package:flutter_huashi_example/utils/utils.dart';

/// 等待读卡、扫码页
/// version 0.1
///
class ReaderPage extends StatefulWidget {
  final String type;

  const ReaderPage({Key key, this.type}) : super(key: key);

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  StreamSubscription<Map> _flutterHuashi;
  // 音频播放
  AudioCache audioCache = AudioCache(prefix: '');
  AudioPlayer advancedPlayer = AudioPlayer();
  String localFilePath;

  @override
  void initState() {
    super.initState();
    _initOpenCard();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _initOpenCard() async {
    if (widget.type == 'card') {
      await audioCache.play('audios/read-card.mp3'); // 播报音频
      String result = await FlutterHuashi.initCard;
      print('46:result:$result');
      if (result == 'SUCCESS') {
        Map<String, dynamic> map = await FlutterHuashi.openAutoCard;
        print('map:${map['code']}');
        print('data:${map['data']}');
        if (map['code'] == 'SUCCESS') {
          CardInfoModel model =
              JsonUtil.getObject(map['data'], (v) => CardInfoModel.fromJson(v));
          print('peopleName:${model.peopleName}');
          print('iDCard:${model.iDCard}');
          checkHealth(context, widget.type, model.iDCard, username: model.peopleName);
        } else {
          Utils.showToast('身份证读取失败，请稍后重试...');
        }
      }
    } else {
      audioCache.play('audios/scan-code.mp3'); // 播报音频
      Map<String, dynamic> result = await FlutterHuashi.scanCode;
      print('59:result: $result');
      await FlutterHuashi.closeScanCode;
      if (result['code'] == 'SUCCESS') {
        Map<String, dynamic> resultMap = JsonUtil.getObject(result['data'], (v) => Map.of(v));
        checkHealth(context, widget.type, resultMap['codeId'], json: result['data']);
      } else {
        print('messages:${result['messages']}');
        Utils.showToast('${result['messages']}' ?? '渝康码识别失败，请稍后重试...');
      }
    }
  }

  Future<void> checkHealth(BuildContext context, String type, String code,{String json, String username}) async{
    if(type =='card'){
      Response response = await HomeService.checkHealthByCardNo(context, params: {"cardNo": code});
      LogUtil.e(response.data, tag: 'response');
      Navigator.pushReplacement(context, new MaterialPageRoute(
          builder: (context) => new ResultPage(type: widget.type, username: username, result: response.data['result'].toString()))
      );
    }else{
      Response response = await HomeService.checkHealthByCodeId(context, params: {"codeId": code});
      Response nameResponse = await HomeService.queryNameByQrcode(context, params: {"qrcode": json});
      LogUtil.e(nameResponse, tag: 'nameResponse');
      Navigator.pushReplacement(context, new MaterialPageRoute(
          builder: (context) => new ResultPage(type: widget.type, username: nameResponse.data['name'] ?? '', result: response.data['result'].toString()))
      );
    }
  }

  @override
  void dispose() {
    _flutterHuashi?.cancel();
    advancedPlayer.dispose();
    audioCache.disableLog();
    audioCache.clearCache();
    if (widget.type == 'scan') {
      FlutterHuashi.closeScanCode;
    }
    super.dispose();
  }

  Widget _buildScanCodeWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 50.0,
            left: MediaQuery.of(context).size.width / 2 - 135,
            child: Text(
              '请将手机渝康码放置感应区',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff2762D9),
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ),
          Center(
            widthFactor: double.infinity,
            child: Image.asset('images/scan-code-bg.png',
                width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            top: 150.0,
            left: MediaQuery.of(context).size.width / 2 - 85,
            child: Column(
              children: [
                Text(
                  '将手机渝康码放置感应区域',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xfff7b764),
                      fontWeight: FontWeight.w300,
                      fontSize: 14),
                ),
                Text(
                  '即可生成、查看渝康码信息',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xfff7b764),
                      fontWeight: FontWeight.w300,
                      fontSize: 14),
                )
              ],
            ),
          ),
          Positioned(
              left: MediaQuery.of(context).size.width / 2 - 60,
              bottom: 25.0,
              child: Image.asset(
                'images/read-footer.png',
                width: 140.0,
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.type == 'card' ? '识别身份证' : '识别渝康码'),
          backgroundColor: Color(0xff2762D9),
          elevation: 0,
        ),
        body: widget.type == 'scan'
            ? _buildScanCodeWidget(context)
            : Container(
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      top: 50.0,
                      left: MediaQuery.of(context).size.width / 2 - 135,
                      child: Text(
                        '请将本人身份证放置感应区',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xff2762D9),
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                    ),
                    Center(
                      widthFactor: double.infinity,
                      child: Image.asset('images/read-card-bg.png',
                          width: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 150.0,
                      left: MediaQuery.of(context).size.width / 2 - 85,
                      child: Column(
                        children: [
                          Text(
                            '将身份证放置感应区域',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xfff7b764),
                                fontWeight: FontWeight.w300,
                                fontSize: 14),
                          ),
                          Text(
                            '即可生成、查看渝康码信息',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xfff7b764),
                                fontWeight: FontWeight.w300,
                                fontSize: 14),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 60,
                        bottom: 25.0,
                        child: Image.asset(
                          'images/read-footer.png',
                          width: 140.0,
                        ))
                  ],
                ),
              ));
  }
}
