
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/render/state/bakeMap.dart';

void resetDynamicShadesToBakeMap() {
  final dynamicShading = modules.isometric.state.dynamicShading;
  for (int row = 0; row < dynamicShading.length; row++) {
    for (int column = 0; column < dynamicShading[0].length; column++) {
      dynamicShading[row][column] = bakeMap[row][column];
    }
  }
}