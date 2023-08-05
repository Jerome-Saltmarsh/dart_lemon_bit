import 'package:image/image.dart';

void copyPaste({
  required Image srcImage,
  required Image dstImage,
  required int width,
  required int height,
  required int srcX,
  required int srcY,
  required int dstX,
  required int dstY,
}) {
  final endX = srcX + width;
  final endY = srcY + height;
  for (var x = srcX; x < endX; x++){
    for (var y = srcY; y < endY; y++){
      final color = srcImage.getPixel(x, y);
      dstImage.setPixel(dstX + x, dstY + y, color);
    }
  }
}
