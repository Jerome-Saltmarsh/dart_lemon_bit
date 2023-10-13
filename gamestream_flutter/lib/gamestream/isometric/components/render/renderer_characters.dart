import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_sprite/lib.dart';

class RendererCharacters extends RenderGroup {

  var renderBottom = true;
  var renderQueueTop = 0;
  var renderQueueBottom = 0;
  late Character character;

  RendererCharacters(){
    print('RendererCharacters()');
  }

  @override
  void reset() {
    renderQueueBottom = 0;
    renderQueueTop = 0;
    renderBottom = true;
    super.reset();
  }

  void updateFunction() {
    final characters = scene.characters;
    final characterTop = characters[renderQueueTop];
    final characterTopOrder = characterTop.sortOrder;

    if (renderQueueBottom < scene.totalCharacters){
      final characterBottom = characters[renderQueueBottom];
      final characterBottomNodeType = scene.getNodeTypeAtPosition(characterBottom);
      final characterBottomOrder = characterBottom.sortOrder + (characterBottomNodeType == NodeType.Grass_Long ? -48 : 0);

      if (characterTopOrder >= characterBottomOrder){
        character = characterBottom;
        order = characterBottomOrder;
        renderBottom = true;
        renderQueueBottom++;
        return;
      }
    }

    character = characterTop;
    order = characterTopOrder;
    renderBottom = false;
    renderQueueTop++;
  }

  @override
  void renderFunction() => renderCurrentCharacter();

  @override
  int getTotal() => scene.totalCharacters * 2;

  void renderCurrentCharacter(){

    if (!renderBottom){
      if (!character.allie && options.renderHealthBarEnemies) {
        render.characterHealthBar(character);
      }

      if (character.allie && options.renderHealthBarAllies) {
        render.characterHealthBar(character);
      }
    }

    if (options.renderCharacterAnimationFrame){
      render.textPosition(character, character.animationFrame, offsetY: -100);
    }

    if (character.spawning) {
      return;
    }

    switch (character.characterType) {
      case CharacterType.Kid:
        renderCharacterKid(character);
        break;
      case CharacterType.Fallen:
        renderCharacterFallen(character);
        break;
      case CharacterType.Skeleton:
        renderCharacterSkeleton(character);
        break;
      default:
        throw Exception('Cannot render character type: ${character.characterType}');
    }
  }

  double getZombieSrcX(Character character) {
    const framesPerDirection = 0;
    switch (character.state) {
      case CharacterState.Running:
        return loop4(
            animation: const [3, 4, 5, 6],
            character: character,
            framesPerDirection: framesPerDirection
        );
      case CharacterState.Idle:
        return single(
            frame: 1,
            direction: character.direction,
            framesPerDirection: framesPerDirection
        );
      case CharacterState.Hurt:
        return single(
          frame: 2,
          direction: character.direction,
          framesPerDirection: framesPerDirection,
        );
      case CharacterState.Strike:
        return animate(
          animation: const [7, 7, 8, 8],
          character: character,
          framesPerDirection: framesPerDirection,
        );
      case CharacterState.Stunned:
        render.starsPosition(character);

        return single(
            frame: 1,
            direction: character.direction,
            framesPerDirection: framesPerDirection
        );
      default:
        throw Exception('Render zombie invalid state ${character.state}');
    }
  }

  double single({
    required int frame,
    required num direction,
    required int framesPerDirection,
    double size = 64.0
  }) {
    return ((direction * framesPerDirection) + (frame - 1)) * size;
  }

  double loop4({
    required List<int> animation,
    required Character character,
    required int framesPerDirection,
    double size = 64,
  }) => (character.renderDirection * framesPerDirection * size) +
        ((animation[character.animationFrame % 4] - 1) * size);

  double animate({
    required List<int> animation,
    required Character character,
    required int framesPerDirection,
    double size = 64.0
  }) {
    final animationFrame = min(character.animationFrame, animation.length - 1);
    final frame = animation[animationFrame] - 1;
    return (character.renderDirection * framesPerDirection * size) + (frame * size);
  }

  void renderCharacterShadowCircle(Character character) {
    final maxNodes = 5;
    final lightIndex = scene.getNearestLightSourcePosition(
        character, maxDistance: maxNodes);

    double x;
    double y;
    double z;
    double radius;

    if (lightIndex != -1) {
      final lightRow = scene.getRow(lightIndex);
      final lightColumn = scene.getColumn(lightIndex);
      final lightZ = scene.getIndexZ(lightIndex);

      final lightX = (lightRow * Node_Size) + Node_Size_Half;
      final lightY = (lightColumn * Node_Size) + Node_Size_Half;
      final lightPosZ = (lightZ * Node_Height) + Node_Height_Half;

      final angle = angleBetween(lightX, lightY, character.x, character.y);
      final distance = getDistanceXYZ(
          character.x,
          character.y,
          character.z,
          lightX,
          lightY,
          lightPosZ,
      );

      final maxDistance = maxNodes * Node_Size;
      final distanceInverse =  (distance <= 0 ? 0 : (maxDistance / distance)).clamp(0, 1);
      final shadowDistance = distanceInverse * 8.0;
      x = character.x + adj(angle, shadowDistance);
      y = character.y + opp(angle, shadowDistance);
      z = character.z;
    } else {
      x = character.x;
      y = character.y;
      z = character.z;
    }

    const radiusBase = 6.0;
    const radiusDelta = goldenRatio_0618;
    const shadowRadia = [
      radiusBase,
      radiusBase + radiusDelta,
      radiusBase,
      radiusBase - radiusDelta,
    ];

    if (character.running) {
      radius = shadowRadia[character.animationFrame % 4];
    } else {
      radius = shadowRadia[0];
    }

    engine.color = options.characterShadowColor;
    render.circleFilled(x, y, z, radius);
    engine.color = Colors.white;
  }

  /// TODO OPTIMIZE
  void renderCharacterKid(Character character) {
    const anchorY = 0.7;

    final characterIndex = scene.getIndexPosition(character);
    final scale = options.characterRenderScale;
    final direction = IsometricDirection.toInputDirection(character.direction);
    final color = character.color;
    // final colorN = scene.colorNorth(characterIndex);
    // final colorE = scene.colorEast(characterIndex);
    final colorS = scene.colorSouth(characterIndex);
    final colorW = scene.colorWest(characterIndex);
    final colorWest = colorW;
    final colorSouth = colorS;
    // final colorWest = mergeColors(colorN, colorW);
    // final colorSouth = mergeColors(colorS, colorE);
    final dstX = character.renderX;
    final dstY = character.renderY;
    final characterState = character.state;
    final row = character.renderDirection;
    final animationFrame = character.animationFrame;
    final actionComplete = character.actionComplete;
    final completingAction = actionComplete > 0;

    final spritesSouth = images.kidCharacterSpritesIsometricSouth;
    final spritesWest = images.kidCharacterSpritesIsometricWest;
    final atlasHandsLeftSouth = spritesSouth.handLeft[character.handTypeLeft] ?? (throw Exception());
    final atlasHandsLeftWest = spritesWest.handLeft[character.handTypeLeft] ?? (throw Exception());
    final atlasHandsRightSouth = spritesSouth.handRight[character.handTypeRight] ?? (throw Exception());
    final atlasHandsRightWest = spritesWest.handRight[character.handTypeRight] ?? (throw Exception());
    final atlasHelmSouth = spritesSouth.helm[character.helmType] ?? (throw Exception());
    final atlasHelmWest = spritesWest.helm[character.helmType] ?? (throw Exception());
    final atlasLegsSouth =  spritesSouth.legs[character.legType] ?? (throw Exception());
    final atlasLegsWest =  spritesWest.legs[character.legType] ?? (throw Exception());
    final bodySpriteSouth = character.gender == Gender.male ? spritesSouth.bodyMale : spritesSouth.bodyFemale;
    final bodySpriteWest = character.gender == Gender.male ? spritesWest.bodyMale : spritesWest.bodyFemale;
    final atlasBodySouth = bodySpriteSouth[character.bodyType] ?? (throw Exception());
    final atlasBodyWest = bodySpriteWest[character.bodyType] ?? (throw Exception());
    final atlasWeaponSouth = spritesSouth.weapons[character.weaponType]
        ?? spritesSouth.weapons[WeaponType.Unarmed] ?? (throw Exception());
    final atlasWeaponWest = spritesWest.weapons[character.weaponType]
        ?? spritesWest.weapons[WeaponType.Unarmed] ?? (throw Exception());
    final atlasBodyArmSouth = spritesSouth.bodyArms[character.bodyType] ?? (throw Exception());
    final atlasBodyArmWest = spritesWest.bodyArms[character.bodyType] ?? (throw Exception());
    final atlasArmLeftSouth = spritesSouth.armLeft[ArmType.regular] ?? (throw Exception());
    final atlasArmLeftWest = spritesWest.armLeft[ArmType.regular] ?? (throw Exception());
    final atlasArmRightSouth = spritesSouth.armRight[ArmType.regular] ?? (throw Exception());
    final atlasArmRightWest = spritesWest.armRight[ArmType.regular] ?? (throw Exception());
    final atlasHeadSouth = spritesSouth.head[character.headType] ?? (throw Exception());
    final atlasHeadWest = spritesWest.head[character.headType] ?? (throw Exception());
    final atlasTorsoSouth = spritesSouth.torso[character.gender] ?? (throw Exception());
    final atlasTorsoWest = spritesWest.torso[character.gender] ?? (throw Exception());
    final atlasShadow = spritesSouth.shadow[ShadowType.regular] ?? (throw Exception());
    final atlasHairFront = spritesSouth.hairFront[character.hairType] ?? (throw Exception());
    final atlasHairBack = spritesSouth.hairBack[character.hairType] ?? (throw Exception());
    final atlasHairTop = spritesSouth.hairTop[character.hairType] ?? (throw Exception());
    final atlasShoesLeftSouth = spritesSouth.shoesLeft[character.shoeType] ?? (throw Exception());
    final atlasShoesLeftWest = spritesWest.shoesLeft[character.shoeType] ?? (throw Exception());
    final atlasShoesRightSouth = spritesSouth.shoesRight[character.shoeType] ?? (throw Exception());
    final atlasShoesRightWest = spritesWest.shoesRight[character.shoeType] ?? (throw Exception());

    final spriteWeaponSouth = atlasWeaponSouth.fromCharacterState(characterState);
    final spriteWeaponWest = atlasWeaponWest.fromCharacterState(characterState);
    final spriteHelmSouth = atlasHelmSouth.fromCharacterState(characterState);
    final spriteHelmWest = atlasHelmWest.fromCharacterState(characterState);
    final spriteBodySouth = atlasBodySouth.fromCharacterState(characterState);
    final spriteBodyWest = atlasBodyWest.fromCharacterState(characterState);
    final spriteBodyArmSouth = atlasBodyArmSouth.fromCharacterState(characterState);
    final spriteBodyArmWest = atlasBodyArmWest.fromCharacterState(characterState);
    final spriteHeadSouth = atlasHeadSouth.fromCharacterState(characterState);
    final spriteHeadWest = atlasHeadWest.fromCharacterState(characterState);
    final spriteArmLeftSouth = atlasArmLeftSouth.fromCharacterState(characterState);
    final spriteArmLeftWest = atlasArmLeftWest.fromCharacterState(characterState);
    final spriteArmRightSouth = atlasArmRightSouth.fromCharacterState(characterState);
    final spriteArmRightWest = atlasArmRightWest.fromCharacterState(characterState);
    final spriteTorsoSouth = atlasTorsoSouth.fromCharacterState(characterState);
    final spriteTorsoWest = atlasTorsoWest.fromCharacterState(characterState);
    final spriteLegsSouth = atlasLegsSouth.fromCharacterState(characterState);
    final spriteLegsWest = atlasLegsWest.fromCharacterState(characterState);
    final spriteHandsLeftSouth = atlasHandsLeftSouth.fromCharacterState(characterState);
    final spriteHandsLeftWest = atlasHandsLeftWest.fromCharacterState(characterState);
    final spriteHandsRightSouth = atlasHandsRightSouth.fromCharacterState(characterState);
    final spriteHandsRightWest = atlasHandsRightWest.fromCharacterState(characterState);
    final spriteShadow = atlasShadow.fromCharacterState(characterState);
    final spriteHairFront = atlasHairFront.fromCharacterState(characterState);
    final spriteHairBack = atlasHairBack.fromCharacterState(characterState);
    final spriteShoesLeftSouth = atlasShoesLeftSouth.fromCharacterState(characterState);
    final spriteShoesLeftWest = atlasShoesLeftWest.fromCharacterState(characterState);
    final spriteShoesRightSouth = atlasShoesRightSouth.fromCharacterState(characterState);
    final spriteShoesRightWest = atlasShoesRightWest.fromCharacterState(characterState);
    final spriteHairTop = atlasHairTop.fromCharacterState(characterState);

    final Sprite spriteHairInFront;
    final Sprite spriteHairBehind;
    final Sprite spriteHandFrontSouth;
    final Sprite spriteHandFrontWest;
    final Sprite spriteHandBehindSouth;
    final Sprite spriteHandBehindWest;
    final Sprite spriteArmFrontSouth;
    final Sprite spriteArmFrontWest;
    final Sprite spriteArmBehindSouth;
    final Sprite spriteArmBehindWest;
    final Sprite spriteShoesFrontSouth;
    final Sprite spriteShoesFrontWest;
    final Sprite spriteShoesBehindSouth;
    final Sprite spriteShoesBehindWest;

    final palette = colors.palette;
    final colorSkin = palette[character.complexion].value;
    final colorHair = palette[character.hairColor].value;

    final render = this.render;

    final leftInFront = const [
      InputDirection.Up_Left,
      InputDirection.Left,
      InputDirection.Down_Left,
    ].contains(direction);

    final fringeInFront = const [
      InputDirection.Down_Right,
      InputDirection.Down,
      InputDirection.Down_Left,
    ].contains(direction);

    if (fringeInFront){
      spriteHairInFront = spriteHairFront;
      spriteHairBehind = spriteHairBack;
    } else {
      spriteHairInFront = spriteHairBack;
      spriteHairBehind = spriteHairFront;
    }

    if (leftInFront) {
      spriteHandFrontSouth = spriteHandsLeftSouth;
      spriteHandFrontWest = spriteHandsLeftWest;
      spriteHandBehindSouth = spriteHandsRightSouth;
      spriteHandBehindWest = spriteHandsRightWest;
      spriteArmFrontSouth = spriteArmLeftSouth;
      spriteArmFrontWest = spriteArmLeftWest;
      spriteArmBehindSouth = spriteArmRightSouth;
      spriteArmBehindWest = spriteArmRightWest;
      spriteShoesFrontSouth = spriteShoesLeftSouth;
      spriteShoesFrontWest = spriteShoesLeftWest;
      spriteShoesBehindSouth = spriteShoesRightSouth;
      spriteShoesBehindWest = spriteShoesRightWest;
    } else {
      spriteHandFrontSouth = spriteHandsRightSouth;
      spriteHandFrontWest = spriteHandsRightSouth;
      spriteHandBehindSouth = spriteHandsLeftSouth;
      spriteHandBehindWest = spriteHandsLeftWest;
      spriteArmFrontSouth = spriteArmRightSouth; // spriteArmRight
      spriteArmFrontWest = spriteArmRightSouth; // spriteArmRight
      spriteArmBehindSouth = spriteArmLeftSouth;
      spriteArmBehindWest = spriteArmLeftWest;
      spriteShoesFrontSouth = spriteShoesRightSouth;
      spriteShoesFrontWest = spriteShoesRightWest;
      spriteShoesBehindSouth = spriteShoesLeftSouth;
      spriteShoesBehindWest = spriteShoesLeftWest;
    }

    final renderSprite = render.sprite;
    final modulate = render.modulate;

    if (renderBottom) {

      renderSprite(
        sprite: spriteShadow,
        frame: completingAction
            ? spriteShadow.getFramePercentage(row, actionComplete)
            : spriteShadow.getFrame(row: row, column: animationFrame),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      modulate(
        sprite: spriteTorsoSouth,
        frame: completingAction
            ? spriteTorsoSouth.getFramePercentage(row, actionComplete)
            : spriteTorsoSouth.getFrame(column: animationFrame, row: row),
        color1: colorSkin,
        color2: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      modulate(
        sprite: spriteTorsoWest,
        frame: completingAction
            ? spriteTorsoWest.getFramePercentage(row, actionComplete)
            : spriteTorsoWest.getFrame(column: animationFrame, row: row),
        color1: colorSkin,
        color2: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteLegsSouth,
        frame: completingAction
            ? spriteLegsSouth.getFramePercentage(row, actionComplete)
            : spriteLegsSouth.getFrame(row: row, column: animationFrame),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteLegsWest,
        frame: completingAction
            ? spriteLegsWest.getFramePercentage(row, actionComplete)
            : spriteLegsWest.getFrame(row: row, column: animationFrame),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteShoesBehindSouth,
        frame: completingAction
            ? spriteShoesBehindSouth.getFramePercentage(row, actionComplete)
            : spriteShoesBehindSouth.getFrame(row: row, column: animationFrame),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteShoesFrontSouth,
        frame: completingAction
            ? spriteShoesFrontSouth.getFramePercentage(row, actionComplete)
            : spriteShoesFrontSouth.getFrame(row: row, column: animationFrame),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
      renderSprite(
        sprite: spriteShoesFrontWest,
        frame: completingAction
            ? spriteShoesFrontWest.getFramePercentage(row, actionComplete)
            : spriteShoesFrontWest.getFrame(row: row, column: animationFrame),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
      return;
    }


    final hairFrame = completingAction
        ? spriteHairTop.getFramePercentage(row, actionComplete)
        : spriteHairTop.getFrame(row: row, column: animationFrame);

    modulate(
      sprite: spriteHairBehind,
      frame: hairFrame,
      color1: colorHair,
      color2: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteArmBehindSouth,
      frame: completingAction
          ? spriteArmBehindSouth.getFramePercentage(row, actionComplete)
          : spriteArmBehindSouth.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteArmBehindWest,
      frame: completingAction
          ? spriteArmBehindWest.getFramePercentage(row, actionComplete)
          : spriteArmBehindWest.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHandBehindSouth,
      frame: completingAction
          ? spriteHandBehindSouth.getFramePercentage(row, actionComplete)
          : spriteHandBehindSouth.getFrame(row: row, column: animationFrame),
      color: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHandBehindWest,
      frame: completingAction
          ? spriteHandBehindWest.getFramePercentage(row, actionComplete)
          : spriteHandBehindWest.getFrame(row: row, column: animationFrame),
      color: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    if (spriteHandsRightSouth != spriteHandFrontSouth){
      renderSprite(
        sprite: spriteWeaponSouth,
        frame: completingAction
            ? spriteWeaponSouth.getFramePercentage(row, actionComplete)
            : spriteWeaponSouth.getFrame(row: row, column: animationFrame),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteWeaponWest,
        frame: completingAction
            ? spriteWeaponWest.getFramePercentage(row, actionComplete)
            : spriteWeaponWest.getFrame(row: row, column: animationFrame),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }

    final bodyFirst = const [
      InputDirection.Down_Left,
      InputDirection.Down,
      InputDirection.Down_Right,
      InputDirection.Right,
    ].contains(direction);


    // render.textPosition(character, direction, offsetY: -100);
    // render.textPosition(character, bodyFirst, offsetY: -100);

    if (bodyFirst){
      renderSprite(
        sprite: spriteBodySouth,
        frame: completingAction
            ? spriteBodySouth.getFramePercentage(row, actionComplete)
            : spriteBodySouth.getFrame(row: row, column: animationFrame),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
      renderSprite(
        sprite: spriteBodyWest,
        frame: completingAction
            ? spriteBodyWest.getFramePercentage(row, actionComplete)
            : spriteBodyWest.getFrame(row: row, column: animationFrame),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }

    renderSprite(
      sprite: spriteWeaponSouth,
      frame: completingAction
          ? spriteWeaponSouth.getFramePercentage(row, actionComplete)
          : spriteWeaponSouth.getFrame(row: row, column: animationFrame),
      color: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteWeaponWest,
      frame: completingAction
          ? spriteWeaponWest.getFramePercentage(row, actionComplete)
          : spriteWeaponWest.getFrame(row: row, column: animationFrame),
      color: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteArmFrontSouth,
      frame: completingAction
          ? spriteArmFrontSouth.getFramePercentage(row, actionComplete)
          : spriteArmFrontSouth.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteArmFrontWest,
      frame: completingAction
          ? spriteArmFrontWest.getFramePercentage(row, actionComplete)
          : spriteArmFrontWest.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHandFrontSouth,
      frame: completingAction
          ? spriteHandFrontSouth.getFramePercentage(row, actionComplete)
          : spriteHandFrontSouth.getFrame(row: row, column: animationFrame),
      color: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHandFrontWest,
      frame: completingAction
          ? spriteHandFrontWest.getFramePercentage(row, actionComplete)
          : spriteHandFrontWest.getFrame(row: row, column: animationFrame),
      color: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    if (!bodyFirst){
      renderSprite(
        sprite: spriteBodySouth,
        frame: completingAction
            ? spriteBodySouth.getFramePercentage(row, actionComplete)
            : spriteBodySouth.getFrame(row: row, column: animationFrame),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteBodyWest,
        frame: completingAction
            ? spriteBodyWest.getFramePercentage(row, actionComplete)
            : spriteBodyWest.getFrame(row: row, column: animationFrame),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }

    renderSprite(
      sprite: spriteBodyArmSouth,
      frame: completingAction
          ? spriteBodyArmSouth.getFramePercentage(row, actionComplete)
          : spriteBodyArmSouth.getFrame(row: row, column: animationFrame),
      color: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteBodyArmWest,
      frame: completingAction
          ? spriteBodyArmWest.getFramePercentage(row, actionComplete)
          : spriteBodyArmWest.getFrame(row: row, column: animationFrame),
      color: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteHeadSouth,
      frame: completingAction
          ? spriteHeadSouth.getFramePercentage(row, actionComplete)
          : spriteHeadSouth.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteHeadWest,
      frame: completingAction
          ? spriteHeadWest.getFramePercentage(row, actionComplete)
          : spriteHeadWest.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteHairInFront,
      frame: hairFrame,
      color1: colorHair,
      color2: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteHairTop,
      frame: hairFrame,
      color1: colorHair,
      color2: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHelmSouth,
      frame: completingAction
          ? spriteHelmSouth.getFramePercentage(row, actionComplete)
          : spriteHelmSouth.getFrame(row: row, column: animationFrame),
      color: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHelmWest,
      frame: completingAction
          ? spriteHelmWest.getFramePercentage(row, actionComplete)
          : spriteHelmWest.getFrame(row: row, column: animationFrame),
      color: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    // engine.renderText(compositor.order.toString(), dstX - 24, dstY - 24);
  }

  void renderCharacterFallen(Character character) {

    if (
      (renderBottom && !character.dead) ||
      (!renderBottom && character.dead))
      return;

    const scale = 0.61;
    const anchorY = 0.6;

    final row = character.renderDirection;
    final column = character.animationFrame;
    final sprite = images.spriteGroupFallen.fromCharacterState(character.state);

    render.sprite(
      sprite: sprite,
      frame: sprite.getFrame(row: row, column: column),
      color: character.color,
      scale: scale,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: anchorY,
    );
  }

  void renderCharacterSkeleton(Character character) {

    if (
      (renderBottom && !character.dead) ||
      (!renderBottom && character.dead))
      return;

    const scale = 0.61;
    const anchorY = 0.6;

    final row = character.renderDirection;
    final column = character.animationFrame;
    final sprite = images.spriteGroupSkeleton.fromCharacterState(character.state);

    render.sprite(
      sprite: sprite,
      frame: sprite.getFrame(row: row, column: column),
      color: character.color,
      scale: scale,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: anchorY,
    );
  }
}

// int mergeColors(int a, int b){
//   final aRed = getRed(a);
//   final aBlue = getBlue(a);
//   final aGreen = getGreen(a);
//   final bRed = getRed(b);
//   final bBlue = getBlue(b);
//   final bGreen = getGreen(b);
//   return rgba(
//       r: (aRed + bRed) ~/ 2,
//       g: (aGreen + bGreen) ~/ 2,
//       b: (aBlue + bBlue) ~/ 2,
//       a: 255
//   );
// }

int mergeColors(int a, int b) {
  // Extract the red, green, and blue components of each color
  int aRed = (a >> 16) & 0xFF;
  int aGreen = (a >> 8) & 0xFF;
  int aBlue = a & 0xFF;

  int bRed = (b >> 16) & 0xFF;
  int bGreen = (b >> 8) & 0xFF;
  int bBlue = b & 0xFF;

  // Calculate the average of the color components
  int mergedRed = (aRed + bRed) ~/ 2;
  int mergedGreen = (aGreen + bGreen) ~/ 2;
  int mergedBlue = (aBlue + bBlue) ~/ 2;

  // Combine the color components into a single integer
  int mergedColor = (mergedRed << 16) | (mergedGreen << 8) | mergedBlue;

  return mergedColor;
}