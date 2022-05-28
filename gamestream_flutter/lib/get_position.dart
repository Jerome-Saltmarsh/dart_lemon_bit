import 'package:lemon_math/library.dart';

final _position = Vector2(0, 0);

Position getPosition(double x, double y){
  _position.x = x;
  _position.y = y;
  return _position;
}