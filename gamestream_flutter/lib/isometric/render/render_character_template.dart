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
import 'package:gamestream_flutter/game_render.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import '../classes/character.dart';
import 'render_character_health_bar.dart';

void renderLine(double x, double y, double z, double angle, double distance) {
  final x2 = x + getAdjacent(angle, distance);
  final y2 = y + getOpposite(angle, distance);
  Engine.drawLine(
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

bool weaponIs96(int weapon) =>
   weapon == AttackType.Staff ||
   weapon == AttackType.Blade ;

void renderTemplateWeapon(
    int weaponType,
    int direction,
    int frame,
    int color,
    double dstX,
    double dstY,
    ) {
  if (weaponType == AttackType.Unarmed) return;
  var size = weaponIs64(weaponType) ? 64.0 : 96.0;
  Engine.renderSprite(
    image: ImagesTemplateWeapons.fromWeaponType(weaponType),
    srcX: frame * size,
    srcY: direction * size,
    srcWidth: size,
    srcHeight: size,
    dstX: dstX,
    dstY: dstY,
    scale: 0.75,
    color: color,
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

  final dstX = GameRender.getRenderV3X(character);
  final dstY = GameRender.getRenderV3Y(character);
  final color = getRenderColor(character);

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
    GameRender.renderTextV3(character, character.weaponFrame, offsetY: -50);
    final animation = TemplateAnimation.getAttackAnimation(character.weaponType);
    frameWeapon = (character.weaponFrame >= animation.length ? animation.last : animation[character.weaponFrame]) - 1;
    frameBody = frameWeapon;
    frameHead = frameWeapon;
  }

  if (!weaponInFront) {
    renderTemplateWeapon(character.weaponType, finalDirection, frameWeapon, color, dstX, dstY);
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
    dstX: GameRender.getRenderX(shadowX, shadowY, shadowZ),
    dstY: GameRender.getRenderY(shadowX, shadowY, shadowZ),
    scale: 0.75,
    color: color,
    anchorY: 0.75,
  );
  Engine.renderSprite(
    image: ImagesTemplateLegs.fromLegType(character.legType),
    srcX: frameLegs * 64,
    srcY: upperBodyDirection * 64,
    srcWidth: 64,
    srcHeight: 64,
    dstX: dstX,
    dstY: dstY,
    scale: 0.75,
    color: color,
    anchorY: 0.75
  );
  Engine.renderSprite(
    image: ImagesTemplateBody.fromBodyType(character.bodyType),
    srcX: frameBody * 64,
    srcY: finalDirection * 64,
    srcWidth: 64,
    srcHeight: 64,
    dstX: dstX,
    dstY: dstY,
    scale: 0.75,
    color: color,
    anchorY: 0.75
  );
  Engine.renderSprite(
    image: ImagesTemplateHead.fromHeadType(character.headType),
    srcX: frameHead * 64,
    srcY: character.aimDirection * 64,
    srcWidth: 64,
    srcHeight: 64,
    dstX: dstX,
    dstY: dstY,
    scale: 0.75,
    color: color,
    anchorY: 0.75
  );
  if (weaponInFront) {
    renderTemplateWeapon(character.weaponType, finalDirection, frameWeapon, color, dstX, dstY);
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
    final list = Uint8List(9);
    list[0] = 5;
    list[1] = 5;
    list[2] = 5;
    list[3] = 5;
    list[4] = 8;
    list[5] = 8;
    list[6] = 8;
    list[7] = 8;
    list[8] = 10;
    return list;
  }();

  static Uint8List FiringHandgun = (){
    final list = Uint8List(3);
    list[0] = 7;
    list[1] = 7;
    list[2] = 6;
    return list;
  }();

  static const FiringShotgun = [
    6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 8, 8, 8, 8
  ];

  static const Striking = [
     10, 10, 10, 10, 10, 11
  ];

  static Uint8List StrikingBlade = (){
    final list = Uint8List(7);
    list[0] = 10;
    list[1] = 10;
    list[2] = 10;
    list[3] = 11;
    list[4] = 11;
    list[5] = 11;
    list[6] = 11;
    return list;
  }();

  static List<int> getAttackAnimation(int weaponType){
      switch (weaponType) {
        case AttackType.Unarmed:
          return Striking;
        case AttackType.Handgun:
          return FiringHandgun;
        case AttackType.Shotgun:
          return FiringShotgun;
        case AttackType.Bow:
          return FiringBow;
        case AttackType.Blade:
          return StrikingBlade;
        default:
          throw Exception("TemplateAnimation.getAttackAnimation(${AttackType.getName(weaponType)})");
      }
  }
}

