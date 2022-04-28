import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:bleed_common/library.dart';

Vector2 getTilePosition({required int row, required int column}){
  return Vector2(
    getTileWorldX(row, column),
    getTileWorldY(row, column),
  );
}

double get mouseUnprojectPositionX => projectedToWorldX(mouseWorldX, mouseWorldY);

double get mouseUnprojectPositionY =>
    projectedToWorldY(mouseWorldX, mouseWorldY);

int get mouseColumn {
  return mouseUnprojectPositionX ~/ tileSize;
}

int get mouseRow {
  return mouseUnprojectPositionY ~/ tileSize;
}

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}
