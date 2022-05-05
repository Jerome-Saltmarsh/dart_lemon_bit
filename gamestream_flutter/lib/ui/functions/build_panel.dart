
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/ui/functions/styles.dart';

Widget buildPanel({required Widget child}){
  return Container(
      width: panelWidth,
      height: 50,
      decoration: panelDecoration,
      child: child,
      alignment: Alignment.center,
  );
}