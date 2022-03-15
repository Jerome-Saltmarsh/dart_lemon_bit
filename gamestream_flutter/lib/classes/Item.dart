
import 'package:gamestream_flutter/common/ItemType.dart';
import 'package:lemon_math/Vector2.dart';

class Item extends Vector2 {
  ItemType type;
  Item({required this.type, required double x, required double y}): super(x, y);
}