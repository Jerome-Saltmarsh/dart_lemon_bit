import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/packages/common.dart';
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

  /// TODO OPTIMIZE
  void renderCharacterKid(Character character) {
    const anchorY = 0.7;
    final scene = this.scene;
    final characterIndex = scene.getIndexPosition(character);
    final scale = options.characterRenderScale;
    final direction = IsometricDirection.toInputDirection(character.direction);
    final color = character.color;
    final colorN = scene.colorNorth(characterIndex);
    final colorE = scene.colorEast(characterIndex);
    final colorS = scene.colorSouth(characterIndex);
    final colorW = scene.colorWest(characterIndex);
    // final colorNorth = merge32BitColors(color, colorN);
    // final colorEast = merge32BitColors(color, colorE);
    final colorNorth = colorN;
    final colorEast = colorE;
    final colorSouth = merge32BitColors(colorS, colorE);
    final colorWest = merge32BitColors(colorN, colorW);
    final dstX = character.renderX;
    final dstY = character.renderY;
    final characterState = character.state;
    final row = character.renderDirection;
    final animationFrame = character.animationFrame;
    final actionComplete = character.actionComplete;
    final completingAction = actionComplete > 0;

    final images = this.images;
    final spritesNorth = images.kidCharacterSpritesIsometricNorth;
    final spritesEast = images.kidCharacterSpritesIsometricEast;
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
    final atlasHeadNorth = spritesNorth.head[character.headType] ?? (throw Exception());
    final atlasHeadEast = spritesEast.head[character.headType] ?? (throw Exception());
    final atlasHeadSouth = spritesSouth.head[character.headType] ?? (throw Exception());
    final atlasHeadWest = spritesWest.head[character.headType] ?? (throw Exception());
    final atlasTorsoTopSouth = spritesSouth.torsoTop[character.gender] ?? (throw Exception());
    final atlasTorsoTopWest = spritesWest.torsoTop[character.gender] ?? (throw Exception());
    final atlasTorsoBottomSouth = spritesSouth.torsoBottom[character.gender] ?? (throw Exception());
    final atlasTorsoBottomWest = spritesWest.torsoBottom[character.gender] ?? (throw Exception());
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
    final spriteHeadNorth = atlasHeadNorth.fromCharacterState(characterState);
    final spriteHeadEast = atlasHeadEast.fromCharacterState(characterState);
    final spriteHeadSouth = atlasHeadSouth.fromCharacterState(characterState);
    final spriteHeadWest = atlasHeadWest.fromCharacterState(characterState);
    final spriteArmLeftSouth = atlasArmLeftSouth.fromCharacterState(characterState);
    final spriteArmLeftWest = atlasArmLeftWest.fromCharacterState(characterState);
    final spriteArmRightSouth = atlasArmRightSouth.fromCharacterState(characterState);
    final spriteArmRightWest = atlasArmRightWest.fromCharacterState(characterState);
    final spriteTorsoTopSouth = atlasTorsoTopSouth.fromCharacterState(characterState);
    final spriteTorsoTopWest = atlasTorsoTopWest.fromCharacterState(characterState);
    final spriteTorsoBottomSouth = atlasTorsoBottomSouth.fromCharacterState(characterState);
    final spriteTorsoBottomWest = atlasTorsoBottomWest.fromCharacterState(characterState);
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
        sprite: spriteTorsoBottomSouth,
        frame: completingAction
            ? spriteTorsoBottomSouth.getFramePercentage(row, actionComplete)
            : spriteTorsoBottomSouth.getFrame(column: animationFrame, row: row),
        color1: colorSkin,
        color2: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      modulate(
        sprite: spriteTorsoBottomWest,
        frame: completingAction
            ? spriteTorsoBottomWest.getFramePercentage(row, actionComplete)
            : spriteTorsoBottomWest.getFrame(column: animationFrame, row: row),
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
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteShoesBehindWest,
        frame: completingAction
            ? spriteShoesBehindWest.getFramePercentage(row, actionComplete)
            : spriteShoesBehindWest.getFrame(row: row, column: animationFrame),
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

      modulate(
        sprite: spriteTorsoTopSouth,
        frame: completingAction
            ? spriteTorsoTopSouth.getFramePercentage(row, actionComplete)
            : spriteTorsoTopSouth.getFrame(column: animationFrame, row: row),
        color1: colorSkin,
        color2: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      modulate(
        sprite: spriteTorsoTopWest,
        frame: completingAction
            ? spriteTorsoTopWest.getFramePercentage(row, actionComplete)
            : spriteTorsoTopWest.getFrame(column: animationFrame, row: row),
        color1: colorSkin,
        color2: colorWest,
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

      modulate(
        sprite: spriteTorsoTopSouth,
        frame: completingAction
            ? spriteTorsoTopSouth.getFramePercentage(row, actionComplete)
            : spriteTorsoTopSouth.getFrame(column: animationFrame, row: row),
        color1: colorSkin,
        color2: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      modulate(
        sprite: spriteTorsoTopWest,
        frame: completingAction
            ? spriteTorsoTopWest.getFramePercentage(row, actionComplete)
            : spriteTorsoTopWest.getFrame(column: animationFrame, row: row),
        color1: colorSkin,
        color2: colorWest,
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

    if (options.renderNorth){
      modulate(
        sprite: spriteHeadNorth,
        frame: completingAction
            ? spriteHeadNorth.getFramePercentage(row, actionComplete)
            : spriteHeadNorth.getFrame(row: row, column: animationFrame),
        color1: colorSkin,
        color2: colorNorth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }

    if (options.renderEast){
      modulate(
        sprite: spriteHeadEast,
        frame: completingAction
            ? spriteHeadEast.getFramePercentage(row, actionComplete)
            : spriteHeadEast.getFrame(row: row, column: animationFrame),
        color1: colorSkin,
        color2: colorEast,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

    }

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
    final spriteWest = images.spriteGroupFallenWest.fromCharacterState(character.state);
    final spriteSouth = images.spriteGroupFallenSouth.fromCharacterState(character.state);
    final spriteShadow = images.spriteGroupFallenShadow.fromCharacterState(character.state);
    final characterIndex = scene.getIndexPosition(character);
    final color = character.color;
    final colorN = scene.colorNorth(characterIndex);
    final colorE = scene.colorEast(characterIndex);
    final colorS = scene.colorSouth(characterIndex);
    final colorW = scene.colorWest(characterIndex);
    final colorWest = merge32BitsColors3(colorN, colorW, color);
    final colorSouth = merge32BitsColors3(colorS, colorE, color);

    render.sprite(
      sprite: spriteShadow,
      frame: spriteShadow.getFrame(row: row, column: column),
      color: character.color,
      scale: scale,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteWest,
      frame: spriteWest.getFrame(row: row, column: column),
      color: colorWest,
      scale: scale,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteSouth,
      frame: spriteSouth.getFrame(row: row, column: column),
      color: colorSouth,
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
    final spriteShadow = images.spriteGroupSkeletonShadow.fromCharacterState(character.state);
    final spriteWest = images.spriteGroupSkeletonWest.fromCharacterState(character.state);
    final spriteSouth = images.spriteGroupSkeletonSouth.fromCharacterState(character.state);

    final characterIndex = scene.getIndexPosition(character);
    final color = character.color;
    final colorN = scene.colorNorth(characterIndex);
    final colorE = scene.colorEast(characterIndex);
    final colorS = scene.colorSouth(characterIndex);
    final colorW = scene.colorWest(characterIndex);
    final colorWest = merge32BitsColors3(colorN, colorW, color);
    final colorSouth = merge32BitsColors3(colorS, colorE, color);

    render.sprite(
      sprite: spriteShadow,
      frame: spriteShadow.getFrame(row: row, column: column),
      color: color,
      scale: scale,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteWest,
      frame: spriteWest.getFrame(row: row, column: column),
      color: colorWest,
      scale: scale,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteSouth,
      frame: spriteSouth.getFrame(row: row, column: column),
      color: colorSouth,
      scale: scale,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: anchorY,
    );
  }
}


int mergeColors(int a, int b) {
  // Extract the alpha, red, green, and blue components from both colors.
  int alphaA = (a >> 24) & 0xFF;
  int redA = (a >> 16) & 0xFF;
  int greenA = (a >> 8) & 0xFF;
  int blueA = a & 0xFF;

  int alphaB = (b >> 24) & 0xFF;
  int redB = (b >> 16) & 0xFF;
  int greenB = (b >> 8) & 0xFF;
  int blueB = b & 0xFF;

  // Calculate the merged color components.
  int mergedAlpha = (alphaA + alphaB) ~/ 2; // Average the alpha values.
  int mergedRed = (redA + redB) ~/ 2; // Average the red values.
  int mergedGreen = (greenA + greenB) ~/ 2; // Average the green values.
  int mergedBlue = (blueA + blueB) ~/ 2; // Average the blue values.

  // Combine the components to create the merged 32-bit color.
  int mergedColor = (mergedAlpha << 24) | (mergedRed << 16) | (mergedGreen << 8) | mergedBlue;

  return mergedColor;
}


int merge32BitColors(int a, int b) {

  // Extract the color components from a and b.
  int alphaA = (a >> 24) & 0xFF;
  int redA = (a >> 16) & 0xFF;
  int greenA = (a >> 8) & 0xFF;
  int blueA = a & 0xFF;

  int alphaB = (b >> 24) & 0xFF;
  int redB = (b >> 16) & 0xFF;
  int greenB = (b >> 8) & 0xFF;
  int blueB = b & 0xFF;

  // Merge the color components using your desired logic.
  int mergedAlpha = (alphaA + alphaB) ~/ 2;
  int mergedRed = (redA + redB) ~/ 2;
  int mergedGreen = (greenA + greenB) ~/ 2;
  int mergedBlue = (blueA + blueB) ~/ 2;

  // Combine the merged color components to create the result color.
  int resultColor = (mergedAlpha << 24) | (mergedRed << 16) | (mergedGreen << 8) | mergedBlue;

  return resultColor;
}


int merge32BitsColors3(int a, int b, int c) {
  // Extract the alpha, red, green, and blue components of each color.
  int alphaA = (a >> 24) & 0xFF;
  int redA = (a >> 16) & 0xFF;
  int greenA = (a >> 8) & 0xFF;
  int blueA = a & 0xFF;

  int alphaB = (b >> 24) & 0xFF;
  int redB = (b >> 16) & 0xFF;
  int greenB = (b >> 8) & 0xFF;
  int blueB = b & 0xFF;

  int alphaC = (c >> 24) & 0xFF;
  int redC = (c >> 16) & 0xFF;
  int greenC = (c >> 8) & 0xFF;
  int blueC = c & 0xFF;

  // Merge the components into a single color.
  int mergedColor = 0;

  mergedColor |= ((alphaA + alphaB + alphaC) ~/ 3) << 24;
  mergedColor |= ((redA + redB + redC) ~/ 3) << 16;
  mergedColor |= ((greenA + greenB + greenC) ~/ 3) << 8;
  mergedColor |= ((blueA + blueB + blueC) ~/ 3);

  return mergedColor;
}