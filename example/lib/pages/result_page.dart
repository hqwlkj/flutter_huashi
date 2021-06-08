import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_huashi_example/widgets/v_empty_view.dart';


///
/// 认证结果
///
class ResultPage extends StatefulWidget {
  final String result;
  final String type;
  final String username;

  const ResultPage({Key key, this.result, this.type, this.username})
      : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  AudioCache audioCache = AudioCache(prefix: '', fixedPlayer: AudioPlayer());
  Timer _timer;
  int seconds;
  String _upTime;
  @override
  void initState() {
    super.initState();
    /// 获取总秒数
    seconds = 2;
    _upTime='${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute < 10 ? '0${DateTime.now().minute}' : DateTime.now().minute}:${DateTime.now().second}';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _startTimer();
      if (widget.result == "0") {
        audioCache.play('audios/success.mp3');
      } else {
        audioCache.play('audios/error.mp3');
      }
    });
  }
  void _startTimer() {
    ///设置 1 秒回调一次
    const period = const Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      ///更新界面
      setState(() {
        /// 秒数减一，因为一秒回调一次
        seconds--;
      });
      if (seconds == 0) {
        ///倒计时秒数为0，取消定时器
        _cancelTimer();
        Navigator.pop(context);
      }
    });
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    audioCache.clearCache();
    _cancelTimer();
    super.dispose();
  }

  String _getPageTitle(){
    if(widget.type == 'card'){
      return '身份证认证';
    }else if(widget.type == 'scan'){
      return '渝康码认证';
    }else{
      return '人脸识别认证';
    }
  }

  @override
  Widget build(BuildContext context) {
    Color _globalColor =
    widget.result == '0' ? Color(0xff03b75a) : Color(0xffeb4141);
    String _username = widget.username ?? '';
    return Scaffold(
      backgroundColor: _globalColor,
      appBar: AppBar(
          title: Text(_getPageTitle()),
          elevation: 0,
          actions: [
            FlatButton(
              onPressed: (){
                if(seconds > 0){
                  // Navigator.pop(context);
                  // _cancelTimer();
                } else {
                  LogUtil.e('====================');
                }
              },
              child: Container(
                  alignment: Alignment.center,
                  height: 20,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  child: Text('关闭 ${seconds ?? 0}', style: TextStyle(fontWeight: FontWeight.w300,fontSize: 12, color: Colors.white),)
              ),
            )
          ],
          backgroundColor: _globalColor),
      body: Column(
        children: [
          VEmptyView(20),
          Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Image.asset('images/result-bg.png'),
                  ),
                  Center(
                    child: Image.asset(
                      widget.result == '0'
                          ? 'images/success.png'
                          : 'images/error.png',
                      width: 120.0,
                    ),
                  ),
                  Positioned(
                    top: 65,
                    left: 165,
                    child: Text(
                      TextUtil.hideNumber(_username,
                          start: _username.length >= 3 ? 1 : 0,
                          end: _username.length - 1,
                          replacement: "*" * (_username.length >= 3 ? 1 : 2)),
                      style: TextStyle(
                          color: _globalColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: 120,
                    child: Text(
                      "健康码状态：${widget.result == '0' ? '健康' : '异常'}",
                      style: TextStyle(
                          color: _globalColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Positioned(
                    bottom: 90,
                    left: 125,
                    child: Column(
                      children: [
                        Text('更新于',
                            style: TextStyle(
                                color: _globalColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400)),
                        VEmptyView(5),
                        Text(
                            _upTime,
                            style: TextStyle(
                                color: _globalColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400))
                      ],
                    ),
                  )
                ],
              )),
          Container(
            padding: EdgeInsets.only(bottom: 25, top: 40),
            alignment: Alignment.center,
            child: Image.asset(
              'images/home-footer.png',
              width: 140.0,
            ),
          )
        ],
      ),
    );
  }
}
