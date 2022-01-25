
import 'dart:typed_data';
import 'dart:ui';

import 'package:lemon_engine/engine.dart';

void drawRawAtlas(Image image, Float32List dst, Float32List src){
  engine.state.canvas.drawRawAtlas(image, dst, src, null, null, null, engine.state.paint);
}

