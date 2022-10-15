
import 'package:gamestream_flutter/isometric/classes/vector3.dart';

class RenderUtil {
  static double getRenderX(Vector3 v3) => (v3.x - v3.y) * 0.5;
  static double getRenderY(Vector3 v3) => ((v3.y + v3.x) * 0.5) - v3.z;
}