
import '../classes.dart';
import '../common/ItemType.dart';

class Item extends GameObject {
  ItemType type;
  Item({required this.type, required double x, required double y}) : super(x, y);
}

