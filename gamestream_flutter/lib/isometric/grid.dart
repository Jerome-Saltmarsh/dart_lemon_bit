
import 'dart:math';

import 'package:bleed_common/Shade.dart';
import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/light_mode.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'effects.dart';

final gridShadows = Watch(true, onChanged: (bool value){
  refreshLighting();
});
final ambient = Watch(Shade.Bright, onChanged: _onAmbientChanged);
final grid = <List<List<int>>>[];
final gridLightBake = <List<List<int>>>[];
final gridLightDynamic = <List<List<int>>>[];
var gridTotalZ = 0;
var gridTotalRows = 0;
var gridTotalColumns = 0;
var gridTotalColumnsMinusOne = gridTotalColumns - 1;

void gridEmitDynamic(int z, int row, int column){
  _applyEmission(
      map: gridLightDynamic,
      zIndex: z,
      rowIndex: row,
      columnIndex: column
  );
}

void _onAmbientChanged(int ambient) {
  refreshLighting();
}

void refreshLighting(){
  _refreshGridMetrics();
  _setLightMapValue(gridLightBake, ambient.value);
  _setLightMapValue(gridLightDynamic, ambient.value);
  if (gridShadows.value){
    gridApplyShadows();
  }
  _applyBakeMapEmissions();
}

void gridApplyShadows(){
  if (ambient.value > Shade.Very_Bright) return;
  // final hour = hours.value;
  _applyShadowsMidAfternoon();
  // if (hour < 11) return _applyShadowsMorning();
  // if (hour < 13) return _applyShadowsAfternoon();
  // if (hour < 15) return _applyShadowsEvening();
}

void _applyShadowsMorning() {
  _applyShadowAt(directionZ: -1, directionRow: 0, directionColumn: 1, maxDistance: 1);
}

void _applyShadowsAfternoon() {
  _applyShadowAt(directionZ: -1, directionRow: 1, directionColumn: 0, maxDistance: 1);
}

void _applyShadowsMidAfternoon() {
  _applyShadowAt(directionZ: -1, directionRow: 0, directionColumn: 0, maxDistance: 1);
}

void _applyShadowsEvening() {
  _applyShadowAt(directionZ: -1, directionRow: 0, directionColumn: -1, maxDistance: 1);
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
        if (tile != GridNodeType.Bricks && tile != GridNodeType.Grass && !GridNodeType.isStairs(tile)) continue;
        var projectionZ = z + directionZ;
        var projectionRow = row + directionRow;
        var projectionColumn = column + directionColumn;
        var distance = 0;
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
            if (grid[projectionZ + 1][projectionRow][projectionColumn] == GridNodeType.Empty){
              gridLightBake[projectionZ][projectionRow][projectionColumn] = shadowShade;
            }
          }
          projectionZ += directionZ;
          distance++;
          // if (distance < maxDistance){
            projectionRow += directionRow;
            projectionColumn += directionColumn;
          // }
        }
      }
    }
  }
}

void gridRefreshDynamicLight(){
  for (var z = 0; z < gridTotalZ; z++) {
     for (var row = 0; row < gridTotalRows; row++) {
        for (var column = 0; column < gridTotalColumns; column++) {
           gridLightDynamic[z][row][column] = gridLightBake[z][row][column];
        }
     }
  }
}

void _refreshGridMetrics(){
  gridTotalZ = grid.length;
  gridTotalRows = grid[0].length;
  gridTotalColumns = grid[0][0].length;
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
        if (type != GridNodeType.Torch && type != GridNodeType.Player_Spawn) continue;
        if (gridLightBake[zIndex][rowIndex][columnIndex] <= Shade.Very_Bright) continue;
        _applyEmission(
          map: gridLightBake,
          zIndex: zIndex,
          rowIndex: rowIndex,
          columnIndex: columnIndex
        );
      }
    }
  }
}

void _applyEmission({
  required List<List<List<int>>> map,
  required int zIndex,
  required int rowIndex,
  required int columnIndex
}){
  final radius = 5;
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
        final distanceValue = _convertDistanceToShade(distance);
        if (distanceValue >= currentValue) continue;
        map[z][row][column] = distanceValue;
      }
    }
  }
}

int _convertDistanceToShade(int distance){
   return clamp(distance - 1, 0, 6);
}

void applyEmissionFromEffects() {
  for (final effect in effects) {
    if (!effect.enabled) continue;
    final percentage = effect.percentage;
    if (percentage < 0.33) {
      break;
    }
    if (percentage < 0.66) {
      break;
    }
  }
}