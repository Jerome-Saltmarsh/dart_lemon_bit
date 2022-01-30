import 'package:bleed_client/functions/emit/emitPixel.dart';
import 'package:bleed_client/functions/spawners/spawnZombieLeg.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomBool.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

import '../audio.dart';
import '../common/GameEventType.dart';
import '../spawn.dart';
import 'spawnBulletHole.dart';
import 'spawners/spawnArm.dart';
import 'spawners/spawnBlood.dart';
import 'spawners/spawnOrgan.dart';
import 'spawners/spawnShell.dart';
import 'spawners/spawnShotSmoke.dart';
import 'spawners/spawnShrapnel.dart';
import 'spawners/spawnZombieHead.dart';


void emitPixelExplosion(double x, double y, {int amount = 10}) {
  for (int i = 0; i < amount; i++) {
    emitPixel(x: x, y: y);
  }
}
