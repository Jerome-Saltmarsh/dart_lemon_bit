
import 'package:bleed_common/library.dart';
import 'package:lemon_engine/engine.dart';

var animationFrame = 0;
var animationFrameWater = 0;
var animationFrameWaterHeight = 0;
var animationFrameWaterSrcX = 0.0;
var animationFrameTorch = 0;
var animationFrameGrass = 0;
var animationFrameRain = 0;

void updateAnimationFrame(){
  final frame = engine.frame;
  animationFrame = frame ~/ 15;
  _updateWaterFrame();
  animationFrameTorch = frame ~/ 10;
  animationFrameGrass = (frame ~/ 40) % 4;
  animationFrameRain = (frame ~/ 8) % 6;

  if (animationFrameGrass == 3){
    animationFrameGrass = 1;
  }
}

void _updateWaterFrame() {
  animationFrameWater = animationFrame % 4;
  if (animationFrameWater == 1) {
    animationFrameWaterHeight = 2;
  } else if (animationFrameWater == 3) {
    animationFrameWaterHeight = 0;
  } else {
    animationFrameWaterHeight = 1;
  }
  animationFrameWaterSrcX = animationFrameWater * tileSize;
}


