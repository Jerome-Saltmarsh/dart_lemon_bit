import 'package:lemon_math/Vector2.dart';

class Crate extends Vector2 {
  int deactiveDuration = 0;

  bool get active => deactiveDuration <= 0;

  Crate({required double x, required double y}) : super(x, y);
}