import 'package:lemon_engine/engine.dart';

import '../classes/vector3.dart';

double getDistanceFromMouse(Vector3 value){
  return distanceFromMouse(value.renderX, value.renderY);
}