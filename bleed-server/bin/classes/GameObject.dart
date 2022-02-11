
import 'dart:math';

import 'package:lemon_math/Vector2.dart';

class GameObject extends Vector2 {

  static int _idCount = 0;

  // state
  int id = _idCount++;
  double z = 0;
  double xv = 0;
  double yv = 0;
  double zv = 0;
  double radius = 0;
  bool collidable = true;
  bool active = true;

  // properties
  double get angle => atan2(xv, yv);
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;
  bool get inactive => !active;

  // constructor
  GameObject(double x, double y,
      {this.z = 0, this.xv = 0, this.yv = 0, this.zv = 0, this.radius = 5}) : super(x, y);

  // methods
  void assignNewId(){
    id = _idCount++;
  }
}