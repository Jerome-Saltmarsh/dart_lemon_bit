
import 'package:bleed_common/library.dart';

import 'package:lemon_engine/render.dart';

import '../classes/character.dart';
import 'render_character_health_bar.dart';
import 'src_utils.dart';

void renderCharacter(Character character) {
  assert(character.direction >= 0);
  assert(character.direction < 8);


  // renderPixelRed(character.renderX, character.renderY);
  // final f = (engine.frame % 360) * degreesToRadians;
  // // renderCircle32(character.renderX, character.renderY, rotation: f);
  // renderCircle32(character.renderX, character.renderY, rotation: 0);
  // renderCircle32(character.renderX, character.renderY, rotation: piQuarter);
  // renderCircle32(character.renderX, character.renderY, rotation: piHalf);
  // renderCircle32(character.renderX, character.renderY, rotation: piQuarter * 3);
  // renderCircle32(character.renderX, character.renderY, rotation: pi);
  // renderCircle(x: character.renderX, y: character.renderY, size: 8);

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
        character,
        _mapEquippedWeaponToSpriteIndex(character)
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
  _renderCharacterPart(character, _SpriteLayer.Shadow);
}

void _renderCharacterPartHead(Character character) {
  _renderCharacterPart(character, _getSpriteIndexHead(character));
}

void _renderCharacterPartBody(Character character) {
  _renderCharacterPart(character, _getSpriteIndexBody(character));
}

void _renderCharacterPartLegs(Character character) {
  _renderCharacterPart(character, _SpriteLayer.Legs_Blue);
}

void _renderCharacterPart(Character character, int layer) {
  render(
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: _getTemplateSrcX(character, size: 64),
      srcY: 1051.0 + (layer * 64),
      srcWidth: 64.0,
      srcHeight: 64.0,
      scale: 0.75,
      anchorX: 0.5,
      anchorY: 0.75,
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

int _getSpriteIndexBody(Character character) {
  switch (character.armour) {
    case SlotType.Empty:
      return _SpriteLayer.Body_Cyan;
    case SlotType.Body_Blue:
      return _SpriteLayer.Body_Blue;
    case SlotType.Armour_Padded:
      return _SpriteLayer.Body_Blue;
    case SlotType.Magic_Robes:
      return _SpriteLayer.Body_Blue;
    default:
      throw Exception("cannot render body ${character.armour}");
  }
}

int _mapEquippedWeaponToSpriteIndex(Character character) {
  switch (character.weapon) {
    case WeaponType.Sword:
      return _SpriteLayer.Sword_Wooden;
    case WeaponType.Bow:
      return _SpriteLayer.Bow_Wooden;
    case WeaponType.Shotgun:
      return _SpriteLayer.Weapon_Shotgun;
    case WeaponType.Handgun:
      return _SpriteLayer.Weapon_Handgun;
    default:
      throw Exception("cannot map ${character.weapon} to sprite index");
  }
}

int _getSpriteIndexHead(Character character) {
  switch (character.helm) {
    case SlotType.Empty:
      return _SpriteLayer.Head_Plain;
    case SlotType.Steel_Helmet:
      return _SpriteLayer.Head_Steel;
    case SlotType.Magic_Hat:
      return _SpriteLayer.Head_Magic;
    case SlotType.Rogue_Hood:
      return _SpriteLayer.Head_Rogue;
    default:
      throw Exception("cannot render head ${character.helm}");
  }
}

class _SpriteLayer {
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
