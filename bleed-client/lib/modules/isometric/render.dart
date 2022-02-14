import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:bleed_client/modules/isometric/animations.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/isometric/maps.dart';
import 'package:bleed_client/modules/isometric/properties.dart';
import 'package:bleed_client/modules/isometric/queries.dart';
import 'package:bleed_client/modules/isometric/utilities.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/mapCharacterSrc.dart';
import 'package:bleed_client/render/mapParticleToDst.dart';
import 'package:bleed_client/render/mapParticleToSrc.dart';
import 'package:bleed_client/state/game.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/diff_over.dart';

import 'functions.dart';
import 'state.dart';

const _size = 64;
const _sizeD = 64.0;
const _sizeDHalf = 32.0;
const _anchorX = _size * 0.5;
const _anchorY = _size * 0.75;
const _framesPerDirection = 9;

const _indexIdle = 0;
const _indexChanging = 1;

enum SpriteLayer {
  Shadow,
  Sword_Wooden,
  Sword_Steel,
  Staff_Wooden,
  Bow_Wooden,
  Legs_Blue,
  Body_Cyan,
  Body_Blue,
  Head_Magic,
  Head_Rogue,
  Head_Plain,
  Head_Steel,
}

class IsometricRender {

  final IsometricState state;
  final IsometricProperties properties;
  final IsometricQueries queries;
  final IsometricMaps maps;
  IsometricRender(this.state, this.properties, this.queries, this.maps);

  void tiles() {
    engine.actions.setPaintColorWhite();
    // engine.state.canvas.drawRawAtlas(
    //     state.image,
    //     state.tilesDst,
    //     state.tilesSrc,
    //     null,
    //     null,
    //     null,
    //     engine.state.paint);

    final minRow = state.minRow;
    final maxRow = state.maxRow;
    final minColumn = state.minColumn;
    final maxColumn = state.maxColumn;
    final engineState = engine.state;
    final atlasY = atlas.tiles.y;
    final dynamicShade = state.dynamicShade;
    final totalColumnsInt = state.totalColumnsInt;
    final tilesSrc = state.tilesSrc;
    final tilesDst = state.tilesDst;

    for (int row = minRow; row < maxRow; row++){
      for(int column = minColumn; column < maxColumn; column++){
        final i = row * totalColumnsInt * 4 + (column * 4);
        engineState.mapDstCheap(
          x: tilesDst[i + 2],
          y: tilesDst[i + 3],
        );
        final shade = dynamicShade[row][column];
        final top = atlasY + shade * tileSize; // top
        final left = tilesSrc[i];
        engineState.mapSrc(x: left, y: top, width: tileSize, height: tileSize);
        engine.actions.renderAtlas();
      }
    }

    engine.actions.flushRenderBuffer();
  }

  void sprites() {
    engine.actions.setPaintColorWhite();
    int indexHuman = 0;
    int indexEnv = 0;
    int indexParticle = 0;
    int indexZombie = 0;
    int indexNpc = 0;

    final environmentObjects = state.environmentObjects;
    final particles = state.particles;
    final totalParticles = properties.totalActiveParticles;
    final totalEnvironment = environmentObjects.length;
    final zombies = game.zombies;
    final interactableNpcs = game.interactableNpcs;
    bool zombiesRemaining = indexZombie < game.totalZombies.value;
    bool humansRemaining = indexHuman < game.totalHumans;
    bool npcsRemaining = indexHuman < game.totalNpcs;
    bool environmentRemaining = indexEnv < totalEnvironment;
    bool particlesRemaining = indexParticle < totalParticles;
    final screenBottom = engine.state.screen.bottom;


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
        final humanY = game.humans[indexHuman].y;

        if (!environmentRemaining ||
            humanY < environmentObjects[indexEnv].y) {
          if (!particlesRemaining ||
              humanY < particles[indexParticle].y &&
                  particles[indexParticle].type != ParticleType.Blood) {
            if (!zombiesRemaining || humanY < zombies[indexZombie].y) {
              if (!npcsRemaining || humanY < interactableNpcs[indexNpc].y) {
                drawCharacter(game.humans[indexHuman]);
                indexHuman++;
                continue;
              }
            }
          }
        }
      }

      if (environmentRemaining) {
        final env = environmentObjects[indexEnv];
        if (!particlesRemaining ||
            env.y < particles[indexParticle].y &&
                particles[indexParticle].type != ParticleType.Blood) {
          if (!zombiesRemaining || env.y < zombies[indexZombie].y) {
            if (!npcsRemaining || env.y < interactableNpcs[indexNpc].y) {
              if (env.top > screenBottom) return;
              environmentObject(env);
              indexEnv++;
              continue;
            }
          }
        }
      }

      if (particlesRemaining) {
        final particle = particles[indexParticle];

        if (particle.type == ParticleType.Blood) {
          _drawParticle(particle);
          indexParticle++;
          continue;
        }

        if (!zombiesRemaining || particle.y < zombies[indexZombie].y) {
          if (!npcsRemaining || particle.y < interactableNpcs[indexNpc].y) {
            _drawParticle(particle);
            indexParticle++;
            continue;
          }
        }
      }

      if (zombiesRemaining) {
        final zombie = zombies[indexZombie];
        if (!npcsRemaining || zombie.y < interactableNpcs[indexNpc].y) {
          drawCharacter(zombies[indexZombie]);
          indexZombie++;
          continue;
        }
      }
      drawInteractableNpc(interactableNpcs[indexNpc]);
      indexNpc++;
    }
  }

  void _drawParticle(Particle value){
    if (!onScreen(value.x, value.y)) return;
    final shade = properties.getShadeAtPosition(value.x, value.y);
    if (shade >= Shade.Very_Dark) return;
    mapParticleToDst(value);
    mapParticleToSrc(value);
    engine.actions.renderAtlas();
  }

  void renderItem(Item item) {
    if (!maps.itemAtlas.containsKey(item.type)) return;

    final _anchor = 32;
    srcLoop(
        atlas: maps.itemAtlas[item.type]!,
        direction: Direction.Down,
        frame: core.state.timeline.frame,
        framesPerDirection: 8);
    engine.state.mapDst(x: item.x - _anchor, y: item.y - _anchor,);
    engine.actions.renderAtlas();
  }

  void environmentObject(EnvironmentObject value) {
    if (!queries.environmentObjectOnScreenScreen(value)) return;
    final shade = properties.getShade(value.row, value.column);
    if (shade == Shade.Pitch_Black) return;

    mapEnvironmentObjectToSrc(value);
      engine.state.mapDst(
          x: value.x,
          y: value.y,
          anchorX: value.anchorX,
          anchorY: value.anchorY
      );
      engine.actions.renderAtlas();
  }


  void drawCharacter(Character character) {
    if (!onScreen(character.x, character.y)) return;
    if (!character.alive) return;
    final shade = properties.getShadeAtPosition(character.x, character.y);
    if (shade > Shade.Dark) return;

    if (character.type == CharacterType.Zombie){
      _renderZombie(character, shade);
      return;
    }

    if (character.type != CharacterType.Template) {
      _renderCharacterStandard(character, shade);
      return;
    }

    if (character.direction.index > Direction.Right.index) {
      _renderCharacterTemplateWeapon(character);
      _renderCharacterTemplate(character);
      return;
    }
    _renderCharacterTemplate(character);
    _renderCharacterTemplateWeapon(character);
  }

  void _renderZombie(Character character, int shade) {
    final x = mapZombieSrcX(character, shade);
    final size = 64.0;
    final y = atlas.zombieY + (shade * size);
    engine.state.mapSrc(x: x, y: y);
    engine.state.mapDst(x: character.x, y: character.y, anchorX: 32, anchorY: 45, scale: 0.7);
    engine.actions.renderAtlas();
  }

  double mapZombieSrcX(Character character, int shade){
    switch(character.state){
      case CharacterState.Idle:
        return character.direction.index * 7.0;
      case CharacterState.Striking:
        return animate(animation: animations.zombie.striking, character: character, framesPerDirection: 7);
      case CharacterState.Running:
        return loop(animation: animations.zombie.running, character: character, framesPerDirection: 7);
      default:
        throw Exception("Render zombie invalid state ${character.state}");
    }
  }

  double loop({
    required List<int> animation,
    required Character character,
    required int framesPerDirection,
    double size = 64.0
  }){
    final animationFrame = character.frame % animation.length;
    final frame = animation[animationFrame] - 1;
    return (character.direction.index * framesPerDirection * size) + (frame * size);
  }

  double animate({
        required List<int> animation,
        required Character character,
        required int framesPerDirection,
        double size = 64.0
      }){
    final animationFrame = min(character.frame, animation.length - 1);
    final frame = animation[animationFrame] - 1;
    return (character.direction.index * framesPerDirection * size) + (frame * size);
  }

  void _renderCharacterStandard(Character character, int shade) {
      mapCharacterDst(character, character.type);
      mapCharacterSrc(
        type: character.type,
        state: character.state,
        slotType: character.equippedWeapon,
        direction: character.direction,
        frame: character.frame,
        shade: shade,
      );
    engine.actions.renderAtlas();
  }

  void _renderCharacterTemplate(Character character) {
    _renderCharacterShadow(character);
    _renderCharacterPartLegs(character);
    _renderCharacterPartBody(character);
    _renderCharacterPartHead(character);
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

  void _renderCharacterPart(Character character, SpriteLayer layer, {double scale = 0.7}) {
    engine.state.mapDst(
        x: character.x,
        y: character.y,
        anchorX: _sizeDHalf,
        anchorY: _anchorY,
        scale: scale
    );
    engine.state.mapSrc(
        x: getCharacterSrcX(character),
        y: atlas.parts.y + ((layer.index) * _sizeD)
    );
    engine.actions.renderAtlas();
  }

  SpriteLayer getSpriteIndexHead(Character character){
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
        throw Exception("cannot render head ${character.equippedHead.name}");
    }
  }

  SpriteLayer getSpriteIndexBody(Character character){
    switch(character.equippedArmour){
      case SlotType.Empty:
        return SpriteLayer.Body_Cyan;
      case SlotType.Body_Blue:
        return SpriteLayer.Body_Blue;
      default:
        throw Exception("cannot render body ${character.equippedHead.name}");
    }
  }

  SpriteLayer getSpriteIndexLegs(Character character){
    return SpriteLayer.Legs_Blue;
  }

  double getCharacterSrcX(Character character){
    final direction = character.direction.index;

    switch(character.state){
      case CharacterState.Idle:
        return ((direction * _framesPerDirection) + _indexIdle) * _sizeD;

      case CharacterState.Changing:
        return ((direction * _framesPerDirection) + _indexChanging) * _sizeD;

      case CharacterState.Striking:
        final animation = character.equippedWeapon.isBow ? animations.firingBow : animations.strikingSword;
        final animationFrame = min(character.frame, animation.length - 1);
        final frame = animation[animationFrame] - 1;
        return (direction * _framesPerDirection * _sizeD) + (frame * _sizeD);

      case CharacterState.Performing:
        final animation = character.equippedWeapon.isBow ? animations.firingBow : animations.strikingSword;
        final animationFrame = min(character.frame, animation.length - 1);
        final frame = animation[animationFrame] - 1;
        return (direction * _framesPerDirection * _sizeD) + (frame * _sizeD);

      case CharacterState.Running:
        final animation = animations.running;
        final animationFrame = character.frame % animation.length;
        final frame = animation[animationFrame] - 1;
        return (direction * _framesPerDirection * _sizeD) + (frame * _sizeD);

      default:
        throw Exception("getCharacterSrcX cannot get body x for state ${character.state.name}");
    }
  }

  SpriteLayer mapEquippedWeaponToSpriteIndex(Character character){
     switch(character.equippedWeapon){
       case SlotType.Sword_Wooden:
         return SpriteLayer.Sword_Wooden;
       case SlotType.Sword_Short:
         return SpriteLayer.Sword_Steel;
       case SlotType.Bow_Wooden:
         return SpriteLayer.Bow_Wooden;
       case SlotType.Staff_Wooden:
         return SpriteLayer.Staff_Wooden;
       default:
         throw Exception("cannot map ${character.equippedWeapon} to sprite index");
     }
  }

  void _renderCharacterTemplateWeapon(Character character) {
    if (character.equippedWeapon == SlotType.Empty) return;
    _renderCharacterPart(character, mapEquippedWeaponToSpriteIndex(character));
  }

  final _width = 35.0;
  final _widthHalf = 35.0 * 0.5;
  final _height = 35.0 * goldenRatio_0381 * goldenRatio_0381;
  final _marginBottom = 50;


  void drawCharacterHealthBar(Character character){
    if (!onScreen(character.x, character.y)) return;
    engine.actions.setPaintColor(colours.redDarkest);
    engine.state.canvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom, _width, _height), engine.state.paint);
    engine.actions.setPaintColor(colours.red);
    engine.state.canvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom, _width * character.health, _height), engine.state.paint);
  }

  void drawCharacterMagicBar(Character character){
    engine.actions.setPaintColorWhite();
    engine.state.canvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom + _height, _width, _height), engine.state.paint);
    engine.actions.setPaintColor(colours.blue);
    engine.state.canvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom + _height, _width * character.magic, _height), engine.state.paint);
  }

  void drawInteractableNpc(Character npc) {
    drawCharacter(npc);
    if (diffOver(npc.x, mouseWorldX, 50)) return;
    if (diffOver(npc.y, mouseWorldY, 50)) return;
    engine.draw.text(npc.name, npc.x - isometric.constants.charWidth * npc.name.length, npc.y, style: state.nameTextStyle);
  }

  void mapCharacterDst(
      Character character,
      CharacterType type,
      ) {
    return engine.state.mapDst(
      scale: 0.7,
      x: character.x,
      y: character.y,
      anchorX: _anchorX,
      anchorY: _anchorY,
    );
  }
}
