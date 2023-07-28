
import '../../../library.dart';

mixin IsometricAnimation {
  var animationFrame = 0;
  var animationFrameWater = 0;
  var animationFrameWaterHeight = 0;
  var animationFrameWaterSrcX = 0.0;
  var animationFrameWaterFlowingSrcX = 0.0;
  var animationFrame6 = 0;
  var animationFrame8 = 0;
  var animationFrame16 = 0;
  var animationFrameRainWater = 0;
  var animationFrameTreePosition = 0;
  var rainPosition = 0.0;
  var _next = 0;
  var rendersPerFrame = 3;

  final treeAnimation = [0, 1, 2, 1, 0, -1, -2, -1];

  void updateAnimationFrame() {
    if (_next++ < rendersPerFrame)
      return;

    _next = 0;
    animationFrame++;
    animationFrame6++;
    animationFrame8++;
    animationFrame16++;

    if (animationFrame6 >= 6){
      animationFrame6 = 0;
    }

    if (animationFrame8 >= 8){
      animationFrame8 = 0;
    }

    if (animationFrame16 >= 16) {
      animationFrame16 = 0;
    }

    if (animationFrameWater++ >= 9){
      animationFrameWater = 0;
    }
    animationFrameWaterHeight = const [
      0, 1, 2, 3, 4, 5, 4, 3, 2, 1,
    ][animationFrameWater];

    animationFrameWaterSrcX = animationFrameWater * Node_Size;
  }
}