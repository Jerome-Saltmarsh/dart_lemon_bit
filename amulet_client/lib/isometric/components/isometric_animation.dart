import 'package:amulet_common/src.dart';
import 'package:amulet_client/packages/lemon_components/updatable.dart';

class IsometricAnimation implements Updatable {
  var frameWater = 0;
  var frameWaterHeight = 0;
  var frameWaterSrcX = 0.0;
  var frameWaterFlowingSrcX = 0.0;
  var frame16 = 0;
  var frameRainWater = 0;
  var frameTreePosition = 0;
  var rainPosition = 0.0;
  var frame = 0;
  var frameRate2 = 0;
  var frameRate3 = 0;
  var frameRate4 = 0;
  var frameRate5 = 0;

  @override
  void onComponentUpdate() {
    frame++;

    if (frame % 2 == 0){
      frameRate2++;
    }
    if (frame % 3 == 0){
      frameRate3++;
    }
    if (frame % 4 == 0){
      frameRate4++;
    }
    if (frame % 5 == 0){
      frameRate5++;
    }

    if (frame % 6 == 0){
      if (frameWater++ >= 9){
        frameWater = 0;
      }
      frameWaterHeight = const [
        0, 1, 2, 3, 4, 5, 4, 3, 2, 1,
      ][frameWater];
      frameWaterSrcX = frameWater * Node_Size;
    }

    frame16++;

    if (frame16 >= 16) {
      frame16 = 0;
    }
  }
}