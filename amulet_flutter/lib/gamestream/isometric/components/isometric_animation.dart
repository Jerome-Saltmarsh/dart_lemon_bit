import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/packages/lemon_components/updatable.dart';

class IsometricAnimation implements Updatable {
  var frame1 = 0;
  var frameWater = 0;
  var frameWaterHeight = 0;
  var frameWaterSrcX = 0.0;
  var frameWaterFlowingSrcX = 0.0;
  var frame2 = 0;
  var frame6 = 0;
  var frame8 = 0;
  var frame16 = 0;
  var frameRainWater = 0;
  var frameTreePosition = 0;
  var rainPosition = 0.0;
  var frameRate1 = 0;
  var frameRate2 = 0;
  var frameRate3 = 0;
  var frameRate4 = 0;
  var frameRate5 = 0;

  @override
  void onComponentUpdate() {
    frameRate1++;

    if (frameRate1 % 2 == 0){
      frameRate2++;
    }
    if (frameRate1 % 3 == 0){
      frameRate3++;
    }
    if (frameRate1 % 4 == 0){
      frameRate4++;
    }
    if (frameRate1 % 5 == 0){
      frameRate5++;
    }

    if (frameRate1 % 6 == 0){
      if (frameWater++ >= 9){
        frameWater = 0;
      }
      frameWaterHeight = const [
        0, 1, 2, 3, 4, 5, 4, 3, 2, 1,
      ][frameWater];
      frameWaterSrcX = frameWater * Node_Size;
    }

    frame1++;
    frame2++;
    frame6++;
    frame8++;
    frame16++;

    if (frame2 >= 2){
      frame2 = 0;
    }

    if (frame6 >= 6){
      frame6 = 0;
    }

    if (frame8 >= 8){
      frame8 = 0;
    }

    if (frame16 >= 16) {
      frame16 = 0;
    }
  }
}