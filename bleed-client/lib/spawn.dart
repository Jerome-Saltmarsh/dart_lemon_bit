import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/spawners/spawnFireYellow.dart';
import 'package:bleed_client/spawners/spawnShrapnel.dart';
import 'package:bleed_client/utils.dart';

import 'audio.dart';
import 'functions/spawnBulletHole.dart';
import 'instances/settings.dart';
import 'maths.dart';
import 'spawners/spawnSmoke.dart';

int get shrapnelCount => randomInt(4, 15);

void spawnExplosion(double x, double y) {
  print("spawnExplosion()");
  playAudioExplosion(x, y);
  // animations.add(SpriteAnimation(spritesExplosion, x.toDouble(), y.toDouble(), scale: 0.5)
  // );
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
  }, 15, 120);
}

void spawnFloatingText(double x, double y, dynamic value) {
  for (FloatingText floatingText in render.floatingText) {
    if (floatingText.duration > 0) continue;
    floatingText.duration = settings.floatingTextDuration;
    floatingText.x = x;
    floatingText.y = y;
    floatingText.value = value.toString();
    return;
  }
  render.floatingText.add(FloatingText(
      x: x,
      y: y,
      value: value.toString(),
      duration: settings.floatingTextDuration));
}
