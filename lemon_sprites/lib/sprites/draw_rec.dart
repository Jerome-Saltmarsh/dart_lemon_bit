
import 'package:image/image.dart';

void drawRec({
  required Image image,
  required int left,
  required int top,
  required int right,
  required int bottom,
  required Color color,
}) {
  for (var x = left; x < right; x++){
    image.setPixel(x, top, color);
    image.setPixel(x, bottom, color);
  }
  for (var y = top; y < bottom; y++){
    image.setPixel(left, y, color);
    image.setPixel(right, y, color);
  }
}