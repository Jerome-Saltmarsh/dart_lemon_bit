
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/enums.dart';

class InteractableNpc {
  CharacterState state;
  Direction direction;
  double x;
  double y;
  int frame;
  String name;

  InteractableNpc({this.state, this.direction, this.x, this.y, this.frame, this.name});
}