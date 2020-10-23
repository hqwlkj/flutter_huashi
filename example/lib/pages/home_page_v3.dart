import 'dart:collection';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_huashi/flutter_huashi.dart' as FlutterHuashi;
import 'package:flutter_huashi/flutter_huashi.dart';
import 'package:flutter_huashi_example/services/home_service.dart';
import 'package:flutter_huashi_example/utils/net_utils.dart';
import 'package:flutter_huashi_example/utils/utils.dart';
import 'package:flutter_huashi_example/widgets/loading.dart';

import 'result_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 音频播放
  AudioCache audioCache = AudioCache(prefix: '', fixedPlayer: AudioPlayer());
  String _type = 'card'; // card、scan、face
  String _currentBg = '';
  List<Map<String, dynamic>> _currentBtn = [];
  int _count = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _type = 'card';
    _currentBg = 'images/v3/read-card-bg.png';
    _currentBtn = [
      {"type": 'scan', "url": 'images/v3/scan-code-left-btn.png'},
      {"type": 'face', "url": 'images/v3/face-btn.png'}
    ];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      LogUtil.e('addPostFrameCallback', tag: 'addPostFrameCallback');
      if (_type == 'scan') {
        scanCodeInfo();
      } else {
        readCardInfo();
      }
    });
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    // TODO: implement didUpdateWidget
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      LogUtil.e(_type, tag: 'didUpdateWidget_type:');
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_type == 'scan') {
      FlutterHuashi.closeScanCode;
    }
    LogUtil.e('object', tag: 'dispose');
    super.dispose();
  }

  ///
  /// 按钮切换 功能
  ///
  void handleSwitch(BuildContext context, String type) async {
    Loading.showLoading(context, text: '初始化中...');
    switch (type) {
      case 'card':
        setState(() {
          _type = type;
          _currentBg = 'images/v3/read-card-bg.png';
          _currentBtn = [
            {"type": 'scan', "url": 'images/v3/scan-code-left-btn.png'},
            {"type": 'face', "url": 'images/v3/face-btn.png'}
          ];
        });
        Future.delayed(Duration(milliseconds: 1000), () {
          readCardInfo();
          Loading.hideLoading(context);
        });
        break;
      case 'scan':
        setState(() {
          _type = type;
          _currentBg = 'images/v3/scan-code-bg.png';
          _currentBtn = [
            {"type": 'card', "url": 'images/v3/read-card-btn.png'},
            {"type": 'face', "url": 'images/v3/face-btn.png'}
          ];
        });
        Future.delayed(Duration(milliseconds: 1000), () {
          scanCodeInfo();
          Loading.hideLoading(context);
        });
        break;
      case 'face':
        setState(() {
          _type = type;
          _currentBg = 'images/v3/face-bg.png';
          _currentBtn = [
            {"type": 'card', "url": 'images/v3/read-card-btn.png'},
            {"type": 'scan', "url": 'images/v3/scan-code-right-btn.png'}
          ];
        });
        faceInfo();
        break;
      default:
        Utils.showToast('别点了，没有你想去的地方');
        break;
    }
  }

  ///
  /// 读取身份证信息进行健康认证
  ///
  Future<void> readCardInfo() async {
    await audioCache.play('audios/read-card.mp3'); // 播报音频
    String result = await FlutterHuashi.initCard;
    print('82:result: $result');
    if (result == 'SUCCESS') {
      Map<String, dynamic> map = await FlutterHuashi.openAutoCard;
      if (map['code'] == 'SUCCESS') {
        CardInfoModel model =
            JsonUtil.getObject(map['data'], (v) => CardInfoModel.fromJson(v));
        print('peopleName:${model.peopleName}');
        print('iDCard:${model.iDCard}');
        checkHealth(context, _type, model.iDCard, username: model.peopleName);
      } else {
        Utils.showToast('身份证读取失败，请稍后重试...');
        readCardInfo();
      }
    }
  }

  ///
  /// 扫描渝康码信息进行健康认证
  ///
  Future<void> scanCodeInfo() async {
    await audioCache.play('audios/scan-code.mp3'); // 播报音频
    Map<String, dynamic> result = await FlutterHuashi.scanCode;
    print('100:result: $result');
    await FlutterHuashi.closeScanCode;
    if (result['code'] == 'SUCCESS') {
      LogUtil.e(result['data'], tag: 'result=>1:');
      if(result['data'].toString().indexOf("{{") > -1){
        result['data'] = result['data'].toString().substring(1,result['data'].toString().length);
      }
      LogUtil.e(result['data'], tag: 'result=>2:');
      Map<String, dynamic> resultMap =
          JsonUtil.getObject(result['data'], (v) => Map.of(v));
      checkHealth(context, _type, resultMap['codeId'], json: result['data']);
    } else {
      Utils.showToast(result['messages'] ?? '渝康码识别失败，请稍后重试...');
    }
  }

  ///
  ///  人脸识别
  ///
  Future<void> faceInfo() async {
    await FlutterHuashi.closeScanCode; // 先关闭扫码
    await audioCache.play('audios/face.mp3'); // 播报音频
    Map<String, dynamic> result = await FlutterHuashi.initWxFace();
    LogUtil.e(result['code'], tag: 'initWxFace =>  result:');
    Map<String, dynamic> result2 = await FlutterHuashi.wxFaceVerify();
    LogUtil.e(result2, tag: 'wxFaceVerify =>  result:');
    Loading.hideLoading(context);
    if (result2['code'] == 'SUCCESS') {
      Map<String, dynamic> resultMap =
          JsonUtil.getObject(result2['data'], (v) => Map.of(v));
      Response authUser =
          await HomeService.getAuthUserInfo(context, resultMap['face_sid']);
      LogUtil.e(authUser, tag: 'authUser');
      if (authUser.statusCode == 200) {
        checkHealth(context, 'face', authUser.data['credential_no'],
            username: authUser.data['real_name']);
      }
    } else {
      Utils.showToast(result2['message']); // 用户取消了也要让用户可以再次刷脸
      setState(() {
        _currentBg = 'images/v3/face-repeat-bg.png';
      });
    }
  }

  ///
  /// 根据信息进行健康认证
  ///
  Future<void> checkHealth(BuildContext context, String type, String code,
      {String json, String username}) async {
    if (type == 'card' || type == 'face') {
      Response response = await HomeService.checkHealthByCardNo(context,
          params: {"cardNo": code});
      LogUtil.e(response.data, tag: 'response');
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new ResultPage(
                  type: _type,
                  username: username,
                  result: response.data['result'].toString()))).then((value) {
        if (type == 'card') {
          readCardInfo();
        } else {
          audioCache.play('audios/face-repeat.mp3'); // 播报音频
          setState(() {
            _currentBg = 'images/v3/face-repeat-bg.png';
          });
        }
      });
    } else {
      Response response = await HomeService.checkHealthByCodeId(context,
          params: {"codeId": code});
      Response nameResponse = await HomeService.queryNameByQrcode(context,
          params: {"qrcode": json});
      LogUtil.e(nameResponse, tag: 'nameResponse');
      _count += 1;
      LogUtil.e(_count, tag: 'scan_count');
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new ResultPage(
                  type: _type,
                  username: nameResponse.data['name'] ?? '',
                  result: response.data['result'].toString()))).then((value) {
        LogUtil.e(value, tag: 'value');
        scanCodeInfo();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    NetUtils.init();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('images/v3/page-bg.jpg'),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 105,
              child: InkWell(
                onTap: (){
                  if(_type == 'face'){
                    faceInfo();
                  }
                },
                child: Image.asset(_currentBg, width: 390.0),
              ),
            ),
            Positioned(
              left: 55,
              right: 55,
              bottom: 100,
              child: Container(
                width: double.infinity,
                height: 68,
                decoration: BoxDecoration(),
                child: Stack(
                  children: _currentBtn.asMap().keys.map((index){
                    if(index == 0){
                      return Positioned(
                        left: 0,
                        child: InkWell(
                          onTap: () {
                            handleSwitch(context, _currentBtn[index]['type']);
                          },
                          child: Image.asset(_currentBtn[index]['url'], width: 152.0),
                        ),
                      );
                    }else{
                      return Positioned(
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            handleSwitch(context, _currentBtn[index]['type']);
                          },
                          child: Image.asset(_currentBtn[index]['url'], width: 152.0),
                        ),
                      );
                    }
                  }
                  ).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
