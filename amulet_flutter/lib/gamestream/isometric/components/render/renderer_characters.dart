import 'package:amulet_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_images.dart';
import 'package:amulet_flutter/isometric/classes/character.dart';
import 'package:amulet_engine/packages/common.dart';
import 'package:lemon_engine/lemon_engine.dart';

import 'functions/merge_32_bit_colors.dart';

class RendererCharacters extends RenderGroup {

  var renderBottom = true;
  var renderQueueTop = 0;
  var renderQueueBottom = 0;
  late Character character;

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
  void renderFunction(LemonEngine engine, IsometricImages images) {
    final character = this.character;

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

    scene.applyColorToCharacter(character);

    switch (character.characterType) {
      case CharacterType.Human:
        renderCharacterHuman(character);
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

  @override
  int getTotal() => scene.totalCharacters * 2;


  /// TODO OPTIMIZE
  void renderCharacterHuman(Character character) {
    const anchorY = 0.7;
    // final scene = this.scene;
    final scale = options.characterRenderScale;

    // final colorN = merge32BitColors(colorN1, colorN2);
    // final colorE = merge32BitColors(colorE1, colorE2);
    // final colorS = merge32BitColors(colorS1, colorS2);
    // final colorW = merge32BitColors(colorW1, colorW2);

    // final colorSouth = merge32BitsColors3(colorS, colorE, colorSE);
    // final colorWest = merge32BitsColors3(colorN, colorW, colorNW);

    final colorSouth = character.colorSouthEast;
    final colorWest = character.colorNorthWest;

    final colorDiffuse = merge32BitColors(colorSouth, colorWest);
    final dstX = character.renderX;
    final dstY = character.renderY;
    final characterState = character.state;
    final row = character.renderDirection;
    final animationFrame = character.animationFrame;
    final actionComplete = character.actionComplete;
    final completingAction = actionComplete > 0;

    final images = this.images;
    final spritesShadow = images.kidCharacterSpriteGroupShadow;
    final spritesSouth = images.kidCharacterSpritesIsometricSouth;
    final spritesWest = images.kidCharacterSpritesIsometricWest;
    final spritesDiffuse = images.kidCharacterSpritesIsometricDiffuse;

    final handTypeLeft = character.handTypeLeft;
    final handTypeRight = character.handTypeRight;
    final helmType = character.helmType;
    final legType = character.legType;
    final gender = character.gender;
    final bodyType = character.bodyType;
    final weaponType = character.weaponType;
    final headType = character.headType;
    final hairType = character.hairType;
    final shoeType = character.shoeType;

    final atlasHandsLeftSouth = spritesSouth.handLeft[handTypeLeft] ?? (throw Exception());
    final atlasHandsLeftWest = spritesWest.handLeft[handTypeLeft] ?? (throw Exception());
    final atlasHandsLeftDiffuse = spritesDiffuse.handLeft[handTypeLeft] ?? (throw Exception());
    final atlasHandsRightSouth = spritesSouth.handRight[handTypeRight] ?? (throw Exception());
    final atlasHandsRightWest = spritesWest.handRight[handTypeRight] ?? (throw Exception());
    final atlasHandsRightDiffuse = spritesDiffuse.handRight[handTypeRight] ?? (throw Exception());
    final atlasHelmSouth = spritesSouth.helm[helmType] ?? (throw Exception());
    final atlasHelmWest = spritesWest.helm[helmType] ?? (throw Exception());
    final atlasHelmDiffuse = spritesDiffuse.helm[helmType] ?? (throw Exception());
    final atlasLegsDiffuse =  spritesDiffuse.legs[legType] ?? (throw Exception());
    final atlasLegsSouth =  spritesSouth.legs[legType] ?? (throw Exception());
    final atlasLegsWest =  spritesWest.legs[legType] ?? (throw Exception());
    final bodySpriteSouth = gender == Gender.male ? spritesSouth.bodyMale : spritesSouth.bodyFemale;
    final bodySpriteWest = gender == Gender.male ? spritesWest.bodyMale : spritesWest.bodyFemale;
    final bodySpriteDiffuse = gender == Gender.male ? spritesDiffuse.bodyMale : spritesDiffuse.bodyFemale;
    final atlasBodySouth = bodySpriteSouth[bodyType] ?? (throw Exception());
    final atlasBodyWest = bodySpriteWest[bodyType] ?? (throw Exception());
    final atlasBodyDiffuse = bodySpriteDiffuse[bodyType] ?? (throw Exception());
    final atlasWeaponSouth = spritesSouth.weapons[weaponType]
        ?? spritesSouth.weapons[WeaponType.Unarmed] ?? (throw Exception());
    final atlasWeaponWest = spritesWest.weapons[weaponType]
        ?? spritesWest.weapons[WeaponType.Unarmed] ?? (throw Exception());
    final atlasWeaponDiffuse = spritesDiffuse.weapons[weaponType]
        ?? spritesWest.weapons[WeaponType.Unarmed] ?? (throw Exception());
    final atlasHairSouth = spritesSouth.hair[hairType] ?? (throw Exception());
    final atlasHairWest = spritesWest.hair[hairType] ?? (throw Exception());
    final atlasHairDiffuse = spritesDiffuse.hair[hairType] ?? (throw Exception());
    final atlasHeadSouth = spritesSouth.head[headType] ?? (throw Exception());
    final atlasHeadWest = spritesWest.head[headType] ?? (throw Exception());
    final atlasHeadDiffuse = spritesDiffuse.head[headType] ?? (throw Exception());
    final atlasTorsoSouth = spritesSouth.torso[gender] ?? (throw Exception());
    final atlasTorsoWest = spritesWest.torso[gender] ?? (throw Exception());
    final atlasTorsoDiffuse = spritesDiffuse.torso[gender] ?? (throw Exception());
    final atlasShoesSouth = spritesSouth.shoes[shoeType] ?? (throw Exception());
    final atlasShoesWest = spritesWest.shoes[shoeType] ?? (throw Exception());

    final spriteWeaponSouth = atlasWeaponSouth.fromCharacterState(characterState);
    final spriteWeaponWest = atlasWeaponWest.fromCharacterState(characterState);
    final spriteWeaponDiffuse = atlasWeaponDiffuse.fromCharacterState(characterState);
    final spriteHelmSouth = atlasHelmSouth.fromCharacterState(characterState);
    final spriteHelmWest = atlasHelmWest.fromCharacterState(characterState);
    final spriteHelmDiffuse = atlasHelmDiffuse.fromCharacterState(characterState);
    final spriteBodySouth = atlasBodySouth.fromCharacterState(characterState);
    final spriteBodyWest = atlasBodyWest.fromCharacterState(characterState);
    final spriteBodyDiffuse = atlasBodyDiffuse.fromCharacterState(characterState);
    final spriteHeadSouth = atlasHeadSouth.fromCharacterState(characterState);
    final spriteHeadWest = atlasHeadWest.fromCharacterState(characterState);
    final spriteHeadDiffuse = atlasHeadDiffuse.fromCharacterState(characterState);
    final spriteTorsoSouth = atlasTorsoSouth.fromCharacterState(characterState);
    final spriteTorsoWest = atlasTorsoWest.fromCharacterState(characterState);
    final spriteTorsoDiffuse = atlasTorsoDiffuse.fromCharacterState(characterState);
    final spriteLegsDiffuse = atlasLegsDiffuse.fromCharacterState(characterState);
    final spriteLegsSouth = atlasLegsSouth.fromCharacterState(characterState);
    final spriteLegsWest = atlasLegsWest.fromCharacterState(characterState);
    final spriteHandsLeftSouth = atlasHandsLeftSouth.fromCharacterState(characterState);
    final spriteHandsLeftWest = atlasHandsLeftWest.fromCharacterState(characterState);
    final spriteHandsLeftDiffuse = atlasHandsLeftDiffuse.fromCharacterState(characterState);
    final spriteHandsRightSouth = atlasHandsRightSouth.fromCharacterState(characterState);
    final spriteHandsRightWest = atlasHandsRightWest.fromCharacterState(characterState);
    final spriteHandsRightDiffuse = atlasHandsRightDiffuse.fromCharacterState(characterState);
    final spriteShadow = spritesShadow.fromCharacterState(characterState);
    final spriteHairSouth = atlasHairSouth.fromCharacterState(characterState);
    final spriteHairWest = atlasHairWest.fromCharacterState(characterState);
    final spriteHairDiffuse = atlasHairDiffuse.fromCharacterState(characterState);
    final spriteShoesSouth = atlasShoesSouth.fromCharacterState(characterState);
    final spriteShoesWest = atlasShoesWest.fromCharacterState(characterState);

    final palette = colors.palette;
    final colorSkin = palette[character.complexion].value;
    final colorHair = palette[character.hairColor].value;

    final render = this.render;
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
        sprite: spriteTorsoDiffuse,
        frame: completingAction
            ? spriteTorsoDiffuse.getFramePercentage(row, actionComplete)
            : spriteTorsoDiffuse.getFrame(column: animationFrame, row: row),
        color1: colorSkin,
        color2: colorDiffuse,
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
        sprite: spriteLegsDiffuse,
        frame: completingAction
            ? spriteLegsDiffuse.getFramePercentage(row, actionComplete)
            : spriteLegsDiffuse.getFrame(row: row, column: animationFrame),
        color: colorSouth,
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
        sprite: spriteShoesSouth,
        frame: completingAction
            ? spriteShoesSouth.getFramePercentage(row, actionComplete)
            : spriteShoesSouth.getFrame(row: row, column: animationFrame),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteShoesWest,
        frame: completingAction
            ? spriteShoesWest.getFramePercentage(row, actionComplete)
            : spriteShoesWest.getFrame(row: row, column: animationFrame),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
      return;
    }

    renderSprite(
      sprite: spriteWeaponDiffuse,
      frame: completingAction
          ? spriteWeaponDiffuse.getFramePercentage(row, actionComplete)
          : spriteWeaponDiffuse.getFrame(row: row, column: animationFrame),
      color: colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

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

    renderSprite(
      sprite: spriteBodyDiffuse,
      frame: completingAction
          ? spriteBodyDiffuse.getFramePercentage(row, actionComplete)
          : spriteBodyDiffuse.getFrame(row: row, column: animationFrame),
      color: colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

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

    renderSprite(
      sprite: spriteHandsLeftDiffuse,
      frame: completingAction
          ? spriteHandsLeftDiffuse.getFramePercentage(row, actionComplete)
          : spriteHandsLeftDiffuse.getFrame(row: row, column: animationFrame),
      color: colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHandsLeftWest,
      frame: completingAction
          ? spriteHandsLeftWest.getFramePercentage(row, actionComplete)
          : spriteHandsLeftWest.getFrame(row: row, column: animationFrame),
      color: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHandsLeftSouth,
      frame: completingAction
          ? spriteHandsLeftSouth.getFramePercentage(row, actionComplete)
          : spriteHandsLeftSouth.getFrame(row: row, column: animationFrame),
      color: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHandsRightDiffuse,
      frame: completingAction
          ? spriteHandsRightDiffuse.getFramePercentage(row, actionComplete)
          : spriteHandsRightDiffuse.getFrame(row: row, column: animationFrame),
      color: colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHandsRightWest,
      frame: completingAction
          ? spriteHandsRightWest.getFramePercentage(row, actionComplete)
          : spriteHandsRightWest.getFrame(row: row, column: animationFrame),
      color: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHandsRightSouth,
      frame: completingAction
          ? spriteHandsRightSouth.getFramePercentage(row, actionComplete)
          : spriteHandsRightSouth.getFrame(row: row, column: animationFrame),
      color: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteHeadDiffuse,
      frame: completingAction
          ? spriteHeadDiffuse.getFramePercentage(row, actionComplete)
          : spriteHeadDiffuse.getFrame(row: row, column: animationFrame),
      color1: colorSkin,
      color2: colorDiffuse,
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
      sprite: spriteHairDiffuse,
      frame: completingAction
          ? spriteHairDiffuse.getFramePercentage(row, actionComplete)
          : spriteHairDiffuse.getFrame(row: row, column: animationFrame),
      color1: colorHair,
      color2: colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteHairSouth,
      frame: completingAction
          ? spriteHairSouth.getFramePercentage(row, actionComplete)
          : spriteHairSouth.getFrame(row: row, column: animationFrame),
      color1: colorHair,
      color2: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    modulate(
      sprite: spriteHairWest,
      frame: completingAction
          ? spriteHairWest.getFramePercentage(row, actionComplete)
          : spriteHairWest.getFrame(row: row, column: animationFrame),
      color1: colorHair,
      color2: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHelmDiffuse,
      frame: completingAction
          ? spriteHelmDiffuse.getFramePercentage(row, actionComplete)
          : spriteHelmDiffuse.getFrame(row: row, column: animationFrame),
      color: colorDiffuse,
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
  }

  void renderCharacterFallen(Character character) {

    final renderBottom = this.renderBottom;
    final characterDead = character.dead;

    if (
      (renderBottom && !characterDead) ||
      (!renderBottom && characterDead))
      return;

    const scale = 0.5;
    const anchorY = 0.6;

    final images = this.images;
    final row = character.renderDirection;
    final column = character.animationFrame;
    final characterState = character.state;
    final spriteWest = images.spriteGroupFallenWest.fromCharacterState(characterState);
    final spriteSouth = images.spriteGroupFallenSouth.fromCharacterState(characterState);
    final spriteShadow = images.spriteGroupFallenShadow.fromCharacterState(characterState);
    final render = this.render;
    final dstX = character.renderX;
    final dstY = character.renderY;

    render.sprite(
      sprite: spriteShadow,
      frame: spriteShadow.getFrame(row: row, column: column),
      color: character.colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteWest,
      frame: spriteWest.getFrame(row: row, column: column),
      color: character.colorNorthWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteSouth,
      frame: spriteSouth.getFrame(row: row, column: column),
      color: character.colorSouthEast,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );
  }

  void renderCharacterSkeleton(Character character) {

    if (
      (renderBottom && !character.dead) ||
      (!renderBottom && character.dead))
      return;

    const scale = 0.5;
    const anchorY = 0.6;

    final images = this.images;
    final row = character.renderDirection;
    final column = character.animationFrame;
    final spriteShadow = images.spriteGroupSkeletonShadow.fromCharacterState(character.state);
    final spriteWest = images.spriteGroupSkeletonWest.fromCharacterState(character.state);
    final spriteSouth = images.spriteGroupSkeletonSouth.fromCharacterState(character.state);

    final dstX = character.renderX;
    final dstY = character.renderY;
    final render = this.render;

    render.sprite(
      sprite: spriteShadow,
      frame: spriteShadow.getFrame(row: row, column: column),
      color: character.colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteWest,
      frame: spriteWest.getFrame(row: row, column: column),
      color: character.colorNorthWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteSouth,
      frame: spriteSouth.getFrame(row: row, column: column),
      color: character.colorSouthEast,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );
  }
}





