
import 'dart:typed_data';
import 'dart:ui';

import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_engine/state/screen.dart';

class Renderable {
  Image image;
  final Float32List dst = Float32List(4);
  final Float32List src = Float32List(4);

  double get left => dst[0];
  double get top => dst[1];
  double get right => dst[2];
  double get bottom => dst[3];

  set left(double value){
    dst[0] = value;
  }

  set top(double value){
    dst[1] = value;
  }

  set right(double value){
    dst[2] = value;
  }

  set bottom(double value){
    dst[3] = value;
  }
}

void drawRenderable(Renderable renderable) {
  if (!renderableOnScreen(renderable)) return;
  globalCanvas.drawRawAtlas(renderable.image, renderable.dst, renderable.src, null, null, null, paint);
}

bool renderableOnScreen(Renderable renderable) {
  if (renderable.top > screen.bottom) return false;
  if (renderable.right < screen.left) return false;
  if (renderable.left > screen.right) return false;
  if (renderable.bottom < screen.top) return false;
  return true;
}