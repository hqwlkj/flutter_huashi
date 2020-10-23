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

///
/// 初始化读卡器
///
Future<String> get initCard async {
  final String result = await _channel.invokeMethod('initCard');
  return result;
}

///
/// 开启读卡
///
Future<String> get openCard async {
  final String result = await _channel.invokeMethod('openCard');
  return result;
}

///
/// 开启自动读卡
///
Future<Map<String, dynamic>> get openAutoCard async {
  final Map<String, dynamic> result = await _channel.invokeMapMethod('openAutoCard');
  return result;
}

///
/// 开启扫码
///
Future<Map<String, dynamic>> get scanCode async {
  final Map<String, dynamic> result = await _channel.invokeMapMethod('scanCode');
  return result;
}

///
/// 关闭扫码
///
Future<String> get closeScanCode async {
  final String result = await _channel.invokeMethod('closeScanCode');
  return result;
}

///
/// 关闭读卡
///
Future<String> get closeOpenCard async {
  final String result = await _channel.invokeMethod('closeOpenCard');
  return result;
}

/// 开启 loading
Future<void> showPayLoadingDialog() async {
await _channel.invokeMethod('showPayLoading');
}

/// 关闭 loading
Future<void> hidePayLoadingDialog() async {
await _channel.invokeMethod('hidePayLoading');
}

/// 初始化人脸识别
Future<Map<String, dynamic>> initWxFace() async {
  final Map<String, dynamic> result = await _channel.invokeMapMethod('initWxpayface');
  return result;
}

/// 人脸识别获取 face_sid 和 opneid
Future<Map<String, dynamic>> wxFaceVerify() async {
  final Map<String, dynamic> result = await _channel.invokeMapMethod('faceVerified');
  return result;
}

/// 人脸支付
Future<Map<String, dynamic>> wxFacePay() async {
  final Map<String, dynamic> result = await _channel.invokeMapMethod('wxFacePay');
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