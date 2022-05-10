import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/classes/DynamicObject.dart';
import 'package:gamestream_flutter/classes/static_object.dart';
import 'package:gamestream_flutter/classes/GeneratedObject.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/classes/Structure.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/mappers/mapParticleToDst.dart';
import 'package:gamestream_flutter/mappers/mapParticleToSrc.dart';
import 'package:gamestream_flutter/modules/isometric/animations.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/isometric/enums.dart';
import 'package:gamestream_flutter/modules/isometric/module.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import '../modules.dart';
import 'classes.dart';

const _framesPerDirectionHuman = 19;
const _framesPerDirectionZombie = 8;
final _screen = engine.screen;

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

class RenderList {
  List<Position> values;
  var index = 0;

  RenderList(this.values);
}

class IsometricRender {

  final IsometricModule state;
  IsometricRender(this.state);

  void renderTiles() {

    final screen = engine.screen;

    state.minRow = max(0, getRow(screen.left, screen.top));
    state.maxRow = min(state.totalRowsInt, getRow(screen.right, screen.bottom));
    state.minColumn = max(0, getColumn(screen.right, screen.top));
    state.maxColumn = min(state.totalColumnsInt, getColumn(screen.left, screen.bottom));

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
    final screenTop = engine.screen.top;
    final screenBottom = engine.screen.bottom;
    final screenBottom100 = engine.screen.bottom + 120;

    final staticObjects = isometric.staticObjects;
    final zombies = game.zombies;
    final players = game.players;
    final npcs = game.interactableNpcs;
    final dynamicObjects = game.dynamicObjects;
    final generatedObjects = game.generatedObjects;
    final structures = isometric.structures;

    final totalStaticObjects = staticObjects.length;
    final totalZombies = game.totalZombies.value;
    final totalPlayers = game.totalPlayers.value;
    final totalNpcs = game.totalNpcs;
    final totalDynamicObjects = game.dynamicObjects.length;
    final totalStructures = isometric.totalStructures;
    final totalGenerated = generatedObjects.length;

    var indexPlayer = 0;
    var indexStaticObject = 0;
    var indexParticle = 0;
    var indexZombie = 0;
    var indexNpc = 0;
    var indexDynamicObject = 0;
    var indexStructure = 0;
    var indexGenerated = 0;

    var remainingZombies = indexZombie < totalZombies;
    var remainingPlayers = indexPlayer < totalPlayers;
    var remainingNpcs = indexPlayer < totalNpcs;
    var remainingStaticObjects = indexStaticObject < totalStaticObjects;
    var remainingParticles = indexParticle < totalParticles;
    var remainingDynamicObjects = indexDynamicObject < totalDynamicObjects;
    var remainingStructures = indexStructure < totalStructures;
    var remainingBuildMode = modules.game.structureType.value != null;
    var remainingGenerated = indexGenerated < totalGenerated;

    var yPlayer = remainingPlayers ? players[0].y : 0;
    var yStaticObject = remainingStaticObjects ? staticObjects[0].y : 0;
    var yParticle = remainingParticles ? particles[0].y : 0;
    var yZombie = remainingZombies ? zombies[0].y : 0;
    var yNpc = remainingNpcs ? npcs[0].y : 0;
    var yDynamicObject = remainingDynamicObjects ? dynamicObjects[0].y : 0;
    var yStructure = remainingStructures ? structures[0].y : 0;
    var yBuildMode = remainingBuildMode ? mouseWorldY : 0;
    var yGenerated = remainingGenerated ? generatedObjects[0].y : 0;

    while (remainingGenerated) {
      final generatedObject = generatedObjects[indexGenerated];
      yGenerated = generatedObject.y;
      if (yGenerated < screenTop){
        indexGenerated++;
        remainingGenerated = indexGenerated < totalGenerated;
        continue;
      }
      if (yGenerated > screenBottom100) {
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
      yParticle = particle.y;
      if (yParticle < screenTop){
         indexParticle++;
         remainingParticles = indexParticle < totalParticles;
         continue;
      }
      if (yParticle > screenBottom100){
        remainingParticles = false;
      }
      break;
    }

    while (remainingDynamicObjects) {
      yDynamicObject = dynamicObjects[indexDynamicObject].y;
      if (yDynamicObject < screenTop) {
        indexDynamicObject++;
        remainingDynamicObjects = indexDynamicObject < totalDynamicObjects;
        continue;
      }
      if (yDynamicObject > screenBottom100) {
        remainingDynamicObjects = false;
      }
      break;
    }

    var particleIsBlood = remainingParticles ? particles[indexParticle].type == ParticleType.Blood : false;

    remainingParticles = false;

    while (true) {
      if (remainingPlayers) {
        if (!remainingGenerated || yPlayer < yGenerated) {
          if (!remainingBuildMode || yPlayer < yBuildMode) {
            if (!remainingStaticObjects || yPlayer < yStaticObject) {
              if (!remainingParticles ||
                  (yPlayer < yParticle && !particleIsBlood)) {
                if (!remainingZombies || yPlayer < yZombie) {
                  if (!remainingStructures || yPlayer < yStructure) {
                    if (!remainingDynamicObjects || yPlayer < yDynamicObject) {
                      if (!remainingNpcs || yPlayer < yNpc) {
                        renderCharacter(players[indexPlayer]);
                        indexPlayer++;
                        remainingPlayers = indexPlayer < totalPlayers;
                        while (remainingPlayers) {
                          final player = players[indexPlayer];
                          yPlayer = player.y;
                          if (yPlayer > screenBottom100){
                            remainingPlayers = false;
                            break;
                          }
                          final x = player.x;
                          if (x < screenLeft || x > screenRight || yPlayer < screenTop) {
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
      }

      if (remainingStaticObjects) {
        if (!remainingGenerated || yStaticObject < yGenerated) {
          if (!remainingBuildMode || yStaticObject < yBuildMode) {
            if (!remainingStructures || yStaticObject < yStructure) {
              if (!remainingParticles || (yStaticObject < yParticle && !particleIsBlood)) {
                if (!remainingDynamicObjects || yStaticObject < yDynamicObject) {
                  if (!remainingZombies || yStaticObject < yZombie) {
                    if (!remainingNpcs || yStaticObject < yNpc) {
                      renderStaticObject(staticObjects[indexStaticObject]);
                      indexStaticObject++;
                      remainingStaticObjects = indexStaticObject < totalStaticObjects;
                      while (remainingStaticObjects) {
                        final value = staticObjects[indexStaticObject];
                        yStaticObject = value.y;
                        if (yStaticObject > screenBottom100){
                          remainingStaticObjects = false;
                          break;
                        }
                        final x = value.x;
                        if (x < screenLeft || x > screenRight || yStaticObject < screenTop) {
                          indexStaticObject++;
                          remainingStaticObjects = indexStaticObject < totalStaticObjects;
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

            yParticle = particle.y;
            if (yParticle > screenBottom100){
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

        if (!remainingZombies || yParticle < yZombie) {
          if (!remainingGenerated || yParticle < yGenerated) {
            if (!remainingBuildMode || yParticle < yBuildMode) {
              if (!remainingStructures || yParticle < yStructure) {
                if (!remainingDynamicObjects || yParticle < yDynamicObject) {
                  if (!remainingNpcs || yParticle < yNpc) {
                    renderParticle(particles[indexParticle]);
                    indexParticle++;
                    remainingParticles = indexParticle < totalParticles;

                    while (remainingParticles) {
                      final particle = particles[indexParticle];

                      if (!particle.active) {
                        remainingParticles = false;
                        break;
                      }

                      yParticle = particle.y;
                      if (yParticle > screenBottom100){
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
      }

      if (remainingZombies) {
        if (!remainingGenerated || yZombie < yGenerated) {
          if (!remainingBuildMode || yZombie < yBuildMode) {
            if (!remainingStructures || yZombie < yStructure) {
              if (!remainingDynamicObjects || yZombie < yDynamicObject) {
                if (!remainingNpcs || yZombie < yNpc) {
                  renderZombie(zombies[indexZombie]);
                  indexZombie++;
                  remainingZombies = indexZombie < totalZombies;
                  while (remainingZombies) {
                    final zombie = zombies[indexZombie];
                    yZombie = zombie.y;
                    if (yZombie > screenBottom100){
                      remainingZombies = false;
                      break;
                    }
                    final x = zombie.x;
                    if (x < screenLeft || x > screenRight || yZombie < screenTop) {
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
      }

      if (remainingNpcs) {
        if (!remainingGenerated || yNpc < yGenerated) {
          if (!remainingBuildMode || yNpc < yBuildMode) {
            if (!remainingStructures || yNpc < yStructure) {
              if (!remainingDynamicObjects || yNpc < yDynamicObject) {
                drawInteractableNpc(npcs[indexNpc]);
                indexNpc++;
                remainingNpcs = indexNpc < totalNpcs;
                if (remainingNpcs) {
                  yNpc = npcs[indexNpc].y;
                  if (yNpc > screenBottom) {
                    remainingNpcs = false;
                  }
                }
                continue;
              }
            }
          }
        }
      }

      if (remainingDynamicObjects) {
        if (!remainingGenerated || yDynamicObject < yGenerated) {
          if (!remainingBuildMode || yDynamicObject < yBuildMode) {
            if (!remainingStructures || yDynamicObject < yStructure) {
              renderDynamicObject(dynamicObjects[indexDynamicObject]);
              indexDynamicObject++;
              remainingDynamicObjects = indexDynamicObject < totalDynamicObjects;

              while (remainingDynamicObjects) {
                yDynamicObject = dynamicObjects[indexDynamicObject].y;
                if (yDynamicObject > screenBottom100){
                  remainingDynamicObjects = false;
                  break;
                }
                final x = dynamicObjects[indexDynamicObject].x;
                if (x < screenLeft || x > screenRight) {
                  indexDynamicObject++;
                  remainingDynamicObjects = indexDynamicObject < totalDynamicObjects;
                  continue;
                }
                break;
              }
              continue;
            }
          }
        }
      }

      if (remainingStructures) {
        if (!remainingGenerated || yStructure < yGenerated) {
          if (!remainingBuildMode || yStructure < yBuildMode) {
            renderStructure(structures[indexStructure]);
            indexStructure++;
            remainingStructures = indexStructure < totalStructures;
            if (remainingStructures) {
              yStructure = structures[indexStructure].y;
              if (yStructure > screenBottom) {
                remainingStructures = false;
              }
              continue;
            }
          }
        }
      }

      if (remainingBuildMode){
        if (!remainingGenerated || yBuildMode < yGenerated) {
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
           yGenerated = generatedObjects[indexGenerated].y;
           if (yGenerated > screenBottom100){
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
          remainingZombies ||
          remainingPlayers ||
          remainingNpcs ||
          remainingStaticObjects ||
          remainingDynamicObjects ||
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
    }
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

  void renderTorch(Vector2 position) {
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
        srcY: 70 + (((position.x + position.y + engine.animationFrame) % 6) * 70),
        srcWidth: 25,
        srcHeight: 70,
        anchorY: 0.66
    );
  }

  void renderDynamicObject(DynamicObject dynamicObject){
    switch(dynamicObject.type) {
      case DynamicObjectType.Pot:
        renderPot(dynamicObject);
        break;
      case DynamicObjectType.Rock:
        renderRockLarge(dynamicObject);
        break;
      case DynamicObjectType.Tree:
        renderTree(dynamicObject);
        break;
      case DynamicObjectType.Chest:
        return renderChest(dynamicObject);
      case DynamicObjectType.House:
        return renderHouse(dynamicObject);
    }
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
    engine.renderCustom(
        dstX: position.x,
        dstY: position.y,
        srcX: 2049,
        srcY: isometric.getShadeAt(position) * 96,
        srcWidth: 96,
        srcHeight: 96,
        anchorY: 0.66,
    );
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

  void renderParticle(Particle value) {
    switch (value.type) {
      case ParticleType.Smoke:
        return renderSmoke(x: value.x, y: value.renderY, scale: value.renderScale);
      default:
        break;
    }

    final shade = state.getShadeAtPosition(value.x, value.y);
    if (shade >= Shade.Very_Dark) return;
    mapParticleToDst(value);
    mapParticleToSrc(value);
    engine.renderAtlas();

    if (value.casteShadow) {
      if (value.z < 0.1) return;
      mapShadeShadow();
      engine.mapDst(
          x: value.x,
          y: value.y,
          anchorX: 4.0,
          anchorY: 4.0,
          scale: value.z,
      );
      engine.renderAtlas();
    }
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
        y: ((engine.animationFrame % 4) * size),
        width: size,
        height: size
    );
  }

  void renderStaticObject(StaticObject value) {
    switch(value.type) {
      case ObjectType.Fireplace:
        return renderFireplace(value);
      case ObjectType.Long_Grass:
        return renderLongGrass(value);
      case ObjectType.Grave:
        return renderGrave(value);
      case ObjectType.Tree_Stump:
        return renderTreeStump(value);
      case ObjectType.Rock_Small:
        return renderRockSmall(value);
      case ObjectType.Flag:
        return renderFlag(value);
      default:
        break;
    }
  }

  void renderRockSmall(Position position){
    render(position: position, srcX: 5569, width: 12, height: 14);
  }
  
  void renderFireplace(Position position) {
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y,
      srcY: ((position.x + position.y + engine.animationFrame) % 6) * 43,
      srcX: 6464,
      srcWidth: 46,
      srcHeight: 43,
    );
  }

  void renderFlame(Position position){
    engine.renderCustom(
        dstX: position.x,
        dstY: position.y,
        srcY: ((position.x + position.y + engine.animationFrame) % 6) * 23,
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
    final shade = state.getShadeAtPosition(character.x, character.y);
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
    final weapon = character.equipped;
    final direction = character.direction;

    if (TechType.isBow(weapon)) {
       if (
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

    if (TechType.isMelee(weapon)) {
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
        y: character.y,
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
    final weapon = character.equipped;
    final variation = weapon == SlotType.Shotgun || SlotType.isBow(weapon);

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
        final weapon = character.equipped;
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
     switch(character.equipped) {
       case TechType.Sword:
         return SpriteLayer.Sword_Wooden;
       case TechType.Bow:
         return SpriteLayer.Bow_Wooden;
       case TechType.Shotgun:
         return SpriteLayer.Bow_Wooden;
       case TechType.Handgun:
         return SpriteLayer.Weapon_Handgun;
       default:
         throw Exception("cannot map ${character.equipped} to sprite index");
     }
  }

  void _renderCharacterTemplateWeapon(Character character) {
    final equipped = character.equipped;
    if (equipped == SlotType.Empty) return;
    if (TechType.isMelee(equipped)){
      engine.mapDst(
        x: character.x,
        y: character.y,
        anchorX: 48,
        anchorY: 61,
        scale: 1.0,
      );

      final row = const [
        TechType.Hammer,
        TechType.Axe,
        TechType.Pickaxe,
        TechType.Sword,
        TechType.Sword,
        TechType.Sword,
      ].indexOf(equipped);

      engine.mapSrc96(
          x: getTemplateSrcX(character, size: 96),
          y: 2159.0 + (row * 96)
      );
      engine.renderAtlas();
    } else {
      _renderCharacterPart(character, mapEquippedWeaponToSpriteIndex(character));
    }
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
}

