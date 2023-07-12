
import 'package:gamestream_server/isometric.dart';

class MMOItem extends IsometricGameObject {
  var characterDamage = 0;

  MMOItem({
    required super.x,
    required super.y,
    required super.z,
    required super.team,
    required super.type,
    required super.subType,
    required super.id,
  });
}