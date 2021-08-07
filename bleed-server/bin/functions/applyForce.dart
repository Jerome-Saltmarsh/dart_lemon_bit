import '../classes.dart';
import '../maths.dart';

void applyForce(GameObject gameObject, double rotation, double amount){
  gameObject.xv += adj(rotation, amount);
  gameObject.yv += opp(rotation, amount);
}