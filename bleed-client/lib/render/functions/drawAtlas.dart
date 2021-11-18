import 'dart:typed_data';
import 'dart:ui';

import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';

Float32List transform = Float32List(4);
Float32List src = Float32List(4);

void drawSprite(
    Image image,
    double x,
    double y,
    double left,
    double top,
    double right,
    double bottom
    ) {
  transform[0] = 1;
  transform[1] = 0;
  transform[2] = x;
  transform[3] = y;
  src[0] = left; // left
  src[1] = top; // right
  src[2] = right; // top
  src[3] = bottom; // bottom;
  globalCanvas.drawRawAtlas(image, transform, src, null, null, null, paint);
}
