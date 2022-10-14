

import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_engine/state/atlas.dart';

void renderAtlas(){
  Engine.canvas.drawRawAtlas(atlas, dst, src, colors, renderBlendMode, null, Engine.paint);
}