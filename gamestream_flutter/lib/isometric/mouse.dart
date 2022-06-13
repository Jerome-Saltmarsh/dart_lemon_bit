
import 'package:bleed_common/library.dart';
import 'package:lemon_engine/engine.dart';

double get mouseGridX => convertWorldToGridX(mouseWorldX, mouseWorldY);
double get mouseGridY => convertWorldToGridY(mouseWorldX, mouseWorldY);

int get mouseColumn {
  return mouseGridX ~/ tileSize;
}

int get mouseRow {
  return mouseGridY ~/ tileSize;
}

double get mouseRowPercentage {
  return (convertWorldToGridY(mouseWorldX, mouseWorldY) / tileSize) % 1.0;
}
