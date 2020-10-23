import 'package:flutter/material.dart';

/// 纵向空组件（用于占位）
/// @author Yanghc
class VEmptyView extends StatelessWidget {
  final double height;

  VEmptyView(this.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}
