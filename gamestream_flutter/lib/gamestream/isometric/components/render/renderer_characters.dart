import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:golden_ratio/constants.dart';
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
      case CharacterType.Template:
        // renderCharacterTemplate(character);
        break;
      case CharacterType.Zombie:
        renderCharacterZombie(character);
        break;
      case CharacterType.Kid:
        renderCharacterKid(character);
        break;
      case CharacterType.Slime:
        break;
      case CharacterType.Rat:
        renderCharacterRat(character);
        break;
      case CharacterType.Dog:
        renderCharacterDog(character);
      case CharacterType.Fallen:
        renderCharacterFallen(character);
        break;
      default:
        throw Exception('Cannot render character type: ${character.characterType}');
    }
  }

  void renderCharacterDog(Character character){
    const Src_Size = 80.0;
    const Anchor_Y = 0.66;

    if (character.state == CharacterState.Idle){
      engine.renderSprite(
        image: images.character_dog,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: 0,
        srcY: Src_Size * character.direction,
        srcWidth: Src_Size,
        srcHeight: Src_Size,
        anchorY: Anchor_Y,
        scale: 1,
        color: character.color,
      );
      return;
    }

    if (character.state == CharacterState.Running) {
      const frames = const [4, 5];
      final frame = frames[(character.animationFrame % 2)];
      engine.renderSprite(
        image: images.character_dog,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: frame * Src_Size,
        srcY: Src_Size * character.direction,
        srcWidth: Src_Size,
        srcHeight: Src_Size,
        anchorY: Anchor_Y,
        scale: 1,
        color: character.color,
      );
      return;
    }

    // if (character.state == CharacterState.Performing) {
    //   const frames = const [1, 2];
    //   var frame = character.animationFrame;
    //   if (character.animationFrame >= frames.length){
    //     frame = frames.last;
    //   } else {
    //     frame = frames[frame];
    //   }
    //   engine.renderSprite(
    //     image: images.character_dog,
    //     dstX: character.renderX,
    //     dstY: character.renderY,
    //     srcX: frame * Src_Size,
    //     srcY: Src_Size * character.direction,
    //     srcWidth: Src_Size,
    //     srcHeight: Src_Size,
    //     anchorY: Anchor_Y,
    //     scale: 1,
    //     color: character.color,
    //   );
    //   return;
    // }

    if (character.state == CharacterState.Hurt) {
      engine.renderSprite(
        image: images.character_dog,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: Src_Size,
        srcY: Src_Size * character.direction,
        srcWidth: Src_Size,
        srcHeight: Src_Size,
        anchorY: Anchor_Y,
        scale: 1,
        color: character.color,
      );
      return;
    }

    if (character.state == CharacterState.Stunned){
      render.starsPosition(character);
      engine.renderSprite(
        image: images.character_dog,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: 0,
        srcY: Src_Size * character.direction,
        srcWidth: Src_Size,
        srcHeight: Src_Size,
        anchorY: Anchor_Y,
        scale: 1,
        color: character.color,
      );
      return;
    }
  }

  void renderCharacterZombie(Character character) {
    if (character.dead) return;
    if (character.spawning) return;

    var angle = 0.0;
    var dist = 0.0;
    // final nodes = gamestream.scene;

    // if (!nodes.outOfBoundsV3(character)){
    //   var torchIndex = nodes.getTorchIndex(nodes.getNodeIndexV3(character));
    //   if (torchIndex != -1) {
    //     final torchRow = nodes.convertNodeIndexToIndexX(torchIndex);
    //     final torchColumn = nodes.convertNodeIndexToIndexY(torchIndex);
    //     final torchPosX = torchRow * Node_Size + Node_Size_Half;
    //     final torchPosY = torchColumn * Node_Size + Node_Size_Half;
    //     angle = angleBetween(character.x, character.y, torchPosX, torchPosY);
    //     dist = min(
    //       Character_Shadow_Distance_Max,
    //       distanceBetween(
    //           character.x,
    //           character.y,
    //           torchPosX,
    //           torchPosY
    //       ) * Character_Shadow_Distance_Ratio,
    //     );
    //   }
    // }

    final shadowX = character.x + adj(angle, dist);
    final shadowY = character.y + opp(angle, dist);
    final shadowZ = character.z;

    engine.renderSprite(
      image: images.zombie_shadow,
      srcX: getZombieSrcX(character),
      srcY: character.renderDirection * 64,
      srcWidth: 64,
      srcHeight: 64,
      dstX: getRenderX(shadowX, shadowY, shadowZ),
      dstY: getRenderY(shadowX, shadowY, shadowZ),
      anchorY: 0.66,
      scale: 0.7,
      color: character.color,
    );

    engine.renderSprite(
      image: images.zombie,
      srcX: getZombieSrcX(character),
      srcY: character.renderDirection * 64,
      srcWidth: 64,
      srcHeight: 64,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: 0.68,
      scale: 0.7,
      color: character.color,
    );
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

  void renderCharacterRat(Character character){
    if (character.state == CharacterState.Running){
      engine.renderSprite(
        image: images.atlas_gameobjects,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: loop4(animation: const [1, 2, 3, 4], character: character, framesPerDirection: 4),
        srcY: 853,
        srcWidth: 64,
        srcHeight: 64,
        anchorY: 0.66,
        scale: 1,
        color: scene.getRenderColorPosition(character),
      );
    }

    // if (character.state == CharacterState.Performing){
    //   engine.renderSprite(
    //     image: images.atlas_gameobjects,
    //     dstX: character.renderX,
    //     dstY: character.renderY,
    //     srcX: 2680,
    //     srcY: character.direction * 64,
    //     srcWidth: 64,
    //     srcHeight: 64,
    //     anchorY: 0.66,
    //     scale: 1,
    //     color: scene.getRenderColorPosition(character),
    //   );
    // }

    engine.renderSprite(
      image: images.atlas_gameobjects,
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: 2680,
      srcY: character.direction * 64,
      srcWidth: 64,
      srcHeight: 64,
      anchorY: 0.66,
      scale: 1,
      color: scene.getRenderColorPosition(character),
    );
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
      final lightRow = scene.getIndexRow(lightIndex);
      final lightColumn = scene.getIndexColumn(lightIndex);
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

    final atlasHandsLeft = images.spriteGroup2HandsLeft[character.handTypeLeft] ?? (throw Exception());
    final atlasHandsRight = images.spriteGroup2HandsRight[character.handTypeRight] ?? (throw Exception());
    final atlasHelm = images.spriteGroup2Helms[character.headType] ?? (throw Exception());
    final atlasLegs =  images.spriteGroup2Legs[character.legType] ?? (throw Exception());
    final atlasBody = images.spriteGroup2Body[character.bodyType] ?? (throw Exception());
    final atlasWeapon = images.spriteGroup2Weapons[character.weaponType] ??
        (throw Exception('images.spriteGroupWeapons[${WeaponType.getName(character.weaponType)}] is null'));
    final atlasBodyArm = images.spriteGroup2BodyArms[character.bodyType] ?? (throw Exception());
    final atlasArmLeft = images.spriteGroup2ArmsLeft[ArmType.regular] ?? (throw Exception());
    final atlasArmRight = images.spriteGroup2ArmsRight[ArmType.regular] ?? (throw Exception());
    final atlasHead = images.spriteGroup2Heads[HeadType.regular] ?? (throw Exception());
    final atlasTorso = images.spriteGroup2Torso[TorsoType.regular] ?? (throw Exception());
    final atlasShadow = images.spriteGroup2Shadow[ShadowType.regular] ?? (throw Exception());

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

    final Sprite spriteHandFront;
    final Sprite spriteHandBehind;
    final Sprite spriteArmFront;
    final Sprite spriteArmBehind;

    final colorSkin = colors.fair_0.value;

    // render.textPosition(character, direction, offsetY: -100);

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
    } else {
      spriteHandFront = spriteHandsRight;
      spriteHandBehind = spriteHandsLeft;
      spriteArmFront = spriteArmRight; // spriteArmRight
      spriteArmBehind = spriteArmLeft;
    }

    if (renderBottom) {

      render.sprite2Frame(
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

      render.modulate2(
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

      render.sprite2Frame(
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
      return;
    }

    render.modulate2(
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

    render.sprite2Frame(
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
      render.sprite2Frame(
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
      render.sprite2Frame(
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


    render.modulate2(
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
      render.sprite2Frame(
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

    render.sprite2Frame(
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
      render.sprite2Frame(
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

    render.sprite2Frame(
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

    render.modulate2(
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

    render.sprite2Frame(
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
    final sprite = images.fallenSpriteGroup2.fromCharacterState(character.state);

    render.sprite2Frame(
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
