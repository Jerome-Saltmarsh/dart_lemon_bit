import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/enums/Shading.dart';

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

  Float32List tilesRstTransforms;
  Float32List tilesRects;
  List<Shading> bakeMap = [];
  List<List<Shading>> dynamicShading = [];


  Render items = Render();
  Render crates = Render();
  Render npcs = Render();
}