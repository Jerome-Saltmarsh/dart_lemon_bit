import 'dart:ui';

final _RenderState render = _RenderState();

class _RenderState {
  List<RSTransform> tileTransforms = [];
  List<Rect> tileRects = [];
  List<RSTransform> playersTransforms = [];
  List<Rect> playersRects = [];
  List<RSTransform> npcsTransforms = [];
  List<Rect> particleRects = [];
  List<RSTransform> particleTransforms = [];
  List<Rect> npcsRects = [];
}