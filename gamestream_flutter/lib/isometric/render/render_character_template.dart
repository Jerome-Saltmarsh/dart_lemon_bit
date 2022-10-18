import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_config.dart';
import 'package:gamestream_flutter/isometric/convert_index.dart';
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
  switch (character.weaponType) {
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

void renderTemplateWeapon(Character character, int direction, int frame) {
  if (character.unarmed) return;
  var size = weaponIs64(character.weaponType) ? 64.0 : 96.0;
  // var frame = 0;
  // var isTwoHandedFirearm = AttackType.isTwoHandedFirearm(character.weaponType);
  //
  // switch (character.state) {
  //   case CharacterState.Idle:
  //     if (isTwoHandedFirearm) {
  //       frame = 0;
  //     } else {
  //       frame = 1;
  //     }
  //     break;
  //   case CharacterState.Running:
  //     if (isTwoHandedFirearm) {
  //        frame = const[15, 16, 17, 18][character.frame % 4];
  //     } else {
  //        frame = const[11, 12, 13, 14][character.frame % 4];
  //     }
  //     break;
  //   case CharacterState.Performing:
  //     if (weapon == AttackType.Shotgun){
  //       frame = const[15, 16, 17, 18][character.frame % 4];
  //     }
  //     break;
  //   case CharacterState.Changing:
  //     break;
  //   case CharacterState.Hurt:
  //     break;
  //   default:
  //     return;
  // }

  Engine.renderSprite(
    image: ImagesTemplateWeapons.fromWeaponType(character.weaponType),
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
  var frameWeapon = 0;
  final diff = Direction.getDifference(character.renderDirection, character.aimDirection).abs();
  final weaponInFront = character.renderDirection >= 2 && character.renderDirection < 6;
  final runningBackwards = diff >= 3 && character.running;

  final renderDirectionOpposite = (character.renderDirection + 4) % 8;
  final upperBodyDirection = runningBackwards ? renderDirectionOpposite : character.renderDirection;
  final finalDirection = character.usingWeapon ? character.aimDirection : upperBodyDirection;

  var weaponIsTwoHandedFirearm = AttackType.isTwoHandedFirearm(character.weaponType);

  switch (character.state) {
    case CharacterState.Idle:
      frameLegs = 0;
      frameBody = weaponIsTwoHandedFirearm ? 0 : 1;
      frameHead = frameBody;
      frameWeapon = frameBody;
      break;
    case CharacterState.Running:
      if (weaponIsTwoHandedFirearm) {
        frameBody = 15 + (character.frame % 4);
      } else {
        frameBody = 11 + (character.frame % 4);
      }
      frameWeapon = frameBody;
      frameLegs = frameBody;
      break;
  }

  if (character.usingWeapon) {
    final animation = TemplateAnimation.getAttackAnimation(character.weaponType);
    frameWeapon = character.weaponFrame >= animation.length ? animation.last : animation[character.weaponFrame];
    frameBody = frameWeapon;
    frameHead = frameWeapon;
  }

  if (!weaponInFront) {
    renderTemplateWeapon(character, finalDirection, frameWeapon);
  }

  // find the nearest torch and move the shadow behind the character
  final characterNodeIndex = getNodeIndexV3(character);
  final initialSearchIndex = characterNodeIndex - Game.nodesTotalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
  var torchIndex = -1;

  for (var row = 0; row < 3; row++){
    for (var column = 0; column < 3; column++){
       final searchIndex = initialSearchIndex + (row * Game.nodesTotalColumns) + column;
       if (Game.nodesType[searchIndex] != NodeType.Torch) continue;
       torchIndex = searchIndex;
       break;
    }
  }

  var angle = 0.0;
  var distance = 0.0;

  if (torchIndex != -1) {
      final torchRow = convertIndexToRow(torchIndex);
      final torchColumn = convertIndexToColumn(torchIndex);
      final torchPosX = torchRow * nodeSize + nodeSizeHalf;
      final torchPosY = torchColumn * nodeSize + nodeSizeHalf;
      angle = getAngleBetween(character.x, character.y, torchPosX, torchPosY);
      distance = min(
          GameConfig.Character_Shadow_Distance_Max,
          Engine.calculateDistance(
              character.x,
              character.y,
              torchPosX,
              torchPosY
          ) * GameConfig.Character_Shadow_Distance_Ratio,
      );
  }

  final shadowX = character.x + getAdjacent(angle, distance);
  final shadowY = character.y + getOpposite(angle, distance);
  final shadowZ = character.z;

  Engine.renderSprite(
    image: Images.templateShadow,
    srcX: frameLegs * 64,
    srcY: upperBodyDirection * 64,
    srcWidth: 64,
    srcHeight: 64,
    dstX: RenderEngine.getRenderX(shadowX, shadowY, shadowZ),
    dstY: RenderEngine.getRenderY(shadowX, shadowY, shadowZ),
    scale: 0.75,
    color: getRenderColor(character),
    anchorY: 0.75,
  );
  Engine.renderSprite(
    image: ImagesTemplateLegs.fromLegType(character.legType),
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
    image: ImagesTemplateBody.fromBodyType(character.bodyType),
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
    image: ImagesTemplateHead.fromHeadType(character.headType),
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
    renderTemplateWeapon(character, finalDirection, frameWeapon);
  }

  return;
  // final inLongGrass = gridNodeTypeAtVector3(character) == NodeType.Grass_Long;
  //
  // if (!inLongGrass) {
  //   renderCharacterTemplateShadow(character);
  // }
  //
  // // final diff = Direction.getDifference(character.renderDirection, character.aimDirection).abs();
  // // final weaponInFront = character.renderDirection >= 2 && character.renderDirection < 6;
  //
  // /// If the the player is running backwards to the direction they are aiming
  // /// render the player to run backwards
  // if (diff >= 3 && character.running) {
  //   final renderDirectionOpposite = (character.renderDirection + 4) % 8;
  //
  //   if (weaponInFront) {
  //     renderCharacterTemplateWeapon2(character, renderDirectionOpposite);
  //   }
  //
  //   if (!inLongGrass){
  //     renderCharacterTemplatePartCustom(
  //       layer: mapToLayerLegs(character.legType),
  //       variation: false,
  //       renderX: character.renderX,
  //       renderY: character.renderY,
  //       state: character.state,
  //       frame: character.frame,
  //       direction: renderDirectionOpposite,
  //       color: character.color,
  //       weapon: character.weaponType,
  //     );
  //   }
  //
  //
  //   renderCharacterTemplatePartCustom(
  //     layer: mapToLayerBody(character.bodyType),
  //     variation: getVariation(character),
  //     renderX: character.renderX,
  //     renderY: character.renderY,
  //     state: character.usingWeapon ? CharacterState.Performing : character.state,
  //     frame: character.usingWeapon ? character.weaponFrame : character.frame,
  //     direction: character.usingWeapon ? character.aimDirection : renderDirectionOpposite,
  //     color: character.color,
  //     weapon: character.weaponType,
  //   );
  //
  //   renderCharacterTemplatePartCustom(
  //     layer: mapToLayerHead(character.headType),
  //     variation: getVariation(character),
  //     renderX: character.renderX,
  //     renderY: character.renderY,
  //     state: character.usingWeapon ? CharacterState.Performing : character.state,
  //     frame: character.usingWeapon ? character.weaponFrame : character.frame,
  //     direction: character.aimDirection,
  //     color: character.color,
  //     weapon: character.weaponType,
  //   );
  //
  //   if (!weaponInFront) {
  //     renderCharacterTemplateWeapon2(character, renderDirectionOpposite);
  //   }
  //   return;
  // }
  //
  // if (!weaponInFront){
  //   renderCharacterTemplateWeapon2(character, character.renderDirection);
  // }
  //
  // if (!inLongGrass){
  //   renderCharacterTemplatePartCustom(
  //     layer: mapToLayerLegs(character.legType),
  //     variation: false,
  //     renderX: character.renderX,
  //     renderY: character.renderY,
  //     state: character.state,
  //     frame: character.frame,
  //     direction: character.renderDirection,
  //     color: character.color,
  //     weapon: character.weaponType,
  //   );
  // }
  //
  // renderCharacterTemplatePartCustom(
  //   layer: mapToLayerBody(character.bodyType),
  //   variation: getVariation(character),
  //   renderX: character.renderX,
  //   renderY: character.renderY,
  //   state: character.usingWeapon ? CharacterState.Performing : character.state,
  //   frame: character.usingWeapon ? character.weaponFrame : character.frame,
  //   direction: character.usingWeapon ? character.aimDirection : character.renderDirection,
  //   color: character.color,
  //   weapon: character.weaponType,
  // );
  //
  // renderCharacterTemplatePartCustom(
  //   layer: mapToLayerHead(character.headType),
  //   variation: getVariation(character),
  //   renderX: character.renderX,
  //   renderY: character.renderY,
  //   state: character.usingWeapon ? CharacterState.Performing : character.state,
  //   frame: character.usingWeapon ? character.weaponFrame : character.frame,
  //   direction: character.aimDirection,
  //   color: character.color,
  //   weapon: character.weaponType,
  // );
  //
  // if (weaponInFront){
  //   renderCharacterTemplateWeapon2(character,  character.renderDirection);
  // }
}

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
      character.weaponType == AttackType.Shotgun ||
      character.weaponType == AttackType.Bow;


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
    final list = Uint8List(3);
    list[0] = 5;
    list[1] = 8;
    list[2] = 6;
    return list;
  }();

  static Uint8List FiringHandgun = (){
    final list = Uint8List(4);
    list[0] = 6;
    list[1] = 7;
    list[2] = 7;
    list[3] = 6;
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

  static Uint8List getAttackAnimation(int weaponType){
      switch (weaponType) {
        case AttackType.Unarmed:
          return Striking;
        case AttackType.Handgun:
          return FiringHandgun;
        case AttackType.Shotgun:
          return FiringShotgun;
        case AttackType.Bow:
          return FiringBow;
        default:
          throw Exception("TemplateAnimation.getAttackAnimation(${AttackType.getName(weaponType)})");
      }
  }
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
