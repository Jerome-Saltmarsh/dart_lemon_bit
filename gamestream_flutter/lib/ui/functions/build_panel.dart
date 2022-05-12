
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/ui/functions/styles.dart';

Widget buildPanel({required Widget child, double? height}){
  return Container(
      width: panelWidth,
      height: height,
      decoration: panelDecoration,
      child: child,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
  );
}