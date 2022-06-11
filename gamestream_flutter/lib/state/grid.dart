
import 'dart:math';
import 'package:lemon_math/library.dart';
import 'package:bleed_common/grid_node_type.dart';

final grid = <List<List<int>>>[];
final gridLightBake = <List<List<int>>>[];
final gridLightDynamic = <List<List<int>>>[];
var gridTotalZ = 0;
var gridTotalRows = 0;
var gridTotalColumns = 0;

void gridSetAmbient(int ambient) {
  print("gridSetAmbient($ambient)");
  _refreshGridMetrics();
  _setLightMapValue(gridLightBake, ambient);
  _setLightMapValue(gridLightDynamic, ambient);
  _applyBakeMapEmissions();
}

void gridEmitDynamic(int z, int row, int column){
  _applyEmission(
      map: gridLightDynamic,
      zIndex: z,
      rowIndex: row,
      columnIndex: column
  );
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
        if (type != GridNodeType.Torch) continue;
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
        final distance = (z - zIndex).abs() + (row - rowIndex).abs() + (column - columnIndex).abs();
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