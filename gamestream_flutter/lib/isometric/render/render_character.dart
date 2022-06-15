import 'package:bleed_common/library.dart';
import 'package:bleed_common/weapon_type.dart';
import 'package:gamestream_flutter/modules/isometric/render.dart';
import 'package:lemon_engine/engine.dart';

import '../classes/character.dart';
import 'render_character_health_bar.dart';
import 'src_utils.dart';

void renderCharacter(Character character) {
  assert(character.direction >= 0);
  assert(character.direction < 8);

  if (character.dead) return;
  renderCharacterHealthBar(character);

  final weapon = character.weapon;
  final direction = character.direction;

  if (weapon == WeaponType.Bow || weapon == WeaponType.Shotgun) {
    if (direction == Direction.North_West ||
        direction == Direction.North ||
        direction == Direction.North_East ||
        direction == Direction.East) {
      _renderCharacterTemplateWeapon(character);
      _renderCharacterTemplate(character);
    } else {
      _renderCharacterTemplate(character);
      _renderCharacterTemplateWeapon(character);
    }
    return;
  }

  if (WeaponType.isMelee(weapon)) {
    if (direction == Direction.North_East ||
        direction == Direction.North ||
        direction == Direction.South_West) {
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

void _renderCharacterTemplate(Character character) {
  _renderCharacterShadow(character);
  _renderCharacterPartLegs(character);
  _renderCharacterPartBody(character);
  _renderCharacterPartHead(character);
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
    _renderCharacterPart(
        character, mapEquippedWeaponToSpriteIndex(character));
    return;
  }
  engine.mapDst(
    x: character.renderX,
    y: character.renderY,
    anchorX: 48,
    anchorY: 61,
    scale: 1.0,
  );
  engine.mapSrc96(
      x: getTemplateSrcX(character, size: 96), y: 2159.0 + (renderRow * 96));
  engine.renderAtlas();
}


void _renderCharacterShadow(Character character) {
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
    x: character.renderX,
    y: character.renderY,
    anchorX: 32,
    anchorY: 48,
    scale: 0.75,
  );
  engine.mapSrc64(
      x: getTemplateSrcX(character, size: 64), y: 1051.0 + (layer * 64));
  engine.renderAtlas();
}

double getTemplateSrcX(Character character, {required double size}) {
  const _framesPerDirectionHuman = 19;
  final weapon = character.weapon;
  final variation = weapon == WeaponType.Shotgun || weapon == WeaponType.Bow;

  switch (character.state) {
    case CharacterState.Running:
      const frames1 = [12, 13, 14, 15];
      const frames2 = [16, 17, 18, 19];
      return loop4(
          size: size,
          animation: variation ? frames2 : frames1,
          character: character,
          framesPerDirection: _framesPerDirectionHuman);

    case CharacterState.Idle:
      return single(
          size: size,
          frame: variation ? 1 : 2,
          direction: character.direction,
          framesPerDirection: _framesPerDirectionHuman);

    case CharacterState.Hurt:
      return single(
          size: size,
          frame: 3,
          direction: character.direction,
          framesPerDirection: _framesPerDirectionHuman);

    case CharacterState.Changing:
      return single(
          size: size,
          frame: 4,
          direction: character.direction,
          framesPerDirection: _framesPerDirectionHuman);

    case CharacterState.Performing:
      final weapon = character.weapon;
      return animate(
          size: size,
          animation: weapon == WeaponType.Bow
              ? const [5, 8, 6, 10]
              : weapon == WeaponType.Handgun
              ? const [8, 9, 8]
              : weapon == WeaponType.Shotgun
              ? const [6, 7, 6, 6, 6, 8, 8, 6]
              : [10, 10, 11, 11],
          character: character,
          framesPerDirection: _framesPerDirectionHuman);

    default:
      throw Exception(
          "getCharacterSrcX cannot get body x for state ${character.state}");
  }
}

int getSpriteIndexBody(Character character) {
  switch (character.armour) {
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

int mapEquippedWeaponToSpriteIndex(Character character) {
  switch (character.weapon) {
    case WeaponType.Sword:
      return SpriteLayer.Sword_Wooden;
    case WeaponType.Bow:
      return SpriteLayer.Bow_Wooden;
    case WeaponType.Shotgun:
      return SpriteLayer.Weapon_Shotgun;
    case WeaponType.Handgun:
      return SpriteLayer.Weapon_Handgun;
    default:
      throw Exception("cannot map ${character.weapon} to sprite index");
  }
}

int getSpriteIndexHead(Character character) {
  switch (character.helm) {
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

int getSpriteIndexLegs(Character character) {
  return SpriteLayer.Legs_Blue;
}