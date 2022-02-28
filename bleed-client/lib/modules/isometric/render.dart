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
import 'package:bleed_client/render/mapParticleToDst.dart';
import 'package:bleed_client/render/mapParticleToSrc.dart';
import 'package:bleed_client/state/game.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/diff_over.dart';

import 'functions.dart';
import 'state.dart';

const _size4 = 4.0;
const _size8 = 8.0;
const _size32 = 32.0;
const _size48 = 48.0;
const _size64 = 64.0;

const _scaleZombie = 0.7;
const _scaleTemplate = 0.75;
const _atlasZombieY = 789.0;
const _atlasSpritesY = 1051.0;
const _framesPerDirectionHuman = 19;
const _framesPerDirectionZombie = 8;

const _healthBarWidth = 35.0;
const _healthBarWidthHalf = _healthBarWidth * 0.5;
const _healthBarHeight = _healthBarWidth * goldenRatio_0381 * goldenRatio_0381;
const _healthBarMargin = 50;
const _animationRunning = [12, 13, 14, 15];
const _animationRunning2 = [16, 17, 18, 19];

enum SpriteLayer {
  Legs_Blue,
  Sword_Wooden,
  Weapon_Shotgun,
  Weapon_Handgun,
  Bow_Wooden,
  Body_Cyan,
  Head_Plain,
  Shadow,
  Sword_Steel,
  Staff_Wooden,
  Body_Blue,
  Head_Magic,
  Head_Rogue,
  Head_Steel,
}

class IsometricRender {

  final IsometricState state;
  final IsometricProperties properties;
  final IsometricQueries queries;
  final IsometricMaps maps;
  IsometricRender(this.state, this.properties, this.queries, this.maps);

  void tiles() {
    final screen = engine.screen;
    state.minRow = max(0, getRow(screen.left, screen.top));
    state.maxRow = min(state.totalRowsInt, getRow(screen.right, screen.bottom));
    state.minColumn = max(0, getColumn(screen.right, screen.top));
    state.maxColumn = min(state.totalColumnsInt, getColumn(screen.left, screen.bottom));

    final minRow = state.minRow;
    final maxRow = state.maxRow;
    final minColumn = state.minColumn;
    final maxColumn = state.maxColumn;
    final atlasY = atlas.tiles.y;
    final dynamicShade = state.dynamicShade;
    final totalColumnsInt = state.totalColumnsInt;
    final tilesSrc = state.tilesSrc;
    final tilesDst = state.tilesDst;

    for (var row = minRow; row < maxRow; row++){
      for(var column = minColumn; column < maxColumn; column++){
        final i = row * totalColumnsInt * 4 + (column * 4);
        engine.mapDstCheap(
          x: tilesDst[i + 2],
          y: tilesDst[i + 3],
        );
        final shade = dynamicShade[row][column];
        final top = atlasY + shade * tileSize; // top
        final left = tilesSrc[i];
        engine.mapSrc(x: left, y: top, width: tileSize, height: tileSize);
        engine.renderAtlas();
      }
    }
  }

  void sprites() {
    engine.setPaintColorWhite();

    final environmentObjects = state.environmentObjects;
    final particles = state.particles;
    final totalParticles = properties.totalActiveParticles;
    final totalEnvironment = environmentObjects.length;
    final zombies = game.zombies;
    final interactableNpcs = game.interactableNpcs;
    final screenBottom = engine.screen.bottom;

    var indexHuman = 0;
    var indexEnv = 0;
    var indexParticle = 0;
    var indexZombie = 0;
    var indexNpc = 0;
    var zombiesRemaining = indexZombie < game.totalZombies.value;
    var humansRemaining = indexHuman < game.totalHumans;
    var npcsRemaining = indexHuman < game.totalNpcs;
    var environmentRemaining = indexEnv < totalEnvironment;
    var particlesRemaining = indexParticle < totalParticles;

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
        final human = game.humans[indexHuman];
        final humanY = human.y;

        if (!environmentRemaining ||
            humanY < environmentObjects[indexEnv].y) {
          if (!particlesRemaining ||
              humanY < particles[indexParticle].y &&
                  particles[indexParticle].type != ParticleType.Blood) {
            if (!zombiesRemaining || humanY < zombies[indexZombie].y) {
              if (!npcsRemaining || humanY < interactableNpcs[indexNpc].y) {
                renderCharacter(human);
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
          _renderParticle(particle);
          indexParticle++;
          continue;
        }

        if (!zombiesRemaining || particle.y < zombies[indexZombie].y) {
          if (!npcsRemaining || particle.y < interactableNpcs[indexNpc].y) {
            _renderParticle(particle);
            indexParticle++;
            continue;
          }
        }
      }

      if (zombiesRemaining) {
        final zombie = zombies[indexZombie];
        if (!npcsRemaining || zombie.y < interactableNpcs[indexNpc].y) {
          renderCharacter(zombies[indexZombie]);
          indexZombie++;
          continue;
        }
      }
      drawInteractableNpc(interactableNpcs[indexNpc]);
      indexNpc++;
    }
  }

  void _renderParticle(Particle value){
    if (!onScreen(value.x, value.y)) return;
    final shade = state.getShadeAtPosition(value.x, value.y);
    if (shade >= Shade.Very_Dark) return;

    mapParticleToDst(value);
    mapParticleToSrc(value);
    engine.renderAtlas();

    if (value.hasShadow) {
      if (value.z < 0.1) return;
      mapShadeShadow();
      engine.mapDst(
          x: value.x,
          y: value.y,
          anchorX: _size4,
          anchorY: _size4,
          scale: value.z,
      );
      engine.renderAtlas();
    }
  }

  void mapShadeShadow(){
    engine.mapSrc(x: atlas.shadow.x, y: atlas.shadow.y, width: _size8, height: _size8);
  }

  void renderItem(Item item) {
    if (!maps.itemAtlas.containsKey(item.type)) return;

    final _anchor = 32;
    srcLoop(
        atlas: maps.itemAtlas[item.type]!,
        direction: Direction.Down.index,
        frame: core.state.timeline.frame,
        framesPerDirection: 8);
    engine.mapDst(x: item.x - _anchor, y: item.y - _anchor,);
    engine.renderAtlas();
  }

  void environmentObject(EnvironmentObject value) {
    if (!queries.environmentObjectOnScreenScreen(value)) return;
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

  void renderCharacter(Character character) {
    assert(character.direction >= 0);
    assert(character.direction < directionsLength);

    if (character.dead) return;

    if (!onScreen(character.x, character.y)) return;
    final shade = state.getShadeAtPosition(character.x, character.y);
    if (shade > Shade.Dark) return;
    renderCharacterHealthBar(character);

    if (character.type == CharacterType.Zombie){
      _renderZombie(character, shade);
      return;
    }

    final weapon = character.equippedWeapon;
    final variation = weapon.isShotgun || weapon.isBow;
    final maxDirection = variation ? Direction.Right : Direction.UpRight;
    final minDirection = variation ? Direction.DownLeft : Direction.Down;

    if ( character.direction <= minDirection.index && character.direction >= maxDirection.index) {
      _renderCharacterTemplate(character);
      _renderCharacterTemplateWeapon(character);
      return;
    }
    _renderCharacterTemplateWeapon(character);
    _renderCharacterTemplate(character);
  }

  void _renderZombie(Character character, int shade) {
    final x = mapZombieSrcX(character, shade);
    final y = _atlasZombieY + (shade * _size64);
    engine.mapSrc(x: x, y: y);
    engine.mapDst(x: character.x, y: character.y, anchorX: _size32, anchorY: _size48, scale: _scaleZombie);
    engine.renderAtlas();
  }

  double mapZombieSrcX(Character character, int shade){
    switch(character.state){
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
      case CharacterState.Running:
        return loop(
            animation: animations.zombie.running,
            character: character,
            framesPerDirection: _framesPerDirectionZombie
        );
      default:
        throw Exception("Render zombie invalid state ${character.state}");
    }
  }

  double single({
    required int frame,
    required num direction,
    required int framesPerDirection,
    num size = _size64
  }){
    return ((direction * framesPerDirection) + (frame - 1)) * _size64;
  }

  double loop({
    required List<int> animation,
    required Character character,
    required int framesPerDirection,
    double size = _size64
  }){
    final animationFrame = character.frame % animation.length;
    final frame = animation[animationFrame] - 1;
    return (character.direction * framesPerDirection * size) + (frame * size);
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
    // _renderCharacterShadow(character);
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

  void _renderCharacterPart(Character character, SpriteLayer layer) {
    engine.mapDst(
        x: character.x,
        y: character.y,
        anchorX: _size32,
        anchorY: _size48,
        scale: _scaleTemplate
    );

    engine.mapSrc(
        x: getTemplateSrcX(character),
        y: _atlasSpritesY + (layer.index * _size64)
    );

    engine.mapSrc(
        x: getTemplateSrcX(character),
        y: _atlasSpritesY + (layer.index * _size64)
    );
    engine.renderAtlas();
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
      case SlotType.Armour_Padded:
        return SpriteLayer.Body_Blue;
      case SlotType.Magic_Robes:
        return SpriteLayer.Body_Blue;
      default:
        throw Exception("cannot render body ${character.equippedHead.name}");
    }
  }

  SpriteLayer getSpriteIndexLegs(Character character){
    return SpriteLayer.Legs_Blue;
  }

  double getTemplateSrcX(Character character){
    final weapon = character.equippedWeapon;
    final variation = weapon.isShotgun || weapon.isBow;

    switch(character.state){
      case CharacterState.Idle:
        return single(
            frame: variation ? 1 : 2,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionHuman
        );

      case CharacterState.Hurt:
        return single(
            frame: 3,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionHuman
        );

      case CharacterState.Changing:
        return single(
            frame: 4,
            direction: character.direction,
            framesPerDirection: _framesPerDirectionHuman
        );

      case CharacterState.Performing:
        final weapon = character.equippedWeapon;
        return animate(
            animation: weapon.isBow
                ? animations.firingBow
                : weapon.isHandgun
                ? animations.firingHandgun
                : weapon.isShotgun
                ? animations.firingShotgun
                : animations.strikingSword,
            character: character,
            framesPerDirection: _framesPerDirectionHuman
        );

      case CharacterState.Running:
        return loop(
            animation: variation ? _animationRunning2 : _animationRunning,
            character: character,
            framesPerDirection: _framesPerDirectionHuman
        );

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
    if (character.equippedWeapon == SlotType.Empty) return;
    _renderCharacterPart(character, mapEquippedWeaponToSpriteIndex(character));
  }

  void drawCharacterHealthBar(Character character){
    if (!onScreen(character.x, character.y)) return;
    final shade = state.getShadeAtPosition(character.x, character.y);
    if (shade >= Shade.Dark) return;
    // engine.render(dstX: character.x , dstY: character.y, srcX: atlas.shades.red1.x, srcY: atlas.shades.red1.y, anchorX: _widthHalf);
    engine.setPaintColor(colours.redDarkest);
    engine.canvas.drawRect(Rect.fromLTWH(character.x - _healthBarWidthHalf, character.y - _healthBarMargin, _healthBarWidth, _healthBarHeight), engine.paint);
    engine.setPaintColor(colours.red);
    engine.canvas.drawRect(Rect.fromLTWH(character.x - _healthBarWidthHalf, character.y - _healthBarMargin, _healthBarWidth * character.health, _healthBarHeight), engine.paint);
  }

  void drawCharacterMagicBar(Character character){
    engine.setPaintColorWhite();
    engine.canvas.drawRect(Rect.fromLTWH(character.x - _healthBarWidthHalf, character.y - _healthBarMargin + _healthBarHeight, _healthBarWidth, _healthBarHeight), engine.paint);
    engine.setPaintColor(colours.blue);
    engine.canvas.drawRect(Rect.fromLTWH(character.x - _healthBarWidthHalf, character.y - _healthBarMargin + _healthBarHeight, _healthBarWidth * character.magic, _healthBarHeight), engine.paint);
  }

  void drawInteractableNpc(Character npc) {
    renderCharacter(npc);
    if (diffOver(npc.x, mouseWorldX, 50)) return;
    if (diffOver(npc.y, mouseWorldY, 50)) return;
    engine.draw.text(npc.name, npc.x - isometric.constants.charWidth * npc.name.length, npc.y, style: state.nameTextStyle);
  }

  void mapCharacterDst(
      Character character,
      CharacterType type,
      ) {
    return engine.mapDst(
      scale: 0.7,
      x: character.x,
      y: character.y,
      anchorX: _size32,
      anchorY: _size48,
    );
  }
}
