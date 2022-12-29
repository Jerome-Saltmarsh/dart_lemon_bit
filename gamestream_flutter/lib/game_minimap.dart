
import 'dart:ui';

import 'library.dart';

class GameMinimap {
  static var src = Float32List(0);
  static var dst = Float32List(0);

  static double mapNodeTypeToSrcX(int nodeType){
    return 147;
  }

  static void generateSrcDst(){
    var index = 0;
    final rows = GameState.nodesTotalRows;
    final columns = GameState.nodesTotalColumns;
    final area = GameNodes.nodesArea;
    final nodeTypes = GameNodes.nodesType;
    final total = area * 4;
    if (src.length != total){
      src = Float32List(total);
    }
    if (dst.length != total){
      dst = Float32List(total);
    }
    for (var row = 0; row < rows; row++){
      for (var column = 0; column < columns; column++){
        final nodeType = nodeTypes[index];
        const srcWidth = 48.0;
        const srcHeight = 48.0;
        final srcX = mapNodeTypeToSrcX(nodeType);
        final srcY = 0;
        final dstX = (row - column) * Node_Size_Half;
        final dstY = (row + column) * Node_Size_Half;
        final anchorX = 0.5;
        final anchorY = 0.5;
        var f = index * 4;
        src[f] = srcX;
        src[f + 1] = 0;
        src[f + 2] = srcX + srcWidth;
        src[f + 3] = srcY + srcHeight;
        dst[f] = 1;
        dst[f + 1] = 0;
        dst[f + 2] = dstX - (srcWidth * anchorX);
        dst[f + 3] = dstY - (srcHeight * anchorY);
        index++;
      }
    }
  }

  static void renderCanvas(Canvas canvas){
    canvas.drawRawAtlas(GameImages.atlas_nodes, dst, src, null, null, null, Engine.paint);
  }
}