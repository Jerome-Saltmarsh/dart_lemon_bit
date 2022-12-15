import 'dart:math';

import 'package:gamestream_flutter/library.dart';

const piQuarter = pi * 0.25;

void renderPixelRed(double x, double y){
  Engine.renderSprite(
      image: GameImages.atlas_gameobjects,
      srcX: 171,
      srcY: 0,
      srcWidth: 8,
      srcHeight: 8,
      dstX: x,
      dstY: y,
  );
}

void renderFireball(double x, double y, double rotation) {
  // renderRotated(
  //   dstX: x,
  //   dstY: y,
  //   srcX: 5580,
  //   srcY: ((animationFrame) % 6) * 23,
  //   srcWidth: 18,
  //   srcHeight: 23,
  //   rotation: rotation,
  // );
}


void renderOrb(double x, double y) {
  Engine.renderSprite(
      image: GameImages.atlas_gameobjects,
      dstX: x,
      dstY: y,
      srcX: 417,
      srcY: 26,
      srcWidth: 8,
      srcHeight: 8,
      scale: 1.5
  );
}
