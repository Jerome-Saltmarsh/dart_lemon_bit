import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/convert_index.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/render/get_character_render_color.dart';
import 'package:gamestream_flutter/isometric/utils/convert.dart';
import 'package:gamestream_flutter/modules/game/render_rotated.dart';
import 'package:gamestream_flutter/render_engine.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
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
  final angle = character.lookRadian + piQuarter;
  final distance = 15.0;
  const size = 32.0;
  final direction = character.aimDirection;

  Engine.renderBuffer(
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
  final angle = character.lookRadian + piQuarter;
  final distance = 15.0;
  const size = 32.0;
  final direction = character.aimDirection;

  Engine.renderBuffer(
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
  final angle = character.lookRadian + piQuarter;
  final distance = 15.0;
  const size = 64.0;
  final direction = character.aimDirection;

  Engine.renderBuffer(
    dstX: character.renderX + getAdjacent(angle, distance),
    dstY: character.renderY + getOpposite(angle, distance) - 8,
    srcX: 304,
    srcY: size * direction,
    srcWidth: size,
    srcHeight: size,
  );
}

bool weaponIs96(int weapon) =>
   weapon == AttackType.Staff ||
   weapon == AttackType.Blade ;

void renderTemplateWeapon(Character character, int direction){
  if (character.unarmed) return;
  final weapon = character.weapon;
  var size = weaponIs64(weapon) ? 64.0 : 96.0;
  var frame = 0;
  var bowOrShotgun = weapon == AttackType.Bow ||weapon == AttackType.Shotgun;

  if (character.usingWeapon){

  }

  switch (character.state) {
    case CharacterState.Idle:
      if (bowOrShotgun) {
        frame = 0;
      } else {
        frame = 1;
      }
      break;
    case CharacterState.Running:
      if (bowOrShotgun){
         frame = const[15, 16, 17, 18][character.frame % 4];
      } else {
         frame = const[11, 12, 13, 14][character.frame % 4];
      }
      break;
    case CharacterState.Performing:
      if (weapon == AttackType.Shotgun){
        frame = const[15, 16, 17, 18][character.frame % 4];
      }
      break;
    case CharacterState.Changing:
      break;
    case CharacterState.Hurt:
      break;
    default:
      return;
  }

  Engine.renderSprite(
    image: ImagesTemplateWeapons.shotgun,
    srcX: frame * size,
    srcY: direction * size,
    srcWidth: size,
    srcHeight: size,
    dstX: RenderEngine.getRenderV3X(character),
    dstY: RenderEngine.getRenderV3Y(character),
    scale: 0.75,
    color: getRenderColor(character),
    anchorY: 0.75
  );
}

void renderCharacterTemplate(Character character, {
  bool renderHealthBar = true,
}) {
  assert(character.direction >= 0);
  assert(character.direction < 8);
  if (character.deadOrDying) return;

  if (renderHealthBar) {
    renderCharacterHealthBar(character);
  }

  var frameLegs = 0;
  var frameHead = 0;
  var frameBody = 0;
  final diff = Direction.getDifference(character.renderDirection, character.aimDirection).abs();
  final weaponInFront = character.renderDirection >= 2 && character.renderDirection < 6;
  final runningBackwards = diff >= 3 && character.running;

  final renderDirectionOpposite = (character.renderDirection + 4) % 8;
  final upperBodyDirection = runningBackwards ? renderDirectionOpposite : character.renderDirection;
  final finalDirection = character.usingWeapon ? character.aimDirection : upperBodyDirection;

  var variation = character.weapon == AttackType.Bow || character.weapon == AttackType.Shotgun;

  switch (character.state) {
    case CharacterState.Idle:
      frameLegs = 0;
      if (variation){
        frameBody = 0;
      } else {
        frameBody = 1;
      }
      break;
    case CharacterState.Running:
      frameLegs = TemplateAnimation.Running1[character.frame % 4];
      break;
  }

  if (!weaponInFront){
    renderTemplateWeapon(character, finalDirection);
  }

  // find the nearest torch and move the shadow behind the character
  final characterNodeIndex = getNodeIndexV3(character);
  final initialSearchIndex = characterNodeIndex - Game.nodesTotalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
  var torchFound = false;
  var torchIndex = -1;

  for (var row = 0; row < 3; row++){
    for (var column = 0; column < 3; column++){
       final searchIndex = initialSearchIndex + (row * Game.nodesTotalColumns) + column;
       if (Game.nodesType[searchIndex] != NodeType.Torch) continue;
       torchFound = true;
       torchIndex = searchIndex;
       break;
    }
  }

  // final angle = ang
  var angle = 0.0;
  var distance = 0.0;

  if (torchFound){
      final torchRow = convertIndexToRow(torchIndex);
      final torchColumn = convertIndexToColumn(torchIndex);
      final torchPosX = torchRow * nodeSize + nodeSizeHalf;
      final torchPosY = torchColumn * nodeSize + nodeSizeHalf;
      angle = getAngleBetween(character.x, character.y, torchPosX, torchPosY);
      distance = min(20, distanceBetween(character.x, character.y, torchPosX, torchPosY) * 0.15);
  }

  final x = character.x + getAdjacent(angle, distance);
  final y = character.y + getOpposite(angle, distance);
  final z = character.z;

  Engine.renderSprite(
    image: Images.templateShadow,
    srcX: frameLegs * 64,
    srcY: upperBodyDirection * 64,
    srcWidth: 64,
    srcHeight: 64,
    dstX: RenderEngine.getRenderX(x, y, z),
    dstY: RenderEngine.getRenderY(x, y, z),
    scale: 0.75,
    color: getRenderColor(character),
    anchorY: 0.75,
  );
  Engine.renderSprite(
    image: ImagesTemplateLegs.white,
    srcX: frameLegs * 64,
    srcY: upperBodyDirection * 64,
    srcWidth: 64,
    srcHeight: 64,
    dstX: RenderEngine.getRenderV3X(character),
    dstY: RenderEngine.getRenderV3Y(character),
    scale: 0.75,
    color: getRenderColor(character),
    anchorY: 0.75
  );
  Engine.renderSprite(
    image: ImagesTemplateBody.blue,
    srcX: frameBody * 64,
    srcY: finalDirection * 64,
    srcWidth: 64,
    srcHeight: 64,
    dstX: RenderEngine.getRenderV3X(character),
    dstY: RenderEngine.getRenderV3Y(character),
    scale: 0.75,
    color: getRenderColor(character),
    anchorY: 0.75
  );
  Engine.renderSprite(
    image: ImagesTemplateHead.rogue,
    srcX: frameHead * 64,
    srcY: character.aimDirection * 64,
    srcWidth: 64,
    srcHeight: 64,
    dstX: RenderEngine.getRenderV3X(character),
    dstY: RenderEngine.getRenderV3Y(character),
    scale: 0.75,
    color: getRenderColor(character),
    anchorY: 0.75
  );
  if (weaponInFront){
    renderTemplateWeapon(character, finalDirection);
  }

  return;
  final inLongGrass = gridNodeTypeAtVector3(character) == NodeType.Grass_Long;

  if (!inLongGrass) {
    renderCharacterTemplateShadow(character);
  }

  // final diff = Direction.getDifference(character.renderDirection, character.aimDirection).abs();
  // final weaponInFront = character.renderDirection >= 2 && character.renderDirection < 6;

  /// If the the player is running backwards to the direction they are aiming
  /// render the player to run backwards
  if (diff >= 3 && character.running) {
    final renderDirectionOpposite = (character.renderDirection + 4) % 8;

    if (weaponInFront) {
      renderCharacterTemplateWeapon2(character, renderDirectionOpposite);
    }

    if (!inLongGrass){
      renderCharacterTemplatePartCustom(
        layer: mapToLayerLegs(character.legs),
        variation: false,
        renderX: character.renderX,
        renderY: character.renderY,
        state: character.state,
        frame: character.frame,
        direction: renderDirectionOpposite,
        color: character.color,
        weapon: character.weapon,
      );
    }


    renderCharacterTemplatePartCustom(
      layer: mapToLayerBody(character.body),
      variation: getVariation(character),
      renderX: character.renderX,
      renderY: character.renderY,
      state: character.usingWeapon ? CharacterState.Performing : character.state,
      frame: character.usingWeapon ? character.weaponFrame : character.frame,
      direction: character.usingWeapon ? character.aimDirection : renderDirectionOpposite,
      color: character.color,
      weapon: character.weapon,
    );

    renderCharacterTemplatePartCustom(
      layer: mapToLayerHead(character.head),
      variation: getVariation(character),
      renderX: character.renderX,
      renderY: character.renderY,
      state: character.usingWeapon ? CharacterState.Performing : character.state,
      frame: character.usingWeapon ? character.weaponFrame : character.frame,
      direction: character.aimDirection,
      color: character.color,
      weapon: character.weapon,
    );

    if (!weaponInFront) {
      renderCharacterTemplateWeapon2(character, renderDirectionOpposite);
    }
    return;
  }

  if (!weaponInFront){
    renderCharacterTemplateWeapon2(character, character.renderDirection);
  }

  if (!inLongGrass){
    renderCharacterTemplatePartCustom(
      layer: mapToLayerLegs(character.legs),
      variation: false,
      renderX: character.renderX,
      renderY: character.renderY,
      state: character.state,
      frame: character.frame,
      direction: character.renderDirection,
      color: character.color,
      weapon: character.weapon,
    );
  }

  renderCharacterTemplatePartCustom(
    layer: mapToLayerBody(character.body),
    variation: getVariation(character),
    renderX: character.renderX,
    renderY: character.renderY,
    state: character.usingWeapon ? CharacterState.Performing : character.state,
    frame: character.usingWeapon ? character.weaponFrame : character.frame,
    direction: character.usingWeapon ? character.aimDirection : character.renderDirection,
    color: character.color,
    weapon: character.weapon,
  );

  renderCharacterTemplatePartCustom(
    layer: mapToLayerHead(character.head),
    variation: getVariation(character),
    renderX: character.renderX,
    renderY: character.renderY,
    state: character.usingWeapon ? CharacterState.Performing : character.state,
    frame: character.usingWeapon ? character.weaponFrame : character.frame,
    direction: character.aimDirection,
    color: character.color,
    weapon: character.weapon,
  );

  if (weaponInFront){
    renderCharacterTemplateWeapon2(character,  character.renderDirection);
  }
}


void renderCharacterTemplateWeapon2(Character character, int direction){
  if (character.weapon == AttackType.Unarmed) return;
  if (weaponIs96(character.weapon)) {
    renderCharacterTemplatePartCustom96(
      variation: getVariation(character),
      renderX: character.renderX,
      renderY: character.renderY,
      state:
          character.usingWeapon ? CharacterState.Performing : character.state,
      frame: character.usingWeapon ? character.weaponFrame : character.frame,
      direction: character.usingWeapon
          ? character.aimDirection
          : direction,
      color: character.color,
      weapon: character.weapon,
    );
    return;
  }
  renderCharacterTemplatePartCustom(
    variation: getVariation(character),
    renderX: character.renderX,
    renderY: character.renderY,
    state: character.usingWeapon ? CharacterState.Performing : character.state,
    frame: character.usingWeapon ? character.weaponFrame : character.frame,
    direction: character.usingWeapon
        ? character.aimDirection
        : direction,
    layer: mapToLayerWeapon(character.weapon),
    color: character.color,
    weapon: character.weapon,
  );
}

void renderCharacterTemplateWeapon(Character character) {
  final equipped = character.weapon;
  if (equipped == AttackType.Unarmed) return;

  final renderRow = const [
    AttackType.Blade,
    AttackType.Staff,
  ].indexOf(equipped);

  if (renderRow == -1) {
    _renderCharacterPart(character,
        mapToLayerWeapon(character.weapon), getNodeBelowShade(character));
    return;
  }
  Engine.renderBuffer(
    dstX: character.renderX,
    dstY: character.renderY,
    srcX: _getTemplateSrcX(character, size: 96),
    srcY: 2491.0 + (renderRow * 96),
    srcWidth: 96,
    srcHeight: 96,
    anchorX: 0.5,
    anchorY: 0.7,
    scale: 0.75,
    color: character.color,
  );
}

void renderCharacterTemplateShadow(Character character) {
  _renderCharacterPart(character, SpriteLayer.Shadow, 0);
}

void _renderCharacterPart(Character character, int layer, int color) {
  Engine.renderBuffer(
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

void renderCharacterTemplatePartCustom({
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
    Engine.renderBuffer(
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

bool weaponIs64(int weapon) =>
   weapon == AttackType.Handgun ||
   weapon == AttackType.Bow ||
   weapon == AttackType.Shotgun;

void renderCharacterTemplatePartCustom96({
  required bool variation,
  required double renderX,
  required double renderY,
  required int state,
  required int frame,
  required int direction,
  required int weapon,
  required int color,
}) =>
    Engine.renderBuffer(
      dstX: renderX,
      dstY: renderY,
      srcX: getTemplateSrcXCustom(
        variation: variation,
        size: 96,
        characterState: state,
        direction: direction,
        frame: frame,
        weapon: weapon,
      ),
      srcY: 2491.0 + (AtlasIndex96.getWeaponIndex(weapon) * 96),
      srcWidth: 96.0,
      srcHeight: 96.0,
      scale: 0.75,
      anchorX: 0.5,
      anchorY: 0.69,
      color: color,
    );

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

class TemplateAnimation {
  static final Uint8List Running1 = (){
      final list = Uint8List(4);
      list[0] = 12;
      list[1] = 13;
      list[2] = 14;
      list[3] = 15;
      return list;
  }();

  static final Uint8List Running2 = (){
    final list = Uint8List(4);
    list[0] = 16;
    list[1] = 17;
    list[2] = 18;
    list[3] = 19;
    return list;
  }();

  static Uint8List Idle = (){
    final list = Uint8List(1);
    list[0] = 1;
    return list;
  }();

  static Uint8List Hurt = (){
    final list = Uint8List(1);
    list[0] = 3;
    return list;
  }();

  static Uint8List Changing = (){
    final list = Uint8List(1);
    list[0] = 4;
    return list;
  }();

  static Uint8List FiringBow = (){
    final list = Uint8List(4);
    list[0] = 5;
    list[1] = 8;
    list[2] = 6;
    list[3] = 10;
    return list;
  }();

  static Uint8List FiringHandgun = (){
    final list = Uint8List(3);
    list[0] = 8;
    list[1] = 9;
    list[2] = 8;
    return list;
  }();

  static Uint8List FiringShotgun = (){
    final list = Uint8List(8);
    list[0] = 6;
    list[1] = 7;
    list[2] = 6;
    list[3] = 6;
    list[4] = 6;
    list[5] = 8;
    list[6] = 8;
    list[7] = 6;
    return list;
  }();

  static Uint8List Striking = (){
    final list = Uint8List(4);
    list[0] = 10;
    list[1] = 10;
    list[2] = 11;
    list[3] = 11;
    return list;
  }();
}

Uint8List getAnimation({
  required int characterState,
  required int weapon,
}) {
  switch (characterState) {
    case CharacterState.Running:
      final variation = weapon == AttackType.Shotgun || weapon == AttackType.Bow;
      return variation
          ? TemplateAnimation.Running1
          : TemplateAnimation.Running2;

    case CharacterState.Idle:
      return TemplateAnimation.Idle;

    case CharacterState.Hurt:
      return TemplateAnimation.Hurt;

    case CharacterState.Changing:
      return TemplateAnimation.Changing;

    case CharacterState.Performing:
      switch (weapon) {
        case AttackType.Bow:
          return TemplateAnimation.FiringBow;
        case AttackType.Handgun:
          return TemplateAnimation.FiringHandgun;
        case AttackType.Shotgun:
          return TemplateAnimation.FiringShotgun;
        default:
          return TemplateAnimation.Striking;
      }

    default:
      throw Exception(
          "getCharacterSrcX cannot get body x for state ${characterState}");
  }
}

int mapToLayerLegs(int legType) {
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

int mapToLayerBody(int armourType) {
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

int mapToLayerWeapon(int weaponType) {
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

int mapToLayerHead(int headType) {
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

class AtlasIndex96 {
  static const Hammer = 0;
  static const Axe = Hammer + 1;
  static const Pickaxe = Axe + 1;
  static const Sword = Pickaxe + 1;
  static const Wooden_Sword = Sword + 1;
  static const Staff = Wooden_Sword + 1;

  static int getWeaponIndex(int weapon){
    switch (weapon){
      case AttackType.Blade:
        return Sword;
      case AttackType.Staff:
        return Staff;
      default:
        throw Exception('AtlasIndex96.getWeaponIndex(weapon: $weapon)');
    }
  }
}
