
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/isometric/scope.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/draw/drawCharacter.dart';
import 'package:bleed_client/render/draw/drawInteractableNpcs.dart';
import 'package:bleed_client/render/mappers/mapParticleToDst.dart';
import 'package:bleed_client/render/mappers/mapParticleToSrc.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';

class IsometricRender with IsometricScope {

  void tiles() {
    engine.actions.setPaintColorWhite();
    drawAtlas(
      dst: modules.isometric.state.tilesDst,
      src: modules.isometric.state.tilesSrc,
    );
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

    if (totalParticles > 0) {
      sortParticles();
    }

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
            env.y < isometric.state.particles[indexParticle].y &&
                isometric.state.particles[indexParticle].type != ParticleType.Blood) {
          if (!zombiesRemaining || env.y < game.zombies[indexZombie].y) {
            if (!npcsRemaining || env.y < game.interactableNpcs[indexNpc].y) {
              drawEnvironmentObject(modules.isometric.state.environmentObjects[indexEnv]);
              indexEnv++;
              continue;
            }
          }
        }
      }

      if (particlesRemaining) {
        Particle particle = isometric.state.particles[indexParticle];

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
    final shade = isometric.properties.getShadeAtPosition(value.x, value.y);
    if (shade >= Shade_VeryDark) return;
    mapParticleToDst(value);
    mapParticleToSrc(value);
    engine.actions.renderAtlas();
  }
}