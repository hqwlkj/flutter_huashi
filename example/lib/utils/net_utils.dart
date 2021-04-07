import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_huashi_example/utils/utils.dart';
import 'package:flutter_huashi_example/widgets/loading.dart';

import 'custom_log_interceptor.dart';

/// 网络请求管理
/// @author Yanghc
class NetUtils {
  static Dio _dio;

  ///  服务器请求地址
//  static final String mockUrl = 'http://yapi.parsec.com.cn/mock/448';
//  static final String debugBaseUrl = 'http://parsec.cqkqinfo.com/app/ykm-demo-api';
//  static final String baseUrl = 'http://parsec.cqkqinfo.com/app/ykm-demo-api';
    static final String debugBaseUrl = 'https://h5b.parsec.com.cn/app/ykm-demo-api';
  static final String baseUrl = 'https://h5b.parsec.com.cn/app/ykm-demo-api';
  static const int CONNECT_TIMEOUT = 1000 * 8;
  static const int RECEIVE_TIMEOUT = 3000;

  static void init() async {
    const bool inProduction = const bool.fromEnvironment("dart.vm.product");

    _dio = Dio(BaseOptions(
        baseUrl: inProduction ? '$baseUrl' : '$debugBaseUrl',
        connectTimeout: CONNECT_TIMEOUT,
        receiveTimeout:  RECEIVE_TIMEOUT,
        followRedirects: false))
      ..interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
        // 在请求被发送之前做一些事情
        //Set the token to headers
        return options; //continue
        // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
      }, onResponse: (Response response) async {
        // 在返回响应数据之前做一些预处理
        return response; // continue
      }, onError: (DioError e) async {
        // 当请求失败时做一些预处理
        return e; //continue
      }))
      ..interceptors.add(DioCacheManager(CacheConfig(baseUrl: '$baseUrl')).interceptor)
      ..interceptors.add(CustomLogInterceptor(responseBody: true, requestBody: true));
  }

  static Future<Response> _dioErrorInterceptor(DioError e) {
    if (e == null) {
      return Future.error(Response(data: -1));
    }

    switch (e.type) {
      case DioErrorType.CANCEL:
         return Future.error(Response(data: -1, statusMessage: '请求取消'));
      case DioErrorType.CONNECT_TIMEOUT:
         return Future.error(Response(data: -1, statusMessage: '连接超时'));
      case DioErrorType.SEND_TIMEOUT:
         return Future.error(Response(data: -1, statusMessage: '请求超时'));
      case DioErrorType.RECEIVE_TIMEOUT:
        return Future.error(Response(data: -1, statusMessage: '响应超时'));
      case DioErrorType.RESPONSE:
        if (e.response.statusCode >= 300 && e.response.statusCode < 400) {
          return Future.error(Response(data: -1));
        } else if (e.response.statusCode == 403) {
          // _reLogin();
          return Future.error(Response(data: -1));
        } else if (e.response.statusCode == 404) {
          _notFound(); // 现在是弹窗提示，正确的是显示一个 页面
          return Future.error(Response(data: -1));
        } else {
          return Future.value(e.response);
        }
        break;
      default:
        return Future.value(e.response);
    }
  }

  static Future<Response> get(BuildContext context,
      String url, {
        Map<String, dynamic> params,
        Options options,
        bool isShowLoading = true,
      }) async {
   if (isShowLoading) Loading.showLoading(context);
    try {
      return await _dio.get(url, queryParameters: params, options: options);
    } on DioError catch (e) {
      return NetUtils._dioErrorInterceptor(e);
    } finally {
     // Loading.hideLoading(context);
    }
  }

  static Future<Response> post(BuildContext context,
      String url, {
        data,
        Map<String, dynamic> queryParameters,
        Options options,
        CancelToken cancelToken,
        ProgressCallback onSendProgress,
        ProgressCallback onReceiveProgress,
        bool isShowLoading = true,
      }) async {
    if (isShowLoading) Loading.showLoading(context);
    try {
      return await _dio.post(url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress);
    } on DioError catch (e) {
      return NetUtils._dioErrorInterceptor(e);
    } finally {
      // Loading.hideLoading(context);
    }
  }

  static Future<Response> delete(BuildContext context, String url,
      {data,
        Map<String, dynamic> queryParameters,
        Options options,
        CancelToken cancelToken,
        bool isShowLoading = true}) async {
    if (isShowLoading) Loading.showLoading(context);
    try {
      return await _dio.delete(url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken);
    } on DioError catch (e) {
      return NetUtils._dioErrorInterceptor(e);
    } finally {
      Loading.hideLoading(context);
    }
  }

  static Future<Response> put(BuildContext context, String url,
      {data,
        Map<String, dynamic> queryParameters,
        Options options,
        CancelToken cancelToken,
        ProgressCallback onSendProgress,
        ProgressCallback onReceiveProgress,
        bool isShowLoading = true}) async {
    if (isShowLoading) Loading.showLoading(context);
    try {
      return await _dio.put(url,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
    } on DioError catch (e) {
      return NetUtils._dioErrorInterceptor(e);
    } finally {
      Loading.hideLoading(context);
    }
  }

  /// 重新登录
  // static void _reLogin() {
  //   Future.delayed(Duration(milliseconds: 200), () {
  //     Utils.showToast('登录信息已过期，请重新登录');
  //     Application.getIt<NavigateService>().popAndPushNamed(Routes.login);
  //   });
  // }

  /// 404 了
  static void _notFound() {
    Utils.showToast('访问的资源不存在');
  }
}
