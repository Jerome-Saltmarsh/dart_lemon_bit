
import 'package:gamestream_flutter/packages/common/src/isometric/node_size.dart';

class IsometricAnimation {
  var frame = 0;
  var frameWater = 0;
  var frameWaterHeight = 0;
  var frameWaterSrcX = 0.0;
  var frameWaterFlowingSrcX = 0.0;
  var frame6 = 0;
  var frame8 = 0;
  var frame16 = 0;
  var frameRainWater = 0;
  var frameTreePosition = 0;
  var rainPosition = 0.0;
  var _next = 0;
  var rendersPerFrame = 3;

  final treeAnimation = [0, 1, 2, 1, 0, -1, -2, -1];

  void update() {
    if (_next++ < rendersPerFrame)
      return;

    _next = 0;
    frame++;
    frame6++;
    frame8++;
    frame16++;

    if (frame6 >= 6){
      frame6 = 0;
    }

    if (frame8 >= 8){
      frame8 = 0;
    }

    if (frame16 >= 16) {
      frame16 = 0;
    }

    if (frameWater++ >= 9){
      frameWater = 0;
    }
    frameWaterHeight = const [
      0, 1, 2, 3, 4, 5, 4, 3, 2, 1,
    ][frameWater];

    frameWaterSrcX = frameWater * Node_Size;
  }
}