import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/functions/spawners/spawnFireYellow.dart';
import 'package:bleed_client/functions/spawners/spawnShrapnel.dart';
import 'package:bleed_client/functions/spawners/spawnSmoke.dart';
import 'package:bleed_client/render/state/floatingText.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomInt.dart';

import 'audio.dart';
import 'functions/spawnBulletHole.dart';

int get shrapnelCount => randomInt(4, 15);

void spawnExplosion(double x, double y) {
  game.explosions.add(Explosion(x: x, y: y, type: ExplosionType.Explosion));
  playAudioExplosion(x, y);
  spawnBulletHole(x, y);
  for (int i = 0; i < randomInt(4, 10); i++) {
    spawnShrapnel(x, y);
  }
  for (int i = 0; i < randomInt(4, 10); i++) {
    spawnFireYellow(x, y);
  }
  double r = 0.2;
  repeat(() {
    spawnSmoke(x, y, 0.01, xv: giveOrTake(r), yv: giveOrTake(r));
  }, 5, 50);
}

void spawnFreezeCircle({double x, double y}){
  game.explosions.add(Explosion(x: x, y: y, type: ExplosionType.FreezeCircle));
  for (int i = 0; i < randomInt(4, 10); i++) {
    spawnFireYellow(x, y);
  }
}

void spawnFloatingText(double x, double y, dynamic value) {
  for (FloatingText text in floatingText) {
    if (text.duration > 0) continue;
    text.duration = game.settings.floatingTextDuration;
    text.x = x;
    text.y = y;
    text.value = value.toString();
    return;
  }
  floatingText.add(FloatingText(
      x: x,
      y: y,
      value: value.toString(),
      duration: game.settings.floatingTextDuration));
}
