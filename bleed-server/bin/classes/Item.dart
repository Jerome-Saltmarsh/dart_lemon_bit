
import '../common/CommonSettings.dart';
import '../settings.dart';
import 'GameObject.dart';

class Item extends GameObject {
  int type;
  int duration = settings.itemDuration;
  bool timed;

  Item({
    required this.type,
    required double x,
    required double y,
    bool this.timed = false
  }) : super(x, y, radius: commonSettings.itemRadius);
}

