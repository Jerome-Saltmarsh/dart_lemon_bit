import 'dart:ui';

import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/common/classes/Vector2.dart';

final _RenderState render = _RenderState();

class Render {
  List<RSTransform> transforms = [];
  List<Rect> rects = [];
}

void clear(Render render){
  render.transforms.clear();
  render.rects.clear();
}

class _RenderState {
  List<RSTransform> tileTransforms = [];
  List<Rect> tileRects = [];
  List<RSTransform> playersTransforms = [];
  List<Rect> playersRects = [];
  List<RSTransform> zombiesTransforms = [];
  List<Rect> zombieRects = [];
  List<RSTransform> particleTransforms = [];
  List<Rect> particleRects = [];
  List<List<Vector2>> paths = [];
  List<FloatingText> floatingText = [];

  Render items = Render();
  Render crates = Render();
  Render npcs = Render();
}