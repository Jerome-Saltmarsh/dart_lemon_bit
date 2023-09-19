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
  assert (width > 0);
  assert (height > 0);

  for (var x = 0; x < width; x++){
    for (var y = 0; y < height; y++){
      final color = srcImage.getPixel(srcX + x, srcY + y);
      dstImage.setPixel(dstX + x, dstY + y, color);
    }
  }
}
