
import 'dart:math';

import 'package:gamestream_flutter/library.dart';

class GameNodes {
  static const Nodes_Initial_Size = 0;

  static var nodeBake = Uint8List(Nodes_Initial_Size);
  static var nodeColors = Int32List(Nodes_Initial_Size);
  static var nodeOrientations = Uint8List(Nodes_Initial_Size);
  static var nodeShades = Uint8List(Nodes_Initial_Size);
  static var nodeTypes = Uint8List(Nodes_Initial_Size);
  static var nodeVariations = List<bool>.generate(Nodes_Initial_Size, (index) => false, growable: false);
  static var nodeVisible = Uint8List(Nodes_Initial_Size);
  static var nodeVisibleIndex = Uint16List(Nodes_Initial_Size);
  static var nodeDynamicIndex = Uint16List(Nodes_Initial_Size);
  static var nodeWind = Uint8List(Nodes_Initial_Size);
  static var miniMap = Uint8List(0);
  static var visibleIndex = 0;
  static var dynamicIndex = 0;
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
      nodeShades[i] = nodeBake[i];
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
    for (var i = 0; i < total; i++){
      nodeBake[i] = Shade.Pitch_Black;
      nodeShades[i] = Shade.Pitch_Black;
      dynamicIndex = 0;
    }
  }

  static void applyEmissionDynamic({
    required int index,
    int maxBrightness = Shade.Very_Bright,
  }){
    assert (index >= 0);
    assert (index < total);

    final zIndex = index ~/ area;
    final rowIndex = (index - (zIndex * area)) ~/ GameState.nodesTotalColumns;
    // index - ((convertNodeIndexToZ(index) * GameNodes.nodesArea) + (convertNodeIndexToRow(index) * nodesTotalColumns));
    // final columnIndex = GameState.convertNodeIndexToColumn(index);
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
          final distanceValue = Engine.clamp(b + (column - columnIndex).abs() - 2, maxBrightness, Shade.Pitch_Black);
          if (distanceValue >= nodeShades[nodeIndex]) continue;
          nodeShades[nodeIndex] = distanceValue;
          nodeDynamicIndex[dynamicIndex++] = nodeIndex;
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
