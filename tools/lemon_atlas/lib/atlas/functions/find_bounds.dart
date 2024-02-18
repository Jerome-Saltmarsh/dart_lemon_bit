
import 'package:image/image.dart';

int findBoundsLeft(Image image, {
  int left = 0,
  int top = 0,
  int? right,
  int? bottom,
}){
  right = right ?? image.width;
  bottom = bottom ?? image.height;

  for (var x = left; x < right; x++) {
    for (var y = top; y < bottom; y++) {
      if (image.getPixel(x, y).a > 0) {
        return x;
      }
    }
  }
  return -1;
}

int findBoundsRight(Image image, {
  int left = 0,
  int top = 0,
  int? right,
  int? bottom,
}){
  right = right ?? image.width;
  bottom = bottom ?? image.height;

  for (var x = right - 1; x >= left; x--) {
    for (var y = top; y < bottom; y++) {
      if (image.getPixel(x, y).a > 0) {
        return x;
      }
    }
  }
  return -1;
}

int findBoundsTop(Image image, {
  int left = 0,
  int top = 0,
  int? right,
  int? bottom,
}){
  right = right ?? image.width;
  bottom = bottom ?? image.height;

  for (var y = top; y < bottom; y++){
    for (var x = left; x < right; x++){
      if (image.getPixel(x, y).a > 0) {
        return y;
      }
    }
  }
  return -1;
}

int findBoundsBottom(Image image, {
  int left = 0,
  int top = 0,
  int? right,
  int? bottom,
}){
  right = right ?? image.width;
  bottom = bottom ?? image.height;
  for (var y = bottom - 1; y >= top; y--){
    for (var x = left; x < right; x++){
      if (image.getPixel(x, y).a > 0) {
        return y;
      }
    }
  }
  return -1;
}