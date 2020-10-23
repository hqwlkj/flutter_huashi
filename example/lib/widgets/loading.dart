import 'package:flutter/material.dart';
import 'package:flutter_huashi_example/widgets/v_empty_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// 加载组件
/// @author Yanghc
class Loading {
  static bool isLoading = false;

  static void showLoading(BuildContext context,{String text}) {
    if (!isLoading) {
      isLoading = true;
      showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel:
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {
            return Align(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.black54,
                  child: text != null ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitCircle(
                        color: Colors.white,
                        size: 40,
                      ),
                      VEmptyView(15),
                      Text(text, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w200, decoration: TextDecoration.none ),)
                    ],
                  ) :SpinKitCircle(
                      color: Colors.white,
                      size: 40
                  ),
                ),
              ),
            );
          }).then((v) {
        isLoading = false;
      });
    }
  }

  static void hideLoading(BuildContext context) {
    if (isLoading) {
      Navigator.of(context).pop();
    }
  }
}
