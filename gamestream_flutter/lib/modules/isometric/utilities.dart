import 'package:bleed_common/library.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

Vector2 getTilePosition({required int row, required int column}){
  return Vector2(
    getTileWorldX(row, column),
    getTileWorldY(row, column),
  );
}

double get mouseGridX => convertWorldToGridX(mouseWorldX, mouseWorldY);

double get mouseGridY =>
    convertWorldToGridY(mouseWorldX, mouseWorldY);

int get mouseColumn {
  return mouseGridX ~/ tileSize;
}

int get mouseRow {
  return mouseGridY ~/ tileSize;
}

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}
