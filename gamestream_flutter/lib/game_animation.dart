
import 'library.dart';

class GameAnimation {
  static var animationFrame = 0;
  static var animationFrameWater = 0;
  static var animationFrameWaterHeight = 0;
  static var animationFrameWaterSrcX = 0.0;
  static var animationFrameWaterFlowingSrcX = 0.0;
  static var animationFrame8 = 0;
  static var animationFrameGrass = 0;
  static var animationFrameGrassShort = 0;
  static var animationFrameRainWater = 0;
  static var animationFrameTreePosition = 0;
  static var rainPosition = 0.0;

  static const treeStrength = 0.5;
  static const treeAnimation = [0, 1, 2, 1, 0, -1, -2, -1];
  static final treeAnimationLength = treeAnimation.length;

  static var animationFrameJellyFish = 0;
  static var animationFrameRateJellyFish = 0;
  static var _next = 0;

  static void updateAnimationFrame() {
    if (_next++ < 3) return;
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
  }
}