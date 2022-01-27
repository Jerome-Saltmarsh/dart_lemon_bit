import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/modules/modules.dart';

final tileSize = isometric.constants.tileSize;
final halfTileSize = isometric.constants.halfTileSize;

double perspectiveProjectX(double x, double y) {
  return -y + x;
}

double perspectiveProjectY(double x, double y) {
  return x + y;
}

double projectedToWorldX(double x, double y) {
  return y - x;
}

double projectedToWorldY(double x, double y) {
  return x + y;
}

double getTileWorldX(int row, int column){
  return perspectiveProjectX(row * halfTileSize, column * halfTileSize);
}

double getTileWorldY(int row, int column){
  return perspectiveProjectY(row * halfTileSize, column * halfTileSize);
}

Vector2 getTilePosition({required int row, required int column}){
  return Vector2(
    getTileWorldX(row, column),
    getTileWorldY(row, column),
  );
}

double get mouseUnprojectPositionX =>    projectedToWorldX(mouseWorldX, mouseWorldY);

double get mouseUnprojectPositionY =>
    projectedToWorldY(mouseWorldX, mouseWorldY);

int get mouseColumn {
  return mouseUnprojectPositionX ~/ isometric.constants.tileSize;
}

int get mouseRow {
  return mouseUnprojectPositionY ~/ isometric.constants.tileSize;
}

Tile getTile(int row, int column){
  if (row < 0) return Tile.Boundary;
  if (column < 0) return Tile.Boundary;
  if (row >= modules.isometric.state.totalRows.value) return Tile.Boundary;
  if (column >= modules.isometric.state.totalColumns.value) return Tile.Boundary;
  return isometric.state.tiles[row][column];
}

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}
