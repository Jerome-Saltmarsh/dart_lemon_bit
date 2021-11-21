import 'dart:typed_data';

void setDst(
    Float32List dst, {
      int index = 0,
      double scale = 1,
      double rotation = 0,
      double x,
      double y
    }){
  dst[index] = scale;
  dst[index + 1] = rotation;
  dst[index + 2] = x;
  dst[index + 3] = y;
}

