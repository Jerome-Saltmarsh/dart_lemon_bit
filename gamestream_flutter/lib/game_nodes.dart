
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:gamestream_flutter/library.dart';

class GameNodes {
  static const Nodes_Initial_Size = 0;

  static void applyLightAt(int index, double hue, double sat, double val, double strength){
     final outputHue = GameLighting.linerInterpolation(hue, nodeHues[index], strength);
     final outputSat = GameLighting.linerInterpolation(sat, nodeSats[index], strength);
     final outputVal = GameLighting.linerInterpolation(val, nodeVals[index], strength);
     final outputColor = GameLighting.hsvToColorValue(outputHue, outputSat, outputVal, strength);
     nodeColors[index] = outputColor;
  }

  static final ambient_color      = Color.fromRGBO(
      31, 1, 86, 0.5647058823529412);

  static final ambient_color_hsv  = HSVColor.fromColor(ambient_color);
  static final ambient_hue        = ambient_color_hsv.hue;
  static final ambient_sat        = ambient_color_hsv.saturation;
  static final ambient_val        = ambient_color_hsv.value;
  static final ambient_alp        = ambient_color_hsv.alpha;
  static final ambient_color_value  = ambient_color.value;

  static void resetNodeColorsToAmbient() {
     print('resetNodeColorsToAmbient($total)');

     if (nodeColors.length != total) {
       nodeColors = Uint32List(total);
       nodeHues = Float32List(total);
       nodeSats = Float32List(total);
       nodeVals = Float32List(total);
       nodeAlps = Float32List(total);
     }

     for (var i = 0; i < total; i++) {
       nodeColors[i] = ambient_color_value;
       nodeHues[i] = ambient_hue;
       nodeSats[i] = ambient_sat;
       nodeVals[i] = ambient_val;
       nodeAlps[i] = ambient_alp;
     }
  }

  static var nodeColors = Uint32List(Nodes_Initial_Size);
  static var nodeHues = Float32List(Nodes_Initial_Size);
  static var nodeSats = Float32List(Nodes_Initial_Size);
  static var nodeVals = Float32List(Nodes_Initial_Size);
  static var nodeAlps = Float32List(Nodes_Initial_Size);
  // static var nodeBake = Uint8List(Nodes_Initial_Size);
  static var nodeOrientations = Uint8List(Nodes_Initial_Size);
  // static var nodeShades = Uint8List(Nodes_Initial_Size);
  static var nodeTypes = Uint8List(Nodes_Initial_Size);
  static var nodeVariations = List<bool>.generate(Nodes_Initial_Size, (index) => false, growable: false);
  static var nodeVisible = Uint8List(Nodes_Initial_Size);
  static var nodeVisibleIndex = Uint16List(Nodes_Initial_Size);
  static var nodeDynamicIndex = Uint16List(Nodes_Initial_Size);
  static var nodeWind = Uint8List(Nodes_Initial_Size);
  static var miniMap = Uint8List(0);
  static var visibleIndex = 0;
  static var dynamicIndex = -1;
  static var total = Nodes_Initial_Size;
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
      // nodeShades[i] = nodeBake[i];
      nodeColors[i] = ambient_color_value;
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

  static void resetGridToAmbient(){
    if (nodeColors.length != total){
      nodeColors = Uint32List(total);
    }
    if (nodeHues.length != total){
      nodeHues = Float32List(total);
    }
    if (nodeSats.length != total){
      nodeSats = Float32List(total);
    }
    if (nodeVals.length != total){
      nodeVals = Float32List(total);
    }
    if (nodeAlps.length != total){
      nodeAlps = Float32List(total);
    }

    for (var i = 0; i < total; i++){
      // nodeBake[i] = Shade.Pitch_Black;
      // nodeShades[i] = Shade.Pitch_Black;
      nodeColors[i] = ambient_color_value;
      nodeHues[i] = ambient_hue;
      nodeSats[i] = ambient_sat;
      nodeVals[i] = ambient_val;
      nodeAlps[i] = ambient_alp;
      dynamicIndex = 0;
    }
  }

  static void emitLightDynamic({
    required int index,
    required double hue,
    required double saturation,
    required double value,
    required double alpha,

  }){
    assert (index >= 0);
    assert (index < total);

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
          // if (distanceValue >= nodeShades[nodeIndex]) continue;
          if (distanceValue > 5) continue;

          nodeDynamicIndex[dynamicIndex++] = nodeIndex;

          final intensity = 1.0 - GameLighting.interpolations[clamp(distanceValue, 0, 7)];
          nodeHues[nodeIndex] = GameLighting.linerInterpolation(nodeHues[nodeIndex], hue        , intensity);
          nodeSats[nodeIndex] = GameLighting.linerInterpolation(nodeSats[nodeIndex], saturation , intensity);
          nodeVals[nodeIndex] = GameLighting.linerInterpolation(nodeVals[nodeIndex], value      , intensity);
          nodeAlps[nodeIndex] = GameLighting.linerInterpolation(nodeAlps[nodeIndex], alpha      , intensity);

          nodeColors[nodeIndex] = GameLighting.hsvToColorValue(
              nodeHues[nodeIndex],
              nodeSats[nodeIndex],
              nodeVals[nodeIndex],
              nodeAlps[nodeIndex],
          );
        }
      }
      zTotal += area;
    }
  }

  static void emitLightDynamicAmbient({
    required int index,
    required double alpha,

  }){
    assert (index >= 0);
    assert (index < total);

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
          // if (distanceValue >= nodeShades[nodeIndex]) continue;
          if (distanceValue > 5) continue;

          nodeDynamicIndex[dynamicIndex++] = nodeIndex;

          final intensity = 1.0 - GameLighting.interpolations[clamp(distanceValue, 0, 7)];
          nodeAlps[nodeIndex] = GameLighting.linerInterpolation(nodeAlps[nodeIndex], alpha      , intensity);

          nodeColors[nodeIndex] = GameLighting.hsvToColorValue(
            nodeHues[nodeIndex],
            nodeSats[nodeIndex],
            nodeVals[nodeIndex],
            nodeAlps[nodeIndex],
          );
        }
      }
      zTotal += area;
    }
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
