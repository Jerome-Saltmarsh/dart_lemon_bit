
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/spawners/spawnParticle.dart';
import 'package:bleed_client/utils.dart';

double get xyVel => giveOrTake(2);
double get zVel => randomBetween(0.05, 0.1);
int get duration => randomInt(10, 25);
double scale = 1;
double scaleV = 0.035;

void spawnFireYellow(double x, double y){
  spawnParticle(ParticleType.FireYellow, x, y, 0, xyVel, xyVel, zVel, 0, duration, scale, scaleV);
}
