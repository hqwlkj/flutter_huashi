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
  String _title = '';
  String _subtitle = '';
  List<Map<String, dynamic>> _currentBtn = [];
  int _count = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _type = 'card';
    _currentBg = 'images/v6/read-card-bg.png';
    _title = '识别身份证'; // 识别身份证 & 识别二维码
    _subtitle = '请将手机渝康码放置感应区';
    _currentBtn = [
      {"type": 'scan', "text": '扫描渝康码'},
      {"type": 'face', "text": '人脸识别'}
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
          _title = '识别身份证'; // 识别身份证 & 识别二维码
          _subtitle = '请将本人身份证放置感应区';
          _currentBg = 'images/v6/read-card-bg.png';
          _currentBtn = [
            {"type": 'scan', "text": '扫描渝康码'},
            {"type": 'face', "text": '人脸识别'}
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
          _currentBg = 'images/v6/scan-code-bg.png';
          _subtitle = '请将手机渝康码放置感应区';
          _title = '识别二维码'; // 识别身份证 & 识别二维码
          _currentBtn = [
            {"type": 'card', "text": '识别身份证'},
            {"type": 'face', "text": '人脸识别'}
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
          _currentBg = 'images/v6/face-bg.png';
          _subtitle = '请面向屏幕开始刷脸';
          _title = '人脸识别'; // 识别身份证 & 识别二维码 & 人脸识别
          _currentBtn = [
            {"type": 'card', "text": '识别身份证'},
            {"type": 'scan', "text": '扫描渝康码'}
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
    LogUtil.e(map);
    if (map['code'] == 'SUCCESS') {
      CardInfoModel model = JsonUtil.getObject(map['data'], (v) => CardInfoModel.fromJson(v));
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
      if (result['data'].toString().indexOf('codeId') < 0) {
        Utils.showToast(result['messages'] ?? '请出示正常的渝康码信息');
        scanCodeInfo(context);
      } else {
        if (result['data'].toString().indexOf("{{") > -1) {
          result['data'] = result['data'].toString().substring(1, result['data'].toString().length);
        }
        LogUtil.e(result['data'], tag: 'result=>2:');
        Map<String, dynamic> resultMap = JsonUtil.getObject(result['data'], (v) => Map.of(v));
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
    WechatFacePayment result = await WechatFacePayment.initFacePay(
        "wx34aa1d8ffa545b06",
        "1506994921",
        "123455",
        "http://parsec.cqkqinfo.com/app/stage-exhibition-api/face");
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
        // _currentBg = 'images/v3/face-repeat-bg.png';
        _subtitle = '点击屏幕开始人脸识别';
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
      Response response = await HomeService.checkHealthByCardNo(context, params: {"cardNo": code});
      LogUtil.e(response.data, tag: 'response');
      Loading.hideLoading(context);
      if (response.data['data'].toString() == '2') {
        Utils.showToast('渝康码识别失败，请稍后重试...');
      } else {
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
              // _currentBg = 'images/v3/face-repeat-bg.png';
              _subtitle = '点击屏幕开始人脸识别';
            });
          }
        });
      }
    } else {
      Response response = await HomeService.checkHealthByCodeId(context, params: {"codeId": code});
      Response nameResponse = await HomeService.queryNameByQrcode(context, params: {"qrcode": json});
      _count += 1;
      Loading.hideLoading(context);
      if (response.data['result'].toString() == '2') {
        Utils.showToast('渝康码识别失败，请稍后重试...');
      } else {
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
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            // image: new DecorationImage(image: new AssetImage('images/v3/page-bg.jpg'), fit: BoxFit.cover)
            color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              top: 50.0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _subtitle,
                  style: TextStyle(
                      color: Color(0xff2762D9),
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
            ),
            _type == 'face'? Container() :Positioned(
              top: 120.0,
              left: MediaQuery.of(context).size.width / 2 - 108,
              child: Column(
                children: [
                  Text(
                    _type == 'card' ? '将身份证放置感应区域' : '将手机渝康码放置感应区域',
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
              left: 0,
              right: 0,
              top: 105,
              child: InkWell(
                onTap: () {
                  if (_type == 'face') {
                    Loading.showLoading(context, text: '初始化中...');
                    faceInfo(context);
                  }
                },
                child: Image.asset(_currentBg, width: 390.0),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 60,
              child: Container(
                width: double.infinity,
                height: 68,
                decoration: BoxDecoration(),
                child: Stack(
                  children: _currentBtn.asMap().keys.map((index) {
                    if (index == 0) {
                      return Positioned(
                        left: 0,
                        child: InkWell(
                          onTap: () {
                            handleSwitch(context, _currentBtn[index]['type']);
                          },
                          child: Container(
                            width: 172,
                            height: 58,
                            decoration: BoxDecoration(
                                image: new DecorationImage(
                                    image: new AssetImage(
                                        'images/v6/btn-left.png'),
                                    fit: BoxFit.cover)),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                                child: Text('${_currentBtn[index]['text']}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              )),
                          ),
                        ),
                      );
                    } else {
                      return Positioned(
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            handleSwitch(context, _currentBtn[index]['type']);
                          },
                          child: Container(
                            width: 172,
                            height: 58,
                            decoration: BoxDecoration(
                                image: new DecorationImage(
                                    image: new AssetImage(
                                        'images/v6/btn-right.png'),
                                    fit: BoxFit.cover)),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                                child:Text(_currentBtn[index]['text'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            )),
                          ),
                        ),
                      );
                    }
                  }).toList(),
                ),
              ),
            ),
            Positioned(
                left: MediaQuery.of(context).size.width / 2 - 75,
                bottom: 25.0,
                child: Image.asset('images/v6/footer-logo.png',
                    width: 100.0, fit: BoxFit.cover)),
            Positioned(
                left: MediaQuery.of(context).size.width / 2 - 68,
                bottom: 8.0,
                child: Text('023-63066080', style: TextStyle(fontSize: 14, color: Color(0xffB7D6F5))))
          ],
        ),
      ),
    );
  }
}
