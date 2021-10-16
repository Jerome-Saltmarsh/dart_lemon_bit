
import 'dart:ui';

Rect mapDstRect({double x, double y, Image image}){
  return Rect.fromLTWH(
      x - (image.width * 0.5),
      y - (image.height * 0.5),
      image.width.toDouble(),
      image.height.toDouble(),
  );
}
