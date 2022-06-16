import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:gamestream_flutter/isometric/lower_tile_mode.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:lemon_engine/engine.dart';

import '../grid.dart';
import 'render_character.dart';
import 'render_grid_node.dart';
import 'render_particle.dart';
import 'render_zombie.dart';

var gridZ = 0;
var gridColumn = 0;
var gridRow = 0;
var indexPlayer = 0;
var indexGameObject = 0;
var indexParticle = 0;
var indexZombie = 0;

var remainingGrid = false;
var remainingZombies = false;
var remainingPlayers = false;
var remainingParticles = false;

var orderGrid = 0;
var orderPlayer = 0;
var orderPlayerZ = 0;
var orderParticle = 0.0;
var orderParticleZ = 0;
var orderZombie = 0.0;

void renderSprites() {
  final totalParticles = particles.length;
  final screenLeft = engine.screen.left;
  final screenRight = engine.screen.right;
  final screenTop = engine.screen.top;
  final screenBottom = engine.screen.bottom;
  final screenBottom100 = screenBottom + 120;
  final gridTotalColumnsMinusOne = gridTotalColumns - 1;

  gridZ = 0;
  gridColumn = 0;
  gridRow = 0;
  indexPlayer = 0;
  indexParticle = 0;
  indexZombie = 0;

  remainingGrid = true;
  remainingZombies = indexZombie < totalZombies;
  remainingPlayers = indexPlayer < totalPlayers;
  remainingParticles = indexParticle < totalParticles;

  orderGrid = gridColumn + gridRow;
  orderPlayer = remainingPlayers ? players[0].renderOrder : 0;
  orderPlayerZ = remainingPlayers ? players[0].indexZ : 0;
  orderParticle = remainingParticles ? particles[0].renderOrderD : 0;
  orderParticleZ = remainingParticles ? particles[0].indexZ : 0;
  orderZombie = remainingZombies ? zombies[0].y : 0;

  engine.setPaintColorWhite();
  if (remainingParticles) {
    sortParticles();
  }

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
      if (
      gridType == GridNodeType.Empty ||
      !remainingPlayers ||
      orderGrid <= orderPlayer ||
      gridZ < orderPlayerZ
      ) {
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
      if (!remainingParticles || (orderPlayer < orderParticle && !particleIsBlood)) {
        if (!remainingZombies || orderPlayer < orderZombie) {
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
            if (x < screenLeft || x > screenRight || orderPlayer < screenTop) {
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

    // if (remainingGameObjects) {
    //   if (!remainingParticles ||
    //       (orderObject < orderParticle && !particleIsBlood)) {
    //     if (!remainingZombies || orderObject < orderZombie) {
    //       if (!remainingNpcs || orderObject < orderNpc) {
    //         renderGameObject(gameObjects[indexGameObject]);
    //         indexGameObject++;
    //         remainingGameObjects = indexGameObject < totalGameObjects;
    //         while (remainingGameObjects) {
    //           final nextGameObject = gameObjects[indexGameObject];
    //           orderObject = nextGameObject.y;
    //           if (orderObject > screenBottom100) {
    //             remainingGameObjects = false;
    //             break;
    //           }
    //           final x = nextGameObject.x;
    //           if (x < screenLeft ||
    //               x > screenRight ||
    //               orderObject < screenTop) {
    //             indexGameObject++;
    //             remainingGameObjects = indexGameObject < totalGameObjects;
    //             continue;
    //           }
    //           break;
    //         }
    //         continue;
    //       }
    //     }
    //   }
    // }

    if (remainingParticles) {
      if (particleIsBlood) {
        particles[indexParticle].render();
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

    if (remainingZombies) {
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

    if (remainingGrid ||
        remainingZombies ||
        remainingPlayers ||
        remainingParticles) continue;
    return;
  }
}

