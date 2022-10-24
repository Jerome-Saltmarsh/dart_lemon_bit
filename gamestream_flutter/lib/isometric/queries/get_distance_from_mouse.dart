import 'package:gamestream_flutter/classes/vector3.dart';
import 'package:lemon_engine/engine.dart';

double getDistanceFromMouse(Vector3 value){
  return Engine.distanceFromMouse(value.renderX, value.renderY);
}