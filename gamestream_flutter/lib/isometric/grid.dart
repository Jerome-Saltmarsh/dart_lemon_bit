import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/convert_index.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/particle_emitters.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:lemon_watch/watch.dart';

import 'convert/convert_distance_to_shade.dart';
import 'watches/ambient_shade.dart';
import 'watches/raining.dart';

final gridShadows = Watch(true, onChanged: (bool value){
  refreshLighting();
});

var nodesTotalZ = 0;
var nodesTotalRows = 0;
var nodesTotalColumns = 0;
var nodesLengthRow = 0.0;
var nodesLengthColumn = 0.0;
var nodesLengthZ = 0.0;
var nodesArea = 0;


bool outOfBounds(int z, int row, int column){
   if (z < 0) return true;
   if (z >= nodesTotalZ) return true;
   if (row < 0) return true;
   if (row >= nodesTotalRows) return true;
   if (column < 0) return true;
   if (column >= nodesTotalColumns) return true;
   return false;
}

bool nodeIsInBound(int z, int row, int column){
  if (z < 0) return false;
  if (z >= nodesTotalZ) return false;
  if (row < 0) return false;
  if (row >= nodesTotalRows) return false;
  if (column < 0) return false;
  if (column >= nodesTotalColumns) return false;
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

void toggleShadows () => gridShadows.value = !gridShadows.value;

void actionSetAmbientShadeToHour(){
  ambientShade.value = Shade.fromHour(hours.value);
}

void onGridChanged(){
  refreshGridMetrics();
  gridWindResetToAmbient();

  if (raining.value) {
     rainOn();
  }
  refreshLighting();
  refreshParticleEmitters();
}


void refreshParticleEmitters() {
  particleEmitters.clear();
  gridForEachOfType(
      NodeType.Fireplace,
      (z, row, column, type) {
        addSmokeEmitter(z, row, column);
      }
  );

  gridForEachOfType(
      NodeType.Chimney,
          (z, row, column, type) {
        if (gridNodeZRCType(z + 1, row, column) != NodeType.Empty) return;
        addSmokeEmitter(z + 1, row, column);
      }
  );
}

void gridForEachOfType(
    int type, Function(int z, int row, int column, int type) handler) {
  // for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
  //   final zValues = grid[zIndex];
  //   for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
  //     final rowValues = zValues[rowIndex];
  //     for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
  //       final t = rowValues[columnIndex];
  //       if (t.type != type) continue;
  //       handler(zIndex, rowIndex, columnIndex, t.type);
  //     }
  //   }
  // }

  for (var i = 0; i < nodesTotal; i++){
     if (nodesType[i] != type) continue;
     // TODO
     // handler(zIndex, rowIndex, columnIndex, type);
  }
}

void gridForEachNode(Function(int z, int row, int column) apply) {
  for (var zIndex = 0; zIndex < nodesTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < nodesTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < nodesTotalColumns; columnIndex++) {
        apply(zIndex, rowIndex, columnIndex);
      }
    }
  }
}

void resetGridToAmbient(){
  final shade = ambientShade.value;
  for (var i = 0; i < nodesTotal; i++){
     nodesBake[i] = shade;
     nodesShade[i] = shade;
     dynamicIndex = 0;
  }
}

void refreshLighting(){
  resetGridToAmbient();
  if (gridShadows.value){
    _applyShadows();
  }
  applyBakeMapEmissions();
}

void _applyShadows(){
  if (ambientShade.value > Shade.Very_Bright) return;
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
  final current = ambientShade.value;
  final shadowShade = current >= Shade.Pitch_Black ? current : current + 1;

  for (var z = 0; z < nodesTotalZ; z++) {
    for (var row = 0; row < nodesTotalRows; row++){
      for (var column = 0; column < nodesTotalColumns; column++){
        // final tile = grid[z][row][column];
        final index = getNodeIndexZRC(z, row, column);
        final tile = nodesType[index];
        if (!castesShadow(tile)) continue;
        var projectionZ = z + directionZ;
        var projectionRow = row + directionRow;
        var projectionColumn = column + directionColumn;
        while (
            projectionZ >= 0 &&
            projectionRow >= 0 &&
            projectionColumn >= 0 &&
            projectionZ < nodesTotalZ &&
            projectionRow < nodesTotalRows &&
            projectionColumn < nodesTotalColumns
        ) {
          final shade = nodesBake[index];
          if (shade < shadowShade){
            if (gridNodeZRCType(projectionZ + 1, projectionRow, projectionColumn) == NodeType.Empty){
              nodesBake[index] = shadowShade;
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
  if (outOfBounds(z, row, column)) return false;
  for (var zIndex = z + 1; zIndex < nodesTotalZ; zIndex++){
    if (!gridNodeZRCTypeRainOrEmpty(z, row, column)) return false;
  }
  return true;
}

bool gridIsPerceptible(int index){
  if (index < 0) return true;
  if (index >= nodesTotal) return true;
  while (true){
    index += nodesArea;
    index++;
    index += nodesTotalColumns;
    if (index >= nodesTotal) return true;
    if (nodesOrientation[index] != NodeOrientation.None){
      return false;
    }
  }
}

void refreshGridMetrics(){
  // gridTotalZ = grid.length;
  // gridTotalRows = grid[0].length;
  // gridTotalColumns = grid[0][0].length;

  nodesLengthRow = nodesTotalRows * tileSize;
  nodesLengthColumn = nodesTotalColumns * tileSize;
  nodesLengthZ = nodesTotalZ * tileHeight;
}

void applyBakeMapEmissions() {
  for (var zIndex = 0; zIndex < nodesTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < nodesTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < nodesTotalColumns; columnIndex++) {
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

  for (final gameObject in gameObjects){
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
  final zMax = min(zIndex + radius, nodesTotalZ);
  final rowMin = max(rowIndex - radius, 0);
  final rowMax = min(rowIndex + radius, nodesTotalRows);
  final columnMin = max(columnIndex - radius, 0);
  final columnMax = min(columnIndex + radius, nodesTotalColumns);

  for (var z = zMin; z < zMax; z++){
    for (var row = rowMin; row < rowMax; row++){
      for (var column = columnMin; column < columnMax; column++) {
        final nodeIndex = getNodeIndexZRC(z, row, column);
        var distance = (z - zIndex).abs() + (row - rowIndex).abs() + (column - columnIndex).abs() - 1;
        final distanceValue = convertDistanceToShade(distance, maxBrightness: maxBrightness);
        if (distanceValue >= nodesBake[nodeIndex]) continue;
        nodesBake[nodeIndex] = distanceValue;
        nodesShade[nodeIndex] = distanceValue;
      }
    }
  }
}

void applyEmissionDynamic({
  required int index,
  required int maxBrightness,
}){
  final zIndex = convertIndexToZ(index);
  final rowIndex = convertIndexToRow(index);
  final columnIndex = convertIndexToColumn(index);
  final radius = Shade.Pitch_Black;
  final zMin = max(zIndex - radius, 0);
  final zMax = min(zIndex + radius, nodesTotalZ);
  final rowMin = max(rowIndex - radius, 0);
  final rowMax = min(rowIndex + radius, nodesTotalRows);
  final columnMin = max(columnIndex - radius, 0);
  final columnMax = min(columnIndex + radius, nodesTotalColumns);

  for (var z = zMin; z < zMax; z++){
    for (var row = rowMin; row < rowMax; row++){
      final a = (z * nodesArea) + (row * nodesTotalColumns);
      final b = (z - zIndex).abs() + (row - rowIndex).abs();
      for (var column = columnMin; column < columnMax; column++) {
        final nodeIndex = a + column;
        var distance = b + (column - columnIndex).abs() - 1;
        final distanceValue = convertDistanceToShade(distance, maxBrightness: maxBrightness);
        if (distanceValue >= nodesShade[nodeIndex]) continue;
        nodesShade[nodeIndex] = distanceValue;
        nodesDynamicIndex[dynamicIndex] = nodeIndex;
        dynamicIndex++;
      }
    }
  }
}
