
import 'package:bleed_common/library.dart';
import 'package:lemon_engine/engine.dart';

class GameConvert {
  static int distanceToShade(int distance, {
    int maxBrightness = Shade.Very_Bright
  }) =>
      Engine.clamp(distance - 1, maxBrightness, Shade.Pitch_Black);

  static double convertRowColumnZToRenderY(int row, int column, int z){
    return ((row + column) * tileSizeHalf) - (z * tileHeight);
  }

  static double convertRowColumnToRenderY(int row, int column){
    return (row + column) * tileSizeHalf;
  }

  static double convertRowColumnToRenderX(int row, int column){
    return (row - column) * tileSizeHalf;
  }

  static double convertWorldToGridX(double x, double y) {
    return x + y;
  }

  static double convertWorldToGridY(double x, double y) {
    return y - x;
  }

  static int convertWorldToRow(double x, double y, double z) {
    return (x + y + z) ~/ tileSize;
  }

  static int convertWorldToColumn(double x, double y, double z) {
    return (y - x + z) ~/ tileSize;
  }
}