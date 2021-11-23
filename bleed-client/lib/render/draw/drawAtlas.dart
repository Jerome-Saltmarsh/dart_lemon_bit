

import 'dart:typed_data';

import 'package:bleed_client/images.dart';

import 'drawRawAtlas.dart';

void drawAtlas(Float32List dst, Float32List src) {
  drawRawAtlas(images.atlas, dst, src);
}
