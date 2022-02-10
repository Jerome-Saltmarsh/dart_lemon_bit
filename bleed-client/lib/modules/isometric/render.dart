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

final _size = 64;
final _sizeD = 64.0;
final _sizeDHalf = 32.0;
final _anchorX = _size * 0.5;
final _anchorY = _size * 0.75;

class IsometricRender {

  final IsometricState state;
  final IsometricProperties properties;
  final IsometricQueries queries;
  final IsometricMaps maps;
  IsometricRender(this.state, this.properties, this.queries, this.maps);

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
    mapCharacterDst(character, character.type);

    if (character.type != CharacterType.Human){
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

    // // mapCharacterDst(character, character.type);
    // _mapCharacterSrcShadow(character);
    // engine.actions.renderAtlas();
    // // mapCharacterDst(character, character.type);
    // _mapCharacterSrcLegs(character);
    // engine.actions.renderAtlas();
    // // mapCharacterDst(character, character.type);
    // _mapCharacterSrcArmour(character);
    // engine.actions.renderAtlas();
    // // mapCharacterDst(character, character.type);
    // _renderCharacterHead(character);
    // engine.actions.renderAtlas();

    renderCharacterPartLegs(character);
    renderCharacterPartBody(character);
    renderCharacterPartHead(character);
  }

  void renderCharacterPartLegs(Character character) {
    renderCharacterPart(character, getCharacterSrcYLegs(character));
  }

  void renderCharacterPartHead(Character character) {
    renderCharacterPart(character, getCharacterSrcYHead(character));
  }

  void renderCharacterPartBody(Character character) {
    renderCharacterPart(character, getCharacterSrcYBody(character));
  }

  void renderCharacterPart(Character character, double srcY) {
    engine.state.mapDst(
        x: character.x,
        y: character.y,
        anchorX: _sizeDHalf,
        anchorY: _sizeDHalf
    );
    engine.state.mapSrc(
        x: getCharacterSrcX(character),
        y: srcY
    );
    engine.actions.renderAtlas();
  }

  double getCharacterSrcYHead(Character character){
    return getIndexY(getSpriteIndexHead(character));
  }

  double getCharacterSrcYBody(Character character){
    return getIndexY(getSpriteIndexBody(character));
  }

  double getCharacterSrcYLegs(Character character){
    return getIndexY(getSpriteIndexLegs(character));
  }

  double getIndexY(int index){
    return atlas.parts.y + (index * _sizeD);
  }

  void mapCharacterDst2(Character character){
    engine.state.mapDst(
        x: character.x,
        y: character.y,
        anchorX: _sizeDHalf,
        anchorY: _sizeDHalf
    );
  }

  void _mapCharacterSrcShadow(Character character){
    switch(character.state){
      case CharacterState.Idle:
        srcSingle(atlas: atlas.shadow.idle, direction: character.direction);
        break;
      case CharacterState.Striking:
        srcAnimate(
          atlas: atlas.shadow.striking,
          animation: animations.human.strikingSword,
          direction: character.direction,
          frame: character.frame,
          framesPerDirection: 2,
        );
        break;
      case CharacterState.Running:
        srcLoop(
            atlas: atlas.shadow.running,
            direction: character.direction,
            frame: character.frame
        );
        break;
      case CharacterState.Changing:
        srcSingle(atlas: atlas.shadow.idle, direction: character.direction);
        break;
      case CharacterState.Performing:
        srcAnimate(
          atlas: atlas.shadow.striking,
          animation: animations.human.strikingSword,
          direction: character.direction,
          frame: character.frame,
          framesPerDirection: 2,
        );
        break;
    }
  }

  void _mapCharacterSrcLegs(Character character){
    switch(character.state){
      case CharacterState.Running:
        srcLoop(
            atlas: atlas.plain.legs.running,
            direction: character.direction,
            frame: character.frame
        );
        break;
      default:
        srcSingle(atlas: atlas.plain.legs.idle, direction: character.direction);
        break;
    }
  }

  void _mapCharacterSrcArmour(Character character){
    switch(character.state){
      case CharacterState.Idle:
        switch(character.equippedArmour){
          case SlotType.Body_Blue:
            srcSingle(atlas: atlas.blueTorso.idle, direction: character.direction);
            break;
          default:
            srcSingle(atlas: atlas.plain.torso.idle, direction: character.direction);
            break;
        }

        break;
      case CharacterState.Striking:
        switch (character.equippedArmour) {
          case SlotType.Body_Blue:
            srcAnimate(
              atlas: atlas.blueTorso.striking,
              animation: character.equippedWeapon.isBow ? animations.human.firingBow : animations.human.strikingSword,
              direction: character.direction,
              frame: character.frame,
              framesPerDirection: 2,
            );
            break;
          default:
            srcAnimate(
              atlas: atlas.plain.torso.striking,
              animation: character.equippedWeapon.isBow ? animations.human.firingBow : animations.human.strikingSword,
              direction: character.direction,
              frame: character.frame,
              framesPerDirection: 2,
            );
            break;
        }
        break;
      case CharacterState.Running:
        switch (character.equippedArmour) {
          case SlotType.Body_Blue:
            srcLoop(
                atlas: atlas.blueTorso.running,
                direction: character.direction,
                frame: character.frame
            );
            break;
          default:
            srcLoop(
                atlas: atlas.plain.torso.running,
                direction: character.direction,
                frame: character.frame
            );
            break;
        }
        break;
      case CharacterState.Changing:
        switch (character.equippedArmour) {
          case SlotType.Body_Blue:
            srcAnimate(
              atlas: atlas.blueTorso.changing,
              animation: animations.human.changing,
              direction: character.direction,
              frame: character.frame,
              framesPerDirection: 2,
            );
            break;
          default:
            srcAnimate(
              atlas: atlas.plain.torso.changing,
              animation: animations.human.changing,
              direction: character.direction,
              frame: character.frame,
              framesPerDirection: 2,
            );
            break;
        }
        break;
      case CharacterState.Performing:
        switch (character.equippedArmour) {
          case SlotType.Body_Blue:
            srcAnimate(
              atlas: atlas.blueTorso.striking,
              animation: animations.human.strikingSword,
              direction: character.direction,
              frame: character.frame,
              framesPerDirection: 2,
            );
            break;
          default:
            srcAnimate(
              atlas: atlas.plain.torso.striking,
              animation: animations.human.strikingSword,
              direction: character.direction,
              frame: character.frame,
              framesPerDirection: 2,
            );
            break;
        }
        break;
    }
  }

  void _renderCharacterHead(Character character){
    switch(character.state){
      case CharacterState.Striking:
        if (character.equippedHead == SlotType.Steel_Helmet){
          srcAnimate(
            atlas: atlas.headSteel.striking,
            animation: character.equippedWeapon.isBow ? animations.human.firingBow : animations.human.strikingSword,
            direction: character.direction,
            frame: character.frame,
            framesPerDirection: 2,
          );
        }else{
          srcAnimate(
            atlas: atlas.plain.head.striking,
            animation: character.equippedWeapon.isBow ? animations.human.firingBow : animations.human.strikingSword,
            direction: character.direction,
            frame: character.frame,
            framesPerDirection: 2,
          );
        }
        break;
      case CharacterState.Running:
        if (character.equippedHead == SlotType.Steel_Helmet){
          srcLoop(
              atlas: atlas.headSteel.running,
              direction: character.direction,
              frame: character.frame
          );
        }else{
          srcLoop(
              atlas: atlas.plain.head.running,
              direction: character.direction,
              frame: character.frame
          );
        }

        break;
      case CharacterState.Performing:
        if (character.equippedHead == SlotType.Steel_Helmet){
          srcAnimate(
            atlas: atlas.headSteel.striking,
            animation: animations.human.strikingSword,
            direction: character.direction,
            frame: character.frame,
            framesPerDirection: 2,
          );
        }else{
          srcAnimate(
            atlas: atlas.plain.head.striking,
            animation: animations.human.strikingSword,
            direction: character.direction,
            frame: character.frame,
            framesPerDirection: 2,
          );
        }
        break;
      default:
        if (character.equippedHead == SlotType.Steel_Helmet){
          srcSingle(atlas: atlas.headSteel.idle, direction: character.direction);
        } else {
          srcSingle(atlas: atlas.plain.head.idle, direction: character.direction);
        }
    }
    engine.actions.renderAtlas();
  }

  final framesPerDirection = 9;

  int getSpriteIndexHead(Character character){
    switch(character.equippedHead){
      case SlotType.Empty:
        return 6;
      case SlotType.Steel_Helmet:
        return 7;
      default:
        throw Exception("cannot render head ${character.equippedHead.name}");
    }
  }

  int getSpriteIndexBody(Character character){
    switch(character.equippedArmour){
      case SlotType.Empty:
        return 5;
      case SlotType.Body_Blue:
        return 4;
      default:
        throw Exception("cannot render body ${character.equippedHead.name}");
    }
  }

  int getSpriteIndexLegs(Character character){
    return 3;
  }

  final indexIdle = 0;
  final indexChanging = 1;
  final indexPrepareBow = 2;
  final indexPrepareAttack = 3;
  final indexReleaseAttack = 4;
  final indexRun = 5;

  void renderCharacterBody(Character character){

    final y = atlas.parts.y + (getSpriteIndexBody(character) * _sizeD);

    switch(character.state){
      case CharacterState.Idle:
        final x = ((character.direction.index * framesPerDirection) + indexIdle) * _sizeD;
        engine.state.mapSrc(
          x: x,
          y: y,
        );
        break;
      case CharacterState.Changing:
        final x = ((character.direction.index * framesPerDirection) + indexChanging) * _sizeD;
        engine.state.mapSrc(
          x: x,
          y: y,
        );
        break;
      case CharacterState.Striking:
        final animation = character.equippedWeapon.isBow ? animations.firingBow : animations.strikingSword;
        final animationFrame = min(character.frame, animation.length - 1);
        final frame = animation[animationFrame];
        final x = (character.direction.index * framesPerDirection * _sizeD) + (frame * _sizeD);
        engine.state.mapSrc(
          x: x,
          y: y,
        );
        break;

      case CharacterState.Running:
        final animation = animations.running;
        final animationFrame = character.frame % animation.length;
        final frame = animation[animationFrame];
        final x = (character.direction.index * framesPerDirection * _sizeD) + (frame * _sizeD);
        engine.state.mapSrc(
          x: x,
          y: y,
        );
        break;
    }

    engine.actions.renderAtlas();
    engine.state.mapDst(
        x: character.x,
        y: character.y,
        anchorX: _sizeDHalf,
        anchorY: _sizeDHalf
    );
  }


  double getCharacterSrcX(Character character){

    switch(character.state){
      case CharacterState.Idle:
        return ((character.direction.index * framesPerDirection) + indexIdle) * _sizeD;

      case CharacterState.Changing:
        return ((character.direction.index * framesPerDirection) + indexChanging) * _sizeD;

      case CharacterState.Striking:
        final animation = character.equippedWeapon.isBow ? animations.firingBow : animations.strikingSword;
        final animationFrame = min(character.frame, animation.length - 1);
        final frame = animation[animationFrame];
        return (character.direction.index * framesPerDirection * _sizeD) + (frame * _sizeD);

      case CharacterState.Running:
        final animation = animations.running;
        final animationFrame = character.frame % animation.length;
        final frame = animation[animationFrame];
        return (character.direction.index * framesPerDirection * _sizeD) + (frame * _sizeD);

      default:
        throw Exception("cannot get body x");
    }
  }

  void renderSlotType(SlotType slot, CharacterState characterState, Direction direction, int frame, double x, double y){
     if (characterState == CharacterState.Idle){
       int slotIndex = 5;
       engine.state.mapSrc(
           x: direction.index * framesPerDirection * _sizeD,
           y: atlas.parts.y + (slotIndex * _sizeD));
       engine.state.mapDst(x: x, y: y, anchorX: _sizeDHalf, anchorY: _sizeDHalf);
       engine.actions.renderAtlas();
     }
  }

  void _renderCharacterWeapon(Character character) {

    if (character.equippedWeapon == SlotType.Empty) return;

    if (character.equippedWeapon == SlotType.Sword_Wooden){

      if (character.state == CharacterState.Striking){
        srcAnimate(
          atlas: atlas.weapons.swordWooden.striking,
          animation: animations.human.strikingSword,
          direction: character.direction,
          frame: character.frame,
          framesPerDirection: 2,
        );
        mapCharacterDst(character, character.type);
        engine.actions.renderAtlas();
      }

      if (character.state == CharacterState.Idle){
        srcSingle(atlas: atlas.weapons.swordWooden.idle, direction: character.direction);
        mapCharacterDst(character, character.type);
        engine.actions.renderAtlas();
      }

      if (character.state == CharacterState.Running){
        srcLoop(
            atlas: atlas.weapons.swordWooden.running,
            direction: character.direction,
            frame: character.frame
        );
        mapCharacterDst(character, character.type);
        engine.actions.renderAtlas();
      }
    }
    if (character.equippedWeapon == SlotType.Sword_Short){
      if (character.state == CharacterState.Striking){
        srcAnimate(
          atlas: atlas.weapons.swordSteel.striking,
          animation: animations.human.strikingSword,
          direction: character.direction,
          frame: character.frame,
          framesPerDirection: 2,
        );
        mapCharacterDst(character, character.type);
        engine.actions.renderAtlas();
      }
      if (character.state == CharacterState.Idle){
        srcSingle(
            atlas: atlas.weapons.swordSteel.idle,
            direction: character.direction
        );
        mapCharacterDst(character, character.type);
        engine.actions.renderAtlas();
      }
      if (character.state == CharacterState.Running){
        srcLoop(
            atlas: atlas.weapons.swordSteel.running,
            direction: character.direction,
            frame: character.frame
        );
        mapCharacterDst(character, character.type);
        engine.actions.renderAtlas();
      }
    }

    if (character.equippedWeapon.isBow){

      switch(character.state){
        case CharacterState.Striking:
          srcAnimate(
              atlas: atlas.weapons.bowWooden.firing,
              direction: character.direction,
              frame: character.frame,
              animation: animations.bow.firing, framesPerDirection: 2
          );
          mapCharacterDst(character, character.type);
          engine.actions.renderAtlas();
          break;

        case CharacterState.Running:
          srcLoop(
              atlas: atlas.weapons.bowWooden.running,
              direction: character.direction,
              frame: character.frame
          );
          mapCharacterDst(character, character.type);
          engine.actions.renderAtlas();
          break;

        case CharacterState.Idle:
          srcSingle(
              atlas: atlas.weapons.bowWooden.idle,
              direction: character.direction
          );
          mapCharacterDst(character, character.type);
          engine.actions.renderAtlas();
          break;
      }
    }
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
      // scale: 1.0,
      x: character.x,
      y: character.y,
      anchorX: _anchorX,
      anchorY: _anchorY,
    );
  }
}
