
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_sprites/sprites/get_png_colors.dart';
import 'package:lemon_sprites/sprites/write_to_png.dart';
import 'package:lemon_watch/src.dart';

class Sprite {

  final rows = Watch(4);
  final columns = Watch(4);

  final image = Watch<Image?>(null);
  final packedImage = Watch<Uint8List?>(null);

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

    final data = img.data;

    if (data == null) {
      throw Exception('image.data == null');
    }

    final bytes = data.buffer.asUint8List();
    final colors = decodePngColors(bytes);

    if (colors == null) {
      throw Exception('image.colors == null');
    }

     packedImage.value = writeToPng(
         width: img.width,
         height: img.height,
         colors: colors,
     );
  }
}