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

    final scale = options.characterRenderScale;
    final direction = IsometricDirection.toInputDirection(character.direction);
    final color = character.color;
    final dstX = character.renderX;
    final dstY = character.renderY;
    final characterState = character.state;
    final row = character.renderDirection;
    final animationFrame = character.animationFrame;
    final actionComplete = character.actionComplete;
    final completingAction = actionComplete > 0;

    final sprites = images.kidCharacterSprites;
    final atlasHandsLeft = sprites.handLeft[character.handTypeLeft] ?? (throw Exception());
    final atlasHandsRight = sprites.handRight[character.handTypeRight] ?? (throw Exception());
    final atlasHelm = sprites.helm[character.headType] ?? (throw Exception());
    final atlasLegs =  sprites.legs[character.legType] ?? (throw Exception());
    final bodySprite = character.gender == Gender.male ? sprites.bodyMale : sprites.bodyFemale;
    final atlasBody = bodySprite[character.bodyType] ?? (throw Exception());
    final atlasWeapon = sprites.weapons[character.weaponType] ??
        (throw Exception('images.spriteGroupWeapons[${WeaponType.getName(character.weaponType)}] is null'));
    final atlasBodyArm = sprites.bodyArms[character.bodyType] ?? (throw Exception());
    final atlasArmLeft = sprites.armLeft[ArmType.regular] ?? (throw Exception());
    final atlasArmRight = sprites.armRight[ArmType.regular] ?? (throw Exception());
    final atlasHead = sprites.head[HeadType.regular] ?? (throw Exception());
    final atlasTorso = sprites.torso[TorsoType.regular] ?? (throw Exception());
    final atlasShadow = sprites.shadow[ShadowType.regular] ?? (throw Exception());
    final atlasHair = sprites.hair[character.hairType] ?? (throw Exception());
    final atlasShoesLeft = sprites.shoesLeft[character.shoeType] ?? (throw Exception());
    final atlasShoesRight = sprites.shoesRight[character.shoeType] ?? (throw Exception());

    final spriteWeapon = atlasWeapon.fromCharacterState(characterState);
    final spriteHelm = atlasHelm.fromCharacterState(characterState);
    final spriteBody = atlasBody.fromCharacterState(characterState);
    final spriteBodyArm = atlasBodyArm.fromCharacterState(characterState);
    final spriteHead = atlasHead.fromCharacterState(characterState);
    final spriteArmLeft = atlasArmLeft.fromCharacterState(characterState);
    final spriteArmRight = atlasArmRight.fromCharacterState(characterState);
    final spriteTorso = atlasTorso.fromCharacterState(characterState);
    final spriteLegs = atlasLegs.fromCharacterState(characterState);
    final spriteHandsLeft = atlasHandsLeft.fromCharacterState(characterState);
    final spriteHandsRight = atlasHandsRight.fromCharacterState(characterState);
    final spriteShadow = atlasShadow.fromCharacterState(characterState);
    final spriteHair = atlasHair.fromCharacterState(characterState);
    final spriteShoesLeft = atlasShoesLeft.fromCharacterState(characterState);
    final spriteShoesRight = atlasShoesRight.fromCharacterState(characterState);

    final Sprite spriteHandFront;
    final Sprite spriteHandBehind;
    final Sprite spriteArmFront;
    final Sprite spriteArmBehind;
    final Sprite spriteShoesFront;
    final Sprite spriteShoesBehind;

    final palette = colors.palette;
    final colorSkin = palette[character.complexion].value;
    final colorHair = palette[character.hairColor].value;

    final render = this.render;

    // render.textPosition(character, ShoeType.getName(character.shoeType), offsetY: -100);

    final leftInFront = const [
      InputDirection.Up_Left,
      InputDirection.Left,
      InputDirection.Down_Left,
    ].contains(direction);

    if (leftInFront) {
      spriteHandFront = spriteHandsLeft;
      spriteHandBehind = spriteHandsRight;
      spriteArmFront = spriteArmLeft;
      spriteArmBehind = spriteArmRight;
      spriteShoesFront = spriteShoesLeft;
      spriteShoesBehind = spriteShoesRight;
    } else {
      spriteHandFront = spriteHandsRight;
      spriteHandBehind = spriteHandsLeft;
      spriteArmFront = spriteArmRight; // spriteArmRight
      spriteArmBehind = spriteArmLeft;
      spriteShoesFront = spriteShoesRight;
      spriteShoesBehind = spriteShoesLeft;
    }

    if (renderBottom) {

      render.sprite(
        sprite: spriteShadow,
        frame: completingAction
            ? spriteShadow.getFramePercentage(row, actionComplete)
            : spriteShadow.getFrame(row: row, column: animationFrame),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.modulate(
        sprite: spriteTorso,
        frame: completingAction
            ? spriteTorso.getFramePercentage(row, actionComplete)
            : spriteTorso.getFrame(column: animationFrame, row: row),
        color1: colorSkin,
        color2: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: spriteLegs,
        frame: completingAction
            ? spriteLegs.getFramePercentage(row, actionComplete)
            : spriteLegs.getFrame(row: row, column: animationFrame),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: spriteShoesBehind,
        frame: completingAction
            ? spriteShoesBehind.getFramePercentage(row, actionComplete)
            : spriteShoesBehind.getFrame(row: row, column: animationFrame),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: spriteShoesFront,
        frame: completingAction
            ? spriteShoesFront.getFramePercentage(row, actionComplete)
            : spriteShoesFront.getFrame(row: row, column: animationFrame),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
      return;
    }

    render.modulate(
      sprite: spriteArmBehind,
      frame: completingAction
          ? spriteArmBehind.getFramePercentage(row, actionComplete)
          : spriteArmBehind.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteHandBehind,
      frame: completingAction
          ? spriteHandBehind.getFramePercentage(row, actionComplete)
          : spriteHandBehind.getFrame(row: row, column: animationFrame),
      color: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    if (spriteHandsRight != spriteHandFront){
      render.sprite(
        sprite: spriteWeapon,
        frame: completingAction
            ? spriteWeapon.getFramePercentage(row, actionComplete)
            : spriteWeapon.getFrame(row: row, column: animationFrame),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }

    final bodyFirst = const [
      InputDirection.Left,
      InputDirection.Down_Left,
      InputDirection.Down,
      InputDirection.Down_Right,
      InputDirection.Right,
    ].contains(direction);

    if (bodyFirst){
      render.sprite(
        sprite: spriteBody,
        frame: completingAction
            ? spriteBody.getFramePercentage(row, actionComplete)
            : spriteBody.getFrame(row: row, column: animationFrame),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }


    render.modulate(
      sprite: spriteArmFront,
      frame: completingAction
          ? spriteArmFront.getFramePercentage(row, actionComplete)
          : spriteArmFront.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    if (spriteHandsRight == spriteHandFront){
      render.sprite(
        sprite: spriteWeapon,
        frame: completingAction
            ? spriteWeapon.getFramePercentage(row, actionComplete)
            : spriteWeapon.getFrame(row: row, column: animationFrame),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }

    render.sprite(
      sprite: spriteHandFront,
      frame: completingAction
          ? spriteHandFront.getFramePercentage(row, actionComplete)
          : spriteHandFront.getFrame(row: row, column: animationFrame),
      color: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    if (!bodyFirst){
      render.sprite(
        sprite: spriteBody,
        frame: completingAction
            ? spriteBody.getFramePercentage(row, actionComplete)
            : spriteBody.getFrame(row: row, column: animationFrame),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }

    render.sprite(
      sprite: spriteBodyArm,
      frame: completingAction
          ? spriteBodyArm.getFramePercentage(row, actionComplete)
          : spriteBodyArm.getFrame(row: row, column: animationFrame),
      color: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.modulate(
      sprite: spriteHead,
      frame: completingAction
          ? spriteHead.getFramePercentage(row, actionComplete)
          : spriteHead.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.modulate(
      sprite: spriteHair,
      frame: completingAction
          ? spriteHair.getFramePercentage(row, actionComplete)
          : spriteHair.getFrame(row: row, column: animationFrame),
      color1: colorHair,
      color2: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteHelm,
      frame: completingAction
          ? spriteHelm.getFramePercentage(row, actionComplete)
          : spriteHelm.getFrame(row: row, column: animationFrame),
      color: color,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );
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
