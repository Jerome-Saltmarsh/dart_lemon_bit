
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:gamestream_flutter/functions/hsv_to_color.dart';
import 'package:gamestream_flutter/library.dart';

class GameNodes {
  static var ambient_color_hsv  = HSVColor.fromColor(Color.fromRGBO(31, 1, 86, 0.5));
  static var ambient_hue        = ((ambient_color_hsv.hue / 360) * 255).round();
  static var ambient_sat        = (ambient_color_hsv.saturation * 255).round();
  static var ambient_val        = (ambient_color_hsv.value * 255).round();
  static var ambient_alp        = (ambient_color_hsv.alpha * 255).round();
  static var ambient_color      = 0;

  static void resetNodeColorsToAmbient() {
    GameNodes.ambient_alp = clamp(GameNodes.ambient_alp, 0, 255);
    ambient_color = hsvToColor(
        hue: ambient_hue,
        saturation: ambient_sat,
        value: ambient_val,
        opacity: ambient_alp
    );
    dynamicIndex = 0;

     if (nodeColors.length != total) {
       nodeColors = Uint32List(total);
       nodeHues = Uint8List(total);
       nodeSats = Uint8List(total);
       nodeVals = Uint8List(total);
       nodeAlps = Uint8List(total);
     }
     for (var i = 0; i < total; i++) {
       nodeColors[i] = ambient_color;
       nodeHues[i] = ambient_hue;
       nodeSats[i] = ambient_sat;
       nodeVals[i] = ambient_val;
       nodeAlps[i] = ambient_alp;
     }
  }

  static var nodeColors = Uint32List(0);
  static var nodeHues = Uint8List(0);
  static var nodeSats = Uint8List(0);
  static var nodeVals = Uint8List(0);
  static var nodeAlps = Uint8List(0);
  static var nodeOrientations = Uint8List(0);
  static var nodeTypes = Uint8List(0);
  static var nodeVariations = Uint8List(0);
  static var nodeVisible = Uint8List(0);
  static var nodeVisibleIndex = Uint16List(0);
  static var nodeDynamicIndex = Uint16List(0);
  static var nodeWind = Uint8List(0);
  static var miniMap = Uint8List(0);
  static var visibleIndex = 0;
  static var dynamicIndex = -1;
  static var total = 0;
  static var area = 0;
  static var area2 = 0;
  static var projection = 0;
  static var projectionHalf = 0;

  // METHODS

  static int getIndex(int row, int column, int z){
    return (row * GameState.nodesTotalColumns) + column + (z * GameNodes.area);
  }

  static void generateMiniMap(){
      if (miniMap.length != area){
        miniMap = Uint8List(area);
      }

      var index = 0;
      final rows = GameState.nodesTotalRows;
      final columns = GameState.nodesTotalColumns;

      for (var row = 0; row < rows; row++){
          for (var column = 0; column < columns; column++){
            var searchIndex = total - area +  index;
            var typeFound = ItemType.Empty;
            while (true) {
              if (searchIndex < 0) break;
              final type = nodeTypes[searchIndex];
              searchIndex -= area;
              if (NodeType.isRainOrEmpty(type)) continue;
              typeFound = type;
              break;
            }
            miniMap[index] = typeFound;
            index++;
          }
      }
  }
  
  static void resetVisible(){
    while (visibleIndex > 0) {
      nodeVisible[nodeVisibleIndex[visibleIndex]] = Visibility.Opaque;
      visibleIndex--;
    }
    nodeVisible[nodeVisibleIndex[0]] = Visibility.Opaque;
  }

  static void resetStackDynamicLight() {
    while (dynamicIndex >= 0) {
      final i = nodeDynamicIndex[dynamicIndex];
      nodeColors[i] = ambient_color;
      nodeHues[i] = ambient_hue;
      nodeSats[i] = ambient_sat;
      nodeVals[i] = ambient_val;
      nodeAlps[i] = ambient_alp;
      dynamicIndex--;
    }
    dynamicIndex = 0;
  }

  static void addInvisibleIndex(int index){
    if (nodeVisible[index] == Visibility.Invisible) return;
    nodeVisible[index] = Visibility.Invisible;
    nodeVisibleIndex[visibleIndex] = index;
    visibleIndex++;
  }

  static void addTransparentIndex(int index){
    if (nodeVisible[index] == Visibility.Transparent) return;
    nodeVisible[index] = Visibility.Transparent;
    nodeVisibleIndex[visibleIndex] = index;
    visibleIndex++;
  }

  static int linerInterpolationInt(int a, int b, double t) {
    return (a * (1.0 - t) + b * t).round();
  }

  static const interpolations = <double>[
    0,
    0.26530612244897944,
    0.4897959183673469,
    0.6734693877551021,
    0.8163265306122449,
    0.9183673469387755,
    0.9795918367346939,
  ];

  static void emitLightDynamic({
    required int index,
    required int hue,
    required int saturation,
    required int value,
    required int alpha,
    double strength = 1.0,

  }){
    if (index < 0) return;
    if (index >= total) return;

    assert (hue >= 0);
    assert (hue <= 255);
    assert (saturation >= 0);
    assert (saturation <= 255);
    assert (value >= 0);
    assert (value <= 255);
    assert (alpha >= 0);
    assert (alpha <= 255);

    final zIndex = index ~/ area;
    final rowIndex = (index - (zIndex * area)) ~/ GameState.nodesTotalColumns;
    final columnIndex = GameState.convertNodeIndexToIndexY(index);
    final radius = Shade.Pitch_Black;
    final zMin = max(zIndex - radius, 0);
    final zMax = min(zIndex + radius, GameState.nodesTotalZ);
    final rowMin = max(rowIndex - radius, 0);
    final rowMax = min(rowIndex + radius, GameState.nodesTotalRows);
    final columnMin = max(columnIndex - radius, 0);
    final columnMax = min(columnIndex + radius, GameState.nodesTotalColumns);
    final rowInitInit = GameState.nodesTotalColumns * rowMin;
    var zTotal = zMin * area;

    const r = 4;
    final dstXLeft = GameConvert.rowColumnZToRenderX(rowIndex + r, columnIndex - r, zIndex);
    if (dstXLeft < Engine.screen.left)    return;
    final dstXRight = GameConvert.rowColumnZToRenderX(rowIndex - r, columnIndex + r, zIndex);
    if (dstXRight > Engine.screen.right)   return;
    final dstYTop = GameConvert.rowColumnZToRenderY(rowIndex + r, columnIndex + r, zIndex);
    if (dstYTop <  Engine.screen.top) return;
    final dstYBottom = GameConvert.rowColumnZToRenderY(rowIndex - r, columnIndex - r, zIndex);
    if (dstYBottom >  Engine.screen.bottom) return;

    for (var z = zMin; z < zMax; z++) {
      var rowInit = rowInitInit;

      for (var row = rowMin; row <= rowMax; row++){
        final a = (zTotal) + (rowInit);
        rowInit += GameState.nodesTotalColumns;
        final b = (z - zIndex).abs() + (row - rowIndex).abs();
        for (var column = columnMin; column <= columnMax; column++) {
          final nodeIndex = a + column;
          final distanceValue = Engine.clamp(b + (column - columnIndex).abs() - 2, 0, 6);
          if (distanceValue > 5) continue;

          nodeDynamicIndex[dynamicIndex++] = nodeIndex;

          final intensity = (1.0 - interpolations[clamp(distanceValue, 0, 7)]) * strength;
          nodeHues[nodeIndex] = linerInterpolationInt(nodeHues[nodeIndex], hue        , intensity);
          nodeSats[nodeIndex] = linerInterpolationInt(nodeSats[nodeIndex], saturation , intensity);
          nodeVals[nodeIndex] = linerInterpolationInt(nodeVals[nodeIndex], value      , intensity);
          nodeAlps[nodeIndex] = linerInterpolationInt(nodeAlps[nodeIndex], alpha      , intensity);
          refreshNodeColor(nodeIndex);
        }
      }
      zTotal += area;
    }
  }

  static void emitLightDynamicAmbient({
    required int index,
    required int alpha,
  }){
    if (index < 0) return;
    if (index >= total) return;

    final zIndex = index ~/ area;
    final rowIndex = (index - (zIndex * area)) ~/ GameState.nodesTotalColumns;
    final columnIndex = GameState.convertNodeIndexToIndexY(index);
    final radius = Shade.Pitch_Black;
    final zMin = max(zIndex - radius, 0);
    final zMax = min(zIndex + radius, GameState.nodesTotalZ);
    final rowMin = max(rowIndex - radius, 0);
    final rowMax = min(rowIndex + radius, GameState.nodesTotalRows);
    final columnMin = max(columnIndex - radius, 0);
    final columnMax = min(columnIndex + radius, GameState.nodesTotalColumns);
    final rowInitInit = GameState.nodesTotalColumns * rowMin;
    var zTotal = zMin * area;

    const r = 4;
    final dstXLeft = GameConvert.rowColumnZToRenderX(rowIndex + r, columnIndex - r, zIndex);
    if (dstXLeft < Engine.screen.left)    return;
    final dstXRight = GameConvert.rowColumnZToRenderX(rowIndex - r, columnIndex + r, zIndex);
    if (dstXRight > Engine.screen.right)   return;
    final dstYTop = GameConvert.rowColumnZToRenderY(rowIndex + r, columnIndex + r, zIndex);
    if (dstYTop <  Engine.screen.top) return;
    final dstYBottom = GameConvert.rowColumnZToRenderY(rowIndex - r, columnIndex - r, zIndex);
    if (dstYBottom >  Engine.screen.bottom) return;

    for (var z = zMin; z < zMax; z++) {
      var rowInit = rowInitInit;

      for (var row = rowMin; row <= rowMax; row++){
        final a = (zTotal) + (rowInit);
        rowInit += GameState.nodesTotalColumns;
        final b = (z - zIndex).abs() + (row - rowIndex).abs();
        for (var column = columnMin; column <= columnMax; column++) {
          final nodeIndex = a + column;
          final distanceValue = Engine.clamp(b + (column - columnIndex).abs() - 2, 0, Shade.Pitch_Black);
          if (distanceValue > 5) continue;

          nodeDynamicIndex[dynamicIndex++] = nodeIndex;

          final intensity = 1.0 - interpolations[clamp(distanceValue, 0, 7)];
          final nodeAlpha = nodeAlps[nodeIndex];
          if (nodeAlpha < alpha) continue;
          nodeAlps[nodeIndex] = linerInterpolationInt(nodeAlps[nodeIndex], alpha      , intensity);
          refreshNodeColor(nodeIndex);
        }
      }
      zTotal += area;
    }
  }

  static void refreshNodeColor(int index) =>
    nodeColors[index] = hsvToColor(
      hue: nodeHues[index],
      saturation: nodeSats[index],
      value: nodeVals[index],
      opacity: nodeAlps[index],
    );


  static int getTorchIndex(int nodeIndex){
    final initialSearchIndex = nodeIndex - GameState.nodesTotalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
    var torchIndex = -1;
    var rowIndex = 0;

    for (var row = 0; row < 3; row++){
      for (var column = 0; column < 3; column++){
        final searchIndex = initialSearchIndex + rowIndex + column;
        if (searchIndex >= total) break;
        if (nodeTypes[searchIndex] != NodeType.Torch) continue;
        torchIndex = searchIndex;
        break;
      }
      rowIndex += GameState.nodesTotalColumns;
    }
    return torchIndex;
  }
}
