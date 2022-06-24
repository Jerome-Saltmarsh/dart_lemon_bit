
import 'package:bleed_common/armour_type.dart';
import 'package:bleed_common/head_type.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/pants_type.dart';
import 'package:gamestream_flutter/color_pitch_black.dart';

import 'package:lemon_engine/render.dart';

import '../classes/character.dart';
import 'render_character_health_bar.dart';
import 'src_utils.dart';

void renderCharacter(Character character) {
  assert(character.direction >= 0);
  assert(character.direction < 8);

  if (character.dead) return;
  if (character.shade <= Shade.Medium){
    renderCharacterHealthBar(character);
  }

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
  final color = colorShades[character.shade];
  _renderCharacterShadow(character);
  _renderCharacterPartPants(character, color);
  _renderCharacterPartBody(character, color);
  _renderCharacterPartHead(character, color);
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
        character,
        _mapWeaponTypeToSpriteLayer(character.weapon),
        colorShades[character.shade]
    );
    return;
  }
  render(
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: _getTemplateSrcX(character, size: 96),
      srcY: 2159.0 + (renderRow * 96),
      srcWidth: 96,
      srcHeight: 96,
      anchorX: 0.5,
      anchorY: 0.66,
  );
}

void _renderCharacterShadow(Character character) {
  _renderCharacterPart(character, SpriteLayer.Shadow, 0);
}

void _renderCharacterPartHead(Character character, int color) {
  _renderCharacterPart(character, _mapHeadTypeToSpriteLayer(character.helm), color);
}

void _renderCharacterPartBody(Character character, int color) {
  _renderCharacterPart(character, _mapArmourTypeToSpriteLayer(character.armour), color);
}

void _renderCharacterPartPants(Character character, int color) {
  _renderCharacterPart(character, _mapLegTypeToSpriteLayer(character.pants), color);
}

void _renderCharacterPart(Character character, SpriteLayer layer, int color) {
  render(
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: _getTemplateSrcX(character, size: 64),
      srcY: 1051.0 + (layer.index * 64),
      srcWidth: 64.0,
      srcHeight: 64.0,
      scale: 0.75,
      anchorX: 0.5,
      anchorY: 0.75,
      color: color,
  );
}

double _getTemplateSrcX(Character character, {required double size}) {
  const framesPerDirection = 19;
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
          framesPerDirection: framesPerDirection
      );

    case CharacterState.Idle:
      return single(
          size: size,
          frame: variation ? 1 : 2,
          direction: character.direction,
          framesPerDirection: framesPerDirection
      );

    case CharacterState.Hurt:
      return single(
          size: size,
          frame: 3,
          direction: character.direction,
          framesPerDirection: framesPerDirection);

    case CharacterState.Changing:
      return single(
          size: size,
          frame: 4,
          direction: character.direction,
          framesPerDirection: framesPerDirection);

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
              : const [10, 10, 11, 11],
          character: character,
          framesPerDirection: framesPerDirection);

    default:
      throw Exception(
          "getCharacterSrcX cannot get body x for state ${character.state}");
  }
}

SpriteLayer _mapLegTypeToSpriteLayer(int legType){
   switch (legType) {
     case PantsType.brown:
       return SpriteLayer.Pants_Brown;
     case PantsType.blue:
       return SpriteLayer.Pants_Blue;
     case PantsType.white:
       return SpriteLayer.Pants_White;
     default:
       return SpriteLayer.Pants_Blue;
   }
}

SpriteLayer _mapArmourTypeToSpriteLayer(int armourType) {
  switch (armourType) {
    case ArmourType.shirtCyan:
      return SpriteLayer.Shirt_Cyan;
    case ArmourType.shirtBlue:
      return SpriteLayer.Shirt_Blue;
    case ArmourType.tunicPadded:
      return SpriteLayer.Tunic_Padded;
    default:
      throw Exception("cannot render body $armourType");
  }
}

SpriteLayer _mapWeaponTypeToSpriteLayer(int weaponType) {
  switch (weaponType) {
    case WeaponType.Sword:
      return SpriteLayer.Sword_Wooden;
    case WeaponType.Bow:
      return SpriteLayer.Bow_Wooden;
    case WeaponType.Shotgun:
      return SpriteLayer.Shotgun;
    case WeaponType.Handgun:
      return SpriteLayer.Handgun;
    default:
      throw Exception("cannot map ${weaponType} to sprite index");
  }
}

SpriteLayer _mapHeadTypeToSpriteLayer(int headType) {
  switch (headType) {
    case HeadType.None:
      return SpriteLayer.Head_Plain;
    case HeadType.Steel_Helm:
      return SpriteLayer.Steel_Helm;
    case HeadType.Wizards_Hat:
      return SpriteLayer.Hat_Wizard;
    case HeadType.Rogues_Hood:
      return SpriteLayer.Rogues_Hood;
    default:
      throw Exception("cannot render head ${headType}");
  }
}

enum SpriteLayer {
  Shadow,
  Pants_Blue,
  Pants_White,
  Pants_Brown,
  Pants_Swat,
  Staff_Wooden,
  Sword_Wooden,
  Sword_Steel,
  Shotgun,
  Handgun,
  Bow_Wooden,
  Shirt_Cyan,
  Shirt_Blue,
  Swat_Vest,
  Tunic_Padded,
  Head_Plain,
  Steel_Helm,
  Rogues_Hood,
  Hat_Wizard,
  Swat_Helm,
}
