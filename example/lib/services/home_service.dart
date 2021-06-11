import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_huashi_example/utils/net_utils.dart';

class HomeService {
  ///
  /// 用身份证查询健康状态
  /// @params cardNo
  static Future<Response> checkHealthByCardNo(BuildContext context,
      {@required Map<String, dynamic> params}) async {
    return await NetUtils.post(context, '/check-health-by-card-no-v1', data: params, isShowLoading: false);
  }

  ///
  /// 用渝康码查询健康状态
  /// @params codeId
  static Future<Response> checkHealthByCodeId(BuildContext context,
      {@required Map<String, dynamic> params}) async {
    return await NetUtils.post(context, '/check-health-by-code-id', data: params);
  }

  ///
  /// 用渝康码查询身份信息
  /// @params qrcode
  /// @return {"card_no":"身份证号码","name":"真实姓名","card_type":"1"}
  ///
  static Future<Response> queryNameByQrcode(BuildContext context,
      {@required Map<String, dynamic> params}) async {
    return await NetUtils.post(context, '/query-name-by-qrcode', data: params);
  }

  ///
  /// 常德第一人民医院获取微信刷脸认证用户信息
  /// @params faceSid 微信刷脸获取的face_sid
  ///
  static Future<Response> getAuthUserInfo(BuildContext context,String faceSid) async {
    return await NetUtils.get(context, "https://parsec.cqkqinfo.com/app/stage-exhibition-api/face/wx/certification?face_sid=$faceSid");
  }
  
  /// 记录设备使用记录
  static Future<Response> sendDeviceUsageRecords(BuildContext context, {@required Map<String, dynamic> params}) async{
    return await NetUtils.post(context, '/device-usage-records',data: params, isShowLoading: false);
  }
}
