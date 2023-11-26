
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/ui/builders/styles.dart';

Widget buildPanel({required Widget child, double? width, double? height}){
  return Container(
      width: width,
      height: height,
      decoration: panelDecoration,
      child: child,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
  );
}