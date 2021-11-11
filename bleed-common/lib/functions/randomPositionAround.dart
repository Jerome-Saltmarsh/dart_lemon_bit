
import '../../maths.dart';
import '../classes/Vector2.dart';
import 'randomRadian.dart';

Vector2 randomPositionAround(double x, double y, double radius){
  double r = randomRadian();
  return Vector2(x + adj(r, radius), y + opp(r, radius));
}