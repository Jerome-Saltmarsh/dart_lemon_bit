
import 'dart:ui';

Rect mapImageToRect(Image image) {
  return Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
}
