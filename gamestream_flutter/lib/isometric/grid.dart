import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/time.dart';

import 'convert/convert_distance_to_shade.dart';
import 'watches/raining.dart';


bool nodeIsInBound(int z, int row, int column){
  if (z < 0) return false;
  if (z >= Game.nodesTotalZ) return false;
  if (row < 0) return false;
  if (row >= Game.nodesTotalRows) return false;
  if (column < 0) return false;
  if (column >= Game.nodesTotalColumns) return false;
  return true;
}

// Node getNodeXYZ(double x, double y, double z){
//   final plain = z ~/ tileSizeHalf;
//   if (plain < 0) return Node.boundary;
//   if (plain >= gridTotalZ) return Node.empty;
//   final row = x ~/ tileSize;
//   if (row < 0) return Node.boundary;
//   if (row >= gridTotalRows) return Node.boundary;
//   final column = y ~/ tileSize;
//   if (column < 0) return Node.boundary;
//   if (column >= gridTotalColumns) return Node.boundary;
//   return grid[plain][row][column];
// }

// Node getNode(int z, int row, int column) {
//   if (outOfBounds(z, row, column)) return Node.boundary;
//   return grid[z][row][column];
// }

void toggleShadows () => Game.gridShadows.value = !Game.gridShadows.value;

void actionSetAmbientShadeToHour(){
  Game.ambientShade.value = Shade.fromHour(hours.value);
}

void onGridChanged(){
  refreshGridMetrics();
  gridWindResetToAmbient();

  if (raining.value) {
     rainOn();
  }
  refreshLighting();
}

void gridForEachNode(Function(int z, int row, int column) apply) {
  for (var zIndex = 0; zIndex < Game.nodesTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < Game.nodesTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < Game.nodesTotalColumns; columnIndex++) {
        apply(zIndex, rowIndex, columnIndex);
      }
    }
  }
}



void refreshLighting(){
  Game.resetGridToAmbient();
  if (Game.gridShadows.value){
    _applyShadows();
  }
  applyBakeMapEmissions();
}

void _applyShadows(){
  if (Game.ambientShade.value > Shade.Very_Bright) return;
  _applyShadowsMidAfternoon();
}

void _applyShadowsMidAfternoon() {
  _applyShadowAt(directionZ: -1, directionRow: 0, directionColumn: 0, maxDistance: 1);
}

void _applyShadowAt({
  required int directionZ,
  required int directionRow,
  required int directionColumn,
  required int maxDistance,
}){
  final current = Game.ambientShade.value;
  final shadowShade = current >= Shade.Pitch_Black ? current : current + 1;

  for (var z = 0; z < Game.nodesTotalZ; z++) {
    for (var row = 0; row < Game.nodesTotalRows; row++){
      for (var column = 0; column < Game.nodesTotalColumns; column++){
        // final tile = grid[z][row][column];
        final index = Game.getNodeIndexZRC(z, row, column);
        final tile = Game.nodesType[index];
        if (!castesShadow(tile)) continue;
        var projectionZ = z + directionZ;
        var projectionRow = row + directionRow;
        var projectionColumn = column + directionColumn;
        while (
            projectionZ >= 0 &&
            projectionRow >= 0 &&
            projectionColumn >= 0 &&
            projectionZ < Game.nodesTotalZ &&
            projectionRow < Game.nodesTotalRows &&
            projectionColumn < Game.nodesTotalColumns
        ) {
          final shade = Game.nodesBake[index];
          if (shade < shadowShade){
            if (gridNodeZRCType(projectionZ + 1, projectionRow, projectionColumn) == NodeType.Empty){
              Game.nodesBake[index] = shadowShade;
            }
          }
          projectionZ += directionZ;
          projectionRow += directionRow;
          projectionColumn += directionColumn;
        }
      }
    }
  }
}

bool castesShadow(int type) =>
    type == NodeType.Brick_2 ||
    type == NodeType.Water ||
    type == NodeType.Brick_Top;

bool gridIsUnderSomething(int z, int row, int column){
  if (Game.outOfBounds(z, row, column)) return false;
  for (var zIndex = z + 1; zIndex < Game.nodesTotalZ; zIndex++){
    if (!gridNodeZRCTypeRainOrEmpty(z, row, column)) return false;
  }
  return true;
}

bool gridIsPerceptible(int index){
  if (index < 0) return true;
  if (index >= Game.nodesTotal) return true;
  while (true){
    index += Game.nodesArea;
    index++;
    index += Game.nodesTotalColumns;
    if (index >= Game.nodesTotal) return true;
    if (Game.nodesOrientation[index] != NodeOrientation.None){
      return false;
    }
  }
}

void refreshGridMetrics(){
  // gridTotalZ = grid.length;
  // gridTotalRows = grid[0].length;
  // gridTotalColumns = grid[0][0].length;

  Game.nodesLengthRow = Game.nodesTotalRows * tileSize;
  Game.nodesLengthColumn = Game.nodesTotalColumns * tileSize;
  Game.nodesLengthZ = Game.nodesTotalZ * tileHeight;
}

void applyBakeMapEmissions() {
  for (var zIndex = 0; zIndex < Game.nodesTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < Game.nodesTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < Game.nodesTotalColumns; columnIndex++) {
        if (!NodeType.emitsLight(
            gridNodeZRCType(zIndex, rowIndex, columnIndex))
        ) continue;
        applyEmissionBake(
          zIndex: zIndex,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
          maxBrightness: Shade.Very_Bright,
          radius: 7,
        );
      }
    }
  }

  for (final gameObject in Game.gameObjects){
    if (gameObject.type == GameObjectType.Crystal){
      applyEmissionBake(
        zIndex: gameObject.indexZ,
        rowIndex: gameObject.indexRow,
        columnIndex: gameObject.indexColumn,
        maxBrightness: Shade.Very_Bright,
        radius: 7,
      );
    }
  }
}

void applyEmissionBake({
  required int zIndex,
  required int rowIndex,
  required int columnIndex,
  required int maxBrightness,
  int radius = 5,
}){
  final zMin = max(zIndex - radius, 0);
  final zMax = min(zIndex + radius, Game.nodesTotalZ);
  final rowMin = max(rowIndex - radius, 0);
  final rowMax = min(rowIndex + radius, Game.nodesTotalRows);
  final columnMin = max(columnIndex - radius, 0);
  final columnMax = min(columnIndex + radius, Game.nodesTotalColumns);

  for (var z = zMin; z < zMax; z++){
    for (var row = rowMin; row < rowMax; row++){
      for (var column = columnMin; column < columnMax; column++) {
        final nodeIndex = Game.getNodeIndexZRC(z, row, column);
        var distance = (z - zIndex).abs() + (row - rowIndex).abs() + (column - columnIndex).abs() - 1;
        final distanceValue = convertDistanceToShade(distance, maxBrightness: maxBrightness);
        if (distanceValue >= Game.nodesBake[nodeIndex]) continue;
        Game.nodesBake[nodeIndex] = distanceValue;
        Game.nodesShade[nodeIndex] = distanceValue;
      }
    }
  }
}

void applyEmissionDynamic({
  required int index,
  required int maxBrightness,
}){
  final zIndex = Game.convertNodeIndexToZ(index);
  final rowIndex = Game.convertNodeIndexToRow(index);
  final columnIndex = Game.convertNodeIndexToColumn(index);
  final radius = Shade.Pitch_Black;
  final zMin = max(zIndex - radius, 0);
  final zMax = min(zIndex + radius, Game.nodesTotalZ);
  final rowMin = max(rowIndex - radius, 0);
  final rowMax = min(rowIndex + radius, Game.nodesTotalRows);
  final columnMin = max(columnIndex - radius, 0);
  final columnMax = min(columnIndex + radius, Game.nodesTotalColumns);

  for (var z = zMin; z < zMax; z++){
    for (var row = rowMin; row < rowMax; row++){
      final a = (z * Game.nodesArea) + (row * Game.nodesTotalColumns);
      final b = (z - zIndex).abs() + (row - rowIndex).abs();
      for (var column = columnMin; column < columnMax; column++) {
        final nodeIndex = a + column;
        var distance = b + (column - columnIndex).abs() - 1;
        final distanceValue = convertDistanceToShade(distance, maxBrightness: maxBrightness);
        if (distanceValue >= Game.nodesShade[nodeIndex]) continue;
        Game.nodesShade[nodeIndex] = distanceValue;
        Game.nodesDynamicIndex[Game.dynamicIndex] = nodeIndex;
        Game.dynamicIndex++;
      }
    }
  }
}
