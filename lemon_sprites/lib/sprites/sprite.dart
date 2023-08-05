
import 'dart:typed_data';

import 'package:lemon_watch/src.dart';

class Sprite {

  final spritesX = Watch(4);
  final spritesY = Watch(4);

  final image = Watch<Uint8List?>(null);
  final packedImage = Watch<Uint8List?>(null);

  Sprite(){
    image.onChanged(onChangedImage);
  }

  void onChangedImage(Uint8List? bytes){
    clearPackedImage();
  }

  void clearPackedImage() {
    packedImage.value = null;
  }

  void pack() {
     final bytes = image.value;
     if (bytes == null){
       throw Exception('image.value is null');
     }
  }
}