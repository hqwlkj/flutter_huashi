import 'package:flutter/material.dart';
import 'package:flutter_huashi_example/widgets/v_empty_view.dart';

/// 网络请求失败组件
/// @author Yanghc
class NetErrorWidget extends StatelessWidget {
  final VoidCallback callback;

  NetErrorWidget({@required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        alignment: Alignment.center,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.network_wifi,
              size: 130,
              color: Colors.grey,
            ),
            VEmptyView(30),
            Text(
              '请连接网络后点击屏幕重试',
              style: TextStyle(fontSize: 28, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
