
import 'dart:math';

import 'package:gamestream_flutter/library.dart';

class GameNodes {
  static const Nodes_Initial_Size = 0;

  static var nodesBake = Uint8List(Nodes_Initial_Size);
  static var nodesColor = Int32List(Nodes_Initial_Size);
  static var nodesOrientation = Uint8List(Nodes_Initial_Size);
  static var nodesShade = Uint8List(Nodes_Initial_Size);
  static var nodesTotal = Nodes_Initial_Size;
  static var nodesArea = 0;
  static var nodesType = Uint8List(Nodes_Initial_Size);
  static var nodesVariation = List<bool>.generate(Nodes_Initial_Size, (index) => false, growable: false);
  static var nodesVisible = Uint8List(Nodes_Initial_Size);
  static var nodesVisibleIndex = Uint16List(Nodes_Initial_Size);
  static var nodesDynamicIndex = Uint16List(Nodes_Initial_Size);
  static var nodesWind = Uint8List(Nodes_Initial_Size);
  static var visibleIndex = 0;
  static var dynamicIndex = 0;

  static var miniMap = Uint8List(0);

  // METHODS

  static void generateMiniMap(){
      if (miniMap.length != nodesArea){
        miniMap = Uint8List(nodesArea);
      }

      var index = 0;
      final rows = GameState.nodesTotalRows;
      final columns = GameState.nodesTotalColumns;

      for (var row = 0; row < rows; row++){
          for (var column = 0; column < columns; column++){
            var searchIndex = nodesTotal - nodesArea +  index;
            var typeFound = ItemType.Empty;
            while (true) {
              if (searchIndex < 0) break;
              final type = nodesType[searchIndex];
              searchIndex -= nodesArea;
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
      nodesVisible[nodesVisibleIndex[visibleIndex]] = Visibility.Opaque;
      visibleIndex--;
    }
    nodesVisible[nodesVisibleIndex[0]] = Visibility.Opaque;
  }

  static void resetStackDynamicLight() {
    while (dynamicIndex >= 0) {
      final i = nodesDynamicIndex[dynamicIndex];
      nodesShade[i] = nodesBake[i];
      dynamicIndex--;
    }
    dynamicIndex = 0;
  }


  static void addInvisibleIndex(int index){
    if (nodesVisible[index] == Visibility.Transparent) return;
    nodesVisible[index] = Visibility.Invisible;
    nodesVisibleIndex[visibleIndex] = index;
    visibleIndex++;
  }

  static void addTransparentIndex(int index){
    if (nodesVisible[index] == Visibility.Transparent) return;
    nodesVisible[index] = Visibility.Transparent;
    nodesVisibleIndex[visibleIndex] = index;
    visibleIndex++;
  }

  static void resetGridToAmbient(){
    for (var i = 0; i < nodesTotal; i++){
      nodesBake[i] = Shade.Pitch_Black;
      nodesShade[i] = Shade.Pitch_Black;
      dynamicIndex = 0;
    }
  }

  static void applyEmissionDynamic({
    required int index,
    int maxBrightness = Shade.Very_Bright,
  }){
    assert (index >= 0);
    assert (index < nodesTotal);

    final zIndex = index ~/ nodesArea;
    final rowIndex = (index - (zIndex * nodesArea)) ~/ GameState.nodesTotalColumns;
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
    var zTotal = zMin * nodesArea;

    for (var z = zMin; z < zMax; z++) {
      var rowInit = rowInitInit;

      for (var row = rowMin; row <= rowMax; row++){
        final a = (zTotal) + (rowInit);
        rowInit += GameState.nodesTotalColumns;
        final b = (z - zIndex).abs() + (row - rowIndex).abs();
        for (var column = columnMin; column <= columnMax; column++) {
          final nodeIndex = a + column;
          final distanceValue = Engine.clamp(b + (column - columnIndex).abs() - 2, maxBrightness, Shade.Pitch_Black);
          if (distanceValue >= nodesShade[nodeIndex]) continue;
          nodesShade[nodeIndex] = distanceValue;
          nodesDynamicIndex[dynamicIndex++] = nodeIndex;
        }
      }
      zTotal += nodesArea;
    }
  }

  static int getTorchIndex(int nodeIndex){
    final initialSearchIndex = nodeIndex - GameState.nodesTotalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
    var torchIndex = -1;
    var rowIndex = 0;

    for (var row = 0; row < 3; row++){
      for (var column = 0; column < 3; column++){
        final searchIndex = initialSearchIndex + rowIndex + column;
        if (searchIndex >= nodesTotal) break;
        if (nodesType[searchIndex] != NodeType.Torch) continue;
        torchIndex = searchIndex;
        break;
      }
      rowIndex += GameState.nodesTotalColumns;
    }
    return torchIndex;
  }
}
