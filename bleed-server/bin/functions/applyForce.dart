import '../classes/GameObject.dart';
import '../maths.dart';

void applyForce(Velocity gameObject, double rotation, double amount){
  gameObject.xv += adj(rotation, amount);
  gameObject.yv += opp(rotation, amount);
}