
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_sprites/sprites/draw_rec.dart';
import 'package:lemon_watch/src.dart';

import 'sprite_bounds.dart';


class Sprite {

  final rows = Watch(9);
  final columns = Watch(8);
  final image = Watch<Image?>(null);
  final packedImage = Watch<Image?>(null);
  final bounds = SpriteBounds();

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

  void pack(){
    final source = image.value;

    if (source == null){
      throw Exception('source image is null');
    }
    final copy = source.clone();
    bounds.capture(copy, rows.value, columns.value);
    final total = bounds.boundStackIndex;
    final color = ColorRgb8(255, 0, 0);
    for (var i = 0; i < total; i++){
      drawRec(
          image: copy,
          left: bounds.boundStackLeft[i],
          top: bounds.boundStackTop[i],
          right: bounds.boundStackRight[i],
          bottom: bounds.boundStackBottom[i],
          color: color,
      );
    }

    packedImage.value = copy;

  }

}

