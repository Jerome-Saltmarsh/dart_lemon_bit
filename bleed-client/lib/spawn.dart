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

Effect getEffect(){
  for(Effect effect in game.effects){
    if (!effect.enabled) continue;
    return effect;
  }
  Effect effect = Effect();
  game.effects.add(effect);
  return effect;
}

void spawnEffect({double x, double y, EffectType type, int duration}){
  Effect effect = getEffect();
  effect.x = x;
  effect.y = y;
  effect.type = type;
  effect.maxDuration = duration;
  effect.duration = 0;
  effect.enabled = true;
}

void spawnExplosion(double x, double y) {
  spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
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
  spawnEffect(x: x, y: y, type: EffectType.FreezeCircle, duration: 30);
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
