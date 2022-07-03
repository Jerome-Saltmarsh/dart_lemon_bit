import 'dart:math';

import 'package:bleed_common/Rain.dart';
import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_off.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/light_mode.dart';
import 'package:gamestream_flutter/isometric/particle_emitters.dart';
import 'package:gamestream_flutter/isometric/render/weather.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'grid/convert/convert_hour_to_ambient.dart';

final gridShadows = Watch(true, onChanged: (bool value){
  apiGridActionRefreshLighting();
});

final ambient = Watch(Shade.Bright, onChanged: _onAmbientChanged);

final grid = <List<List<int>>>[];
final gridLightBake = <List<List<int>>>[];
final gridLightDynamic = <List<List<int>>>[];
var gridTotalZ = 0;
var gridTotalRows = 0;
var gridTotalColumns = 0;

var gridRowLength = 0.0;
var gridColumnLength = 0.0;


void toggleShadows () => gridShadows.value = !gridShadows.value;

void refreshAmbient(){
  ambient.value = convertHourToAmbient(hours.value);
}

void gridEmitDynamic(int z, int row, int column, {required int maxBrightness, int radius = 5}){
  _applyEmission(
      map: gridLightDynamic,
      zIndex: z,
      rowIndex: row,
      columnIndex: column,
      maxBrightness: maxBrightness,
      radius: radius,
  );
}

void _onAmbientChanged(int ambient) {
  apiGridActionRefreshLighting();
}

void onGridChanged(){
  refreshGridMetrics();
  gridWindResetToAmbient();
  apiGridActionRefreshLighting();

  if (rainingWatch.value != Rain.None) {
     apiGridActionRainOff();
     apiGridActionRainOn();
  }

  refreshParticleEmitters();
}

void refreshParticleEmitters() {
  particleEmitters.clear();
  gridForEachOfType(
      GridNodeType.Fireplace,
      (z, row, column, type) {
        globalParticleEmittersActionAddSmokeEmitter(z, row, column);
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
        if (t != type) continue;
        handler(zIndex, rowIndex, columnIndex, t);
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
        final t = rowValues[columnIndex];
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


void apiGridActionRefreshLighting(){
  _setLightMapValue(gridLightBake, ambient.value);
  _setLightMapValue(gridLightDynamic, ambient.value);
  if (gridShadows.value){
    _applyShadows();
  }
  _applyBakeMapEmissions();
}

void _applyShadows(){
  if (ambient.value > Shade.Very_Bright) return;
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
  final current = ambient.value;
  final shadowShade = current >= Shade.Pitch_Black ? current : current + 1;

  for (var z = 0; z < gridTotalZ; z++) {
    for (var row = 0; row < gridTotalRows; row++){
      for (var column = 0; column < gridTotalColumns; column++){
        final tile = grid[z][row][column];
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
          final shade = gridLightBake[projectionZ][projectionRow][projectionColumn];
          if (shade < shadowShade){
            if (isEmpty(grid[projectionZ + 1][projectionRow][projectionColumn])){
              gridLightBake[projectionZ][projectionRow][projectionColumn] = shadowShade;
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
        GridNodeType.Bricks,
        GridNodeType.Grass,
        GridNodeType.Grass_Long,
        GridNodeType.Stairs_South,
        GridNodeType.Stairs_West,
        GridNodeType.Stairs_East,
        GridNodeType.Stairs_North,
  ].contains(type);
}

bool isEmpty(int type){
  return type == GridNodeType.Empty || type == GridNodeType.Rain_Falling || type == GridNodeType.Rain_Landing;
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
    final type = grid[z][row][column];
    if (type != GridNodeType.Empty &&
        type != GridNodeType.Tree_Top &&
        type != GridNodeType.Rain_Falling &&
        type != GridNodeType.Rain_Landing
    ) return false;
  }
  return true;
}

void refreshGridMetrics(){
  gridTotalZ = grid.length;
  gridTotalRows = grid[0].length;
  gridTotalColumns = grid[0][0].length;

  gridRowLength = gridTotalRows * tileSize;
  gridColumnLength = gridTotalColumns * tileSize;
}

void _setLightMapValue(List<List<List<int>>> map, int value){
  if (
      map.length != gridTotalZ ||
      map[0].length != gridTotalRows ||
      map[0][0].length != gridTotalColumns
  ){
    map.clear();
    for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
      final plain = <List<int>>[];
      map.add(plain);
      for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
        final row = <int> [];
        plain.add(row);
        for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
          row.add(value);
        }
      }
    }
    return;
  }

  for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
        map[zIndex][rowIndex][columnIndex] = value;
      }
    }
  }
}

void _applyBakeMapEmissions() {
  for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
        final type = grid[zIndex][rowIndex][columnIndex];
        if (!const [GridNodeType.Torch, GridNodeType.Player_Spawn, GridNodeType.Fireplace].contains(type)) continue;
        if (gridLightBake[zIndex][rowIndex][columnIndex] <= Shade.Very_Bright) continue;
        _applyEmission(
          map: gridLightBake,
          zIndex: zIndex,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
          maxBrightness: Shade.Very_Bright,
        );
      }
    }
  }
}


void _applyEmission({
  required List<List<List<int>>> map,
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
        final currentValue = map[z][row][column];
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
        final distanceValue = _convertDistanceToShade(distance, maxBrightness: maxBrightness);
        if (distanceValue >= currentValue) continue;
        map[z][row][column] = distanceValue;
      }
    }
  }
}

int _convertDistanceToShade(int distance, {int maxBrightness = Shade.Very_Bright}){
   return clamp(distance - 1, maxBrightness, 6);
}


int getGridTypeAtXYZ(double x, double y, double z){
   final plain = z ~/ tileSizeHalf;
   final row = x ~/ tileSize;
   final column = y ~/ tileSize;

   if (plain < 0) return GridNodeType.Boundary;
   if (row < 0) return GridNodeType.Boundary;
   if (column < 0) return GridNodeType.Boundary;

   if (plain >= gridTotalZ) return GridNodeType.Boundary;
   if (row >= gridTotalRows) return GridNodeType.Boundary;
   if (column >= gridTotalColumns) return GridNodeType.Boundary;

   return grid[plain][row][column];
}