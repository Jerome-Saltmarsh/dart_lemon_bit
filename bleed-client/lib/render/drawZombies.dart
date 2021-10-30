import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/engine/functions/onScreen.dart';
import 'package:bleed_client/engine/render/drawAtlas.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapZombieToRect.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/isWaterAt.dart';

void drawZombies() {
  render.zombiesTransforms.clear();
  render.zombieRects.clear();

  for (int i = 0; i < compiledGame.totalZombies; i++) {
    Zombie zombie = compiledGame.zombies[i];
    if (!zombie.alive) {
      if (isWaterAt(zombie.x, zombie.y)){
        continue;
      }
    }
    if (!onScreen(zombie.x, zombie.y)){
      continue;
    }

    render.zombiesTransforms.add(
        mapZombieToRSTransform(zombie)
    );
    render.zombieRects.add(
        mapZombieToRect(zombie)
    );
  }

  drawAtlas(images.zombie, render.zombiesTransforms, render.zombieRects);
}
