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

///
/// version 0.2
///
class NewHomePage extends StatefulWidget {
  @override
  _NewHomePageState createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  // 音频播放
  AudioCache audioCache = AudioCache(prefix: '');
  AudioPlayer audioPlayer = AudioPlayer();
  String _type = 'card'; // card、scan、face
  String _currentBg = '';
  String _currentBtn = '';
  int _count = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _type = 'card';
    _currentBg = 'images/v2/read-card-bg.png';
    _currentBtn = 'images/v2/scan-code-btn.png';
    // _currentBg = 'images/v2/scan-code-bg.jpg';
    // _currentBtn = 'images/v2/read-card-btn.png';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      LogUtil.e('addPostFrameCallback', tag: 'addPostFrameCallback');
      if(_type == 'scan'){
        scanCodeInfo();
      }else{
        readCardInfo();
      }

    });
  }

  @override
  void didUpdateWidget(NewHomePage oldWidget) {
    // TODO: implement didUpdateWidget
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      LogUtil.e(_type, tag: 'didUpdateWidget_type:');
      // if(_type == 'scan'){
      //   scanCodeInfo(); //唤起扫码
      // }else{
      //   readCardInfo(); // 开启读卡器
      // }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_type == 'scan') {
      FlutterHuashi.stopScanCode;
    }
    LogUtil.e('object', tag: 'dispose');
    super.dispose();
  }

  ///
  /// 按钮切换 功能
  ///
  void handleSwitch(BuildContext context) async {
    Loading.showLoading(context, text: '初始化中...');
    if (_type == 'scan') {
      setState(() {
        _type = 'card';
        _currentBg = 'images/v2/read-card-bg.png';
        _currentBtn = 'images/v2/scan-code-btn.png';
      });
      Future.delayed(Duration(milliseconds: 1000), () {
        readCardInfo();
        Loading.hideLoading(context);
      });
    } else {
      setState(() {
        _type = 'scan';
        _currentBg = 'images/v2/scan-code-bg.jpg';
        _currentBtn = 'images/v2/read-card-btn.png';
      });
      Future.delayed(Duration(milliseconds: 1000), () {
        scanCodeInfo();
        Loading.hideLoading(context);
      });
    }
  }

  ///
  /// 读取身份证信息进行健康认证
  ///
  Future<void> readCardInfo() async {
    await audioCache.play('audios/read-card.mp3'); // 播报音频
    Map<String, dynamic> map = await FlutterHuashi.openCardInfo(disableAudio: true);
    LogUtil.e(map);
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


  ///
  /// 扫描渝康码信息进行健康认证
  ///
  Future<void> scanCodeInfo() async {
    await audioCache.play('audios/scan-code.mp3'); // 播报音频
    Map<String, dynamic> result = await FlutterHuashi.openScanCode(disableAudio: true);
    print('100:result: $result');
    await FlutterHuashi.stopScanCode;
    if (result['code'] == 'SUCCESS') {
      Map<String, dynamic> resultMap = JsonUtil.getObject(result['data'], (v) => Map.of(v));
      checkHealth(context, _type, resultMap['codeId'], json: result['data']);
    } else {
      Utils.showToast(result['messages'] ?? '渝康码识别失败，请稍后重试...');
    }
  }

  ///
  /// 根据信息进行健康认证
  ///
  Future<void> checkHealth(BuildContext context, String type, String code,{String json, String username}) async{
    if(type =='card' || type =='face'){
      Response response = await HomeService.checkHealthByCardNo(context, params: {"cardNo": code});
      LogUtil.e(response.data, tag: 'response');
      Navigator.push(context, new MaterialPageRoute(
          builder: (context) => new ResultPage(type: _type, username: username, result: response.data['result'].toString()))
      ).then((value) {
        if(type =='card'){
          readCardInfo();
        }
      });
    }else{
      Response response = await HomeService.checkHealthByCodeId(context, params: {"codeId": code});
      Response nameResponse = await HomeService.queryNameByQrcode(context, params: {"qrcode": json});
      LogUtil.e(nameResponse, tag: 'nameResponse');
      _count += 1;
      LogUtil.e(_count, tag: 'scan_count');
      Navigator.push(context, new MaterialPageRoute(
          builder: (context) => new ResultPage(type: _type, username: nameResponse.data['name'] ?? '', result: response.data['result'].toString()))
      ).then((value) {
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
                image: new AssetImage('images/v2/page-bg.png'),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            _type == 'card' ? Positioned(
              left: 4,
              top: 120,
              child: Image.asset(_currentBg, width: 390.0),
            ):
            Positioned(
              right: 4,
              top: 120,
              child: Image.asset(_currentBg, width: 390.0),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 78,
              child: Container(
                width: 180,
                height: 58,
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    handleSwitch(context);
                  },
                  child: Image.asset(_currentBtn, width: 320.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
