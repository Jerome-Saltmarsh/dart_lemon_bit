
import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';

extension IsometricQueries on Isometric {

  bool indexOnscreen(int index){
    const padding = Node_Size;
    final x = getIndexRenderX(index);
    if (x < engine.Screen_Left - padding || x > engine.Screen_Right + padding)
      return false;

    final y = getIndexRenderY(index);
    return y > engine.Screen_Top - padding && y < engine.Screen_Bottom + padding;
  }
}