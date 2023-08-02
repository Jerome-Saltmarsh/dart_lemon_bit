
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/mixins/component_isometric.dart';

class IsometricStyle with IsometricComponent {
  late final Color containerColor;
  late final Color containerColorDark;

  final containerPadding = EdgeInsets.all(16);
  final containerBorderRadiusCircular = BorderRadius.all(Radius.circular(4));

  @override
  void onComponentReady() {
    containerColor = colors.brownDark;
    containerColorDark = colors.brownDarkX;
  }
}