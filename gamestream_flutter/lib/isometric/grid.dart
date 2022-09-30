import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/light_mode.dart';
import 'package:gamestream_flutter/isometric/particle_emitters.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/isometric/watches/rain.dart';
import 'package:lemon_watch/watch.dart';

import 'classes/nodes.dart';
import 'convert/convert_distance_to_shade.dart';
import 'watches/ambient_shade.dart';

final gridShadows = Watch(true, onChanged: (bool value){
  refreshLighting();
});

var gridTotalZ = 0;
var gridTotalRows = 0;
var gridTotalColumns = 0;
var gridTotalArea = 0;
var gridRowLength = 0.0;
var gridColumnLength = 0.0;
var gridZLength = 0.0;


bool outOfBounds(int z, int row, int column){
   if (z < 0) return true;
   if (z >= gridTotalZ) return true;
   if (row < 0) return true;
   if (row >= gridTotalRows) return true;
   if (column < 0) return true;
   if (column >= gridTotalColumns) return true;
   return false;
}

bool nodeIsInBound(int z, int row, int column){
  if (z < 0) return false;
  if (z >= gridTotalZ) return false;
  if (row < 0) return false;
  if (row >= gridTotalRows) return false;
  if (column < 0) return false;
  if (column >= gridTotalColumns) return false;
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

  if (rain.value != Rain.None) {
     rainOn();
  }

  connectNodeTrees();
  refreshLighting();
  refreshParticleEmitters();
}

void connectNodeTrees() {
   for (var z = 0; z < gridTotalZ; z++){
    for (var row = 0; row < gridTotalRows; row++){
       for (var column = 0; column < gridTotalColumns; column++){
           // final node = getNode(z, row, column);
           // if (node is NodeTreeTop){
           //   node.bottom = getNode(z - 1, row, column);
           // }
       }
    }
  }
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

  for (var i = 0; i < gridNodeTotal; i++){
     if (gridNodeTypes[i] != type) continue;
     // TODO
     // handler(zIndex, rowIndex, columnIndex, type);
  }
}

void gridForEachNode(Function(int z, int row, int column) apply) {
  for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
        apply(zIndex, rowIndex, columnIndex);
      }
    }
  }
}

void resetGridToAmbient(){
  final shade = ambientShade.value;
  // for (final z in grid){
  //   for (final row in z){
  //     for (final column in row){
  //       column.bake = shade;
  //       column.shade = shade;
  //     }
  //   }
  // }

  for (var i = 0; i < gridNodeTotal; i++){
     gridNodeBake[i] = shade;
     gridNodeShade[i] = shade;
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

  for (var z = 0; z < gridTotalZ; z++) {
    for (var row = 0; row < gridTotalRows; row++){
      for (var column = 0; column < gridTotalColumns; column++){
        // final tile = grid[z][row][column];
        final index = gridNodeIndexZRC(z, row, column);
        final tile = gridNodeTypes[index];
        if (!_castesShadow(tile)) continue;
        var projectionZ = z + directionZ;
        var projectionRow = row + directionRow;
        var projectionColumn = column + directionColumn;
        while (
            projectionZ >= 0 &&
            projectionRow >= 0 &&
            projectionColumn >= 0 &&
            projectionZ < gridTotalZ &&
            projectionRow < gridTotalRows &&
            projectionColumn < gridTotalColumns
        ) {
          final shade = gridNodeBake[index];
          if (shade < shadowShade){
            if (gridNodeZRCType(projectionZ + 1, projectionRow, projectionColumn) == NodeType.Empty){
              gridNodeBake[index] = shadowShade;
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

bool _castesShadow(int type){
  return const [
        NodeType.Brick_Top,
        NodeType.Roof_Tile_South,
        NodeType.Roof_Tile_North,
  ].contains(type);
}

bool gridIsUnderSomething(int z, int row, int column){
  if (outOfBounds(z, row, column)) return false;
  for (var zIndex = z + 1; zIndex < gridTotalZ; zIndex++){
    if (!gridNodeZRCTypeEmpty(z, row, column)) return false;
  }
  return true;
}

bool gridIsPerceptible(int zIndex, int row, int column){
  if (outOfBounds(zIndex, row, column)) return false;

  for (var z = zIndex + 1; z < gridTotalZ; z += 2){
    row++;
    column++;
    if (row >= gridTotalRows) break;
    if (column >= gridTotalColumns) break;
    if (NodeType.blocksPerception(gridNodeZRCType(z, row, column))) return false;
  }
  return true;
}

void refreshGridMetrics(){
  // gridTotalZ = grid.length;
  // gridTotalRows = grid[0].length;
  // gridTotalColumns = grid[0][0].length;

  gridRowLength = gridTotalRows * tileSize;
  gridColumnLength = gridTotalColumns * tileSize;
  gridZLength = gridTotalZ * tileHeight;
}

void applyBakeMapEmissions() {
  for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
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
  final zMax = min(zIndex + radius, gridTotalZ);
  final rowMin = max(rowIndex - radius, 0);
  final rowMax = min(rowIndex + radius, gridTotalRows);
  final columnMin = max(columnIndex - radius, 0);
  final columnMax = min(columnIndex + radius, gridTotalColumns);

  for (var z = zMin; z < zMax; z++){
    for (var row = rowMin; row < rowMax; row++){
      for (var column = columnMin; column < columnMax; column++) {
        // final node = grid[z][row][column];
        // if (!node.isShadable) continue;
        final nodeIndex = gridNodeIndexZRC(z, row, column);
        final currentValue = gridNodeBake[nodeIndex];
        var distance = (z - zIndex).abs() + (row - rowIndex).abs() + (column - columnIndex).abs() - 1;
        final distanceValue = convertDistanceToShade(distance, maxBrightness: maxBrightness);
        if (distanceValue >= currentValue) continue;
        gridNodeBake[nodeIndex] = distanceValue;
        // gridNodeBake[gridNodeIndexZRC(z, row, column)] = distanceValue;
      }
    }
  }
}

void applyEmissionDynamic({
  required int zIndex,
  required int rowIndex,
  required int columnIndex,
  required int maxBrightness,
}){
  final radius = Shade.Pitch_Black;
  final zMin = max(zIndex - radius, 0);
  final zMax = min(zIndex + radius, gridTotalZ);
  final rowMin = max(rowIndex - radius, 0);
  final rowMax = min(rowIndex + radius, gridTotalRows);
  final columnMin = max(columnIndex - radius, 0);
  final columnMax = min(columnIndex + radius, gridTotalColumns);

  for (var z = zMin; z < zMax; z++){
    for (var row = rowMin; row < rowMax; row++){
      for (var column = columnMin; column < columnMax; column++) {
        final nodeIndex = gridNodeIndexZRC(z, row, column);
        final distance = (z - zIndex).abs() + (row - rowIndex).abs() + (column - columnIndex).abs() - 1;
        final shade = convertDistanceToShade(distance, maxBrightness: maxBrightness);

        if (gridNodeShade[nodeIndex] <= shade) return;
        gridNodeShade[nodeIndex] = shade;
      }
    }
  }
}
