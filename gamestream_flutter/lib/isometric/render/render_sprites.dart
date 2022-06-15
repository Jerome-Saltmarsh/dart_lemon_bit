import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:gamestream_flutter/isometric/state/lower_tile_mode.dart';
import 'package:gamestream_flutter/isometric/state/particles.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/isometric/state/grid.dart';
import 'package:gamestream_flutter/ui/builders/player.dart';
import 'package:lemon_engine/engine.dart';

import 'render_character.dart';
import 'render_game_object.dart';
import 'render_grid_node.dart';
import 'render_particle.dart';
import 'render_zombie.dart';

void renderSprites() {
  engine.setPaintColorWhite();
  isometric.sortParticles();
  final _screen = engine.screen;
  final totalParticles = particles.length;
  final screenLeft = _screen.left;
  final screenRight = _screen.right;
  final screenTop = _screen.top;
  final screenBottom = _screen.bottom;
  final screenBottom100 = screenBottom + 120;

  final zombies = game.zombies;
  final players = game.players;
  final npcs = game.interactableNpcs;
  final gameObjects = game.gameObjects;

  final totalGameObjects = gameObjects.length;
  final totalZombies = game.totalZombies.value;
  final totalPlayers = game.totalPlayers.value;
  final totalNpcs = game.totalNpcs;
  final gridTotalZ = grid.length;
  final gridTotalRows = grid[0].length;
  final gridTotalColumns = grid[0][0].length;
  final gridTotalColumnsMinusOne = gridTotalColumns - 1;

  var gridZ = 0;
  var gridColumn = 0;
  var gridRow = 0;
  var indexPlayer = 0;
  var indexGameObject = 0;
  var indexParticle = 0;
  var indexZombie = 0;
  var indexNpc = 0;

  var remainingGrid = true;
  var remainingZombies = indexZombie < totalZombies;
  var remainingPlayers = indexPlayer < totalPlayers;
  var remainingNpcs = indexNpc < totalNpcs;
  var remainingGameObjects = indexGameObject < totalGameObjects;
  var remainingParticles = indexParticle < totalParticles;

  var orderGrid = gridColumn + gridRow;
  var orderPlayer = remainingPlayers ? players[0].renderOrder : 0;
  var orderPlayerZ = remainingPlayers ? players[0].indexZ : 0;
  var orderObject = remainingGameObjects ? gameObjects[0].y : 0;
  var orderParticle = remainingParticles ? particles[0].y : 0;
  var orderZombie = remainingZombies ? zombies[0].y : 0;
  var orderNpc = remainingNpcs ? npcs[0].y : 0;

  while (remainingParticles) {
    final particle = particles[indexParticle];
    if (!particle.active) {
      remainingParticles = false;
      break;
    }
    orderParticle = particle.y;
    if (orderParticle < screenTop) {
      indexParticle++;
      remainingParticles = indexParticle < totalParticles;
      continue;
    }
    if (orderParticle > screenBottom100) {
      remainingParticles = false;
    }
    break;
  }

  var particleIsBlood = remainingParticles
      ? particles[indexParticle].type == ParticleType.Blood
      : false;

  while (true) {
    if (remainingGrid) {
      final gridType = grid[gridZ][gridRow][gridColumn];
      if (gridType == GridNodeType.Empty ||
          !remainingPlayers ||
          orderGrid <= orderPlayer ||
          gridZ < orderPlayerZ) {
        if (!lowerTileMode || player.indexZ >= gridZ) {
          renderGridNode(gridZ, gridRow, gridColumn, gridType);
        }

        gridRow++;
        gridColumn--;

        if (gridColumn < 0 || gridRow >= gridTotalRows) {
          gridZ++;

          if (gridZ >= gridTotalZ) {
            gridZ = 0;
            gridColumn = gridRow + gridColumn + 1;
            gridRow = 0;
            if (gridColumn >= gridTotalColumns) {
              gridRow = (gridColumn - gridTotalColumnsMinusOne);
              gridColumn = gridTotalColumnsMinusOne;
            }

            if (gridRow >= gridTotalRows) {
              remainingGrid = false;
              continue;
            }
          } else {
            gridColumn = gridRow + gridColumn;
            gridRow = 0;
            if (gridColumn >= gridTotalColumns) {
              gridRow = (gridColumn - gridTotalColumnsMinusOne);
              gridColumn = gridTotalColumnsMinusOne;
            }
          }
        }
        orderGrid = gridRow + gridColumn;
        continue;
      }
    }

    if (remainingPlayers) {
      if (!remainingGameObjects || orderPlayer < orderObject) {
        if (!remainingParticles || (orderPlayer < orderParticle && !particleIsBlood)) {
          if (!remainingZombies || orderPlayer < orderZombie) {
            if (!remainingNpcs || orderPlayer < orderNpc) {
              renderCharacter(players[indexPlayer]);
              indexPlayer++;
              remainingPlayers = indexPlayer < totalPlayers;
              while (remainingPlayers) {
                final player = players[indexPlayer];
                orderPlayer = player.renderOrder;
                orderPlayerZ = player.indexZ;
                if (player.renderY > screenBottom100) {
                  remainingPlayers = false;
                  break;
                }
                final x = player.x;
                if (x < screenLeft ||
                    x > screenRight ||
                    orderPlayer < screenTop) {
                  indexPlayer++;
                  remainingPlayers = indexPlayer < totalPlayers;
                  continue;
                }
                break;
              }
              continue;
            }
          }
        }
      }
    }

    if (remainingGameObjects) {
      if (!remainingParticles ||
          (orderObject < orderParticle && !particleIsBlood)) {
        if (!remainingZombies || orderObject < orderZombie) {
          if (!remainingNpcs || orderObject < orderNpc) {
            renderGameObject(gameObjects[indexGameObject]);
            indexGameObject++;
            remainingGameObjects = indexGameObject < totalGameObjects;
            while (remainingGameObjects) {
              final nextGameObject = gameObjects[indexGameObject];
              orderObject = nextGameObject.y;
              if (orderObject > screenBottom100) {
                remainingGameObjects = false;
                break;
              }
              final x = nextGameObject.x;
              if (x < screenLeft ||
                  x > screenRight ||
                  orderObject < screenTop) {
                indexGameObject++;
                remainingGameObjects = indexGameObject < totalGameObjects;
                continue;
              }
              break;
            }
            continue;
          }
        }
      }
    }

    if (remainingParticles) {
      if (particleIsBlood) {
        renderParticle(particles[indexParticle]);
        indexParticle++;
        remainingParticles = indexParticle < totalParticles;
        while (remainingParticles) {
          final particle = particles[indexParticle];

          if (!particle.active) {
            remainingParticles = false;
            break;
          }

          orderParticle = particle.y;
          if (orderParticle > screenBottom100) {
            remainingParticles = false;
            break;
          }
          final x = particle.x;
          if (x < screenLeft || x > screenRight) {
            indexParticle++;
            remainingParticles = indexParticle < totalParticles;
            continue;
          }
          particleIsBlood = particle.type == ParticleType.Blood;
          break;
        }
        continue;
      }

      if (!remainingZombies || orderParticle < orderZombie) {
        if (!remainingNpcs || orderParticle < orderNpc) {
          renderParticle(particles[indexParticle]);
          indexParticle++;
          remainingParticles = indexParticle < totalParticles;

          while (remainingParticles) {
            final particle = particles[indexParticle];

            if (!particle.active) {
              remainingParticles = false;
              break;
            }

            orderParticle = particle.y;
            if (orderParticle > screenBottom100) {
              remainingParticles = false;
              break;
            }
            final x = particle.x;
            if (x < screenLeft || x > screenRight) {
              indexParticle++;
              remainingParticles = indexParticle < totalParticles;
              continue;
            }
            particleIsBlood = particle.type == ParticleType.Blood;
            break;
          }
          continue;
        }
      }
    }

    if (remainingZombies) {
      if (!remainingNpcs || orderZombie < orderNpc) {
        assert(indexZombie >= 0);
        renderZombie(zombies[indexZombie]);
        indexZombie++;
        remainingZombies = indexZombie < totalZombies;
        while (remainingZombies) {
          final zombie = zombies[indexZombie];
          orderZombie = zombie.y;
          if (orderZombie > screenBottom100) {
            remainingZombies = false;
            break;
          }
          final x = zombie.x;
          if (x < screenLeft || x > screenRight || orderZombie < screenTop) {
            indexZombie++;
            remainingZombies = indexZombie < totalZombies;
            continue;
          }
          break;
        }
        continue;
      }
    }

    if (remainingNpcs) {
      // drawInteractableNpc(npcs[indexNpc]);
      indexNpc++;
      remainingNpcs = indexNpc < totalNpcs;
      if (remainingNpcs) {
        orderNpc = npcs[indexNpc].y;
        if (orderNpc > screenBottom) {
          remainingNpcs = false;
        }
      }
      continue;
    }

    if (remainingGrid ||
        remainingZombies ||
        remainingPlayers ||
        remainingNpcs ||
        remainingGameObjects ||
        remainingParticles) continue;
    return;
  }
}
