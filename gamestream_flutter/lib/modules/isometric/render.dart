import 'dart:math';

import 'package:bleed_common/CharacterState.dart';
import 'package:bleed_common/SlotType.dart';
import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/Direction.dart';
import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/classes/Character.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:gamestream_flutter/modules/isometric/animations.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/isometric/enums.dart';
import 'package:gamestream_flutter/modules/isometric/module.dart';
import 'package:gamestream_flutter/render/mapParticleToDst.dart';
import 'package:gamestream_flutter/render/mapParticleToSrc.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/diff.dart';

import '../modules.dart';

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

  void renderSprites() {
    engine.setPaintColorWhite();

    modules.isometric.sortParticles();

    var totalParticles = 0;
    final particles = modules.isometric.particles;

    for (final particle in particles){
        if (!particle.active) continue;
        totalParticles++;
    }

    final environmentObjects = state.environmentObjects;
    final totalEnvironment = environmentObjects.length;
    final zombies = game.zombies;
    final players = game.players;
    final npcs = game.interactableNpcs;
    final screenBottom = engine.screen.bottom;
    final totalZombies = game.totalZombies.value;
    final totalPlayers = game.totalPlayers.value;
    final totalNpcs = game.totalNpcs;

    var indexPlayer = 0;
    var indexEnv = 0;
    var indexParticle = 0;
    var indexZombie = 0;
    var indexNpc = 0;
    var zombiesRemaining = indexZombie < totalZombies;
    var playersRemaining = indexPlayer < totalPlayers;
    var npcsRemaining = indexPlayer < totalNpcs;
    var environmentRemaining = indexEnv < totalEnvironment;
    var particlesRemaining = indexParticle < totalParticles;

    var playerY = playersRemaining ? players[0].y : 0;
    var envY = environmentRemaining ? environmentObjects[0].y : 0;
    var particleY = particlesRemaining ? particles[0].y : 0;
    var particleIsBlood = particlesRemaining ? particles[0].type == ParticleType.Blood : false;
    var zombieY = zombiesRemaining ? zombies[0].y : 0;
    var npcY = npcsRemaining ? npcs[0].y : 0;

    while (true) {

      if (playersRemaining) {

        if (!environmentRemaining || playerY < envY) {
          if (!particlesRemaining || (playerY < particleY && !particleIsBlood)) {
            if (!zombiesRemaining || playerY < zombieY) {
              if (!npcsRemaining || playerY < npcY) {
                renderCharacter(players[indexPlayer]);
                indexPlayer++;
                playersRemaining = indexPlayer < totalPlayers;
                if (playersRemaining) {
                  playerY = players[indexPlayer].y;
                }
                continue;
              }
            }
          }
        }
      }

      if (environmentRemaining) {
        if (!particlesRemaining || envY < particleY && !particleIsBlood) {
          if (!zombiesRemaining || envY < zombieY) {
            if (!npcsRemaining || envY < npcY) {
              if (envY > screenBottom){
                return;
              }
              final env = environmentObjects[indexEnv];
              renderEnvironmentObject(env);
              indexEnv++;
              environmentRemaining = indexEnv < totalEnvironment;
              if (environmentRemaining){
                envY = environmentObjects[indexEnv].y;
              }
              continue;
            }
          }
        }
      }

      if (particlesRemaining) {
        if (particleIsBlood) {
          renderParticle(particles[indexParticle]);
          indexParticle++;
          particlesRemaining = indexParticle < totalParticles;
          if (particlesRemaining){
            var nextParticle = particles[indexParticle];
            particleIsBlood = nextParticle.type == ParticleType.Blood;
            particleY = nextParticle.y;
          }
          continue;
        }

        if (!zombiesRemaining || particleY < zombieY) {
          if (!npcsRemaining || particleY < npcY) {
            renderParticle(particles[indexParticle]);
            indexParticle++;
            particlesRemaining = indexParticle < totalParticles;
            if (particlesRemaining){
              var nextParticle = particles[indexParticle];
              particleIsBlood = nextParticle.type == ParticleType.Blood;
              particleY = nextParticle.y;
            }
            continue;
          }
        }
      }

      if (zombiesRemaining) {
        if (!npcsRemaining || zombieY < npcY) {
          renderZombie(zombies[indexZombie]);
          indexZombie++;
          zombiesRemaining = indexZombie < totalZombies;
          if (zombiesRemaining){
            zombieY = zombies[indexZombie].y;
          }
          continue;
        }
      }

      if (npcsRemaining) {
        drawInteractableNpc(npcs[indexNpc]);
        indexNpc++;
        npcsRemaining = indexNpc < totalNpcs;
        if (npcsRemaining){
          npcY = npcs[indexNpc].y;
        }
        continue;
      }

      return;
    }
  }

  void renderParticle(Particle value){
    if (!_screen.contains(value.x, value.y)) return;
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

  void renderEnvironmentObject(EnvironmentObject value) {
    if (!_screen.containsV(value)) return;
    final shade = state.getShade(value.row, value.column);
    if (shade == Shade.Pitch_Black) return;

    mapEnvironmentObjectToSrc(value);
    engine.mapDst(
      x: value.x,
      y: value.y,
      anchorX: value.anchorX,
      anchorY: value.anchorY
    );
    engine.renderAtlas();
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

    final weapon = character.equippedWeapon;
    final variation = weapon == SlotType.Shotgun || SlotType.isBow(weapon);
    final maxDirection = variation ? Direction.Right : Direction.UpRight;
    final minDirection = variation ? Direction.DownLeft : Direction.Down;
    final direction = character.direction;

    if (direction <= minDirection && direction >= maxDirection) {
      _renderCharacterTemplate(character);
      _renderCharacterTemplateWeapon(character);
      return;
    }
    _renderCharacterTemplateWeapon(character);
    _renderCharacterTemplate(character);
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

      case stateRunning:
        const frames = [3, 4, 5, 6];
        return loop4(
            animation: frames,
            character: character,
            framesPerDirection: _framesPerDirectionZombie
        );

      case stateIdle:
        return single(
            frame: 1,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionZombie
        );

      case stateHurt:
        return single(
            frame: 2,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionZombie
        );

      case statePerforming:
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
    switch(character.equippedHead){
      case SlotType.Empty:
        return SpriteLayer.Head_Plain;
      case SlotType.Steel_Helmet:
        return SpriteLayer.Head_Steel;
      case SlotType.Magic_Hat:
        return SpriteLayer.Head_Magic;
      case SlotType.Rogue_Hood:
        return SpriteLayer.Head_Rogue;
      default:
        throw Exception("cannot render head ${character.equippedHead}");
    }
  }

  int getSpriteIndexBody(Character character){
    switch(character.equippedArmour){
      case SlotType.Empty:
        return SpriteLayer.Body_Cyan;
      case SlotType.Body_Blue:
        return SpriteLayer.Body_Blue;
      case SlotType.Armour_Padded:
        return SpriteLayer.Body_Blue;
      case SlotType.Magic_Robes:
        return SpriteLayer.Body_Blue;
      default:
        throw Exception("cannot render body ${character.equippedHead}");
    }
  }

  int getSpriteIndexLegs(Character character){
    return SpriteLayer.Legs_Blue;
  }

  double getTemplateSrcX(Character character, {required double size}){
    final weapon = character.equippedWeapon;
    final variation = weapon == SlotType.Shotgun || SlotType.isBow(weapon);

    switch(character.state) {
      case stateRunning:
        const frames1 = [12, 13, 14, 15];
        const frames2 = [16, 17, 18, 19];
        return loop4(
            size: size,
            animation: variation ? frames2 : frames1,
            character: character,
            framesPerDirection: _framesPerDirectionHuman
        );

      case stateIdle:
        return single(
            size: size,
            frame: variation ? 1 : 2,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionHuman
        );

      case stateHurt:
        return single(
            size: size,
            frame: 3,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionHuman
        );

      case stateChanging:
        return single(
            size: size,
            frame: 4,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionHuman
        );

      case statePerforming:
        final weapon = character.equippedWeapon;
        return animate(
            size: size,
            animation: SlotType.isBow(weapon)
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
     switch(character.equippedWeapon){
       case SlotType.Sword_Wooden:
         return SpriteLayer.Sword_Wooden;
       case SlotType.Sword_Short:
         return SpriteLayer.Sword_Steel;
       case SlotType.Sword_Long:
         return SpriteLayer.Sword_Steel;
       case SlotType.Bow_Wooden:
         return SpriteLayer.Bow_Wooden;
       case SlotType.Bow_Green:
         return SpriteLayer.Bow_Wooden;
       case SlotType.Bow_Gold:
         return SpriteLayer.Bow_Wooden;
       case SlotType.Staff_Wooden:
         return SpriteLayer.Staff_Wooden;
       case SlotType.Staff_Blue:
         return SpriteLayer.Staff_Wooden;
       case SlotType.Staff_Golden:
         return SpriteLayer.Staff_Wooden;
       case SlotType.Handgun:
         return SpriteLayer.Weapon_Handgun;
       case SlotType.Shotgun:
         return SpriteLayer.Weapon_Shotgun;
       default:
         throw Exception("cannot map ${character.equippedWeapon} to sprite index");
     }
  }

  void _renderCharacterTemplateWeapon(Character character) {
    final equipped = character.equippedWeapon;
    if (equipped == SlotType.Empty) return;
    if (SlotType.isMelee(equipped)){
      engine.mapDst(
        x: character.x,
        y: character.y,
        anchorX: 48,
        anchorY: 61,
        scale: 1.0,
      );
      final row = equipped == SlotType.Sword_Short || equipped == SlotType.Sword_Short ? 0
                              : equipped == SlotType.Sword_Wooden ? 1 : 0;
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
    engine.draw.text(npc.name, npc.x - 4.5 * npc.name.length, npc.y, style: state.nameTextStyle);
  }
}
