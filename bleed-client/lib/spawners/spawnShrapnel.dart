
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/spawners/spawnParticle.dart';
import 'package:bleed_client/utils.dart';

double get xyVel => giveOrTake(2);
double get zVel => randomBetween(0.1, 0.4);
int get duration => randomInt(400, 600);
double get scale => randomBetween(0.6, 1.25);

void spawnShrapnel(double x, double y){
  spawnParticle(ParticleType.Shrapnel, x, y, 0, xyVel, xyVel, zVel, 0.5, duration, scale, 0);
}