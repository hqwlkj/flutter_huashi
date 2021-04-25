import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_huashi/src/enums/ScanType.dart';

MethodChannel _channel = const MethodChannel('flutter_huashi')..setMethodCallHandler(_methodHandler);

StreamController<Map> _flutterHuashiResponseEventHandlerController = new StreamController.broadcast();
Stream<Map> get flutterHuashiResponseEventHandler => _flutterHuashiResponseEventHandlerController.stream;

///
/// 获取 platform 版本号
///
Future<String> get platformVersion async {
  final String version = await _channel.invokeMethod('getPlatformVersion');
  return version;
}

///
/// 开启扫码
/// disableAudio: 是否静音扫码
/// scanType： 扫码类型，默认为扫码，可选参数为：payCode, qrCode
///
Future<Map<String, dynamic>> openScanCode({bool disableAudio, ScanType scanType}) async {
  final Map<String, dynamic> result = await _channel.invokeMapMethod('openScanCode',{
    'disableAudio': disableAudio ?? false,
    'scanType': scanType == ScanType.PAYCODE ? 'PAYCODE' : 'QRCODE'
  });
  return result;
}

/// 停止扫码
Future<String> get stopScanCode async{
  return await _channel.invokeMethod("stopScanCode");
}

/// 停止读卡
Future<String> get stopReadCard async{
  return await _channel.invokeMethod("stopReadCard");
}
///
/// 开始读卡
/// disableAudio: 是否静音读卡
///
Future<Map<String, dynamic>> openCardInfo({bool disableAudio}) async {
  final Map<String, dynamic> result = await _channel.invokeMapMethod('openCardInfo', {
    'disableAudio': disableAudio ?? false
  });
  return result;
}

Future _methodHandler(MethodCall methodCall){
  // var response = BaseWeChatResponse.create(methodCall.method, methodCall.arguments);
  print('_methodHandler');
  var response = Map();
  response['code'] = 200;
  response['message'] = 'success';
  _flutterHuashiResponseEventHandlerController.add(response);
  return Future.value();
}
