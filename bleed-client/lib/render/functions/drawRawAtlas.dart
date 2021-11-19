
import 'dart:typed_data';
import 'dart:ui';

import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';

void drawRawAtlas(Image image, Float32List rsTransform, Float32List src){
  globalCanvas.drawRawAtlas(image, rsTransform, src, null, null, null, paint);
}