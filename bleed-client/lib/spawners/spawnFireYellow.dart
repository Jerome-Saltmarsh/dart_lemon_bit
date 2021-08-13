
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/spawners/spawnParticle.dart';
import 'package:bleed_client/utils.dart';

double get _xyVel => giveOrTake(2);
double get _zVel => randomBetween(0.05, 0.1);
int get _duration => randomInt(10, 25);
double _scale = 1;
double _scaleV = 0.035;

void spawnFireYellow(double x, double y){
  spawnParticle(ParticleType.FireYellow, x, y, 0, _xyVel, _xyVel, _zVel, 0, _duration, _scale, _scaleV);
}
