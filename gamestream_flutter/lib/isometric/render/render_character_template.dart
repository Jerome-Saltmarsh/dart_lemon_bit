import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_renderer.dart';

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
  const Sprite_Size = 125.0;
  engine.renderSprite(
    image: GameImages.getImageForWeaponType(weaponType),
    srcX: frame * Sprite_Size,
    srcY: direction * Sprite_Size,
    srcWidth: Sprite_Size,
    srcHeight: Sprite_Size,
    dstX: dstX,
    dstY: dstY,
    scale: 0.75,
    color: color,
    anchorY:  0.625
  );
}

void renderCharacterTemplate(Character character, {
  bool renderHealthBar = true,
}) {
  assert(character.direction >= 0);
  assert(character.direction < 8);
  if (character.dead) return;

  if (renderHealthBar) {
    if (character.allie){
      renderCharacterHealthBar(character);
    }
  }

  var frameLegs = 0;
  var frameHead = 0;
  var frameBody = 0;
  var frameWeapon = 0;

  final diff = Direction.getDifference(character.renderDirection, character.aimDirection).abs();
  final runningBackwards = diff >= 3 && character.running;
  var renderDirectionOpposite = (character.renderDirection + 4) % 8;

  final upperBodyDirection = runningBackwards ? renderDirectionOpposite : character.renderDirection;
  final weaponInFront = upperBodyDirection >= 2 && upperBodyDirection < 6;
  var weaponIsTwoHandedFirearm = ItemType.isTwoHanded(character.weaponType);

  var directionLegs = upperBodyDirection;
  final weaponEngaged = (character.weaponStateAiming || character.weaponStateFiring || character.weaponStateMelee);
  var directionBody = weaponEngaged ? character.aimDirection : upperBodyDirection;
  var directionHead = weaponEngaged ? directionBody : character.aimDirection;

  switch (character.state) {
    case CharacterState.Idle:
      frameLegs = 0;
      frameWeapon = weaponIsTwoHandedFirearm ? 0 : 1;
      break;
    case CharacterState.Running:
      if (weaponIsTwoHandedFirearm) {
        frameWeapon = 15 + (character.frame % 4);
      } else {
        frameWeapon = 11 + (character.frame % 4);
      }
      frameLegs = frameWeapon;
      break;
    case CharacterState.Changing:
      frameLegs = TemplateAnimation.Frame_Changing;
      frameWeapon = TemplateAnimation.Frame_Changing;
      break;
    case CharacterState.Performing:
      final animation = TemplateAnimation.getAttackAnimation(character.weaponType);
      frameWeapon = capIndex(animation, character.frame);
      frameLegs = frameWeapon;
      directionBody = character.renderDirection;
      directionHead = directionBody;
      directionLegs = directionBody;
      break;
    case CharacterState.Stunned:
      frameLegs = 0;
      frameWeapon = weaponIsTwoHandedFirearm ? 0 : 1;
      gamestream.games.isometric.renderer.renderStarsV3(character);
      break;
  }

  switch (character.weaponState) {
    case WeaponState.Idle:
      break;
    case WeaponState.Firing:
      final animation = TemplateAnimation.getAttackAnimation(character.weaponType);
      frameWeapon = (character.weaponFrame >= animation.length ? animation.last : animation[character.weaponFrame]) - 1;
      break;
    case WeaponState.Reloading:
      frameWeapon = TemplateAnimation.Frame_Changing;
      break;
    case WeaponState.Aiming:
      if (ItemType.isTypeWeaponMelee(character.weaponType) || ItemType.isTypeWeaponThrown(character.weaponType)) {
        frameWeapon = TemplateAnimation.Frame_Aiming_Sword;
      } else
      if (ItemType.isOneHanded(character.weaponType)){
        frameWeapon = TemplateAnimation.Frame_Aiming_One_Handed;
      } else {
        frameWeapon = TemplateAnimation.Frame_Aiming_Two_Handed;
      }
      break;
    case WeaponState.Changing:
      frameWeapon = TemplateAnimation.Frame_Changing;
      break;
    case WeaponState.Throwing:
      frameWeapon = capIndex(TemplateAnimation.Throwing, character.weaponFrame);
      break;
    case WeaponState.Melee:
      frameWeapon = capIndex(TemplateAnimation.Throwing, character.weaponFrame);
      break;
  }

  frameBody = frameWeapon;
  frameHead = frameWeapon;


  final invisible = character.buffInvisible;

  final dstX = GameIsometricRenderer.convertV3ToRenderX(character);
  final dstY = GameIsometricRenderer.convertV3ToRenderY(character);

  const Color_Invisible = GameColors.White38_Value;
  final color = invisible ? Color_Invisible : gamestream.games.isometric.clientState.getV3RenderColor(character);

  if (invisible) {
    engine.bufferBlendMode = BlendMode.srcIn;
  }

  if (!weaponInFront) {
    renderTemplateWeapon(character.weaponType, directionBody, frameWeapon, color, dstX, dstY);
  }
  const Scale = 0.7;
  const Sprite_Size = 125.0;
  const Anchor_Y = 0.625;

  if (character.z >= GameIsometricConstants.Node_Height){
    gamestream.games.isometric.nodes.markShadow(character);

    final shadowAngle = gamestream.games.isometric.nodes.shadow.z + pi;
    final shadowDistance = gamestream.games.isometric.nodes.shadow.magnitudeXY;
    final shadowX = character.x + adj(shadowAngle, shadowDistance);
    final shadowY = character.y + opp(shadowAngle, shadowDistance);
    final shadowZ = character.z;

    engine.renderSprite(
      image: GameImages.template_shadow,
      srcX: frameLegs * 64,
      srcY: upperBodyDirection * 64,
      srcWidth: 64,
      srcHeight: 64,
      dstX: GameIsometricRenderer.getRenderX(shadowX, shadowY, shadowZ),
      dstY: GameIsometricRenderer.getRenderY(shadowX, shadowY, shadowZ),
      scale: Scale,
      color: color,
      anchorY: Anchor_Y,
    );
  }

    engine.renderSprite(
        image: GameImages.getImageForLegType(character.legType),
        srcX: frameLegs * Sprite_Size,
        srcY: directionLegs * Sprite_Size,
        srcWidth: Sprite_Size,
        srcHeight: Sprite_Size,
        dstX: dstX,
        dstY: dstY,
        scale: Scale,
        color: color,
        anchorY: Anchor_Y
    );
    engine.renderSprite(
        image: GameImages.getImageForBodyType(character.bodyType),
        srcX: frameBody * Sprite_Size,
        srcY: directionBody * Sprite_Size,
        srcWidth: Sprite_Size,
        srcHeight: Sprite_Size,
        dstX: dstX,
        dstY: dstY,
        scale: Scale,
        color: color,
        anchorY: Anchor_Y
    );

    // final height = gamestream.games.isometric.nodes.heightMap[(character.indexRow * gamestream.games.isometric.nodes.totalColumns) + character.indexColumn];
    // GameRender.renderTextV3(character, gamestream.games.isometric.nodes.nodeAlps[character.nodeIndex - gamestream.games.isometric.nodes.area], offsetY: -80);

    engine.renderSprite(
        image: GameImages.getImageForHeadType(character.headType),
        srcX: frameHead * Sprite_Size,
        srcY: directionHead * Sprite_Size,
        srcWidth: Sprite_Size,
        srcHeight: Sprite_Size,
        dstX: dstX,
        dstY: dstY,
        scale: Scale,
        color: color,
        anchorY: Anchor_Y
    );
    if (weaponInFront) {
      renderTemplateWeapon(
          character.weaponType, directionBody, frameWeapon, color, dstX, dstY);
    }

  if (invisible) {
    engine.bufferBlendMode = BlendMode.dstATop;
  }
}

class TemplateAnimation {

  static const Frame_Changing = 4;
  static const Frame_Aiming_One_Handed = 7;
  static const Frame_Aiming_Two_Handed = 5;
  static const Frame_Aiming_Sword = 9;

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

  static const FiringRifle = [
    6, 7, 7, 6];

  static const FiringMinigun = [6];

  static const Punch = [
     10, 10, 10, 10, 10, 11
  ];

  static const Throwing = [
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

     if (weaponType == ItemType.Weapon_Ranged_Shotgun){
       return FiringShotgun;
     }

      if (ItemType.isTypeWeaponRifle(weaponType)){
        return FiringRifle;
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
     if (weaponType == ItemType.Weapon_Ranged_Flamethrower){
       return FiringShotgun;
     }
     if (weaponType == ItemType.Weapon_Ranged_Smg) {
       return FiringHandgun;
     }
     if (weaponType == ItemType.Weapon_Ranged_Minigun) {
       return FiringShotgun;
     }
     if (weaponType == ItemType.Weapon_Ranged_Bazooka) {
       return FiringShotgun;
     }
     throw Exception("TemplateAnimation.getAttackAnimation(${ItemType.getName(weaponType)})");
  }
}

