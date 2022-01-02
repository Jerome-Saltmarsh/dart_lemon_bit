

import 'dart:typed_data';

import 'package:bleed_client/images.dart';

import 'drawRawAtlas.dart';

void drawAtlas({required Float32List dst, required Float32List src}) {
  drawRawAtlas(images.atlas, dst, src);
}

