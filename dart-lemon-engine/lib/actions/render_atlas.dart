

import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';

void renderAtlas(){
  Engine.canvas.drawRawAtlas(Engine.atlas, dst, src, colors, renderBlendMode, null, Engine.paint);
}