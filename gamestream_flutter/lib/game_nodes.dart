
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:gamestream_flutter/library.dart';

class GameNodes {
  static var ambient_color_hsv  = HSVColor.fromColor(Color.fromRGBO(31, 1, 86, 0.5));
  static var ambient_hue        = ambient_color_hsv.hue;
  static var ambient_sat        = ambient_color_hsv.saturation;
  static var ambient_val        = ambient_color_hsv.value;
  static var ambient_alp        = ambient_color_hsv.alpha;
  static var ambient_color      = 0;
  static var transparent_color      = 0;

  static void resetNodeColorsToAmbient() {
    GameNodes.ambient_alp = clamp01(GameNodes.ambient_alp);
    ambient_color = GameLighting.hsvToColorValue(ambient_hue, ambient_sat, ambient_val, ambient_alp);
    transparent_color = GameLighting.hsvToColorValue(ambient_hue, ambient_sat, ambient_val, 0.5);
    dynamicIndex = 0;

     if (nodeColors.length != total) {
       nodeColors = Uint32List(total);
       nodeHues = Float32List(total);
       nodeSats = Float32List(total);
       nodeVals = Float32List(total);
       nodeAlps = Float32List(total);
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
  static var nodeHues = Float32List(0);
  static var nodeSats = Float32List(0);
  static var nodeVals = Float32List(0);
  static var nodeAlps = Float32List(0);
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

  // METHODS

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
    if (nodeVisible[index] == Visibility.Transparent) return;
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

  static void emitLightDynamic({
    required int index,
    required double hue,
    required double saturation,
    required double value,
    required double alpha,
    double strength = 1.0,

  }){
    if (index < 0) return;
    if (index >= total) return;

    assert (hue >= 0);
    assert (hue <= 360.0);
    assert (saturation >= 0);
    assert (saturation <= 1);
    assert (value >= 0);
    assert (value <= 1);
    assert (alpha >= 0);
    assert (alpha <= 1);

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

          final intensity = (1.0 - GameLighting.interpolations[clamp(distanceValue, 0, 7)]) * strength;
          nodeHues[nodeIndex] = GameLighting.linerInterpolation(nodeHues[nodeIndex], hue        , intensity);
          nodeSats[nodeIndex] = GameLighting.linerInterpolation(nodeSats[nodeIndex], saturation , intensity);
          nodeVals[nodeIndex] = GameLighting.linerInterpolation(nodeVals[nodeIndex], value      , intensity);
          nodeAlps[nodeIndex] = GameLighting.linerInterpolation(nodeAlps[nodeIndex], alpha      , intensity);
          refreshNodeColor(nodeIndex);
        }
      }
      zTotal += area;
    }
  }

  static void emitLightDynamicAmbient({
    required int index,
    required double alpha,

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

          final intensity = 1.0 - GameLighting.interpolations[clamp(distanceValue, 0, 7)];
          final nodeAlpha = nodeAlps[nodeIndex];
          if (nodeAlpha < alpha) continue;
          nodeAlps[nodeIndex] = GameLighting.linerInterpolation(nodeAlpha, alpha, intensity);
          refreshNodeColor(nodeIndex);
        }
      }
      zTotal += area;
    }
  }

  static void refreshNodeColor(int index){
    nodeColors[index] = GameLighting.hsvToColorValue(
      nodeHues[index],
      nodeSats[index],
      nodeVals[index],
      nodeAlps[index],
    );
  }


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
