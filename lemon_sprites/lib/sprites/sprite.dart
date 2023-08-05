
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_sprites/sprites/get_png_colors.dart';
import 'package:lemon_sprites/sprites/write_to_image.dart';
import 'package:lemon_sprites/sprites/write_to_png.dart';
import 'package:lemon_watch/src.dart';

class Sprite {

  final rows = Watch(4);
  final columns = Watch(4);
  final image = Watch<Image?>(null);
  final packedImage = Watch<Image?>(null);

  Sprite(){
    image.onChanged(onChangedImage);
  }

  void setImageFromBytes(Uint8List bytes) {
    image.value = decodePng(bytes);
  }

  void onChangedImage(Image? image){
    clearPackedImage();
  }

  void clearPackedImage() {
    packedImage.value = null;
  }

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

  void pack() {
    final img = image.value;

    if (img == null) {
      return;
    }

    final width = img.width;
    final height = img.height;
    final packed = Image(width: width, height: height);

    copyPaste(
        srcImage: img,
        dstImage: packed,
        width: 50,
        height: 100,
        srcX: 100,
        srcY: 100,
        dstX: 100,
        dstY: 100,
    );

    packedImage.value = packed;
  }
}

int rgba({
  int r = 0,
  int g = 0,
  int b = 0,
  int a = 0,
}) => int32(a, b, g, r);

int int32(int a, int b, int c, int d) =>
    (a << 24) | (b << 16) | (c << 8) | d;
