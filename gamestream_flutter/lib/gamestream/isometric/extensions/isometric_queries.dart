
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';

extension IsometricQueries on Isometric {

  bool isIndexOnScreen(int index){
    final x = getIndexRenderX(index);
    if (x < engine.Screen_Left || x > engine.Screen_Right)
      return false;

    final y = getIndexRenderY(index);
    return y > engine.Screen_Top && y < engine.Screen_Bottom;
  }
}