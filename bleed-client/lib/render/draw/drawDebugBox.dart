

import 'dart:typed_data';

import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/utils.dart';
import 'package:lemon_engine/engine.dart';

void drawDebugBox(Float32List rsTransform){
  double left = rsTransform[0];
  double top = rsTransform[1];
  double right = rsTransform[2];
  double bottom = rsTransform[3];
  engine.actions.setPaintColor(colours.red);
  drawLine(left, top, right, top);
  drawLine(left, top, left, bottom);
  drawLine(right, top, right, bottom);
  drawLine(left, bottom, right, bottom);
}
