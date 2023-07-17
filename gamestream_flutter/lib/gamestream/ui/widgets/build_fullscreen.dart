import 'package:flutter/material.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

Widget buildFullScreen({
  required Widget child,
  Alignment alignment = Alignment.center,
  Color? color,
}) =>
    Container(
      width: gamestream.engine.screen.width,
      height: gamestream.engine.screen.height,
      alignment: alignment,
      child: child,
      color: color,
    );