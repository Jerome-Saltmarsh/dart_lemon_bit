import 'package:amulet_engine/packages/isometric_engine/packages/lemon_math/src/constants/pi_quarter.dart';
import 'package:amulet_engine/packages/isometric_engine/packages/lemon_math/src/functions/rotate.dart';
import 'package:flutter/material.dart';

class MapLocation {
  // final double x;
  // final double y;
  // final String text;

  late final TextSpan textSpan;
  late final Offset offset;

  MapLocation({
    required double x,
    required double y,
    required String text,
  }) {
    textSpan = TextSpan(
      style: TextStyle(color: Colors.white),
      text: text,
    );
    offset = Offset(
      getRotationX(x, y, piQuarter),
      getRotationY(x, y, piQuarter),
    );
  }
}
