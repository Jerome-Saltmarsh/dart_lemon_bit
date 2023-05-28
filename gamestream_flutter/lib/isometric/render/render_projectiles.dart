import 'dart:math';

import 'package:gamestream_flutter/library.dart';

const piQuarter = pi * 0.25;

void renderPixelRed(double x, double y){
  engine.renderSprite(
      image: GameImages.atlas_gameobjects,
      srcX: 171,
      srcY: 0,
      srcWidth: 8,
      srcHeight: 8,
      dstX: x,
      dstY: y,
  );
}

