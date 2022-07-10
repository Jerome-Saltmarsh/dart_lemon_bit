

import 'package:lemon_engine/canvas.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_engine/state/atlas.dart';

import '../state/paint.dart';

void renderAtlas(){
  canvas.drawRawAtlas(atlas, dst, src, colors, renderBlendMode, null, paint);
}