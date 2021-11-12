
import '../common/ItemType.dart';
import '../settings.dart';
import 'GameObject.dart';

class Item extends GameObject {
  ItemType type;
  int duration = settings.itemDuration;
  Item({required this.type, required double x, required double y}) : super(x, y);
}

