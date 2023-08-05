

import 'package:image/image.dart';

Image copyImage(Image image){
  final width = image.width;
  final height = image.width;
  final copy = Image(width: width, height: height);
  for (var x = 0; x < width; x++){
    for (var y = 0; y < height; y++){
      copy.setPixel(x, y, image.getPixel(x, y));
    }
  }
  return copy;
}
