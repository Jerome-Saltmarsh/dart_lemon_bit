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

final _Indexes indexes = _Indexes();

class _Indexes {
  final shadow = 1;
  final bowWooden = 2;
  final swordWooden = 3;
  final swordSteel = 4;
  final legsBlue = 5;
  final bodyBlue = 6;
  final bodyCyan = 7;
  final headPlain = 8;
  final headSteel = 9;
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
        final shade = dynamicShade[row][column];
        final top = atlasY + shade * tileSize; // top
        final left = tilesSrc[i];
        engineState.mapDstCheap(
          x: tilesDst[i + 2],
          y: tilesDst[i + 3],
        );
        engineState.mapSrc(x: left, y: top, width: tileSize, height: tileSize);
        engine.actions.renderAtlas();
      }
    }
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
              environmentObject(state.environmentObjects[indexEnv]);
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
        final zombie = game.zombies[indexZombie];

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

    final shade = isometric.properties.getShade(value.row, value.column);
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

    final shade = isometric.properties.getShadeAtPosition(character.x, character.y);
    if (shade > Shade.Dark) return;

    if (character.direction.index > Direction.Right.index){
      _renderCharacterWeapon(character);
      _renderCharacter(character, shade);
    } else {
      _renderCharacter(character, shade);
      _renderCharacterWeapon(character);
    }

    if (
    character.type == CharacterType.Witch ||
        character.type == CharacterType.Swordsman ||
        character.type == CharacterType.Archer
    ) {
      if (character.team == modules.game.state.player.team){
        drawCharacterMagicBar(character);
      }
    }

    if (shade <= Shade.Medium) {
      drawCharacterHealthBar(character);
    }

  }

  void _renderCharacter(Character character, int shade) {

    if (character.type != CharacterType.Human){
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
      return;
    }

    _renderCharacterShadow(character);
    _renderCharacterPartLegs(character);
    _renderCharacterPartBody(character);
    _renderCharacterPartHead(character);
  }

  void _renderCharacterShadow(Character character){
    _renderCharacterPart(character, indexes.shadow);
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

  void _renderCharacterPart(Character character, int index, {double scale = 0.7}) {
    engine.state.mapDst(
        x: character.x,
        y: character.y,
        anchorX: _sizeDHalf,
        anchorY: _sizeDHalf,
        scale: scale
    );
    engine.state.mapSrc(
        x: getCharacterSrcX(character),
        y: atlas.parts.y + ((index - 1) * _sizeD)
    );
    engine.actions.renderAtlas();
  }

  int getSpriteIndexHead(Character character){
    switch(character.equippedHead){
      case SlotType.Empty:
        return indexes.headPlain;
      case SlotType.Steel_Helmet:
        return indexes.headSteel;
      default:
        throw Exception("cannot render head ${character.equippedHead.name}");
    }
  }

  int getSpriteIndexBody(Character character){
    switch(character.equippedArmour){
      case SlotType.Empty:
        return indexes.bodyCyan;
      case SlotType.Body_Blue:
        return indexes.bodyBlue;
      default:
        throw Exception("cannot render body ${character.equippedHead.name}");
    }
  }

  int getSpriteIndexLegs(Character character){
    return indexes.legsBlue;
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

      case CharacterState.Running:
        final animation = animations.running;
        final animationFrame = character.frame % animation.length;
        final frame = animation[animationFrame] - 1;
        return (direction * _framesPerDirection * _sizeD) + (frame * _sizeD);

      default:
        throw Exception("getCharacterSrcX cannot get body x for state ${character.state.name}");
    }
  }

  int mapEquippedWeaponToSpriteIndex(Character character){
     switch(character.equippedWeapon){
       case SlotType.Sword_Wooden:
         return indexes.swordWooden;
       case SlotType.Sword_Short:
         return indexes.swordSteel;
       case SlotType.Bow_Wooden:
         return indexes.bowWooden;
       default:
         throw Exception("cannot map ${character.equippedWeapon} to sprite index");
     }
  }

  void _renderCharacterWeapon(Character character) {
    if (character.equippedWeapon == SlotType.Empty) return;
    _renderCharacterPart(character, mapEquippedWeaponToSpriteIndex(character));
  }

  final _width = 35.0;
  final _widthHalf = 35.0 * 0.5;
  final _height = 35.0 * goldenRatio_0381 * goldenRatio_0381 * goldenRatio_0381;
  final _marginBottom = 50;


  void drawCharacterHealthBar(Character character){
    engine.actions.setPaintColorWhite();
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
    isometric.render.drawCharacter(npc);
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
