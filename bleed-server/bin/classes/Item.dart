
import 'Collider.dart';

class Item extends Collider {
  int type;
  int duration = 200;
  bool timed;

  Item({
    required this.type,
    required double x,
    required double y,
    bool this.timed = false
  }) : super(x: x, y: y, radius: 20);
}

