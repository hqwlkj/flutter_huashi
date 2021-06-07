import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_huashi/flutter_huashi.dart' as FlutterHuashi;
import 'package:flutter_huashi/flutter_huashi.dart';
import 'package:flutter_huashi_example/services/home_service.dart';
import 'package:flutter_huashi_example/utils/net_utils.dart';
import 'package:flutter_huashi_example/utils/utils.dart';
import 'package:flutter_huashi_example/widgets/loading.dart';
import 'package:wechat_face_payment/wechat_face_payment.dart';
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
      {"type": 'scan', "url": 'images/v3/scan-code.png'},
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
          _type = type;
          _currentBg = 'images/v3/read-card-bg.png';
          _currentBtn = [
            {"type": 'scan', "url": 'images/v3/scan-code.png'}
          ];
        });
        Future.delayed(Duration(milliseconds: 1000), () {
          readCardInfo(context);
          Loading.hideLoading(context);
        });
        break;
      case 'scan':
        setState(() {
          _type = type;
          _currentBg = 'images/v3/scan-code-bg.png';
          _currentBtn = [
            {"type": 'card', "url": 'images/v3/read-card.png'}
          ];
        });
        Future.delayed(Duration(milliseconds: 1000), () {
          Loading.hideLoading(context);
          scanCodeInfo(context);
        });
        break;
      case 'face':
        setState(() {
          _type = type;
          _currentBg = 'images/v3/face-bg.png';
          _currentBtn = [
            {"type": 'card', "url": 'images/v3/read-card.png'},
            {"type": 'scan', "url": 'images/v3/scan-code-right-btn.png'}
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
    LogUtil.e(map,tag:'idcard');
    if (map['code'] == 'SUCCESS') {
      CardInfoModel model =
      JsonUtil.getObject(map['data'], (v) => CardInfoModel.fromJson(v));
      print('peopleName:${model.peopleName}');
      print('iDCard:${model.iDCard}');
      checkHealth(context, _type, model.iDCard, username: model.peopleName);
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
      if(result['data'].toString().indexOf('codeId') < 0){
        Utils.showToast(result['messages'] ?? '请出示正常的渝康码信息');
        scanCodeInfo(context);
      }else{
        if(result['data'].toString().indexOf("{{") > -1){
          result['data'] = result['data'].toString().substring(1,result['data'].toString().length);
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
    Loading.showLoading(context, text: '认证中,请稍候...' ,fontSize: 12);
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
        _currentBg = 'images/v3/face-repeat-bg.png';
      });
    }
  }

  ///
  /// 根据信息进行健康认证
  ///
  Future<void> checkHealth(BuildContext context, String type, String code,
      {String json, String username}) async {
    Loading.showLoading(context, text: '认证中,请稍候...' ,fontSize: 12);
    if (type == 'card' || type == 'face') {
      HomeService.checkHealthByCardNo(context, params: {"cardNo": code}).then((response) {
        Loading.hideLoading(context);
        LogUtil.e(response, tag: '我是返回的：response=>');
        if(response == null || response?.statusCode != 200 || response?.data['data'].toString()=='2'){
          if (type == 'card') {
            Utils.showToast('身份证认证失败，请稍后重试...');
            readCardInfo(context);
          } else {
            Utils.showToast('人脸认证失败，请稍后重试...');
            audioCache.play('audios/face-repeat.mp3'); // 播报音频
            setState(() {
              _currentBg = 'images/v3/face-repeat-bg.png';
            });
          }
        } else {
          if(response?.data['errcode']==0){
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ResultPage(
                        type: _type,
                        username: username,
                        result: response.data['data'].toString()))).then((value) {
              if (type == 'card') {
                readCardInfo(context);
              } else {
                audioCache.play('audios/face-repeat.mp3'); // 播报音频
                setState(() {
                  _currentBg = 'images/v3/face-repeat-bg.png';
                });
              }
            });
          }else{
            if (type == 'card') {
              Utils.showToast(response?.data['errmsg']);
              readCardInfo(context);
            } else {
              Utils.showToast('人脸认证失败，请稍后重试...');
              audioCache.play('audios/face-repeat.mp3'); // 播报音频
              setState(() {
                _currentBg = 'images/v3/face-repeat-bg.png';
              });
            }
          }
        }
      }).catchError((e){
        Loading.hideLoading(context);
        LogUtil.e(e, tag: 'onError');
        if (type == 'card') {
          Utils.showToast('身份证认证超时，请重新识别...');
          readCardInfo(context);
        } else {
          Utils.showToast('人脸认证超时，请稍后重试...');
          audioCache.play('audios/face-repeat.mp3'); // 播报音频
          setState(() {
            _currentBg = 'images/v3/face-repeat-bg.png';
          });
        }
      });
    } else {
      HomeService.checkHealthByCodeId(context,
          params: {"codeId": code}).then((response) async {
        Response nameResponse = await HomeService.queryNameByQrcode(context,
            params: {"qrcode": json});
        LogUtil.e(nameResponse?.statusCode, tag: 'nameResponse');
        _count += 1;
        Loading.hideLoading(context);
        if(response == null || response?.statusCode != 200 || response?.data['result'].toString()=='2' || nameResponse?.statusCode !=200){
          Utils.showToast('渝康码识别失败，请稍后重试...');
          scanCodeInfo(context);
        }else{
          Navigator.push(
                context,
              new MaterialPageRoute(
                  builder: (context) => new ResultPage(
                      type: _type,
                      username: nameResponse.data['name'] ?? '',
                      result: response.data['result'].toString()))).then((value) {
            scanCodeInfo(context);
          });
        }
      }).catchError((e){
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
                    Loading.showLoading(context, text: '初始化中...');
                    faceInfo(context);
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
                        left: 70,
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
