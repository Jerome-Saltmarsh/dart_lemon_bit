import 'package:flutter/material.dart';
import 'package:lemon_math/src.dart';

class MapLocation {
  late final TextSpan textSpan;
  late final Offset offset;

  MapLocation({
    required double x,
    required double y,
    required String text,
  }) {
    textSpan = TextSpan(
      style: TextStyle(color: Colors.white),
      text: text.replaceAll('_', ' '),
    );
    offset = Offset(
      getRotationX(x, y, piQuarter),
      getRotationY(x, y, piQuarter),
    );
  }
}
