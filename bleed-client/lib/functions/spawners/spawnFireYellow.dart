import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/utils.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomInt.dart';

import 'spawnParticle.dart';


void spawnFireYellow(double x, double y){
  spawnParticle(
    type: ParticleType.FireYellow,
    x: x,
    y: y,
    z: 0,
    xv: giveOrTake(2),
    yv: giveOrTake(2),
    weight: 0,
    duration: randomInt(10, 25),
    scale: 1,
    scaleV: 0.035
  );
}
