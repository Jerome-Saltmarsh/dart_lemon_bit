
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:golden_ratio/constants.dart';

Widget buildDialogCanvasSize(){
  return Container(
      width: 400,
      height: 400 * goldenRatio_0618,
      child: text("Canvas Size"),
  );
}