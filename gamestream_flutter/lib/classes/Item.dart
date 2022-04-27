import 'package:lemon_math/library.dart';

class Item extends Vector2 {
  int type;
  Item({required this.type, required double x, required double y}): super(x, y);
}