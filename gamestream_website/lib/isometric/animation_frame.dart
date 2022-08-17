
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:lemon_engine/engine.dart';

var animationFrame = 0;
var frameChicken = 0;
var animationFrameWater = 0;
var animationFrameWaterHeight = 0;
var animationFrameWaterSrcX = 0.0;
var animationFrameWaterFlowingSrcX = 0.0;
var animationFrameTorch = 0;
var animationFrame8 = 0;
var animationFrameGrass = 0;
var animationFrameGrassShort = 0;
var animationFrameRain = 0;
var animationFrameTreePosition = 0;
var rainPosition = 0.0;

const treeStrength = 0.5;
const treeAnimation = [0, 1, 2, 1, 0, -1, -2, -1];
final treeAnimationLength = treeAnimation.length;

void updateAnimationFrame(){
  final frame = engine.frame;
  animationFrame = frame ~/ 15;
  _updateWaterFrame();
  animationFrameTorch = frame ~/ 10;
  animationFrame8 = frame ~/ 8;
  animationFrameRain = (frame ~/ 4) % 6;
  animationFrameGrass = animationFrame % 6;
  frameChicken = animationFrame % 2;
  // if (windAmbient.value == Wind.Calm){
  //   animationFrameGrass = 0;
  //   animationFrameGrassShort = 0;
  // } else {
  //
  //   if (windAmbient.value == Wind.Gentle){
  //     animationFrameGrassShort = frame ~/ 35;
  //   } else{
  //     animationFrameGrassShort = frame ~/ 10;
  //   }
  // }
  rainPosition = (animationFrameRain * windAmbient.value.index * 2.5);
}

void _updateWaterFrame() {
  animationFrameWater = animationFrame % 6;
  animationFrameWaterHeight = const [
    0, 1, 2, 3, 2, 1
  ][animationFrameWater];
  animationFrameWaterSrcX = animationFrameWater * tileSize;
}


