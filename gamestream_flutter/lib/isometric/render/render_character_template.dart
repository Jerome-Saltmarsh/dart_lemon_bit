import 'dart:math';

import 'package:bleed_common/node_size.dart';
import 'package:lemon_math/library.dart';

import '../../library.dart';
import 'render_character_health_bar.dart';

void renderArrow(double x, double y, double z, double angle) {
  x += getAdjacent(angle, 30);
  y += getOpposite(angle, 30);
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
    image: GameImages.getImageForWeaponType(weaponType),
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

  final dstX = GameConvert.convertV3ToRenderX(character);
  final dstY = GameConvert.convertV3ToRenderY(character);
  final color = GameState.getV3RenderColor(character);

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
    // GameRender.renderTextV3(character, character.weaponFrame, offsetY: -50);
    final animation = TemplateAnimation.getAttackAnimation(character.weaponType);
    frameWeapon = (character.weaponFrame >= animation.length ? animation.last : animation[character.weaponFrame]) - 1;
    frameBody = frameWeapon;
    frameHead = frameWeapon;
  }

  if (!weaponInFront) {
    renderTemplateWeapon(character.weaponType, finalDirection, frameWeapon, color, dstX, dstY);
  }

  var angle = 0.0;
  var distance = 0.0;

  if (!GameState.outOfBoundsV3(character)){
    // find the nearest torch and move the shadow behind the character
    final characterNodeIndex = GameState.getNodeIndexV3(character);
    final initialSearchIndex = characterNodeIndex - GameState.nodesTotalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
    var torchIndex = -1;

    for (var row = 0; row < 3; row++){
      for (var column = 0; column < 3; column++){
        final searchIndex = initialSearchIndex + (row * GameState.nodesTotalColumns) + column;
        if (GameNodes.nodesType[searchIndex] != NodeType.Torch) continue;
        torchIndex = searchIndex;
        break;
      }
    }

    if (torchIndex != -1) {
      final torchRow = GameState.convertNodeIndexToRow(torchIndex);
      final torchColumn = GameState.convertNodeIndexToColumn(torchIndex);
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
  }

  final shadowX = character.x + getAdjacent(angle, distance);
  final shadowY = character.y + getOpposite(angle, distance);
  final shadowZ = character.z;

  Engine.renderSprite(
    image: GameImages.template_shadow,
    srcX: frameLegs * 64,
    srcY: upperBodyDirection * 64,
    srcWidth: 64,
    srcHeight: 64,
    dstX: GameConvert.getRenderX(shadowX, shadowY, shadowZ),
    dstY: GameConvert.getRenderY(shadowX, shadowY, shadowZ),
    scale: 0.75,
    color: color,
    anchorY: 0.75,
  );
  Engine.renderSprite(
    image: GameImages.getImageForLegType(character.legType),
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
    image: GameImages.getImageForBodyType(character.bodyType),
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
    image: GameImages.getImageForHeadType(character.headType),
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
        case AttackType.Staff:
          return StrikingBlade;
        default:
          throw Exception("TemplateAnimation.getAttackAnimation(${AttackType.getName(weaponType)})");
      }
  }
}

