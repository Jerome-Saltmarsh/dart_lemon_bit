import 'dart:ui';

final _RenderState render = _RenderState();

class _RenderState {
  List<RSTransform> tileTransforms = [];
  List<Rect> tileRects = [];
}