import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_math/randomInt.dart';

import 'audio.dart';
import 'modules/modules.dart';

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

void spawnEffect({
  required double x,
  required double y,
  required EffectType type,
  required int duration,
}){
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
  modules.game.actions.spawnBulletHole(x, y);
  for (int i = 0; i < randomInt(4, 10); i++) {
    isometric.spawn.spawnShrapnel(x, y);
  }
  for (int i = 0; i < randomInt(4, 10); i++) {
    isometric.spawn.spawnFireYellow(x, y);
  }
}

void spawnFreezeCircle({
  required double x,
  required double y
}){
  spawnEffect(x: x, y: y, type: EffectType.FreezeCircle, duration: 30);
}

void spawnFloatingText(double x, double y, dynamic value) {
  for (FloatingText text in isometric.state.floatingText) {
    if (text.duration > 0) continue;
    text.duration = game.settings.floatingTextDuration;
    text.x = x;
    text.y = y;
    text.value = value.toString();
    return;
  }
  isometric.state.floatingText.add(FloatingText(
      x: x,
      y: y,
      value: value.toString(),
      duration: game.settings.floatingTextDuration));
}
