
import 'package:flutter/material.dart';

import 'library.dart';

class GameMinimap {
  static var src = Float32List(0);
  static var dst = Float32List(0);

  static double mapNodeTypeToSrcX(int nodeType) => const <int, double>{
      NodeType.Grass: 1,
      NodeType.Water: 2,
      NodeType.Wood: 3,
      NodeType.Wooden_Plank: 3,
      NodeType.Soil: 3,
      NodeType.Road: 4,
      NodeType.Road_2: 4,
      NodeType.Tree_Bottom: 6,
      NodeType.Tree_Top: 6,
      NodeType.Bau_Haus: 7,
      NodeType.Brick: 8,
      NodeType.Torch: 1,
    }[nodeType] ?? 0;

  static void generateSrcDst(){
    var index = 0;
    final rows = gamestream.games.isometric.nodes.totalRows;
    final columns = gamestream.games.isometric.nodes.totalColumns;
    final area = gamestream.games.isometric.nodes.area;
    final nodeTypes = gamestream.games.isometric.nodes.miniMap;

    final vendors = <int>[];

    final total = ((area + vendors.length) * 4);
    if (src.length != total){
      src = Float32List(total);
    }
    if (dst.length != total){
      dst = Float32List(total);
    }

    for (var row = 0; row < rows; row++){
      for (var column = 0; column < columns; column++){
        final nodeType = nodeTypes[index];
        var srcWidth = 1.0;
        var srcHeight = 1.0;
        var srcX = mapNodeTypeToSrcX(nodeType) * 2.0;
        final srcY = 0;
        var dstX = (row - column) * 1.0;
        var dstY = (row + column) * 1.0;
        var f = index * 4;
        src[f + 0] = srcX;
        src[f + 1] = 0;
        src[f + 2] = srcX + srcWidth;
        src[f + 3] = srcY + srcHeight;
        dst[f + 0] = 1;
        dst[f + 1] = 0;
        dst[f + 2] = dstX;
        dst[f + 3] = dstY;
        index++;
      }
    }

    for (var i = 0; i < vendors.length; i++){
       final nodeIndex = vendors[i];
       final indexX = gamestream.games.isometric.clientState.convertNodeIndexToIndexX(nodeIndex);
       final indexY = gamestream.games.isometric.clientState.convertNodeIndexToIndexY(nodeIndex);
       final dstX = (indexX - indexY) * 1.0;
       final dstY = (indexX + indexY) * 1.0;
       final f = ((area + i) * 4);
       src[f + 0] = 26;
       src[f + 1] = 0;
       src[f + 2] = 26 + 10;
       src[f + 3] = 00 + 09;
       dst[f + 0] = 0.612;
       dst[f + 1] = 0;
       dst[f + 2] = dstX;
       dst[f + 3] = dstY;
    }
  }

  static final paint = Paint()
    ..color = Colors.white
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.fill
    ..isAntiAlias = false
    ..strokeWidth = 1;

  static void renderCanvas(Canvas canvas){
    canvas.drawRawAtlas(GameImages.atlas_nodes_mini, dst, src, null, null, null, paint);
  }
}