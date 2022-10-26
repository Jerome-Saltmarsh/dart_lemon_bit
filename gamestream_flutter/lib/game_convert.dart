
import 'library.dart';

class GameConvert {
  static int distanceToShade(int distance, {
    int maxBrightness = Shade.Very_Bright
  }) =>
      Engine.clamp(distance - 1, maxBrightness, Shade.Pitch_Black);

  static double rowColumnZToRenderY(int row, int column, int z){
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

  static double convertV3ToRenderX(Vector3 v3) => getRenderX(v3.x, v3.y, v3.z);
  static double convertV3ToRenderY(Vector3 v3) => getRenderY(v3.x, v3.y, v3.z);

  static double getRenderX(double x, double y, double z) => (x - y) * 0.5;
  static double getRenderY(double x, double y, double z) => ((y + x) * 0.5) - z;
}