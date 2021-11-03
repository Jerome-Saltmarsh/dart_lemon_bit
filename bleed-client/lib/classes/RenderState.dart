import 'dart:ui';

class Render {
  List<RSTransform> transforms = [];
  List<Rect> rects = [];
}

void clear(Render render){
  render.transforms.clear();
  render.rects.clear();
}
