
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/isometric/isometric_position.dart';

double getDistanceBetweenV3(IsometricPosition a, IsometricPosition b){
  return getDistanceV3(a.x, a.y, a.z, b.x, b.y, b.z);
}