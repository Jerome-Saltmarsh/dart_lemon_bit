import 'dart:ui';

import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/paint.dart';

void drawCircle(double x, double y, double radius, Color color) {
  drawCircleOffset(Offset(x, y), radius, color);
}

void drawCircleOffset(Offset offset, double radius, Color color) {
  // TODO Optimize
  paint.color = color;
  globalCanvas.drawCircle(offset, radius, paint);
}