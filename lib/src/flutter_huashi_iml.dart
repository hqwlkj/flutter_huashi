import 'dart:async';

import 'package:flutter/services.dart';

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

/// 开启扫码
Future<Map<String, dynamic>> openScanCode() async {
  final Map<String, dynamic> result = await _channel.invokeMapMethod('openScanCode');
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
/// 新的开始读卡
Future<Map<String, dynamic>> openCardInfo() async {
  final Map<String, dynamic> result = await _channel.invokeMapMethod('openCardInfo');
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
