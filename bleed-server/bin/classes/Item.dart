
import '../common/CommonSettings.dart';
import '../settings.dart';
import 'Collider.dart';

class Item extends Collider {
  int type;
  int duration = settings.itemDuration;
  bool timed;

  Item({
    required this.type,
    required double x,
    required double y,
    bool this.timed = false
  }) : super(x: x, y: y, radius: commonSettings.itemRadius);
}

