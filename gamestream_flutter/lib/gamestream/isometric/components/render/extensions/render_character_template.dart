import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/classes/template_animation.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_characters.dart';
import 'package:gamestream_flutter/language_utils.dart';

import '../../../../../library.dart';

extension RenderCharactersTemplate on RendererCharacters {

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

  void renderCharacterTemplate(IsometricCharacter character, {
    bool renderHealthBar = true,
  }) {
    assert(character.direction >= 0);
    assert(character.direction < 8);
    if (character.dead) return;

    if (renderHealthBar) {
      if (character.allie){
        gamestream.isometric.renderer.renderCharacterHealthBar(character);
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
        gamestream.isometric.renderer.renderStarsV3(character);
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

    final dstX = IsometricRender.convertV3ToRenderX(character);
    final dstY = IsometricRender.convertV3ToRenderY(character);

    const Color_Invisible = GameIsometricColors.White38_Value;
    final color = invisible ? Color_Invisible : gamestream.isometric.nodes.getV3RenderColor(character);

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
      gamestream.isometric.nodes.markShadow(character);

      final shadowAngle = gamestream.isometric.nodes.shadow.z + pi;
      final shadowDistance = gamestream.isometric.nodes.shadow.magnitudeXY;
      final shadowX = character.x + adj(shadowAngle, shadowDistance);
      final shadowY = character.y + opp(shadowAngle, shadowDistance);
      final shadowZ = character.z;

      engine.renderSprite(
        image: GameImages.template_shadow,
        srcX: frameLegs * 64,
        srcY: upperBodyDirection * 64,
        srcWidth: 64,
        srcHeight: 64,
        dstX: IsometricRender.getRenderX(shadowX, shadowY, shadowZ),
        dstY: IsometricRender.getRenderY(shadowX, shadowY, shadowZ),
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

    // final height = gamestream.isometricEngine.nodes.heightMap[(character.indexRow * gamestream.isometricEngine.nodes.totalColumns) + character.indexColumn];
    // GameRender.renderTextV3(character, gamestream.isometricEngine.nodes.nodeAlps[character.nodeIndex - gamestream.isometricEngine.nodes.area], offsetY: -80);

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
}



