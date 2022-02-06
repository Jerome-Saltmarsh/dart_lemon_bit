import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/isometric/properties.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/draw/drawCharacter.dart';
import 'package:bleed_client/render/draw/drawInteractableNpcs.dart';
import 'package:bleed_client/render/mappers/loop.dart';
import 'package:bleed_client/render/mappers/mapParticleToDst.dart';
import 'package:bleed_client/render/mappers/mapParticleToSrc.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';

class IsometricRender {

  final IsometricState state;
  final IsometricProperties properties;
  IsometricRender(this.state, this.properties);

  void tiles() {
    engine.actions.setPaintColorWhite();
    engine.state.canvas.drawRawAtlas(
        state.image,
        state.tilesDst,
        state.tilesSrc,
        null,
        null,
        null,
        engine.state.paint);
  }

  void sprites() {
    engine.actions.setPaintColorWhite();
    int indexHuman = 0;
    int indexEnv = 0;
    int indexParticle = 0;
    int indexZombie = 0;
    int indexNpc = 0;
    final totalParticles = properties.totalActiveParticles;
    final totalEnvironment = state.environmentObjects.length;
    bool zombiesRemaining = indexZombie < game.totalZombies.value;
    bool humansRemaining = indexHuman < game.totalHumans;
    bool npcsRemaining = indexHuman < game.totalNpcs;
    bool environmentRemaining = indexEnv < totalEnvironment;
    bool particlesRemaining = indexParticle < totalParticles;

    while (true) {
      humansRemaining = indexHuman < game.totalHumans;
      environmentRemaining = indexEnv < totalEnvironment;
      particlesRemaining = indexParticle < totalParticles;
      zombiesRemaining = indexZombie < game.totalZombies.value;
      npcsRemaining = indexNpc < game.totalNpcs;

      if (!zombiesRemaining &&
          !humansRemaining &&
          !environmentRemaining &&
          !particlesRemaining &&
          !npcsRemaining) return;

      if (humansRemaining) {
        double humanY = game.humans[indexHuman].y;

        if (!environmentRemaining ||
            humanY < state.environmentObjects[indexEnv].y) {
          if (!particlesRemaining ||
              humanY < state.particles[indexParticle].y &&
                  state.particles[indexParticle].type != ParticleType.Blood) {
            if (!zombiesRemaining || humanY < game.zombies[indexZombie].y) {
              if (!npcsRemaining || humanY < game.interactableNpcs[indexNpc].y) {
                drawCharacter(game.humans[indexHuman]);
                indexHuman++;
                continue;
              }
            }
          }
        }
      }

      if (environmentRemaining) {
        final env = state.environmentObjects[indexEnv];
        if (env.top > engine.state.screen.bottom) return;
        if (!particlesRemaining ||
            env.y < state.particles[indexParticle].y &&
                state.particles[indexParticle].type != ParticleType.Blood) {
          if (!zombiesRemaining || env.y < game.zombies[indexZombie].y) {
            if (!npcsRemaining || env.y < game.interactableNpcs[indexNpc].y) {
              drawEnvironmentObject(state.environmentObjects[indexEnv]);
              indexEnv++;
              continue;
            }
          }
        }
      }

      if (particlesRemaining) {
        Particle particle = state.particles[indexParticle];

        if (particle.type == ParticleType.Blood) {
          if (onScreen(particle.x, particle.y)) {
            _drawParticle(particle);
          }
          indexParticle++;
          continue;
        }

        if (!zombiesRemaining || particle.y < game.zombies[indexZombie].y) {
          if (!npcsRemaining || particle.y < game.interactableNpcs[indexNpc].y) {
            if (onScreen(particle.x, particle.y)) {
              _drawParticle(particle);
            }
            indexParticle++;
            continue;
          }
        }
      }

      if (zombiesRemaining) {
        Zombie zombie = game.zombies[indexZombie];

        if (!npcsRemaining || zombie.y < game.interactableNpcs[indexNpc].y) {
          drawCharacter(game.zombies[indexZombie]);
          indexZombie++;
          continue;
        }
      }

      drawInteractableNpc(game.interactableNpcs[indexNpc]);
      indexNpc++;
    }
  }

  void _drawParticle(Particle value){
    if (!onScreen(value.x, value.y)) return;
    final shade = properties.getShadeAtPosition(value.x, value.y);
    if (shade >= Shade_VeryDark) return;
    mapParticleToDst(value);
    mapParticleToSrc(value);
    engine.actions.renderAtlas();
  }

  void renderItem(Item item) {
    if (!itemAtlas.containsKey(item.type)) return;

    final _anchor = 32;
    srcLoop(
        atlas: itemAtlas[item.type]!,
        direction: Direction.Down,
        frame: core.state.timeline.frame,
        framesPerDirection: 8);
    engine.actions.mapDst(x: item.x - _anchor, y: item.y - _anchor,);
    engine.actions.renderAtlas();
  }
}

