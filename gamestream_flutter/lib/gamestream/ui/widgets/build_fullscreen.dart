import 'package:flutter/material.dart';
import 'package:gamestream_flutter/instances/engine.dart';

Widget buildFullScreen({
  required Widget child,
  Alignment alignment = Alignment.center,
  Color? color,
}) =>
    Container(
      width: engine.screen.width,
      height: engine.screen.height,
      alignment: alignment,
      child: child,
      color: color,
    );