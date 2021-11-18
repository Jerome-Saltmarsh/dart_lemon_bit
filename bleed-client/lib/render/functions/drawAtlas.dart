import 'dart:typed_data';
import 'dart:ui';

import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';

final Float32List _transform = Float32List(4);
final Float32List _src = Float32List(4);

void drawSprite(
    Image image,
    double x,
    double y,
    double left,
    double top,
    double right,
    double bottom,
    {
      double cos = 1,
      double sin = 0}
    ) {
  _transform[0] = cos; // cos
  _transform[1] = sin; // sin
  _transform[2] = x; // x
  _transform[3] = y; // y
  _src[0] = left; // left
  _src[1] = top; // right
  _src[2] = right; // top
  _src[3] = bottom; // bottom;
  globalCanvas.drawRawAtlas(image, _transform, _src, null, null, null, paint);
}
