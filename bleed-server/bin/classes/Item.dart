
import '../classes.dart';
import '../common/ItemType.dart';
import '../instances/settings.dart';

class Item extends GameObject {
  ItemType type;
  int duration = settings.itemDuration;
  Item({required this.type, required double x, required double y}) : super(x, y);
}

