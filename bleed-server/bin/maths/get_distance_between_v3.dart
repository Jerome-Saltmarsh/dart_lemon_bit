

import '../classes/position3.dart';
import 'get_distance_v3.dart';

double getDistanceBetweenV3(Position3 a, Position3 b){
  return getDistanceV3(a.x, a.y, a.z, b.x, b.y, b.z);
}