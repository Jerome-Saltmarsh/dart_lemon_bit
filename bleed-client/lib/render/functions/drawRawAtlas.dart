
import 'dart:typed_data';
import 'dart:ui';

import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';

void drawRawAtlas(Image image, Float32List dst, Float32List src){
  globalCanvas.drawRawAtlas(image, dst, src, null, null, null, paint);
}