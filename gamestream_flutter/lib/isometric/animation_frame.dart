
import 'package:bleed_common/library.dart';

var animationFrame = 0;
var frameChicken = 0;
var animationFrameWater = 0;
var animationFrameWaterHeight = 0;
var animationFrameWaterSrcX = 0.0;
var animationFrameWaterFlowingSrcX = 0.0;
var animationFrame8 = 0;
var animationFrameGrass = 0;
var animationFrameGrassShort = 0;
var animationFrameRainWater = 0;
var animationFrameTreePosition = 0;
var rainPosition = 0.0;

const treeStrength = 0.5;
const treeAnimation = [0, 1, 2, 1, 0, -1, -2, -1];
final treeAnimationLength = treeAnimation.length;

var animationFrameJellyFish = 0;
var animationFrameRateJellyFish = 0;
var _next = 0;

void updateAnimationFrame() {
  if (_next++ < 2) return;
  _next = 0;
  animationFrame++;

  if (animationFrameWater++ >= 9){
    animationFrameWater = 0;
  }
  animationFrameWaterHeight = const [
    0, 1, 2, 3, 4, 5, 4, 3, 2, 1,
  ][animationFrameWater];
  animationFrameWaterSrcX = animationFrameWater * tileSize;

  if (animationFrameGrass++ >= 6){
    animationFrameGrass = 0;
  }
  if (animationFrameRateJellyFish-- <= 0) {
     animationFrameRateJellyFish = 5;
     animationFrameJellyFish = (animationFrameJellyFish + 1) % 6;
  }
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
  // rainPosition = (animationFrameRain * windAmbient.value.index * 2.5);
}



