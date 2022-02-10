import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

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

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}

int getRow(double x, double y){
  return (x + y) ~/ tileSize;
  // return projectedToWorldY(x, y) ~/ tileSize;
}

int getColumn(double x, double y){
  return (y - x) ~/ tileSize;
  // return projectedToWorldX(x, y) ~/ tileSize;
}


