
import 'dart:typed_data';
import 'package:image/image.dart';
import 'find_bounds.dart';

Uint16List buildSrcAbsFromImages({
  required List<Image> images,
  required int rows,
  required int columns,
}){
  final src = Uint16List(rows * columns * 4);
  var i = 0;
  for (final image in images){
    src[i++] = findBoundsLeft(image);
    src[i++] = findBoundsTop(image);
    src[i++] = findBoundsRight(image);
    src[i++] = findBoundsBottom(image);
  }
  return src;
}
