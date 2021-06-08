import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_huashi/flutter_huashi.dart' as FlutterHuashi;
import 'package:flutter_huashi/flutter_huashi.dart';
import 'package:wechat_face_payment/wechat_face_payment.dart';
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
  StreamSubscription<Map> _flutterHuashi;

  // 音频播放
  AudioCache audioCache = AudioCache(prefix: '', fixedPlayer: AudioPlayer());
  String _type = 'card'; // card、scan、face
  String _title = '';
  String _subtitle = '';
  String _currentBg = '';

  List<Map<String, dynamic>> _currentBtn = [];
  int _count = 0;
  String _uiVersion = 'v5';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _type = 'card';
    _title = '识别身份证'; // 识别身份证 & 识别二维码
    _subtitle = '请将本人身份证放置感应区';
    _currentBtn = [
      {"type": 'scan', "url": 'images/$_uiVersion/scan-code.png'},
    ];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      LogUtil.e('addPostFrameCallback', tag: 'addPostFrameCallback');
      readCardInfo(context);
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
    _flutterHuashi?.cancel();
    audioCache.disableLog();
    audioCache.clearCache();
    FlutterHuashi.stopReadCard;
    FlutterHuashi.stopScanCode;
    WechatFacePayment.releaseWxPayFace;
    LogUtil.e('dispose', tag: 'dispose');
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
          _type = 'card';
          _currentBg = 'images/$_uiVersion/read-card-bg.png';
          _title = '识别身份证'; // 识别身份证 & 识别二维码
          _subtitle = '请将本人身份证放置感应区';
          _currentBtn = [
            {"type": 'scan', "url": 'images/$_uiVersion/scan-code.png'}
          ];
        });
        Future.delayed(Duration(milliseconds: 1000), () {
          readCardInfo(context);
          Loading.hideLoading(context);
        });
        break;
      case 'scan':
        setState(() {
          _type = 'scan';
          _title = '识别二维码'; // 识别身份证 & 识别二维码
          _subtitle = '请将手机渝康码放置感应区';
          _currentBg = 'images/$_uiVersion/scan-code-bg.png';
          _currentBtn = [
            {"type": 'card', "url": 'images/$_uiVersion/read-card.png'}
          ];
        });
        Future.delayed(Duration(milliseconds: 1000), () {
          Loading.hideLoading(context);
          scanCodeInfo(context);
        });
        break;
      case 'face':
        setState(() {
          _type = 'face';
          _title = '人脸识别'; // 识别身份证 & 识别二维码 & 人脸识别
          _subtitle = '请面向屏幕开始刷脸';
          _currentBg = 'images/$_uiVersion/face-bg.png';
          _currentBtn = [
            {"type": 'card', "url": 'images/$_uiVersion/read-card.png'},
            {"type": 'scan', "url": 'images/$_uiVersion/scan-code-right-btn.png'}
          ];
        });
        faceInfo(context);
        break;
      default:
        Utils.showToast('别点了，没有你想去的地方');
        break;
    }
  }

  ///
  /// 读取身份证信息进行健康认证
  ///
  Future<void> readCardInfo(BuildContext context) async {
    await audioCache.play('audios/read-card.mp3'); // 播报音频
    Map<String, dynamic> map = await FlutterHuashi.openCardInfo(disableAudio: true);
    LogUtil.e(map, tag: 'idcard');
    if (map['code'] == 'SUCCESS') {
      CardInfoModel model =
          JsonUtil.getObject(map['data'], (v) => CardInfoModel.fromJson(v));
      print('peopleName:${model.peopleName}');
      print('iDCard:${model.iDCard}');
      if(model.iDCard != null){
        checkHealth(context, _type, model.iDCard, username: model.peopleName);
      }else{
        Utils.showToast('身份证读取失败，请稍后重试...');
        readCardInfo(context);
      }
    } else {
      Utils.showToast('身份证读取失败，请稍后重试...');
      readCardInfo(context);
    }
  }

  ///
  /// 扫描渝康码信息进行健康认证
  ///
  Future<void> scanCodeInfo(BuildContext context) async {
    await audioCache.play('audios/scan-code.mp3'); // 播报音频
    Map<String, dynamic> result = await FlutterHuashi.openScanCode(disableAudio: true);
    LogUtil.e(result, tag: 'openScanCode:');
    if (result['code'] == 'SUCCESS') {
      LogUtil.e(result['data'], tag: 'result=>1:');
      if (result['data'].toString().indexOf('codeId') < 0) {
        Utils.showToast(result['messages'] ?? '请出示正常的渝康码信息');
        scanCodeInfo(context);
      } else {
        if (result['data'].toString().indexOf("{{") > -1) {
          result['data'] = result['data']
              .toString()
              .substring(1, result['data'].toString().length);
        }
        LogUtil.e(result['data'], tag: 'result=>2:');
        Map<String, dynamic> resultMap =
            JsonUtil.getObject(result['data'], (v) => Map.of(v));
        checkHealth(context, _type, resultMap['codeId'], json: result['data']);
      }
    } else {
      Utils.showToast(result['messages'] ?? '渝康码识别失败，请稍后重试...');
      scanCodeInfo(context);
    }
  }

  ///
  ///  人脸识别
  ///
  Future<void> faceInfo(BuildContext context) async {
    await audioCache.play('audios/face.mp3'); // 播报音频
    await FlutterHuashi.stopScanCode; // 先停止扫码
    await FlutterHuashi.stopReadCard; // 先停止读卡
    WechatFacePayment result = await WechatFacePayment.initFacePay("wx34aa1d8ffa545b06", "1506994921", "123455", "http://parsec.cqkqinfo.com/app/stage-exhibition-api/face");
    LogUtil.e(result, tag: 'initWxFace =>  result:');
    Loading.hideLoading(context);
    Map<String, dynamic> result2 = await WechatFacePayment.wxFaceVerify();
    Loading.showLoading(context, text: '认证中,请稍候...', fontSize: 12);
    if (result2['code'] == 'SUCCESS') {
      Map<String, dynamic> resultMap = JsonUtil.getObject(result2['data'], (v) => Map.of(v));
      Response authUser = await HomeService.getAuthUserInfo(context, resultMap['face_sid']);
      if (authUser.statusCode == 200) {
        checkHealth(context, 'face', authUser.data['credential_id'], username: authUser.data['real_name']);
      }
    } else {
      Loading.hideLoading(context);
      Utils.showToast(result2['message']); // 用户取消了也要让用户可以再次刷脸
      setState(() {
        _currentBg = 'images/$_uiVersion/face-repeat-bg.png';
      });
    }
  }

  ///
  /// 根据信息进行健康认证
  ///
  Future<void> checkHealth(BuildContext context, String type, String code,
      {String json, String username}) async {
    Loading.showLoading(context, text: '认证中,请稍候...', fontSize: 12);
    if (type == 'card' || type == 'face') {
      HomeService.checkHealthByCardNo(context, params: {"cardNo": code})
          .then((response) {
        Loading.hideLoading(context);
        LogUtil.e(response, tag: '我是返回的：response=>');
        if (response == null ||
            response?.statusCode != 200 ||
            response?.data['data'].toString() == '2') {
          if (type == 'card') {
            Utils.showToast('身份证认证失败，请稍后重试...');
            readCardInfo(context);
          } else {
            Utils.showToast('人脸认证失败，请稍后重试...');
            audioCache.play('audios/face-repeat.mp3'); // 播报音频
            setState(() {
              _currentBg = 'images/$_uiVersion/face-repeat-bg.png';
            });
          }
        } else {
          if (response?.data['errcode'] == 0) {
            Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new ResultPage(
                            type: _type,
                            username: username,
                            result: response.data['data'].toString())))
                .then((value) {
              if (type == 'card') {
                readCardInfo(context);
              } else {
                audioCache.play('audios/face-repeat.mp3'); // 播报音频
                setState(() {
                  _currentBg = 'images/$_uiVersion/face-repeat-bg.png';
                });
              }
            });
          } else {
            if (type == 'card') {
              Utils.showToast(response?.data['errmsg']);
              readCardInfo(context);
            } else {
              Utils.showToast('人脸认证失败，请稍后重试...');
              audioCache.play('audios/face-repeat.mp3'); // 播报音频
              setState(() {
                _currentBg = 'images/$_uiVersion/face-repeat-bg.png';
              });
            }
          }
        }
      }).catchError((e) {
        Loading.hideLoading(context);
        LogUtil.e(e, tag: 'onError');
        if (type == 'card') {
          Utils.showToast('身份证认证超时，请重新识别...');
          readCardInfo(context);
        } else {
          Utils.showToast('人脸认证超时，请稍后重试...');
          audioCache.play('audios/face-repeat.mp3'); // 播报音频
          setState(() {
            _currentBg = 'images/$_uiVersion/face-repeat-bg.png';
          });
        }
      });
    } else {
      HomeService.checkHealthByCodeId(context, params: {"codeId": code}).then((response) async {
        Response nameResponse = await HomeService.queryNameByQrcode(context, params: {"qrcode": json});
        LogUtil.e(nameResponse?.statusCode, tag: 'nameResponse');
        _count += 1;
        Loading.hideLoading(context);
        if (response == null || response?.statusCode != 200 || response?.data['data'].toString() == '2' || nameResponse?.statusCode != 200) {
          Utils.showToast('渝康码识别失败，请稍后重试...');
          scanCodeInfo(context);
        } else {
          Navigator.push(context, new MaterialPageRoute(builder: (context) => new ResultPage(type: _type, username: nameResponse.data['name'] ?? '', result: response.data['data'].toString())))
              .then((value) {
            scanCodeInfo(context);
          });
        }
      }).catchError((e) {
        Loading.hideLoading(context);
        Utils.showToast('渝康码认证超时，请重新扫码...');
        scanCodeInfo(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    NetUtils.init();
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
          backgroundColor: Color(0xff2762D9),
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Positioned(
                top: 50.0,
                left: MediaQuery.of(context).size.width / 2 - 155,
                child: Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xff2762D9),
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
              Positioned(
                top: 100.0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  child: Image.asset(_type == 'card' ? 'images/v5/read-card-bg.png' : 'images/v5/scan-code-bg.png', width: 650, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 120.0,
                left: MediaQuery.of(context).size.width / 2 - 108,
                child: Column(
                  children: [
                    Text(
                      _type == 'card' ?'将身份证放置感应区域' : '将手机渝康码放置感应区域',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xffFFB879),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Text(
                      _type == 'card' ? '即可生成、查看渝康码信息' : '即可生成、查看渝康码信息',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xffFFB879),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    )
                  ],
                ),
              ),
              Positioned(
                left: 25,
                right: 25,
                bottom: 70,
                child: Container(
                  width: double.infinity,
                  height: 58,
                  child: _getButton(context),
                ),
              ),
              Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 75,
                  bottom: 15.0,
                  child: Image.asset('images/v5/footer-logo.png', width: 100.0, fit: BoxFit.cover))
            ],
          ),
        ));
  }

  Widget _getButton(BuildContext context){
    if (_type == 'card') {
      return TextButton(
        onPressed: () {
          handleSwitch(context, 'scan');
        },
        style: ButtonStyle(backgroundColor:
        MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Color(0xff104dd9);
          }
          return Color(0xff2762DA);
        })),
        child: Text('扫描渝康码',style: TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold
        )),
      );
    } else {
      return TextButton(
        style: ButtonStyle(backgroundColor:
        MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Color(0xff104dd9);
          }
          return Color(0xff2762DA);
        })),
        onPressed: () {
          handleSwitch(context, 'card');
        },
        child: Text('识别身份证', style: TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold
        )),
      );
    }
  }
}
