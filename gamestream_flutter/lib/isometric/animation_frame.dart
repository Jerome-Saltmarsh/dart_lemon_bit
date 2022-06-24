
import 'package:bleed_common/library.dart';
import 'package:lemon_engine/engine.dart';

var animationFrame = 0;
var animationFrameWater = 0;
var animationFrameWaterHeight = 0;
var animationFrameWaterSrcX = 0.0;
var animationFrameTorch = 0;

void updateAnimationFrame(){
  animationFrame = engine.frame ~/ 15;
  _updateWaterFrame();
  animationFrameTorch = engine.frame ~/ 10;
}

void _updateWaterFrame() {
  animationFrameWater = animationFrame % 4;
  if (animationFrameWater == 1) {
    animationFrameWaterHeight = 2;
  } else if (animationFrame == 3) {
    animationFrameWaterHeight = 0;
  } else {
    animationFrameWaterHeight = 1;
  }
  animationFrameWaterSrcX = animationFrameWater * tileSize;
}


