

import '../classes.dart';
import '../maths.dart';

void applyForce(PhysicsGameObject gameObject, double rotation, double amount){
  gameObject.xVel += adj(rotation, amount);
  gameObject.yVel += opp(rotation, amount);
}