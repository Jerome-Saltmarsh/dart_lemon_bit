import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';

import 'convert/convert_distance_to_shade.dart';
import 'watches/raining.dart';

void actionSetAmbientShadeToHour(){
  GameState.ambientShade.value = Shade.fromHour(GameState.hours.value);
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
  for (var zIndex = 0; zIndex < GameState.nodesTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < GameState.nodesTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < GameState.nodesTotalColumns; columnIndex++) {
        apply(zIndex, rowIndex, columnIndex);
      }
    }
  }
}

void refreshLighting(){
  GameState.resetGridToAmbient();
  if (GameState.gridShadows.value){
    _applyShadows();
  }
  applyBakeMapEmissions();
}

void _applyShadows(){
  if (GameState.ambientShade.value > Shade.Very_Bright) return;
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
  final current = GameState.ambientShade.value;
  final shadowShade = current >= Shade.Pitch_Black ? current : current + 1;

  for (var z = 0; z < GameState.nodesTotalZ; z++) {
    for (var row = 0; row < GameState.nodesTotalRows; row++){
      for (var column = 0; column < GameState.nodesTotalColumns; column++){
        // final tile = grid[z][row][column];
        final index = GameState.getNodeIndexZRC(z, row, column);
        final tile = GameState.nodesType[index];
        if (!castesShadow(tile)) continue;
        var projectionZ = z + directionZ;
        var projectionRow = row + directionRow;
        var projectionColumn = column + directionColumn;
        while (
            projectionZ >= 0 &&
            projectionRow >= 0 &&
            projectionColumn >= 0 &&
            projectionZ < GameState.nodesTotalZ &&
            projectionRow < GameState.nodesTotalRows &&
            projectionColumn < GameState.nodesTotalColumns
        ) {
          final shade = GameState.nodesBake[index];
          if (shade < shadowShade){
            if (gridNodeZRCType(projectionZ + 1, projectionRow, projectionColumn) == NodeType.Empty){
              GameState.nodesBake[index] = shadowShade;
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
  if (GameState.outOfBounds(z, row, column)) return false;
  for (var zIndex = z + 1; zIndex < GameState.nodesTotalZ; zIndex++){
    if (!gridNodeZRCTypeRainOrEmpty(z, row, column)) return false;
  }
  return true;
}

bool gridIsPerceptible(int index){
  if (index < 0) return true;
  if (index >= GameState.nodesTotal) return true;
  while (true){
    index += GameState.nodesArea;
    index++;
    index += GameState.nodesTotalColumns;
    if (index >= GameState.nodesTotal) return true;
    if (GameState.nodesOrientation[index] != NodeOrientation.None){
      return false;
    }
  }
}

void refreshGridMetrics(){
  // gridTotalZ = grid.length;
  // gridTotalRows = grid[0].length;
  // gridTotalColumns = grid[0][0].length;

  GameState.nodesLengthRow = GameState.nodesTotalRows * tileSize;
  GameState.nodesLengthColumn = GameState.nodesTotalColumns * tileSize;
  GameState.nodesLengthZ = GameState.nodesTotalZ * tileHeight;
}

void applyBakeMapEmissions() {
  for (var zIndex = 0; zIndex < GameState.nodesTotalZ; zIndex++) {
    for (var rowIndex = 0; rowIndex < GameState.nodesTotalRows; rowIndex++) {
      for (var columnIndex = 0; columnIndex < GameState.nodesTotalColumns; columnIndex++) {
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

  for (final gameObject in GameState.gameObjects){
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
  final zMax = min(zIndex + radius, GameState.nodesTotalZ);
  final rowMin = max(rowIndex - radius, 0);
  final rowMax = min(rowIndex + radius, GameState.nodesTotalRows);
  final columnMin = max(columnIndex - radius, 0);
  final columnMax = min(columnIndex + radius, GameState.nodesTotalColumns);

  for (var z = zMin; z < zMax; z++){
    for (var row = rowMin; row < rowMax; row++){
      for (var column = columnMin; column < columnMax; column++) {
        final nodeIndex = GameState.getNodeIndexZRC(z, row, column);
        var distance = (z - zIndex).abs() + (row - rowIndex).abs() + (column - columnIndex).abs() - 1;
        final distanceValue = convertDistanceToShade(distance, maxBrightness: maxBrightness);
        if (distanceValue >= GameState.nodesBake[nodeIndex]) continue;
        GameState.nodesBake[nodeIndex] = distanceValue;
        GameState.nodesShade[nodeIndex] = distanceValue;
      }
    }
  }
}

