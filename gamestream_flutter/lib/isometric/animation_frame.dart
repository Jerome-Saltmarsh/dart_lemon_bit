
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:lemon_engine/engine.dart';

var animationFrame = 0;
var animationFrameWater = 0;
var animationFrameWaterHeight = 0;
var animationFrameWaterSrcX = 0.0;
var animationFrameTorch = 0;
var animationFrameGrass = 0;
var animationFrameRain = 0;
var animationFrameTreePosition = 0;
var rainPosition = 0.0;

const treeStrength = 0.5;
const treeAnimation = [0, 1, 2, 1, 0, -1, -2, -1];

void updateAnimationFrame(){
  final frame = engine.frame;
  animationFrame = frame ~/ 15;
  _updateWaterFrame();
  animationFrameTorch = frame ~/ 10;
  animationFrameRain = (frame ~/ 4) % 6;

  // animationFrameTreePosition = treeAnimation[animationFrame % treeAnimation.length] * windAmbient.value;

  if (windAmbient.value == Wind.Calm){
    animationFrameGrass = 0;
  } else {
    animationFrameGrass = (frame ~/ 15) % 4;
    // if (animationFrameGrass == 3){
    //   animationFrameGrass = 1;
    // }
  }

  rainPosition = (animationFrameRain * windAmbient.value * 2.5);

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


