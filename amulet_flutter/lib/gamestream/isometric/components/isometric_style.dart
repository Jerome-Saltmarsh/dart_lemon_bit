
import 'package:flutter/material.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';

class IsometricStyle with IsometricComponent {
  late final Color containerColor;
  late final Color containerColorDark;

  final containerPadding = EdgeInsets.all(16);
  final containerBorderRadiusCircular = BorderRadius.all(Radius.circular(4));

  final textFieldStyle = TextStyle(color: Colors.white70);
  final textFieldDecoration = InputDecoration(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    ),
  );
  final textFieldCursorColor = Colors.white70;

  final textFieldTitleStyle = TextStyle(color: Colors.white70, fontSize: 20);

  @override
  Future onComponentInit(sharedPreferences) async {
    containerColor = colors.brownDark;
    containerColorDark = colors.brownDarkX;
  }
}