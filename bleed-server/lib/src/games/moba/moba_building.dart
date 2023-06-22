
import 'package:bleed_server/src/isometric/isometric_gameobject.dart';

class MobaBuilding extends IsometricGameObject {
  var health = 0;
  final int healthMax;

  MobaBuilding({
    required this.healthMax,
    required super.x,
    required super.y,
    required super.z,
    required super.type,
    required super.id,
  });
}