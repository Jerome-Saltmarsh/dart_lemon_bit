
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

  void pack() {
    final img = image.value;

    if (img == null) {
      return;
    }

    final width = 50;
    final height = 50;
    final packed = Image(width: width, height: height);

    for (var x = 0; x < width; x++){
      for (var y = 0; y < height; y++){
        final color = img.getPixel(x, y);
        packed.setPixel(x, y, color);
      }
    }
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
