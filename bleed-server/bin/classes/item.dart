
import 'collider.dart';

class Item extends Collider {
  int type;
  int duration = 200;
  bool timed;

  Item({
    required this.type,
    required double x,
    required double y,
    required double z,
    bool this.timed = false
  }) : super(x: x, y: y, z: z, radius: 20);
}

