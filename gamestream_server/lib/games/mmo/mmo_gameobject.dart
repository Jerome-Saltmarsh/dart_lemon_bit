
import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric.dart';

class MMOGameObject extends IsometricGameObject {

  final MMOItem item;

  MMOGameObject({
    required super.x,
    required super.y,
    required super.z,
    required super.id,
    required this.item,
  }) : super(type: item.type, subType: item.subType, team: TeamType.Neutral);

}