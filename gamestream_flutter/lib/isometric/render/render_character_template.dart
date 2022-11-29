import 'dart:math';

import '../../library.dart';
import 'render_character_health_bar.dart';

void renderTemplateWeapon(
    int weaponType,
    int direction,
    int frame,
    int color,
    double dstX,
    double dstY,
    ) {

  if (weaponType == ItemType.Empty) return;
  final size = getWeaponTypeSize(weaponType);
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

double getWeaponTypeSize(int weaponType){
  if (weaponType == ItemType.Weapon_Melee_Sword) return 96.0;
  return 64.0;
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
  final runningBackwards = diff >= 3 && character.running;
  final renderDirectionOpposite = (character.renderDirection + 4) % 8;
  final upperBodyDirection = runningBackwards ? renderDirectionOpposite : character.renderDirection;
  final weaponInFront = upperBodyDirection >= 2 && upperBodyDirection < 6;
  final finalDirection = (character.weaponStateAiming || character.usingWeapon) ? character.aimDirection : upperBodyDirection;
  var weaponIsTwoHandedFirearm = ItemType.isTwoHanded(character.weaponType);

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
    case CharacterState.Changing:
      frameHead = TemplateAnimation.StateChangingFrame;
      frameBody = TemplateAnimation.StateChangingFrame;
      frameLegs = TemplateAnimation.StateChangingFrame;
      frameWeapon = TemplateAnimation.StateChangingFrame;
      break;
  }


  if (character.usingWeapon) {
    final animation = TemplateAnimation.getAttackAnimation(character.weaponType);
    frameWeapon = (character.weaponFrame >= animation.length ? animation.last : animation[character.weaponFrame]) - 1;
    frameBody = frameWeapon;
    frameHead = frameWeapon;
  } else
  if (character.weaponStateReloading){
    frameHead = TemplateAnimation.StateChangingFrame;
    frameBody = TemplateAnimation.StateChangingFrame;
    frameWeapon = TemplateAnimation.StateChangingFrame;
  } else
  if (character.weaponStateAiming) {
    if (ItemType.isOneHanded(character.weaponType)){
      frameHead = TemplateAnimation.Frame_Aiming_One_Handed;
      frameBody = TemplateAnimation.Frame_Aiming_One_Handed;
      frameWeapon = TemplateAnimation.Frame_Aiming_One_Handed;
    } else {
      frameHead = TemplateAnimation.Frame_Aiming_Two_Handed;
      frameBody = TemplateAnimation.Frame_Aiming_Two_Handed;
      frameWeapon = TemplateAnimation.Frame_Aiming_Two_Handed;
    }
  } else
  if (character.weaponStateChanging) {
    frameHead = TemplateAnimation.StateChangingFrame;
    frameBody = TemplateAnimation.StateChangingFrame;
    frameWeapon = TemplateAnimation.StateChangingFrame;
  }


  if (!weaponInFront) {
    renderTemplateWeapon(character.weaponType, finalDirection, frameWeapon, color, dstX, dstY);
  }

  var angle = 0.0;
  var distance = 0.0;

  if (ClientState.torchesIgnited.value && !GameState.outOfBoundsV3(character)){
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
      final torchPosX = torchRow * Node_Size + Node_Size_Half;
      final torchPosY = torchColumn * Node_Size + Node_Size_Half;
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

// bool weaponIs64(int weapon) =>
//    weapon == ItemType.isTypeWeaponHandgun(weapon) ||
//    weapon == ItemType.Weapon_Ranged_Bow ||
//    weapon == ItemType.Weapon_Ranged_Shotgun ||
//    weapon == ItemType.Weapon_Melee_Knife;

class TemplateAnimation {

  static const StateChangingFrame = 4;
  static const Frame_Aiming_One_Handed = 7;
  static const Frame_Aiming_Two_Handed = 5;


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

  static List<int> FiringHandgun = (){
    final frames = Uint8List(4);
    frames[0] = 8;
    frames[1] = 9;
    frames[2] = 9;
    frames[3] = 8;
    return frames;
  }();

  static const FiringShotgun = [
    6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 8, 8, 8, 8
  ];

  static const FiringMinigun = [6];

  static const Punch = [
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

      if (weaponType == ItemType.Empty) {
        return Punch;
      }

     if (ItemType.isTypeWeaponHandgun(weaponType)) {
       return FiringHandgun;
     }

     if (ItemType.isTypeWeaponRifle(weaponType)){
       return FiringShotgun;
     }

     if (ItemType.isTypeWeaponShotgun(weaponType)){
       return FiringShotgun;
     }

     if (ItemType.isTypeWeaponMelee(weaponType)){
       return StrikingBlade;
     }

     if (ItemType.isTypeWeaponBow(weaponType)){
       return FiringBow;
     }
     if (weaponType == ItemType.Weapon_Thrown_Grenade) {
       return Punch;
     }

     if (weaponType == ItemType.Weapon_Flamethrower){
       return FiringShotgun;
     }
     if (weaponType == ItemType.Weapon_Smg_Mp5) {
       return FiringShotgun;
     }
     if (weaponType == ItemType.Weapon_Special_Minigun) {
       return FiringShotgun;
     }
     throw Exception("TemplateAnimation.getAttackAnimation(${ItemType.getName(weaponType)})");
  }
}

