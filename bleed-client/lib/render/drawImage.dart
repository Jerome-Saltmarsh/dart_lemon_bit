

import 'dart:ui';

import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/paint.dart';

void drawImageRect(Image image, Rect src, Rect dst){
  globalCanvas.drawImageRect(image, src, dst, paint);
}