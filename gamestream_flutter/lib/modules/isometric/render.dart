import 'dart:math';

import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/weapon_type.dart';
import 'package:gamestream_flutter/classes/GeneratedObject.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/classes/Projectile.dart';
import 'package:gamestream_flutter/classes/Structure.dart';
import 'package:gamestream_flutter/classes/game_object.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/get_position.dart';
import 'package:gamestream_flutter/mappers/mapParticleToDst.dart';
import 'package:gamestream_flutter/mappers/mapParticleToSrc.dart';
import 'package:gamestream_flutter/modules/isometric/animations.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/isometric/enums.dart';
import 'package:gamestream_flutter/modules/isometric/module.dart';
import 'package:gamestream_flutter/state/grid.dart';
import 'package:gamestream_flutter/ui/builders/player.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import '../modules.dart';
import 'classes.dart';

const _framesPerDirectionHuman = 19;
const _framesPerDirectionZombie = 8;
final _screen = engine.screen;

class IsometricRender {

  var lowerTileMode = false;
  final IsometricModule state;
  IsometricRender(this.state);

  void renderTiles() {

    final screen = engine.screen;

    state.minRow = max(0, convertWorldToRow(screen.left, screen.top));
    state.maxRow = min(state.totalRowsInt, convertWorldToRow(screen.right, screen.bottom));
    state.minColumn = max(0, convertWorldToColumn(screen.right, screen.top));
    state.maxColumn = min(state.totalColumnsInt, convertWorldToColumn(screen.left, screen.bottom));

    final minRow = state.minRow;
    final maxRow = state.maxRow;
    final minColumn = state.minColumn;
    final maxColumn = state.maxColumn;
    final dynamicShade = state.dynamic;
    final totalColumnsInt4 = state.totalColumnsInt * 4;
    final tilesSrc = state.tilesSrc;
    final tilesDst = state.tilesDst;

    final screenLeft = _screen.left;
    final screenTop = _screen.top;
    final screenRight = _screen.right;
    final screenBottom = _screen.bottom;

    for (var rowIndex = minRow; rowIndex < maxRow; rowIndex++){
      final dynamicRow = dynamicShade[rowIndex];
      final rowIndexMultiplier = rowIndex * totalColumnsInt4;
      for (var columnIndex = minColumn; columnIndex < maxColumn; columnIndex++) {
        final i = rowIndexMultiplier + (columnIndex * 4);
        final x = tilesDst[i + 2];
        if (x < screenLeft) break;
        final y = tilesDst[i + 3];
        if (y > screenBottom) break;
        if (x > screenRight) continue;
        if (y < screenTop) continue;

        engine.mapDstCheap(
          x: x,
          y: y,
        );
        engine.mapSrc48(
            x: tilesSrc[i],
            y: dynamicRow[columnIndex] * 48.0,
        );
        engine.renderAtlas();
      }
    }
  }


  int calculateOrder(Position position) {
     return convertWorldToRow(position.x, position.y) + convertWorldToColumn(position.x, position.y);
  }

  /// While this method is obviously a complete dog's breakfast all readability
  /// has been sacrificed for sheer speed of execution.
  ///
  /// WARNING: Be very careful modifying anything in this code. If something
  /// doesn't make any sense or doesn't seem to belong or do anything look
  /// harder
  void renderSprites() {
    engine.setPaintColorWhite();
    isometric.sortParticles();
    final particles = isometric.particles;
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
    final generatedObjects = game.generatedObjects;
    final structures = isometric.structures;

    final totalGameObjects = gameObjects.length;
    final totalZombies = game.totalZombies.value;
    final totalPlayers = game.totalPlayers.value;
    final totalNpcs = game.totalNpcs;
    final totalStructures = isometric.totalStructures;
    final totalGenerated = generatedObjects.length;
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
    var indexStructure = 0;
    var indexGenerated = 0;

    var remainingGrid = true;
    var remainingZombies = indexZombie < totalZombies;
    var remainingPlayers = indexPlayer < totalPlayers;
    var remainingNpcs = indexNpc < totalNpcs;
    var remainingGameObjects = indexGameObject < totalGameObjects;
    var remainingParticles = indexParticle < totalParticles;
    var remainingStructures = indexStructure < totalStructures;
    var remainingBuildMode = modules.game.structureType.value != null;
    var remainingGenerated = indexGenerated < totalGenerated;


    var orderGrid = gridColumn + gridRow;
    var orderPlayer = remainingPlayers ? calculateOrder(players[0]) : 0;
    var orderPlayerZ = remainingPlayers ? players[0].z ~/ 24 : 0;
    var orderObject = remainingGameObjects ? gameObjects[0].y : 0;
    var orderParticle = remainingParticles ? particles[0].y : 0;
    var orderZombie = remainingZombies ? zombies[0].y : 0;
    var orderNpc = remainingNpcs ? npcs[0].y : 0;
    var orderStructure = remainingStructures ? structures[0].y : 0;
    var orderBuildMode = remainingBuildMode ? mouseWorldY : 0;
    var orderGenerated = remainingGenerated ? generatedObjects[0].y : 0;


    while (remainingGenerated) {
      final generatedObject = generatedObjects[indexGenerated];
      orderGenerated = generatedObject.y;
      if (orderGenerated < screenTop){
        indexGenerated++;
        remainingGenerated = indexGenerated < totalGenerated;
        continue;
      }
      if (orderGenerated > screenBottom100) {
        remainingGenerated = false;
      }
      break;
    }

    while (remainingParticles) {
      final particle = particles[indexParticle];
      if (!particle.active){
        remainingParticles = false;
        break;
      }
      orderParticle = particle.y;
      if (orderParticle < screenTop){
         indexParticle++;
         remainingParticles = indexParticle < totalParticles;
         continue;
      }
      if (orderParticle > screenBottom100){
        remainingParticles = false;
      }
      break;
    }

    var particleIsBlood = remainingParticles ? particles[indexParticle].type == ParticleType.Blood : false;

    while (true) {

      if (remainingGrid) {
        final gridType = grid[gridZ][gridRow][gridColumn];
        if (gridType == GridNodeType.Empty
              ||
            !remainingPlayers
              ||
            orderGrid <= orderPlayer
              ||
            gridZ < orderPlayerZ
            ) {

          // if (!lowerTileMode || player.z ~/ 24 >= gridZ - 1) {
          //   renderGridNode(gridZ, gridRow, gridColumn, gridType);
          // }
          if (!lowerTileMode
              // || gridType == GridNodeType.Empty
              || player.z ~/ 24 >= gridZ
              // || (gridZ + 1 < gridTotalZ && grid[gridZ + 1][gridRow][gridColumn] == GridNodeType.Empty)
          ) {
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

              if (gridRow >= gridTotalRows){
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
          if (!remainingGenerated || orderPlayer < orderGenerated) {
            if (!remainingBuildMode || orderPlayer < orderBuildMode) {
              if (!remainingGameObjects || orderPlayer < orderObject) {
                if (!remainingParticles ||
                    (orderPlayer < orderParticle && !particleIsBlood)) {
                  if (!remainingZombies || orderPlayer < orderZombie) {
                    if (!remainingStructures || orderPlayer < orderStructure) {
                      if (!remainingNpcs || orderPlayer < orderNpc) {
                        renderCharacter(players[indexPlayer]);
                        indexPlayer++;
                        remainingPlayers = indexPlayer < totalPlayers;
                        while (remainingPlayers) {
                          final player = players[indexPlayer];
                          orderPlayer = calculateOrder(player);
                          orderPlayerZ = player.z ~/ 24.0;
                          if (orderPlayer > screenBottom100) {
                            remainingPlayers = false;
                            break;
                          }
                          final x = player.x;
                          if (x < screenLeft || x > screenRight ||
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
          }
        }
      }

      if (remainingGameObjects) {
        if (!remainingGenerated || orderObject < orderGenerated) {
          if (!remainingBuildMode || orderObject < orderBuildMode) {
            if (!remainingStructures || orderObject < orderStructure) {
              if (!remainingParticles || (orderObject < orderParticle && !particleIsBlood)) {
                  if (!remainingZombies || orderObject < orderZombie) {
                    if (!remainingNpcs || orderObject < orderNpc) {
                      renderGameObject(gameObjects[indexGameObject]);
                      indexGameObject++;
                      remainingGameObjects = indexGameObject < totalGameObjects;
                      while (remainingGameObjects) {
                        final nextGameObject = gameObjects[indexGameObject];
                        orderObject = nextGameObject.y;
                        if (orderObject > screenBottom100){
                          remainingGameObjects = false;
                          break;
                        }
                        final x = nextGameObject.x;
                        if (x < screenLeft || x > screenRight || orderObject < screenTop) {
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
            if (orderParticle > screenBottom100){
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
          if (!remainingGenerated || orderParticle < orderGenerated) {
            if (!remainingBuildMode || orderParticle < orderBuildMode) {
              if (!remainingStructures || orderParticle < orderStructure) {
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
                      if (orderParticle > screenBottom100){
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
          }
        }
      }

      if (remainingZombies) {
        if (!remainingGenerated || orderZombie < orderGenerated) {
          if (!remainingBuildMode || orderZombie < orderBuildMode) {
            if (!remainingStructures || orderZombie < orderStructure) {
                if (!remainingNpcs || orderZombie < orderNpc) {
                  renderZombie(zombies[indexZombie]);
                  indexZombie++;
                  remainingZombies = indexZombie < totalZombies;
                  while (remainingZombies) {
                    final zombie = zombies[indexZombie];
                    orderZombie = zombie.y;
                    if (orderZombie > screenBottom100){
                      print("last zombie");
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
            }
          }
      }

      if (remainingNpcs) {
        if (!remainingGenerated || orderNpc < orderGenerated) {
          if (!remainingBuildMode || orderNpc < orderBuildMode) {
            if (!remainingStructures || orderNpc < orderStructure) {
                drawInteractableNpc(npcs[indexNpc]);
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
          }
        }
      }

      if (remainingStructures) {
        if (!remainingGenerated || orderStructure < orderGenerated) {
          if (!remainingBuildMode || orderStructure < orderBuildMode) {
            renderStructure(structures[indexStructure]);
            indexStructure++;
            remainingStructures = indexStructure < totalStructures;
            if (remainingStructures) {
              orderStructure = structures[indexStructure].y;
              if (orderStructure > screenBottom) {
                remainingStructures = false;
              }
              continue;
            }
            continue;
          }
        }
      }

      if (remainingBuildMode){
        if (!remainingGenerated || orderBuildMode < orderGenerated) {
          renderBuildMode();
          remainingBuildMode = false;
          continue;
        }
      }

      if (remainingGenerated) {
         final generatedObject = generatedObjects[indexGenerated];
         renderGeneratedObject(generatedObject);
         indexGenerated++;
         remainingGenerated = indexGenerated < totalGenerated;

         while (remainingGenerated) {
           orderGenerated = generatedObjects[indexGenerated].y;
           if (orderGenerated > screenBottom100){
             remainingGenerated = false;
             break;
           }
           final x = generatedObjects[indexGenerated].x;
           if (x < screenLeft || x > screenRight) {
             indexGenerated++;
             remainingGenerated = indexGenerated < totalGenerated;
             continue;
           }
           break;
         }
         continue;
      }


      if (
          remainingGrid ||
          remainingZombies ||
          remainingPlayers ||
          remainingNpcs ||
          remainingGameObjects ||
          remainingStructures ||
          remainingParticles ||
          remainingGenerated ||
          remainingBuildMode
      ) continue;
      return;
    }
  }

  void renderGeneratedObject(GeneratedObject generatedObject){
    switch (generatedObject.type){
      case GeneratedObjectType.Block_Grass:
        renderBlockGrass(generatedObject);
        break;
      case GeneratedObjectType.Block_Grass_Level_2:
        renderBlockGrassLevel2(generatedObject);
        break;
      case GeneratedObjectType.Block_Grass_Level_3:
        renderBlockGrassLevel3(generatedObject);
        break;
      case GeneratedObjectType.Stairs_Grass_H:
        renderStairsGrassH(generatedObject);
        break;
    }
  }

  void renderProjectile(Projectile value) {
    switch (value.type) {
      case ProjectileType.Arrow:
        renderArrow(value.x, value.y, value.angle);
        break;
      case ProjectileType.Orb:
        renderOrb(value);
        break;
      case ProjectileType.Fireball:
        renderFireball(value.x, value.y, value.angle);
        break;
      default:
        return;
    }
  }

  void renderFireball(double x, double y, double rotation) {
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 5669,
        srcY: ((x + y + (engine.frame ~/ 5) % 6) * 23),
        srcWidth: 18,
        srcHeight: 23,
        rotation: rotation,
    );
  }

  void renderArrow(double x, double y, double angle) {
    engine.mapSrc(x: 2182, y: 1, width: 13, height: 47);
    engine.mapDst(x: x, y: y - 20, rotation: angle, anchorX: 6.5, anchorY: 30, scale: 0.5);
    engine.renderAtlas();
    engine.mapSrc(x: 2172, y: 1, width: 13, height: 47);
    engine.mapDst(x: x, y: y, rotation: angle, anchorX: 6.5, anchorY: 30, scale: 0.5);
    engine.renderAtlas();
  }

  void renderOrb(Position position){
    engine.renderCustom(
        dstX: position.x,
        dstY: position.y,
        srcX: 417,
        srcY: 26,
        srcWidth: 8,
        srcHeight: 8,
        scale: 1.5
    );
  }

  void renderStructure(Structure structure) {
    switch(structure.type) {
      case StructureType.Tower:
        return renderTower(structure.x, structure.y);
      case StructureType.Palisade:
        return renderPalisade(x: structure.x, y: structure.y);
      case StructureType.Torch:
        return renderTorch(structure);
      case StructureType.House:
        return renderHouse(structure);
    }
  }

  void renderPalisade({
    required double x,
    required double y,
    int shade = Shade.Bright
  }){
    engine.renderCustom(
      dstX: x,
      dstY: y,
      srcX: 1314 ,
      srcY: shade * 96,
      srcWidth: 48,
      srcHeight: 96,
      anchorY: 0.66,
    );
  }

  void renderBlockGrass(Position position) {
    render(position: position, srcX: 5981, width: 48, height: 100, anchorY: 0.66);
  }

  void renderBlockGrassLevel2(Position position){
    final shade =  isometric.getShadeAt(position);
    if (shade >= Shade.Pitch_Black) return;
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y - 50,
      srcX: 5981 ,
      srcY: shade * 100,
      srcWidth: 48,
      srcHeight: 100,
      anchorY: 0.66,
    );
  }

  void renderBlockGrassLevel3(Position position){
    final shade =  isometric.getShadeAt(position);
    if (shade >= Shade.Pitch_Black) return;
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y - 100,
      srcX: 5981 ,
      srcY: shade * 100,
      srcWidth: 48,
      srcHeight: 100,
      anchorY: 0.66,
    );
  }

  void renderStairsGrassH(Position position){
    final shade =  isometric.getShadeAt(position);
    if (shade >= Shade.Pitch_Black) return;
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y,
      srcX: 5870 ,
      // srcY: shade * 100,
      srcY: 0,
      srcWidth: 48,
      srcHeight: 100,
      anchorY: 0.66,
    );
  }

  void renderTower(double x, double y) {
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 6125,
        srcY: 0,
        srcWidth: 48,
        srcHeight: 100,
        anchorY: 0.66
    );
  }

  void renderTorch(Position position) {
    if (isometric.dayTime){
      engine.renderCustomV2(
          dst: position,
          srcX: 2145,
          srcWidth: 25,
          srcHeight: 70,
          anchorY: 0.66
      );
      return;
    }
    engine.renderCustomV2(
        dst: position,
        srcX: 2145,
        srcY: 70 + (((position.x + position.y + (engine.frame ~/ 10)) % 6) * 70),
        srcWidth: 25,
        srcHeight: 70,
        anchorY: 0.66

    );
  }

  void renderHouse(Position position){
    engine.renderCustomV2(
        dst: position,
        srcX: 1748,
        srcWidth: 150,
        srcHeight: 150
    );
  }

  void renderPot(Position position) {
    engine.mapSrc64(
        x: 6032,
        y: isometric.getShadeAt(position) * 64
    );
    engine.mapDst(x: position.x, y: position.y, anchorX: 32, anchorY: 32);
    engine.renderAtlas();
  }

  void renderTree(Position position) {
    render(position: position, srcX: 2049, width: 64, height: 81, anchorY: 0.66);
  }

  void renderChest(Position position){
    render(
        position: position,
        srcX: 6328,
        width: 50,
        height: 76,
        anchorY: 0.6,
        scale: 0.75
    );
  }

  void renderFireYellow({
    required double x,
    required double y,
    double scale = 1.0,
  }){
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 145,
        srcY: 25,
        srcWidth: 8,
        srcHeight: 8,
        scale: scale
    );
  }


  void renderShrapnel({
    required double x,
    required double y,
    double scale = 1.0,
  }){
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 1,
        srcY: 1,
        srcWidth: 8,
        srcHeight: 8,
        scale: scale
    );
  }

  void renderSmoke({
    required double x,
    required double y,
    required double scale
  }){
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 5612,
        srcY: 0,
        srcWidth: 50,
        srcHeight: 50,
        scale: scale
    );
  }

  void renderOrbShard({required double x, required double y, required double scale}){
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 345,
        srcY: 67,
        srcWidth: 8,
        srcHeight: 8,
        scale: scale
    );
  }

  void renderParticle(Particle value) {
    switch (value.type) {
      case ParticleType.Smoke:
        return renderSmoke(x: value.x, y: value.renderY, scale: value.renderScale);
      case ParticleType.Orb_Shard:
        return renderOrbShard(x: value.x, y: value.renderY, scale: value.renderScale);
      case ParticleType.Shrapnel:
        return renderShrapnel(x: value.x, y: value.renderY, scale: value.renderScale);
      case ParticleType.FireYellow:
        return renderFireYellow(x: value.x, y: value.renderY, scale: value.renderScale);
      case ParticleType.Flame:
        return renderFlame(value);
      default:
        break;
    }

    final shade = state.getShadeAtPosition(value.x, value.y);
    if (shade >= Shade.Very_Dark) return;
    mapParticleToDst(value);
    mapParticleToSrc(value);
    engine.renderAtlas();

    if (!value.casteShadow) return;
    if (value.z < 0.1) return;
    renderShadow(position: value, scale: value.z);
  }

  void mapShadeShadow(){
    engine.mapSrc(x: 1, y: 34, width: 8.0, height: 8.0);
  }

  void renderItem(Item item) {
    srcLoopSimple(
        x: 5939,
        size: 32,
        frames: 4,
    );
    engine.mapDst(
      anchorX: 16,
      anchorY: 23,
      x: item.x,
        y: item.y
    );
    engine.renderAtlas();
  }

  void srcLoopSimple({
    required double x,
    required int frames,
    required double size
  }){
    engine.mapSrc(
        x: x,
        y: ((engine.frame % 4) * size),
        width: size,
        height: size
    );
  }

  void renderGameObject(GameObject value) {
    switch (value.type) {
      case GameObjectType.Tree:
        return renderTree(value);
      case GameObjectType.Rock:
        return renderRockLarge(value);
      case GameObjectType.Fireplace:
        return renderFireplace(value);
      case GameObjectType.Grass:
        return renderLongGrass(value);
      case GameObjectType.Grave:
        return renderGrave(value);
      case GameObjectType.Tree_Stump:
        return renderTreeStump(value);
      case GameObjectType.Rock_Small:
        return renderRockSmall(value);
      case GameObjectType.Flag:
        return renderFlag(value);
      case GameObjectType.Torch:
        return renderTorch(value);
      case GameObjectType.Chest:
        return renderChest(value);
      case GameObjectType.Pot:
        return renderPot(value);
      default:
        throw Exception("Cannot render GameObject ${value.type}");
    }
  }

  void renderRockSmall(Position position){
    render(position: position, srcX: 5569, width: 12, height: 14);
  }
  
  void renderFireplace(Position position) {
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y,
      srcY: ((position.x + position.y + engine.frame) % 6) * 43,
      srcX: 6464,
      srcWidth: 46,
      srcHeight: 43,
    );
  }

  void renderFlame(Position position){
    engine.renderCustom(
        dstX: position.x,
        dstY: position.y,
        srcY: ((position.x + position.y + engine.frame) % 6) * 23,
        srcX: 5669,
        srcWidth: 18,
        srcHeight: 23,
        anchorY: 0.9
    );
  }

  void renderFlag(Position position) {
    render(position: position, srcX: 6437, width: 19, height: 33);
  }

  void renderLongGrass(Position position){
    render(position: position, srcX: 5585, width: 19, height: 30);
  }

  void renderRockLarge(Position position){
    render(position: position, srcX: 5475, width: 40, height: 43);
  }

  void renderGrave(Position position){
    render(position: position, srcX: 5524, width: 20, height: 41);
  }

  void renderTreeStump(Position position){
    render(position: position, srcX: 5549, width: 15, height: 22);
  }

  void render({
    required Position position,
    required double srcX,
    required double width,
    required double height,
    double anchorY = 0.5,
    double scale = 1.0,
  }){
    final shade =  isometric.getShadeAt(position);
    if (shade >= Shade.Pitch_Black) return;
    engine.renderCustomV2(
      dst: position,
      srcX: srcX,
      srcY: shade * height,
      srcWidth: width,
      srcHeight: height,
      anchorY: anchorY,
      scale: scale,
    );
  }

  void renderZombie(Character character){
    final shade = character.shade;
    if (shade > Shade.Dark) return;

    if (shade < Shade.Dark) {
      renderCharacterHealthBar(character);
    }
    _renderZombie(character, shade);
  }

  void renderCharacter(Character character) {
    assert(character.direction >= 0);
    assert(character.direction < 8);

    if (character.dead) return;

    final shade = state.getShadeAtPosition(character.x, character.y);
    if (shade > Shade.Dark) return;

    if (shade < Shade.Dark) {
      renderCharacterHealthBar(character);
    }
    final weapon = character.weapon;
    final direction = character.direction;

    if (weapon == WeaponType.Bow) {
       if (
            direction == Direction.UpLeft
            ||
            direction == Direction.Up
            ||
            direction == Direction.UpRight
            ||
            direction == Direction.Right
            ||
            direction == Direction.DownRight
       ){
         _renderCharacterTemplateWeapon(character);
         _renderCharacterTemplate(character);
       } else {
         _renderCharacterTemplate(character);
         _renderCharacterTemplateWeapon(character);
       }
       return;
    }

    if (WeaponType.isMelee(weapon)) {
      if (
          direction == Direction.Up
          ||
          direction == Direction.UpLeft
          ||
          direction == Direction.Left
      ){
        _renderCharacterTemplateWeapon(character);
        _renderCharacterTemplate(character);
      } else {
        _renderCharacterTemplate(character);
        _renderCharacterTemplateWeapon(character);
      }
      return;
    }
    _renderCharacterTemplate(character);
    _renderCharacterTemplateWeapon(character);
  }

  void _renderZombie(Character character, int shade) {
    engine.mapSrc64(
        x: mapZombieSrcX(character, shade),
        y: 789.0 + (shade * 64.0),
    );
    engine.mapDst(
        x: character.x,
        y: character.y,
        anchorX: 32,
        anchorY: 48,
        scale: 0.7
    );
    engine.renderAtlas();
  }

  double mapZombieSrcX(Character character, int shade){
    switch(character.state){

      case CharacterState.Running:
        const frames = [3, 4, 5, 6];
        return loop4(
            animation: frames,
            character: character,
            framesPerDirection: _framesPerDirectionZombie
        );

      case CharacterState.Idle:
        return single(
            frame: 1,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionZombie
        );

      case CharacterState.Hurt:
        return single(
            frame: 2,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionZombie
        );

      case CharacterState.Performing:
        return animate(
            animation: animations.zombie.striking,
            character: character,
            framesPerDirection:
            _framesPerDirectionZombie
        );
      default:
        throw Exception("Render zombie invalid state ${character.state}");
    }
  }

  double single({
    required int frame,
    required num direction,
    required int framesPerDirection,
    num size = 64.0
  }){
    return ((direction * framesPerDirection) + (frame - 1)) * size.toDouble();
  }

  double loop({
    required List<int> animation,
    required Character character,
    required int framesPerDirection,
    double size = 64.0
  }){
    // TODO Optimize length call
    final animationFrame = character.frame % animation.length;
    final frame = animation[animationFrame] - 1;
    return (character.direction * framesPerDirection * size) + (frame * size);
  }

  double loop4({
    required List<int> animation,
    required Character character,
    required int framesPerDirection,
    double size = 64
  }){
    return (character.direction * framesPerDirection * size) + ((animation[character.frame % 4] - 1) * size);
  }


  double animate({
        required List<int> animation,
        required Character character,
        required int framesPerDirection,
        double size = 64.0
      }){
    final animationFrame = min(character.frame, animation.length - 1);
    final frame = animation[animationFrame] - 1;
    return (character.direction * framesPerDirection * size) + (frame * size);
  }

  void _renderCharacterTemplate(Character character) {
    _renderCharacterShadow(character);
    _renderCharacterPartLegs(character);
    _renderCharacterPartBody(character);
    _renderCharacterPartHead(character);
  }

  void _renderCharacterSwat(Character character){
    _renderCharacterShadow(character);
    _renderCharacterPart(character, SpriteLayer.Legs_Swat);
    _renderCharacterPart(character, SpriteLayer.Body_Swat);
    _renderCharacterPart(character, SpriteLayer.Head_Swat);
  }

  void _renderCharacterShadow(Character character){
    _renderCharacterPart(character, SpriteLayer.Shadow);
  }

  void _renderCharacterPartHead(Character character) {
    _renderCharacterPart(character, getSpriteIndexHead(character));
  }

  void _renderCharacterPartBody(Character character) {
    _renderCharacterPart(character, getSpriteIndexBody(character));
  }

  void _renderCharacterPartLegs(Character character) {
    _renderCharacterPart(character, getSpriteIndexLegs(character));
  }

  void _renderCharacterPart(Character character, int layer) {
    engine.mapDst(
        x: character.x,
        y: character.y - character.z,
        anchorX: 32,
        anchorY: 48,
        scale: 0.75,
    );
    engine.mapSrc64(
        x: getTemplateSrcX(character, size: 64),
        y: 1051.0 + (layer * 64)
    );
    engine.renderAtlas();
  }

  int getSpriteIndexHead(Character character){
    switch(character.helm){
      case SlotType.Empty:
        return SpriteLayer.Head_Plain;
      case SlotType.Steel_Helmet:
        return SpriteLayer.Head_Steel;
      case SlotType.Magic_Hat:
        return SpriteLayer.Head_Magic;
      case SlotType.Rogue_Hood:
        return SpriteLayer.Head_Rogue;
      default:
        throw Exception("cannot render head ${character.helm}");
    }
  }

  int getSpriteIndexBody(Character character){
    switch(character.armour){
      case SlotType.Empty:
        return SpriteLayer.Body_Cyan;
      case SlotType.Body_Blue:
        return SpriteLayer.Body_Blue;
      case SlotType.Armour_Padded:
        return SpriteLayer.Body_Blue;
      case SlotType.Magic_Robes:
        return SpriteLayer.Body_Blue;
      default:
        throw Exception("cannot render body ${character.armour}");
    }
  }

  int getSpriteIndexLegs(Character character){
    return SpriteLayer.Legs_Blue;
  }

  double getTemplateSrcX(Character character, {required double size}){
    final weapon = character.weapon;
    final variation = weapon == SlotType.Shotgun || TechType.isBow(weapon);

    switch(character.state) {
      case CharacterState.Running:
        const frames1 = [12, 13, 14, 15];
        const frames2 = [16, 17, 18, 19];
        return loop4(
            size: size,
            animation: variation ? frames2 : frames1,
            character: character,
            framesPerDirection: _framesPerDirectionHuman
        );

      case CharacterState.Idle:
        return single(
            size: size,
            frame: variation ? 1 : 2,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionHuman
        );

      case CharacterState.Hurt:
        return single(
            size: size,
            frame: 3,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionHuman
        );

      case CharacterState.Changing:
        return single(
            size: size,
            frame: 4,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionHuman
        );

      case CharacterState.Performing:
        final weapon = character.weapon;
        return animate(
            size: size,
            animation: TechType.isBow(weapon)
                ? animations.firingBow
                : weapon == SlotType.Handgun
                ? animations.firingHandgun
                : weapon == SlotType.Shotgun
                ? animations.firingShotgun
                : animations.strikingSword,
            character: character,
            framesPerDirection: _framesPerDirectionHuman
        );

      default:
        throw Exception("getCharacterSrcX cannot get body x for state ${character.state}");
    }
  }

  int mapEquippedWeaponToSpriteIndex(Character character){
     switch(character.weapon) {
       case WeaponType.Sword:
         return SpriteLayer.Sword_Wooden;
       case WeaponType.Bow:
         return SpriteLayer.Bow_Wooden;
       case WeaponType.Shotgun:
         return SpriteLayer.Bow_Wooden;
       case WeaponType.Handgun:
         return SpriteLayer.Weapon_Handgun;
       default:
         throw Exception("cannot map ${character.weapon} to sprite index");
     }
  }

  void _renderCharacterTemplateWeapon(Character character) {
    final equipped = character.weapon;
    if (equipped == WeaponType.Unarmed) return;

    final renderRow = const [
      WeaponType.Hammer,
      WeaponType.Axe,
      WeaponType.Pickaxe,
      WeaponType.Sword,
      WeaponType.Sword,
      WeaponType.Staff,
    ].indexOf(equipped);

    if (renderRow == -1) {
      _renderCharacterPart(character, mapEquippedWeaponToSpriteIndex(character));
      return;
    }
    engine.mapDst(
      x: character.x,
      y: character.y,
      anchorX: 48,
      anchorY: 61,
      scale: 1.0,
    );
    engine.mapSrc96(
        x: getTemplateSrcX(character, size: 96),
        y: 2159.0 + (renderRow * 96)
    );
    engine.renderAtlas();
  }

  void drawInteractableNpc(Character npc) {
    renderCharacter(npc);
    if (diffOver(npc.x, mouseWorldX, 50)) return;
    if (diffOver(npc.y, mouseWorldY, 50)) return;
    engine.renderText(npc.name, npc.x - 4.5 * npc.name.length, npc.y, style: state.nameTextStyle);
  }

  void renderCircle36V2(Position position){
    renderCircle36(position.x, position.y);
  }

  void renderCircle36(double x, double y){
    engine.render(dstX: x, dstY: y, srcX: 2420, srcY: 57, srcSize: 37);
  }

  void renderIconWood(Vector2 position){
    engine.renderCustom(
        dstX: position.x,
        dstY: position.y,
        srcX: 6189,
        srcWidth: 26,
        srcHeight: 37,
        anchorY: 0.66,
    );
  }

  void renderIconStone(Vector2 position){
    engine.renderCustom(
        dstX: position.x,
        dstY: position.y,
        srcX: 6216,
        srcWidth: 26,
        srcHeight: 36,
        anchorY: 0.66,
    );
  }

  void renderIconCoin(Vector2 position){
    engine.renderCustomV2(
      dst: position,
      srcX: 6245,
      srcWidth: 25,
      srcHeight: 32,
      anchorY: 0.66,
    );
  }

  void renderIconGold(Vector2 position){
    engine.renderCustomV2(
      dst: position,
      srcX: 6273,
      srcWidth: 26,
      srcHeight: 32,
      anchorY: 0.66,
    );
  }

  void renderIconExperience(Vector2 position){
    engine.renderCustomV2(
      dst: position,
      srcX: 6304,
      srcWidth: 17,
      srcHeight: 26,
      anchorY: 0.66,
    );
  }

  final _mouseSnap = Vector2(0, 0);

  void renderBuildMode() {
    final value = modules.game.structureType.value;
    if (value == null) return;

    final x = getMouseSnapX();
    final y = getMouseSnapY();
    _mouseSnap.x = x;
    _mouseSnap.y = y;

    switch (modules.game.structureType.value) {
      case StructureType.Tower:
        return isometric.render.renderTower(x, y);
      case StructureType.Palisade:
        return isometric.render.renderPalisade(x: x, y: y);
      case StructureType.Torch:
        return isometric.render.renderTorch(_mouseSnap);
      default:
        return;
    }
  }

  void renderShadow({required Position position, required double scale}){
    mapShadeShadow();
    engine.mapDst(
      x: position.x,
      y: position.y,
      anchorX: 4.0,
      anchorY: 4.0,
      scale: scale,
    );
    engine.renderAtlas();
  }


  void renderGridNode(int z, int row, int column, int type) {
    if (type == GridNodeType.Empty) return;
    final shade = gridLightDynamic[z][row][column];
    switch(type) {
      case GridNodeType.Bricks:
        return engine.renderCustom(
          dstX: getTileWorldX(row, column),
          dstY: getTileWorldY(row, column) - (z * 24),
          srcX: 7110,
          srcY: 72.0 * shade,
          srcWidth: 48,
          srcHeight: 72,
          anchorY: 0.3334,
        );
      case GridNodeType.Grass:
        return engine.renderCustom(
            dstX: getTileWorldX(row, column),
            dstY: getTileWorldY(row, column) - (z * 24),
            srcX: 7158,
            srcY: 72.0 * shade,
            srcWidth: 48,
            srcHeight: 72,
            anchorY: 0.3334,
        );
      case GridNodeType.Stairs_South:
        return engine.renderCustom(
          dstX: getTileWorldX(row, column),
          dstY: getTileWorldY(row, column) - (z * 24),
          srcX: 7254,
          srcY: 72.0 * shade,
          srcWidth: 48,
          srcHeight: 72,
          anchorY: 0.3334,
        );
      case GridNodeType.Stairs_West:
        return engine.renderCustom(
          dstX: getTileWorldX(row, column),
          dstY: getTileWorldY(row, column) - (z * 24),
          srcX: 7302,
          srcY: 72.0 * shade,
          srcWidth: 48,
          srcHeight: 72,
          anchorY: 0.3334,
        );
      case GridNodeType.Stairs_North:
        return engine.renderCustom(
            dstX: getTileWorldX(row, column),
            dstY: getTileWorldY(row, column) - (z * 24),
            srcX: 7351,
            srcY: 72.0 * shade,
            srcWidth: 48,
            srcHeight: 72,
            anchorY: 0.3334,
        );
      case GridNodeType.Stairs_East:
        return engine.renderCustom(
            dstX: getTileWorldX(row, column),
            dstY: getTileWorldY(row, column) - (z * 24),
            srcX: 7398,
            srcY: 72.0 * shade,
            srcWidth: 48,
            srcHeight: 72,
            anchorY: 0.3334,
        );
      case GridNodeType.Water:
        final animationFrame = (engine.frame ~/ 15) % 4;
        var height = 1;
        if (animationFrame == 1){
          height = 2;
        } else
        if (animationFrame == 3){
          height = 0;
        }

        return engine.renderCustom(
          dstX: getTileWorldX(row, column),
          dstY: getTileWorldY(row, column) - (z * 24) + height,
          srcX: 7206 + (animationFrame * 48),
          srcY: 72.0 * shade,
          srcWidth: 48,
          srcHeight: 72,
          anchorY: 0.3334,
        );

      case GridNodeType.Torch:
        return renderTorch(getPosition(getTileWorldX(row, column), getTileWorldY(row, column) - (z * 24) + 24));
      default:
        throw Exception("Cannot render grid node type $type");
    }
  }

  void renderWireFrame(int row, int column, int z){
    return engine.renderCustom(
      dstX: getTileWorldX(row, column),
      dstY: getTileWorldY(row, column) - (z * 24),
      srcX: 6895,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
    );
  }

  void renderWireFrameBlue(int row, int column, int z){
    return engine.renderCustom(
      dstX: getTileWorldX(row, column),
      dstY: getTileWorldY(row, column) - (z * 24),
      srcX: 6944,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
    );
  }


  void renderArrowUp(double x, double y){
    return engine.renderCustom(
      dstX: x,
      dstY: y,
      srcX: 6993,
      srcWidth: 13,
      srcHeight: 29,
      anchorY: 1.0,
    );
  }
}

class SpriteLayer {
  static const Shadow = 0;
  static const Legs_Blue = 1;
  static const Legs_Swat = 2;
  static const Staff_Wooden = 3;
  static const Sword_Wooden = 4;
  static const Sword_Steel = 5;
  static const Weapon_Shotgun = 6;
  static const Weapon_Handgun = 7;
  static const Bow_Wooden = 8;
  static const Body_Cyan = 9;
  static const Body_Blue = 10;
  static const Body_Swat = 11;
  static const Head_Plain = 12;
  static const Head_Steel = 13;
  static const Head_Rogue = 14;
  static const Head_Magic = 15;
  static const Head_Swat = 16;
}