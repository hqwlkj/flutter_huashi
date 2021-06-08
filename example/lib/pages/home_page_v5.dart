import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chs/flutter_chs.dart';
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

  // 音频播放
  AudioCache audioCache = AudioCache(prefix: '', fixedPlayer: AudioPlayer());
  String _type = 'card'; // card、scan、face
  String _title = '';
  String _subtitle = '';
  String _currentBg = '';
  String _uiVersion = 'v5'; // UI版本号

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _type = 'card';
    _title = '识别身份证'; // 识别身份证 & 识别二维码
    _subtitle = '请将手机渝康码放置感应区';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      LogUtil.e('addPostFrameCallback', tag: 'addPostFrameCallback');
      multiFunctionCertification(context);
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
    audioCache.disableLog();
    audioCache.clearCache();
    FlutterChs.closeDevice;
    WechatFacePayment.releaseWxPayFace;
    LogUtil.e('dispose', tag: 'dispose');
    super.dispose();
  }


  /// 多功能识别
  void multiFunctionCertification(BuildContext context) async {
    Map<String, dynamic> result = await FlutterChs.openReadDevice(timeout: 24 * 60 * 60);
    LogUtil.e(result);
    if(result['code'] == 0){
      Map<String, dynamic> data = JsonUtil.getObj(result['data'], (v) => Map.of(v));
      LogUtil.e(data);
      LogUtil.e(data['type']);
      if(data['type'] == 'IDCARD'){
        checkHealth(context, data['type'], data['id_number'], username: data['name']);
      }
      if(data['type'] == 'SCAN'){
        // {"barcode":"{\"codeId\":\"1622e0f1383a01b6792048d569d3faf9\",\"lastReportTime\":1617768110000,\"outTime\":9999999999999,\"zoning\":\"500000\"}","type":"SCAN"}}
        Map<String, dynamic> _data = JsonUtil.getObj(data['barcode'], (v) => Map.of(v));
        LogUtil.e(_data);
        checkHealth(context, data['type'], _data['codeId'], json: data['barcode']);
      }
      if(data['type'] == 'HEALTHCARD'){
        checkHealth(context, data['type'], data['idCardNo'], username: data['name']);
      }
    }else{
      Utils.showToast(result['message'] ?? '识别失败，请稍后重试...');
      multiFunctionCertification(context);
    }
  }

  ///
  /// 按钮切换 功能
  ///
  void handleSwitch(BuildContext context, String type) async {
    Loading.showLoading(context, text: '初始化中...');
    if(type == 'face'){
      setState(() {
        _type = 'face';
        _title = '人脸识别'; // 识别身份证 & 识别二维码 & 人脸识别
        _subtitle = '请面向屏幕开始刷脸';
        _currentBg = 'images/$_uiVersion/face-bg.png';
      });
      faceInfo(context);
    } else {
      setState(() {
        _type = 'card';
        _currentBg = 'images/$_uiVersion/read-card-bg.png';
        _title = '识别身份证'; // 识别身份证 & 识别二维码
      });
      Future.delayed(Duration(milliseconds: 1000), () {
        multiFunctionCertification(context);
        Loading.hideLoading(context);
      });
    }
  }

  ///
  ///  人脸识别
  ///
  Future<void> faceInfo(BuildContext context) async {
    await audioCache.play('audios/face.mp3'); // 播报音频
    await FlutterChs.closeDevice; // 先停止多功能功能
    WechatFacePayment result = await WechatFacePayment.initFacePay("wx34aa1d8ffa545b06", "1506994921", "123455", "http://parsec.cqkqinfo.com/app/stage-exhibition-api/face");
    LogUtil.e(result, tag: 'initWxFace =>  result:');
    Loading.hideLoading(context);
    Map<String, dynamic> result2 = await WechatFacePayment.wxFaceVerify();
    Loading.showLoading(context, text: '认证中,请稍候...', fontSize: 12);
    if (result2['code'] == 'SUCCESS') {
      Map<String, dynamic> resultMap =
          JsonUtil.getObject(result2['data'], (v) => Map.of(v));
      Response authUser =
          await HomeService.getAuthUserInfo(context, resultMap['face_sid']);
      if (authUser.statusCode == 200) {
        checkHealth(context, 'face', authUser.data['credential_no'],
            username: authUser.data['real_name']);
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
    if (type == 'IDCARD' || type == 'HEALTHCARD' || type == 'face') {
      HomeService.checkHealthByCardNo(context, params: {"cardNo": code})
          .then((response) {
        Loading.hideLoading(context);
        LogUtil.e(response, tag: '我是返回的：response=>');
        if (response == null || response?.statusCode != 200 || response?.data['data'].toString() == '2') {
          if (type == 'IDCARD' || type == 'HEALTHCARD') {
            Utils.showToast(type == 'IDCARD' ? '身份证认证失败，请稍后重试...' : '社保卡认证失败，请稍后重试...');
            multiFunctionCertification(context);
          } else {
            Utils.showToast('人脸认证失败，请稍后重试...');
            audioCache.play('audios/face-repeat.mp3'); // 播报音频
            setState(() {
              _currentBg = 'images/$_uiVersion/face-repeat-bg.png';
            });
          }
        } else {
          if (response?.data['errcode'] == 0) {
            Navigator.push(context, new MaterialPageRoute(builder: (context) => new ResultPage(type: _type, username: username, result: response.data['data'].toString()))).then((value) {
              if (type == 'IDCARD' || type == 'HEALTHCARD') {
                multiFunctionCertification(context);
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
              multiFunctionCertification(context);
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
        if (type == 'face') {
          Utils.showToast('人脸认证超时，请稍后重试...');
          audioCache.play('audios/face-repeat.mp3'); // 播报音频
          setState(() {
            _currentBg = 'images/$_uiVersion/face-repeat-bg.png';
          });
        } else {
          Utils.showToast('身份证认证超时，请重新识别...');
          multiFunctionCertification(context);
        }
      });
    } else {
      HomeService.checkHealthByCodeId(context, params: {"codeId": code}).then((response) async {
        Response nameResponse = await HomeService.queryNameByQrcode(context, params: {"qrcode": json});
        LogUtil.e(nameResponse?.statusCode, tag: 'nameResponse');
        Loading.hideLoading(context);
        if (response == null || response?.statusCode != 200 || response?.data['result'].toString() == '2' || nameResponse?.statusCode != 200) {
          Utils.showToast('渝康码识别失败，请稍后重试...');
          multiFunctionCertification(context);
        } else {
          Navigator.push(context, new MaterialPageRoute(builder: (context) => new ResultPage(type: _type, username: nameResponse.data['name'] ?? '', result: response.data['result'].toString()))).then((value) {
            multiFunctionCertification(context);
          });
        }
      }).catchError((e) {
        Loading.hideLoading(context);
        Utils.showToast('渝康码认证超时，请重新扫码...');
        multiFunctionCertification(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    NetUtils.init();
    print(MediaQuery.of(context).size.width);
    print(MediaQuery.of(context).size.height);
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
          backgroundColor: Color(0xff2762D9),
          elevation: 0,
          actions: [
            TextButton(onPressed: (){
              handleSwitch(context, 'face');
            }, child: Text('面部签到'))
          ],
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
                  child: Image.asset(_currentBg, width: 650, fit: BoxFit.cover),
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
          handleSwitch(context, 'face');
        },
        style: ButtonStyle(backgroundColor:
        MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Color(0xff104dd9);
          }
          return Color(0xff2762DA);
        })),
        child: Text('面部签到',style: TextStyle(
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
        child: Text('多功能签到', style: TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold
        )),
      );
    }
  }
}
