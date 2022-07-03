
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

Widget buildGameDialogSceneSave(){
  return Container(
     width: 350,
      height: 300,
     color: brownDark,
    constraints: BoxConstraints(
      maxWidth: 350,
    ),
     child: text("Save Game"),
  );
}