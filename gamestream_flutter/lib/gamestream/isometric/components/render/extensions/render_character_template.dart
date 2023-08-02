import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/classes/template_animation.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_characters.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/utils.dart';

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

    if (weaponType == WeaponType.Unarmed) return;
    const Sprite_Size = 125.0;
    engine.renderSprite(
        image: images.getImageForWeaponType(weaponType),
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

    var frameLegs = 0;
    var frameHead = 0;
    var frameBody = 0;
    var frameWeapon = 0;

    final renderLookDirection = character.renderLookDirection;
    final renderDirection = character.renderDirection;

    final lookDirectionDifference = IsometricDirection.getDifference(renderDirection, renderLookDirection).abs();
    final runningBackwards = lookDirectionDifference >= 3 && character.running;
    final renderDirectionOpposite = (renderDirection + 4) % 8;
    final weaponType = character.weaponType;

    final upperBodyDirection = runningBackwards ? renderDirectionOpposite : renderDirection;
    final weaponInFront = upperBodyDirection >= 2 && upperBodyDirection < 6;
    final weaponIsTwoHandedFirearm = const [
      WeaponType.Sniper_Rifle,
      WeaponType.Machine_Gun,
      WeaponType.Shotgun,
      WeaponType.Rifle,
    ].contains(weaponType);

    var directionLegs = upperBodyDirection;
    final weaponEngaged = character.weaponEngaged;
    var directionBody = weaponEngaged ? renderLookDirection : upperBodyDirection;
    var directionHead = weaponEngaged ? directionBody : renderLookDirection;

    switch (character.state) {
      case CharacterState.Idle:
        frameLegs = 0;
        frameWeapon = weaponIsTwoHandedFirearm ? 0 : 1;
        break;
      case CharacterState.Running:
        if (weaponIsTwoHandedFirearm) {
          frameWeapon = 15 + (character.animationFrame % 4);
        } else {
          frameWeapon = 11 + (character.animationFrame % 4);
        }
        frameLegs = frameWeapon;
        break;
      case CharacterState.Changing:
        frameLegs = TemplateAnimation.Frame_Changing;
        frameWeapon = TemplateAnimation.Frame_Changing;
        break;
      case CharacterState.Performing:
        final animation = TemplateAnimation.getWeaponPerformAnimation(weaponType);
        frameWeapon = capIndex(animation, character.animationFrame);
        frameLegs = frameWeapon;
        directionBody = renderDirection;
        directionHead = directionBody;
        directionLegs = directionBody;
        break;
      case CharacterState.Stunned:
        frameLegs = 0;
        frameWeapon = weaponIsTwoHandedFirearm ? 0 : 1;
        render.starsPosition(character);
        break;
    }

    switch (character.weaponState) {
      case WeaponState.Idle:
        break;
      case WeaponState.Performing:
        final animation = TemplateAnimation.getWeaponPerformAnimation(weaponType);
        frameWeapon = capIndex(animation, character.weaponStateDuration);
        break;
      case WeaponState.Reloading:
        frameWeapon = TemplateAnimation.Frame_Changing;
        break;
      case WeaponState.Aiming:
        if (WeaponType.isMelee(weaponType) || WeaponType.Grenade == weaponType) {
          frameWeapon = TemplateAnimation.Frame_Aiming_Sword;
        } else
        if (const[
          WeaponType.Handgun,
          WeaponType.Pistol,
          WeaponType.Smg,
          WeaponType.Plasma_Pistol,
        ].contains(weaponType)){
          frameWeapon = TemplateAnimation.Frame_Aiming_One_Handed;
        } else {
          frameWeapon = TemplateAnimation.Frame_Aiming_Two_Handed;
        }
        break;
      case WeaponState.Changing:
        frameWeapon = TemplateAnimation.Frame_Changing;
        break;
    }

    frameBody = frameWeapon;
    frameHead = frameWeapon;

    final invisible = false;

    final dstX = character.renderX;
    final dstY = character.renderY;

    const Color_Invisible = 1660944383;
    final color = invisible ? Color_Invisible : scene.getRenderColorPosition(character);

    if (invisible) {
      engine.bufferBlendMode = BlendMode.srcIn;
    }

    if (!weaponInFront) {
      renderTemplateWeapon(weaponType, directionBody, frameWeapon, color, dstX, dstY);
    }
    const Scale = 0.7;
    const Sprite_Size = 125.0;
    const Anchor_Y = 0.625;

    if (character.z >= IsometricConstants.Node_Height){

      final lightIndex = scene.getNearestLightSourcePosition(character, maxDistance: 5);

      if (lightIndex != -1){
         final lightRow = scene.getIndexRow(lightIndex);
         final lightColumn = scene.getIndexColumn(lightIndex);

         final lightX = (lightRow * Node_Size) + Node_Size_Half;
         final lightY = (lightColumn * Node_Size) + Node_Size_Half;

         final angle = angleBetween(lightX, lightY, character.x, character.y);
         final diff = angleDiff(angle, 4.0);
         final totalDiff = 1.0 - (diff / pi);
         final distance = 20.0 * totalDiff;

         // render.renderTextPosition(
         //   character,
         //   totalDiff,
         //   offsetY: -50,
         // );

         final x = character.x + adj(angle, distance);
         final y = character.y + opp(angle, distance);
         final z = character.z;

         engine.renderSprite(
           image: images.template_shadow,
           srcX: frameLegs * 64,
           srcY: upperBodyDirection * 64,
           srcWidth: 64,
           srcHeight: 64,
           dstX: getRenderX(x, y, z),
           dstY: getRenderY(x, y, z),
           scale: Scale,
           color: color,
           anchorY: Anchor_Y,
         );
      } else {
        engine.renderSprite(
          image: images.template_shadow,
          srcX: frameLegs * 64,
          srcY: upperBodyDirection * 64,
          srcWidth: 64,
          srcHeight: 64,
          dstX: character.renderX,
          dstY: character.renderY,
          scale: Scale,
          color: color,
          anchorY: Anchor_Y,
        );
      }
    }

    engine.renderSprite(
        image: images.getImageForLegType(character.legType),
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
        image: images.getImageForBodyType(character.bodyType),
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
        image: images.getImageForHeadType(character.headType),
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

  void renderCharacterShadow(Character character, {
    required double srcX,
    required double srcY,
    required double scale,
  }) {
    final lightIndex = scene.getNearestLightSourcePosition(
        character, maxDistance: 5);

    if (lightIndex != -1) {
      final lightRow = scene.getIndexRow(lightIndex);
      final lightColumn = scene.getIndexColumn(lightIndex);

      final lightX = (lightRow * Node_Size) + Node_Size_Half;
      final lightY = (lightColumn * Node_Size) + Node_Size_Half;

      final angle = angleBetween(lightX, lightY, character.x, character.y);
      final diff = angleDiff(angle, 4.0);
      final totalDiff = 1.0 - (diff / pi);
      final distance = 20.0 * totalDiff;

      // render.renderTextPosition(
      //   character,
      //   totalDiff,
      //   offsetY: -50,
      // );

      final x = character.x + adj(angle, distance);
      final y = character.y + opp(angle, distance);
      final z = character.z;

      engine.renderSprite(
        image: images.template_shadow,
        srcX: srcX,
        srcY: srcY,
        srcWidth: 64,
        srcHeight: 64,
        dstX: getRenderX(x, y, z),
        dstY: getRenderY(x, y, z),
        scale: scale,
        color: 0,
        anchorY: 0.8,
      );
    }
  }
}



