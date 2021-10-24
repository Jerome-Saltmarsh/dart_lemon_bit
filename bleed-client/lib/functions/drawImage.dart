
import 'dart:ui';

import 'package:bleed_client/engine/engine_state.dart';
import 'package:bleed_client/engine/global_paint.dart';


void drawImage(Image image, double x, double y){
  globalCanvas.drawImage(image, Offset(x, y), paint);
}