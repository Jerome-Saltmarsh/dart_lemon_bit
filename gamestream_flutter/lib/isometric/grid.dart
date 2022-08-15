import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
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

var grid = <List<List<Node>>>[];
var gridTotalZ = 0;
var gridTotalRows = 0;
var gridTotalColumns = 0;

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

Node getNodeXYZ(double x, double y, double z){
  final plain = z ~/ tileSizeHalf;
  if (plain < 0) return Node.boundary;
  if (plain >= gridTotalZ) return Node.empty;
  final row = x ~/ tileSize;
  if (row < 0) return Node.boundary;
  if (row >= gridTotalRows) return Node.boundary;
  final column = y ~/ tileSize;
  if (column < 0) return Node.boundary;
  if (column >= gridTotalColumns) return Node.boundary;
  return grid[plain][row][column];
}

Node getNode(int z, int row, int column) {
  if (outOfBounds(z, row, column)) return Node.boundary;
  return grid[z][row][column];
}

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
           final node = getNode(z, row, column);
           if (node is NodeTreeTop){
             node.bottom = getNode(z - 1, row, column);
           }
       }
    }
  }
}

void refreshParticleEmitters() {
  particleEmitters.clear();
  gridForEachOfType(
      GridNodeType.Fireplace,
      (z, row, column, type) {
        addSmokeEmitter(z, row, column);
      }
  );

  gridForEachOfType(
      GridNodeType.Chimney,
          (z, row, column, type) {
        if (!getNode(z + 1, row, column).isEmpty) return;
        addSmokeEmitter(z + 1, row, column);
      }
  );
}

void gridForEachOfType(
    int type, Function(int z, int row, int column, int type) handler) {
  for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
    final zValues = grid[zIndex];
    for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
      final rowValues = zValues[rowIndex];
      for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
        final t = rowValues[columnIndex];
        if (t.type != type) continue;
        handler(zIndex, rowIndex, columnIndex, t.type);
      }
    }
  }
}

void gridForEach({
  required bool Function(int type) where,
  required Function(int z, int row, int column, int type) apply,
}) {
  for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
    final zValues = grid[zIndex];
    for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
      final rowValues = zValues[rowIndex];
      for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
        final t = rowValues[columnIndex].type;
        if (!where(t)) continue;
        apply(zIndex, rowIndex, columnIndex, t);
      }
    }
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
  for (final z in grid){
    for (final row in z){
      for (final column in row){
        column.bake = shade;
        column.shade = shade;
      }
    }
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
        final tile = grid[z][row][column];
        if (!_castesShadow(tile.type)) continue;
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
          final shade = grid[projectionZ][projectionRow][projectionColumn].bake;
          if (shade < shadowShade){
            if (grid[projectionZ + 1][projectionRow][projectionColumn].isEmpty){
              grid[projectionZ][projectionRow][projectionColumn].bake = shadowShade;
            }
          }
          // final type = grid[projectionZ][projectionRow][projectionColumn];
          // if (type == GridNodeType.Tree_Bottom){
          //   gridLightBake[projectionZ - 1][projectionRow][projectionColumn] = shadowShade;
          // }
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
        GridNodeType.Bricks,
        GridNodeType.Brick_Top,
        GridNodeType.Grass,
        GridNodeType.Stairs_South,
        GridNodeType.Stairs_West,
        GridNodeType.Stairs_East,
        GridNodeType.Stairs_North,
        GridNodeType.Roof_Tile_South,
        GridNodeType.Roof_Tile_North,
        GridNodeType.Bau_Haus_Roof_South,
        GridNodeType.Bau_Haus_Roof_North,
  ].contains(type);
}

bool gridIsUnderSomething(int z, int row, int column){
  for (var zIndex = z + 1; zIndex < gridTotalZ; zIndex++){
    if (grid[zIndex][row][column] != GridNodeType.Empty) return false;
  }
  return true;
}

bool gridIsPerceptible(int zIndex, int row, int column){
  for (var z = zIndex + 1; z < gridTotalZ; z += 2){
    row++;
    column++;
    if (row >= gridTotalRows) break;
    if (column >= gridTotalColumns) break;
    if (grid[z][row][column].blocksPerception) return false;
  }
  return true;
}

void refreshGridMetrics(){
  gridTotalZ = grid.length;
  gridTotalRows = grid[0].length;
  gridTotalColumns = grid[0][0].length;

  gridRowLength = gridTotalRows * tileSize;
  gridColumnLength = gridTotalColumns * tileSize;
  gridZLength = gridTotalZ * tileHeight;
}

void applyBakeMapEmissions() {
  for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
        if (!grid[zIndex][rowIndex][columnIndex].emitsLight) continue;
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
        final node = grid[z][row][column];
        if (!node.isShadable) continue;
        final currentValue = node.bake;
        var distance = 0;
        if (lightModeRadial.value){
          distance = (z - zIndex).abs() + (row - rowIndex).abs() + (column - columnIndex).abs() - 1;
        } else {
          final distanceZ = (z - zIndex).abs();
          final distanceRow = (row - rowIndex).abs();
          final distanceColumn = (column - columnIndex).abs();
          distance = distanceZ;
          if (distanceRow > distanceZ){
            distance = distanceRow;
          }
          if (distanceColumn > distance){
            distance = distanceColumn;
          }
        }
        final distanceValue = convertDistanceToShade(distance, maxBrightness: maxBrightness);
        if (distanceValue >= currentValue) continue;
        node.bake = distanceValue;
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
  final radius = Shade.Pitch_Black - maxBrightness;
  final zMin = max(zIndex - radius, 0);
  final zMax = min(zIndex + radius, gridTotalZ);
  final rowMin = max(rowIndex - radius, 0);
  final rowMax = min(rowIndex + radius, gridTotalRows);
  final columnMin = max(columnIndex - radius, 0);
  final columnMax = min(columnIndex + radius, gridTotalColumns);

  for (var z = zMin; z < zMax; z++){
    final plain = grid[z];
    for (var row = rowMin; row < rowMax; row++){
      final r = plain[row];
      for (var column = columnMin; column < columnMax; column++) {
        final node = r[column];
        if (!node.isShadable) continue;
        var distance = 0;
        if (lightModeRadial.value){
          distance = (z - zIndex).abs() + (row - rowIndex).abs() + (column - columnIndex).abs() - 1;
        } else {
          final distanceZ = (z - zIndex).abs();
          final distanceRow = (row - rowIndex).abs();
          final distanceColumn = (column - columnIndex).abs();
          distance = distanceZ;
          if (distanceRow > distanceZ){
            distance = distanceRow;
          }
          if (distanceColumn > distance){
            distance = distanceColumn;
          }
        }
        node.applyLight(convertDistanceToShade(distance, maxBrightness: maxBrightness));
      }
    }
  }
}
