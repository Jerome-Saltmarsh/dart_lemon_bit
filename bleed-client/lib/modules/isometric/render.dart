import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:bleed_client/modules/isometric/animations.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/isometric/maps.dart';
import 'package:bleed_client/modules/isometric/properties.dart';
import 'package:bleed_client/modules/isometric/queries.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawCharacterHealthBar.dart';
import 'package:bleed_client/render/draw/drawInteractableNpcs.dart';
import 'package:bleed_client/render/mappers/animate.dart';
import 'package:bleed_client/render/mappers/loop.dart';
import 'package:bleed_client/render/mappers/mapCharacterDst.dart';
import 'package:bleed_client/render/mappers/mapCharacterSrc.dart';
import 'package:bleed_client/render/mappers/mapParticleToDst.dart';
import 'package:bleed_client/render/mappers/mapParticleToSrc.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';

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
    if (!maps.itemAtlas.containsKey(item.type)) return;

    final _anchor = 32;
    srcLoop(
        atlas: maps.itemAtlas[item.type]!,
        direction: Direction.Down,
        frame: core.state.timeline.frame,
        framesPerDirection: 8);
    engine.actions.mapDst(x: item.x - _anchor, y: item.y - _anchor,);
    engine.actions.renderAtlas();
  }

  void environmentObject(EnvironmentObject value) {
    if (!queries.environmentObjectOnScreenScreen(value)) return;

    final shade = isometric.properties.getShade(value.row, value.column);
    if (shade == Shade_PitchBlack) return;

    mapEnvironmentObjectToSrc(value);
    engine.actions.mapDst(x: value.dst[2], y: value.dst[3]);
    engine.actions.renderAtlas();
  }


  void drawCharacter(Character character) {
    if (!onScreen(character.x, character.y)) return;
    if (!character.alive) return;

    final shade = isometric.properties.getShadeAtPosition(character.x, character.y);
    if (shade > (Shade_Dark)) return;

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
    drawCharacterHealthBar(character);
  }

  void _renderCharacter(Character character, int shade) {
    mapCharacterDst(character, character.type);

    if (character.type != CharacterType.Human){
      mapCharacterSrc(
        type: character.type,
        state: character.state,
        slotType: character.equippedSlotType,
        direction: character.direction,
        frame: character.frame,
        shade: shade,
      );
      engine.actions.renderAtlas();
      return;
    }

    _renderCharacterShadow(character);
    _renderCharacterLegs(character);
    _renderCharacterTorso(character);
    _renderCharacterHead(character);
  }

  void _renderCharacterShadow(Character character){
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
      case CharacterState.ChangingWeapon:
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
    engine.actions.renderAtlas();
  }

  void _renderCharacterLegs(Character character){
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
    engine.actions.renderAtlas();
  }

  void _renderCharacterTorso(Character character){
    switch(character.state){
      case CharacterState.Idle:
        switch(character.equippedArmour){
          case SlotType.Armour_Standard:
            srcSingle(atlas: atlas.blueTorso.idle, direction: character.direction);
            break;
          default:
            srcSingle(atlas: atlas.plain.torso.idle, direction: character.direction);
            break;
        }

        break;
      case CharacterState.Striking:
        switch (character.equippedArmour) {
          case SlotType.Armour_Standard:
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
      case CharacterState.Running:
        switch (character.equippedArmour) {
          case SlotType.Armour_Standard:
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
      case CharacterState.ChangingWeapon:
        switch (character.equippedArmour) {
          case SlotType.Armour_Standard:
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
          case SlotType.Armour_Standard:
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
    engine.actions.renderAtlas();
  }

  void _renderCharacterHead(Character character){
    switch(character.state){
      case CharacterState.Idle:
        srcSingle(atlas: atlas.plain.head.idle, direction: character.direction);
        break;
      case CharacterState.Striking:
        srcAnimate(
          atlas: atlas.plain.head.striking,
          animation: animations.human.strikingSword,
          direction: character.direction,
          frame: character.frame,
          framesPerDirection: 2,
        );
        break;
      case CharacterState.Running:
        srcLoop(
            atlas: atlas.plain.head.running,
            direction: character.direction,
            frame: character.frame
        );
        break;
      case CharacterState.Performing:
        srcAnimate(
          atlas: atlas.plain.head.striking,
          animation: animations.human.strikingSword,
          direction: character.direction,
          frame: character.frame,
          framesPerDirection: 2,
        );
        break;
      default:
        srcSingle(atlas: atlas.plain.head.idle, direction: character.direction);
        break;

    }
    engine.actions.renderAtlas();
  }

  void _renderCharacterWeapon(Character character) {

    if (character.equippedSlotType == SlotType.Empty) return;

    if (character.equippedSlotType == SlotType.Sword_Wooden){

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
    if (character.equippedSlotType == SlotType.Sword_Short){
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

    if (character.equippedSlotType == SlotType.Bow_Wooden){

      if (character.state == CharacterState.Idle){
        srcSingle(
            atlas: atlas.weapons.bowWooden.idle,
            direction: character.direction
        );
        mapCharacterDst(character, character.type);
        engine.actions.renderAtlas();
      }

      if (character.state == CharacterState.Striking){
        srcAnimate(
            atlas: atlas.weapons.bowWooden.firing,
            direction: character.direction,
            frame: character.frame,
            animation: animations.bow.firing, framesPerDirection: 2
        );
        mapCharacterDst(character, character.type);
        engine.actions.renderAtlas();
      }

      if (character.state == CharacterState.Running){
        srcLoop(
            atlas: atlas.weapons.bowWooden.running,
            direction: character.direction,
            frame: character.frame
        );
        mapCharacterDst(character, character.type);
        engine.actions.renderAtlas();
      }
    }
  }
}

