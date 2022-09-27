import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/render/renderCharacter.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:gamestream_flutter/modules/game/render_rotated.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_math/library.dart';

import '../classes/character.dart';
import 'render_character_health_bar.dart';
import 'src_utils.dart';

void renderLine(double x, double y, double z, double angle, double distance) {
  final x2 = x + getAdjacent(angle, distance);
  final y2 = y + getOpposite(angle, distance);
  drawLine(
    projectX(x, y),
    projectY(x, y, z),
    projectX(x2, y2),
    projectY(x2, y2, z),
  );
}

void renderArrow(double x, double y, double z, double angle) {
  const pi3Quarters = piQuarter * 3;
  x += getAdjacent(angle, 30);
  y += getOpposite(angle, 30);
  renderRotated(
    dstX: projectX(x, y),
    dstY: projectY(x, y, z),
    srcX: 128,
    srcY: 0,
    srcWidth: 32,
    srcHeight: 32,
    rotation: angle + pi3Quarters,
  );
}

void renderCharacterWeaponHandgun(Character character) {
  final weaponState = character.weaponState;
  final angle = character.aimAngle + piQuarter;
  final distance = 15.0;
  const size = 32.0;
  final direction = character.aimDirection;

  render(
    dstX: character.renderX + getAdjacent(angle, distance),
    dstY: character.renderY + getOpposite(angle, distance) - 8,
    srcX: 224,
    srcY: (size * direction * 3) + (weaponState * size),
    srcWidth: size,
    srcHeight: size,
  );
}

void renderCharacterWeapon(Character character) {
  switch (character.weapon) {
    case AttackType.Handgun:
      return renderCharacterWeaponHandgun(character);
    case AttackType.Shotgun:
      return renderCharacterWeaponShotgun(character);
    case AttackType.Blade:
      return renderCharacterWeaponBlade(character);
  }
}

void renderCharacterWeaponShotgun(Character character) {
  final weaponState = character.weaponState;
  final angle = character.aimAngle + piQuarter;
  final distance = 15.0;
  const size = 32.0;
  final direction = character.aimDirection;

  render(
    dstX: character.renderX + getAdjacent(angle, distance),
    dstY: character.renderY + getOpposite(angle, distance) - 8,
    srcX: 256,
    srcY: (size * direction * 3) + (weaponState * size),
    srcWidth: size,
    srcHeight: size,
  );
}

void renderCharacterWeaponBlade(Character character) {
  // final weaponState = character.weaponState;
  final angle = character.aimAngle + piQuarter;
  final distance = 15.0;
  const size = 64.0;
  final direction = character.aimDirection;

  render(
    dstX: character.renderX + getAdjacent(angle, distance),
    dstY: character.renderY + getOpposite(angle, distance) - 8,
    srcX: 304,
    srcY: size * direction,
    srcWidth: size,
    srcHeight: size,
  );
}

void renderCharacterTemplateWithoutWeapon(Character character,
    {bool renderHealthBar = true}) {
  assert(character.direction >= 0);
  assert(character.direction < 8);
  if (character.deadOrDying) return;

  if (renderHealthBar) {
    renderCharacterHealthBar(character);
  }

  // renderText(text: '${character.aimDirection}', x: character.renderX, y: character.renderY - 100);
  // renderText(text: '${character.aimAngle.toStringAsFixed(3)}', x: character.renderX, y: character.renderY - 75);

  _renderCharacterTemplate(character, colorShades[character.tileBelow.shade]);
}

void renderCharacterTemplateWithWeapon(Character character,
    {bool renderHealthBar = true}) {
  assert(character.direction >= 0);
  assert(character.direction < 8);

  if (character.deadOrDying) return;

  if (renderHealthBar) {
    renderCharacterHealthBar(character);
  }

  // renderArrow(character.x, character.y, character.z, character.aimAngle);
  // renderText(text: '${character.aimDirection}', x: character.renderX, y: character.renderY - 100);

  final weaponType = character.weapon;
  final direction = character.direction;
  final color = colorShades[character.tileBelow.shade];

  if (weaponType == AttackType.Bow || weaponType == AttackType.Shotgun) {
    if (direction == Direction.North_West ||
        direction == Direction.North ||
        direction == Direction.North_East ||
        direction == Direction.East) {
      _renderCharacterTemplateWeapon(character);
      _renderCharacterTemplate(character, color);
    } else {
      _renderCharacterTemplate(character, color);
      _renderCharacterTemplateWeapon(character);
    }
    return;
  }

  if (AttackType.isMelee(weaponType)) {
    if (direction == Direction.North_East ||
        direction == Direction.North ||
        direction == Direction.North_West ||
        direction == Direction.West ||
        direction == Direction.South_West) {
      _renderCharacterTemplateWeapon(character);
      _renderCharacterTemplate(character, color);
    } else {
      _renderCharacterTemplate(character, color);
      _renderCharacterTemplateWeapon(character);
    }
    return;
  }
  _renderCharacterTemplate(character, color);
  _renderCharacterTemplateWeapon(character);
}

void _renderCharacterTemplate(Character character, int color) {
  if (character.tile.type != NodeType.Grass_Long) {
    _renderCharacterShadow(character);

    final diff = Direction.getDifference(character.renderDirection, character.aimDirection).abs();

    // renderText(text: '$diff', x: character.renderX, y: character.renderY - 100);

    if (diff == 4 && character.running) {
      _renderCharacterPartCustom(
         variation: false,
         renderX: character.renderX,
         renderY: character.renderY,
         state: character.state,
         frame: character.frame,
         direction: (character.renderDirection + 4) % 8,
         layer: _mapLegTypeToSpriteLayer(character.legs),
         color: color,
         weapon: character.weapon,
      );
      _renderCharacterPartCustom(
        variation: getVariation(character),
        renderX: character.renderX,
        renderY: character.renderY,
        state: character.usingWeapon ? CharacterState.Performing : character.state,
        frame: character.frame,
        direction: (character.renderDirection + 4) % 8,
        layer: _mapArmourTypeToSpriteLayer(character.body),
        color: color,
        weapon: character.weapon,
      );
      _renderCharacterPartHead(character, color);
      return;
    }
  }
  _renderCharacterPartPants(character, color);
  // _renderCharacterPartBody(character, color);

  _renderCharacterPartCustom(
    variation: getVariation(character),
    renderX: character.renderX,
    renderY: character.renderY,
    state: character.usingWeapon ? CharacterState.Performing : character.state,
    frame: character.frame,
    direction: character.renderDirection,
    layer: _mapArmourTypeToSpriteLayer(character.body),
    color: color,
    weapon: character.weapon,
  );

  _renderCharacterPartHead(character, color);
}

void _renderCharacterTemplateWeapon(Character character) {
  final equipped = character.weapon;
  if (equipped == AttackType.Unarmed) return;

  final renderRow = const [
    AttackType.Blade,
    AttackType.Staff,
  ].indexOf(equipped);

  if (renderRow == -1) {
    _renderCharacterPart(character,
        _mapWeaponTypeToSpriteLayer(character.weapon), character.renderColor);
    return;
  }
  render(
    dstX: character.renderX,
    dstY: character.renderY,
    srcX: _getTemplateSrcX(character, size: 96),
    srcY: 2491.0 + (renderRow * 96),
    srcWidth: 96,
    srcHeight: 96,
    anchorX: 0.5,
    anchorY: 0.7,
    scale: 0.75,
    color: character.renderColor,
  );
}

void _renderCharacterShadow(Character character) {
  _renderCharacterPart(character, SpriteLayer.Shadow, 0);
}

void _renderCharacterPartHead(Character character, int color) {
  if (renderTemplateWithWeapon) {
    _renderCharacterPart(
        character, _mapHeadTypeToSpriteLayer(character.head), color);
  } else {
    _renderCharacterPartAimDirection(
        character, _mapHeadTypeToSpriteLayer(character.head), color);
  }
}

void _renderCharacterPartBody(Character character, int color) {
  _renderCharacterPart(
      character, _mapArmourTypeToSpriteLayer(character.body), color);
}

void _renderCharacterPartPants(Character character, int color) {
  // if (renderTemplateWithWeapon) {
    _renderCharacterPart(character, _mapLegTypeToSpriteLayer(character.legs), color);
  // }
}

void _renderCharacterPart(Character character, int layer, int color) {
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
    color: color,
  );
}

void _renderCharacterPartCustom({
  required bool variation,
  required double renderX,
  required double renderY,
  required int state,
  required int frame,
  required int direction,
  required int weapon,
  required int layer,
  required int color,
}) =>
  render(
    dstX: renderX,
    dstY: renderY,
    srcX: getTemplateSrcXCustom(
        variation: variation,
        size: 64,
        characterState: state,
        direction: direction,
        frame: frame,
        weapon: weapon,
    ),
    srcY: 1051.0 + (layer * 64),
    srcWidth: 64.0,
    srcHeight: 64.0,
    scale: 0.75,
    anchorX: 0.5,
    anchorY: 0.75,
    color: color,
  );

void _renderCharacterPartAimDirection(
    Character character, int layer, int color) {
  render(
    dstX: character.renderX,
    dstY: character.renderY,
    srcX: _getTemplateSrcXAimDirection(character, size: 64),
    srcY: 1051.0 + (layer * 64),
    srcWidth: 64.0,
    srcHeight: 64.0,
    scale: 0.75,
    anchorX: 0.5,
    anchorY: 0.75,
    color: color,
  );
}

bool getVariation(Character character) =>
      character.weapon == AttackType.Shotgun ||
      character.weapon == AttackType.Bow;


double _getTemplateSrcX(Character character, {required double size}) {
  const framesPerDirection = 19;
  final weapon = character.weapon;
  final variation = weapon == AttackType.Shotgun ||
      weapon == AttackType.Bow;

  switch (character.state) {
    case CharacterState.Running:
      const frames1 = [12, 13, 14, 15];
      const frames2 = [16, 17, 18, 19];
      return loop4(
          size: size,
          animation: variation ? frames2 : frames1,
          character: character,
          framesPerDirection: framesPerDirection);

    case CharacterState.Idle:
      return single(
          size: size,
          frame: variation ? 1 : 2,
          direction: (character.renderDirection),
          framesPerDirection: framesPerDirection);

    case CharacterState.Hurt:
      return single(
          size: size,
          frame: 3,
          direction: character.renderDirection,
          framesPerDirection: framesPerDirection);

    case CharacterState.Changing:
      return single(
          size: size,
          frame: 4,
          direction: character.renderDirection,
          framesPerDirection: framesPerDirection);

    case CharacterState.Performing:
      final weapon = character.weapon;
      return animate(
          size: size,
          animation: weapon == AttackType.Bow
              ? const [5, 8, 6, 10]
              : weapon == AttackType.Handgun
                  ? const [8, 9, 8]
                  : weapon == AttackType.Shotgun
                      ? const [6, 7, 6, 6, 6, 8, 8, 6]
                      : const [10, 10, 11, 11],
          character: character,
          framesPerDirection: framesPerDirection);

    default:
      throw Exception(
          "getCharacterSrcX cannot get body x for state ${character.state}");
  }
}

double getTemplateSrcXCustom({
  required bool variation,
  required int characterState,
  required int direction,
  required int frame,
  required int weapon,
  required double size,
}) {
  const framesPerDirection = 19;

  switch (characterState) {
    case CharacterState.Running:
      const frames1 = [12, 13, 14, 15];
      const frames2 = [16, 17, 18, 19];
      return loopCustom(
          size: size,
          frame: frame,
          animation: variation ? frames2 : frames1,
          direction: direction,
          framesPerDirection: framesPerDirection);

    case CharacterState.Idle:
      return single(
          size: size,
          frame: variation ? 1 : 2,
          direction: direction,
          framesPerDirection: framesPerDirection);

    case CharacterState.Hurt:
      return single(
          size: size,
          frame: 3,
          direction: direction,
          framesPerDirection: framesPerDirection);

    case CharacterState.Changing:
      return single(
          size: size,
          frame: 4,
          direction: direction,
          framesPerDirection: framesPerDirection);

    case CharacterState.Performing:
      return animateCustom(
          size: size,
          animation: weapon == AttackType.Bow
              ? const [5, 8, 6, 10]
              : weapon == AttackType.Handgun
              ? const [8, 9, 8]
              : weapon == AttackType.Shotgun
              ? const [6, 7, 6, 6, 6, 8, 8, 6]
              : const [10, 10, 11, 11],
          frame: frame,
          direction: direction,
          framesPerDirection: framesPerDirection);

    default:
      throw Exception(
          "getCharacterSrcX cannot get body x for state ${characterState}");
  }
}

double _getTemplateSrcXAimDirection(Character character,
    {required double size}) {
  const framesPerDirection = 19;
  final weapon = character.weapon;
  final variation = renderTemplateWithWeapon && weapon == AttackType.Shotgun ||
      weapon == AttackType.Bow;

  switch (character.state) {
    case CharacterState.Running:
      const frames1 = [12, 13, 14, 15];
      const frames2 = [16, 17, 18, 19];
      return loop4AimDirection(
          size: size,
          animation: variation ? frames2 : frames1,
          character: character,
          framesPerDirection: framesPerDirection);

    case CharacterState.Idle:
      return single(
          size: size,
          frame: variation ? 1 : 2,
          direction: (character.aimDirection),
          framesPerDirection: framesPerDirection);

    case CharacterState.Hurt:
      return single(
          size: size,
          frame: 3,
          direction: character.aimDirection,
          framesPerDirection: framesPerDirection);

    case CharacterState.Changing:
      return single(
          size: size,
          frame: 4,
          direction: character.aimDirection,
          framesPerDirection: framesPerDirection);

    case CharacterState.Performing:
      final weapon = character.weapon;
      return animate(
          size: size,
          animation: weapon == AttackType.Bow
              ? const [5, 8, 6, 10]
              : weapon == AttackType.Handgun
                  ? const [8, 9, 8]
                  : weapon == AttackType.Shotgun
                      ? const [6, 7, 6, 6, 6, 8, 8, 6]
                      : const [10, 10, 11, 11],
          character: character,
          framesPerDirection: framesPerDirection);

    default:
      throw Exception(
          "getCharacterSrcX cannot get body x for state ${character.state}");
  }
}

int _mapLegTypeToSpriteLayer(int legType) {
  switch (legType) {
    case PantsType.brown:
      return SpriteLayer.Pants_Brown;
    case PantsType.blue:
      return SpriteLayer.Pants_Blue;
    case PantsType.white:
      return SpriteLayer.Pants_White;
    case PantsType.green:
      return SpriteLayer.Pants_Green;
    case PantsType.red:
      return SpriteLayer.Pants_Red;
    default:
      return SpriteLayer.Pants_Blue;
  }
}

int _mapArmourTypeToSpriteLayer(int armourType) {
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

int _mapWeaponTypeToSpriteLayer(int weaponType) {
  switch (weaponType) {
    case AttackType.Blade:
      return SpriteLayer.Sword_Wooden;
    case AttackType.Bow:
      return SpriteLayer.Bow_Wooden;
    case AttackType.Shotgun:
      return SpriteLayer.Shotgun;
    case AttackType.Rifle:
      return SpriteLayer.Shotgun;
    case AttackType.Handgun:
      return SpriteLayer.Handgun;
    case AttackType.Revolver:
      return SpriteLayer.Handgun;
    default:
      throw Exception("cannot map ${weaponType} to sprite index");
  }
}

int _mapHeadTypeToSpriteLayer(int headType) {
  switch (headType) {
    case HeadType.None:
      return SpriteLayer.Head_Plain;
    case HeadType.Steel_Helm:
      return SpriteLayer.Steel_Helm;
    case HeadType.Wizards_Hat:
      return SpriteLayer.Hat_Wizard;
    case HeadType.Rogues_Hood:
      return SpriteLayer.Rogues_Hood;
    case HeadType.Blonde:
      return SpriteLayer.Head_Blonde;
    default:
      throw Exception("cannot render head ${headType}");
  }
}

class SpriteLayer {
  static const Shadow = 0;
  static const Pants_Blue = Shadow + 1;
  static const Pants_Brown = Pants_Blue + 1;
  static const Pants_Green = Pants_Brown + 1;
  static const Pants_Red = Pants_Green + 1;
  static const Pants_White = Pants_Red + 1;
  static const Pants_Swat = Pants_White + 1;
  static const Staff_Wooden = Pants_Swat + 1;
  static const Sword_Wooden = Staff_Wooden + 1;
  static const Sword_Steel = Sword_Wooden + 1;
  static const Shotgun = Sword_Steel + 1;
  static const Handgun = Shotgun + 1;
  static const Bow_Wooden = Handgun + 1;
  static const Shirt_Cyan = Bow_Wooden + 1;
  static const Shirt_Blue = Shirt_Cyan + 1;
  static const Swat_Vest = Shirt_Blue + 1;
  static const Tunic_Padded = Swat_Vest + 1;
  static const Head_Blonde = Tunic_Padded + 1;
  static const Head_Plain = Head_Blonde + 1;
  static const Steel_Helm = Head_Plain + 1;
  static const Rogues_Hood = Steel_Helm + 1;
  static const Hat_Wizard = Rogues_Hood + 1;
  static const Swat_Helm = Hat_Wizard + 1;
}
