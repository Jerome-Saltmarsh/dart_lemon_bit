

import 'dart:typed_data';

import 'package:bleed_client/images.dart';
import 'package:bleed_client/modules/modules.dart';

import 'drawRawAtlas.dart';

void drawAtlas({required Float32List dst, required Float32List src}) {
  drawRawAtlas(isometric.state.image, dst, src);
}

