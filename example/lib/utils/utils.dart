import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

typedef OnItemClick = void Function(int index);

class Utils {
  /// TOAST 方法
  /// @params msg 显示的消息内容
  /// @params gravity 显示消息的位置 默认值 居中显示
  static void showToast(String msg,
      [ToastGravity gravity = ToastGravity.CENTER]) {
    Fluttertoast.showToast(msg: msg, gravity: gravity);
  }

  /// 显示网络图片
  /// @params 图片网络地址 其他的参数不描述了
  static Widget showNetImage(String url,
      {double width, double height, BoxFit fit}) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
    );
//    return Image(
//      image: ExtendedNetworkImageProvider("$url", cache: true),
//      fit: fit,
//      width: width,
//      height: height,
//    );
  }

  /// 弹出一个确认框
  /// @params context        上下文    文本类型  有默认值
  /// @params title          标题      文本类型  有默认值
  /// @params content        内容      文本类型 没有默认值
  /// @params contentWidget  内容      组件类型 没有默认值
  /// @params titleColor     标题颜色
  /// @params contentColor   内容文本颜色，仅在类型是文本时有效
  /// @params cancelText     取消按钮文本
  /// @params cancelStyle    取消按钮样式
  /// @params okText         确认按钮文本
  /// @params okStyle        确认按钮样式
  /// @params barrierDismissible        是否允许点击遮罩层关闭弹窗
  /// @params onCancel       取消回调函数
  /// @params onOk           确认回调函数
  static Future<bool> showConfirm(
    BuildContext context,
    String content, {
    String title = '提示',
    Color titleColor,
    Color contentColor,
    Widget contentWidget,
    String cancelText = '取消',
    TextStyle cancelStyle,
    String okText = '确认',
    TextStyle okStyle,
    bool barrierDismissible = true,
    bool hideCancelBtn = false,
    VoidCallback onCancel,
    VoidCallback onOk,
  }) {
    return showDialog<bool>(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: (BuildContext context) {
          if (Platform.isAndroid) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                title,
                style: TextStyle(color: titleColor),
              ),
              content: contentWidget != null
                  ? contentWidget
                  : Text(
                      content,
                      style: TextStyle(color: contentColor),
                    ),
              actions: <Widget>[
                FlatButton(
                    child: !hideCancelBtn
                        ? Text(
                            cancelText,
                            style: cancelStyle != null
                                ? cancelStyle
                                : TextStyle(color: new Color(0xff666666)),
                          )
                        : Text(''),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onCancel != null) {
                        onCancel();
                      }
                    }),
                FlatButton(
                    child: Text(okText,
                        style: okStyle != null
                            ? okStyle
                            : TextStyle(color: Colors.black45)),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      if (onOk != null) {
                        onOk();
                      }
                    })
              ],
            );
          }
          return CupertinoAlertDialog(
            title: Text(
              title,
              style: TextStyle(color: titleColor),
            ),
            content: contentWidget != null
                ? contentWidget
                : Text(
                    content,
                    style: TextStyle(color: contentColor),
                  ),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text(
                    cancelText,
                    style: cancelStyle != null
                        ? cancelStyle
                        : TextStyle(color: new Color(0xff666666)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onCancel != null) {
                      onCancel();
                    }
                  }),
              CupertinoDialogAction(
                  child: Text(okText,
                      style: okStyle != null
                          ? okStyle
                          : TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    if (onOk != null) {
                      onOk();
                    }
                  })
            ],
          );
        });
  }

  /// 自定义弹窗
  static Future<bool> showPopup(BuildContext context,
      {Widget title,
      @required Widget content,
      bool barrierDismissible = true,
      String okText = '好，知道了！',
      TextStyle okStyle,
      VoidCallback onOk}) {
    return showDialog<bool>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
            backgroundColor: Colors.white,
            title: title,
            content: content,
            actions: <Widget>[
              new FlatButton(
                  child: Text(okText,
                      style: okStyle != null
                          ? okStyle
                          : TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    if (onOk != null) {
                      onOk();
                    }
                  }),
            ],
          );
        }
        return CupertinoAlertDialog(
          title: title,
          content: content,
          actions: <Widget>[
            new CupertinoDialogAction(
                child: Text(okText,
                    style: okStyle != null
                        ? okStyle
                        : TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  if (onOk != null) {
                    onOk();
                  }
                })
          ],
        );
      },
    );
  }

  /// 显示一个列表弹窗
  static Future<void> showListDialog(BuildContext context, String title,
      {@required int itemCount,
      @required ListTile buildItem(int index),
      TextStyle titleStyle}) async {
    int index = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        var child = Column(
          children: <Widget>[
            ListTile(
                title: title != null
                    ? Text(
                        title,
                        style: titleStyle,
                      )
                    : Text("请选择", style: titleStyle)),
            Expanded(
                child: ListView.builder(
              itemCount: itemCount,
              itemBuilder: (BuildContext context, int index) {
                return buildItem(index);
              },
            )),
          ],
        );

        /// 使用AlertDialog会报错
        /// return AlertDialog(content: child);
        return Dialog(child: child);
      },
    );
    if (index != null) {
      print("点击了：$index");
    }
  }

  /// 自定义时间选择Picker
  static Future<DateTime> showCustomDatePicker(BuildContext context) {
    DateTime _selectValue;
    var date = DateTime.now();
    if (Platform.isAndroid) {
      return showDatePicker(
        context: context,
        initialDate: date,
        firstDate: date,
        lastDate: date.add(
          Duration(days: 30),
        ),
      );
    } else {
      return showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          return SizedBox(
            height: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
//                    borderRadius: new BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                      border: new Border(
                          bottom: BorderSide(
                              color: new Color(0xff666666),
                              width: 0.5,
                              style: BorderStyle.solid))),
                  padding:
                      EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('取消'),
                      ),
                      Expanded(
                        child: Text(
                          '选择时间',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black45,
                              fontSize: 32,
                              fontWeight: FontWeight.w500),
                        ),
                        flex: 1,
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          print('这里是选择的值：$_selectValue');
                        },
                        child: Text('确认'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 230,
                  child: CupertinoDatePicker(
                    use24hFormat: true,
                    mode: CupertinoDatePickerMode.dateAndTime,
                    minimumDate: date,
                    maximumDate: date.add(
                      Duration(days: 30),
                    ),
                    maximumYear: date.year + 1,
                    onDateTimeChanged: (DateTime value) {
                      print('onDateTimeChanged:$value');
                      _selectValue = value;
                    },
                  ),
                )
              ],
            ),
          );
        },
      );
    }
  }

  /// 随机生成KEY
  /// @params len 生成的字符串固定长度
  static String getRandomKey({int len = 30}) {
    String alphabet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    String left = '';
    for (var i = 0; i < len; i++) {
      left = left + alphabet[Random().nextInt(alphabet.length)];
    }
    return left;
  }

  /// 是否是数字
  static bool isNumber(String val) {
    var regPos = new RegExp(r'^\d+(\.\d+)?$'); //非负浮点数
    var regNeg = new RegExp(
        r'^(-(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*)))$'); //负浮点数
    if (regPos.hasMatch(val) || regNeg.hasMatch(val)) {
      return true;
    } else {
      return false;
    }
  }
}
