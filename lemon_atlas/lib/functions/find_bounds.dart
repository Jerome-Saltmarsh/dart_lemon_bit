
import 'package:image/image.dart';

import 'is_empty.dart';

int findBoundsLeft(Image image,){
  final width = image.width;
  final height = image.height;

  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      if (!isEmpty(image.getPixel(x, y))) {
        return x;
      }
    }
  }
  return -1;
}

int findBoundsRight(Image image){
  final width = image.width;
  final height = image.height;

  for (var x = width - 1; x >= 0; x--) {
    for (var y = 0; y < height; y++) {
      if (!isEmpty(image.getPixel(x, y))) {
        return x;
      }
    }
  }
  return -1;
}

int findBoundsTop(Image image,){
  final width = image.width;
  final height = image.height;

  for (var y = 0; y < height; y++){
    for (var x = 0; x < width; x++){
      if (!isEmpty(image.getPixel(x, y))) {
        return y;
      }
    }
  }
  return -1;
}

int findBoundsBottom(Image image){
  final width = image.width;
  final height = image.height;

  for (var y = height -1; y >= 0; y--){
    for (var x = 0; x < width; x++){
      if (!isEmpty(image.getPixel(x, y))) {
        return y;
      }
    }
  }
  return -1;
}