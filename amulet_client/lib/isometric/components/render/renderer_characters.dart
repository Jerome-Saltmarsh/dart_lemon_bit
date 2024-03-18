import 'package:amulet_common/src.dart';
import 'package:amulet_client/isometric/classes/render_group.dart';
import 'package:amulet_client/isometric/components/isometric_images.dart';
import 'package:amulet_client/isometric/components/render/functions/map_character_state_to_animation_mode.dart';
import 'package:amulet_client/isometric/classes/character_shader.dart';
import 'package:amulet_client/isometric/classes/character.dart';
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

    if (!renderBottom) {
      if (options.renderHealthBars && !character.dead) {

        render.renderHealthBarCharacter(character);
        // if (!character.isPlayer){
        //   render.renderHealthBarCharacter(character);
        // }

        if (character.isPlayer){
          render.renderMagicBarCharacter(character);
        }

        if (!character.isPlayer) {
          render.textPosition(
              character,
              character.level,
              offsetX: -18,
              offsetY: -56,
          );
        }
      }
    }

    if (options.renderCharacterAnimationFrame){
      render.textPosition(character, character.animationFrame, offsetY: -100);
    }

    if (character.spawning) {
      return;
    }

    scene.applyColorToCharacter(character);

    if (character.isAilmentBlind) {
      engine.renderSprite(
          image: images.atlas_amulet_items,
          srcX: 400,
          srcY: 336,
          srcWidth: 16,
          srcHeight: 16,
          dstX: character.renderX,
          dstY: character.renderY - 70,
      );
    }

    switch (character.characterType) {
      case CharacterType.Human:
        renderCharacterHuman(character);
        break;
      case CharacterType.Fallen:
        renderCharacterShader(
            character: character,
            shader: images.characterShaderFallen,
            scale: 0.5,
        );
        break;
      case CharacterType.Fallen_Armoured:
        renderCharacterShader(
            character: character,
            shader: images.characterShaderFallenArmoured,
            scale: 1.0,
        );
        break;
      case CharacterType.Skeleton:
        renderCharacterShader(
            character: character,
            shader: images.characterShaderSkeleton,
            scale: 0.5,
        );
        break;
      case CharacterType.Wolf:
        renderCharacterShader(
            character: character,
            shader: images.characterShaderWolf,
            scale: 0.3,
        );
        break;
      case CharacterType.Zombie:
        renderCharacterShader(
            character: character,
            shader: images.characterShaderZombie,
            scale: 0.35,
        );
        break;
      case CharacterType.Gargoyle_01:
        renderCharacterShader(
            character: character,
            shader: images.characterShaderGargoyle,
            scale: 0.6,
            anchorY: 0.7,
        );
        break;
      // case CharacterType.Toad_Warrior:
      //   renderCharacterShader(
      //       character: character,
      //       shader: images.characterShaderToadWarrior,
      //       scale: 0.6,
      //       anchorY: 0.7,
      //   );
      //   break;
      default:
        throw Exception('Cannot render character type: ${character.characterType}');
    }
  }

  @override
  int getTotal() => scene.totalCharacters * 2;


  void renderCharacterHuman(Character character) {
    const anchorY = 0.7;

    final scale = options.characterRenderScale;
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

    // final handTypeLeft = character.handTypeLeft;
    // final handTypeRight = character.handTypeRight;
    final helmType = character.helmType;
    final gender = character.gender;
    final armorType = character.armorType == 0 ? ArmorType.Tunic : character.armorType;
    final weaponType = character.weaponType;
    final headType = character.headType;
    final hairType = character.hairType;
    final shoeType = character.shoeType;

    // final atlasHandsLeftSouth = spritesSouth.handLeft[handTypeLeft] ?? (throw Exception());
    // final atlasHandsLeftWest = spritesWest.handLeft[handTypeLeft] ?? (throw Exception());
    // final atlasHandsLeftDiffuse = spritesDiffuse.handLeft[handTypeLeft] ?? (throw Exception());
    // final atlasHandsRightSouth = spritesSouth.handRight[handTypeRight] ?? (throw Exception());
    // final atlasHandsRightWest = spritesWest.handRight[handTypeRight] ?? (throw Exception());
    // final atlasHandsRightDiffuse = spritesDiffuse.handRight[handTypeRight] ?? (throw Exception());
    final atlasHelmSouth = spritesSouth.helm[helmType] ?? (throw Exception());
    final atlasHelmWest = spritesWest.helm[helmType] ?? (throw Exception());
    final atlasHelmDiffuse = spritesDiffuse.helm[helmType] ?? (throw Exception());
    final armorSpriteSouth = spritesSouth.armor;
    final armorSpriteWest = spritesWest.armor;
    final armorSpriteDiffuse = spritesDiffuse.armor;
    final atlasArmorSouth = armorSpriteSouth[armorType] ?? (throw Exception());
    final atlasArmorWest = armorSpriteWest[armorType] ?? (throw Exception());
    final atlasArmorDiffuse = armorSpriteDiffuse[armorType] ?? (throw Exception());
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
    final atlasShoesDiffuse = spritesDiffuse.shoes[shoeType] ?? (throw Exception());
    final atlasShoesSouth = spritesSouth.shoes[shoeType] ?? (throw Exception());
    final atlasShoesWest = spritesWest.shoes[shoeType] ?? (throw Exception());

    final spriteWeaponSouth = atlasWeaponSouth.fromCharacterState(characterState);
    final spriteWeaponWest = atlasWeaponWest.fromCharacterState(characterState);
    final spriteWeaponDiffuse = atlasWeaponDiffuse.fromCharacterState(characterState);
    final spriteHelmSouth = atlasHelmSouth.fromCharacterState(characterState);
    final spriteHelmWest = atlasHelmWest.fromCharacterState(characterState);
    final spriteHelmDiffuse = atlasHelmDiffuse.fromCharacterState(characterState);
    final spriteArmorSouth = atlasArmorSouth.fromCharacterState(characterState);
    final spriteArmorWest = atlasArmorWest.fromCharacterState(characterState);
    final spriteArmorDiffuse = atlasArmorDiffuse.fromCharacterState(characterState);
    final spriteHeadSouth = atlasHeadSouth.fromCharacterState(characterState);
    final spriteHeadWest = atlasHeadWest.fromCharacterState(characterState);
    final spriteHeadDiffuse = atlasHeadDiffuse.fromCharacterState(characterState);
    final spriteTorsoSouth = atlasTorsoSouth.fromCharacterState(characterState);
    final spriteTorsoWest = atlasTorsoWest.fromCharacterState(characterState);
    final spriteTorsoDiffuse = atlasTorsoDiffuse.fromCharacterState(characterState);
    // final spriteHandsLeftSouth = atlasHandsLeftSouth.fromCharacterState(characterState);
    // final spriteHandsLeftWest = atlasHandsLeftWest.fromCharacterState(characterState);
    // final spriteHandsLeftDiffuse = atlasHandsLeftDiffuse.fromCharacterState(characterState);
    // final spriteHandsRightSouth = atlasHandsRightSouth.fromCharacterState(characterState);
    // final spriteHandsRightWest = atlasHandsRightWest.fromCharacterState(characterState);
    // final spriteHandsRightDiffuse = atlasHandsRightDiffuse.fromCharacterState(characterState);
    final spriteShadow = spritesShadow.fromCharacterState(characterState);
    final spriteHairSouth = atlasHairSouth.fromCharacterState(characterState);
    final spriteHairWest = atlasHairWest.fromCharacterState(characterState);
    final spriteHairDiffuse = atlasHairDiffuse.fromCharacterState(characterState);
    final spriteShoesDiffuse = atlasShoesDiffuse.fromCharacterState(characterState);
    final spriteShoesSouth = atlasShoesSouth.fromCharacterState(characterState);
    final spriteShoesWest = atlasShoesWest.fromCharacterState(characterState);

    final palette = colors.palette;
    final colorSkin = palette[character.complexion].value;
    final colorHair = palette[character.hairColor].value;

    final render = this.render;
    final renderSprite = render.sprite;
    final modulate = render.modulate;

    final weaponInFront = const [4, 3, 2, 1].contains(character.renderDirection);
    final animationMode = mapCharacterStateToAnimationMode(characterState);

    if (renderBottom) {

      renderSprite(
        sprite: spriteShadow,
        frame: completingAction
            ? spriteShadow.getFramePercentage(row, actionComplete, animationMode)
            : spriteShadow.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      modulate(
        sprite: spriteTorsoDiffuse,
        frame: completingAction
            ? spriteTorsoDiffuse.getFramePercentage(row, actionComplete, animationMode)
            : spriteTorsoDiffuse.getFrame(column: animationFrame, row: row, mode: animationMode),
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
            ? spriteTorsoSouth.getFramePercentage(row, actionComplete, animationMode)
            : spriteTorsoSouth.getFrame(column: animationFrame, row: row, mode: animationMode),
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
            ? spriteTorsoWest.getFramePercentage(row, actionComplete, animationMode)
            : spriteTorsoWest.getFrame(column: animationFrame, row: row, mode: animationMode),
        color1: colorSkin,
        color2: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteShoesDiffuse,
        frame: completingAction
            ? spriteShoesDiffuse.getFramePercentage(row, actionComplete, animationMode)
            : spriteShoesDiffuse.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorDiffuse,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteShoesSouth,
        frame: completingAction
            ? spriteShoesSouth.getFramePercentage(row, actionComplete, animationMode)
            : spriteShoesSouth.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteShoesWest,
        frame: completingAction
            ? spriteShoesWest.getFramePercentage(row, actionComplete, animationMode)
            : spriteShoesWest.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
      return;
    }

    if (!weaponInFront){
      renderSprite(
        sprite: spriteWeaponDiffuse,
        frame: completingAction
            ? spriteWeaponDiffuse.getFramePercentage(row, actionComplete, animationMode)
            : spriteWeaponDiffuse.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorDiffuse,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteWeaponSouth,
        frame: completingAction
            ? spriteWeaponSouth.getFramePercentage(row, actionComplete, animationMode)
            : spriteWeaponSouth.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteWeaponWest,
        frame: completingAction
            ? spriteWeaponWest.getFramePercentage(row, actionComplete, animationMode)
            : spriteWeaponWest.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }

    renderSprite(
      sprite: spriteArmorDiffuse,
      frame: completingAction
          ? spriteArmorDiffuse.getFramePercentage(row, actionComplete, animationMode)
          : spriteArmorDiffuse.getFrame(row: row, column: animationFrame, mode: animationMode),
      color: colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteArmorSouth,
      frame: completingAction
          ? spriteArmorSouth.getFramePercentage(row, actionComplete, animationMode)
          : spriteArmorSouth.getFrame(row: row, column: animationFrame, mode: animationMode),
      color: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteArmorWest,
      frame: completingAction
          ? spriteArmorWest.getFramePercentage(row, actionComplete, animationMode)
          : spriteArmorWest.getFrame(row: row, column: animationFrame, mode: animationMode),
      color: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    if (weaponInFront){
      renderSprite(
        sprite: spriteWeaponDiffuse,
        frame: completingAction
            ? spriteWeaponDiffuse.getFramePercentage(row, actionComplete, animationMode)
            : spriteWeaponDiffuse.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorDiffuse,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteWeaponSouth,
        frame: completingAction
            ? spriteWeaponSouth.getFramePercentage(row, actionComplete, animationMode)
            : spriteWeaponSouth.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      renderSprite(
        sprite: spriteWeaponWest,
        frame: completingAction
            ? spriteWeaponWest.getFramePercentage(row, actionComplete, animationMode)
            : spriteWeaponWest.getFrame(row: row, column: animationFrame, mode: animationMode),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }


    // renderSprite(
    //   sprite: spriteHandsLeftDiffuse,
    //   frame: completingAction
    //       ? spriteHandsLeftDiffuse.getFramePercentage(row, actionComplete, animationMode)
    //       : spriteHandsLeftDiffuse.getFrame(row: row, column: animationFrame, mode: animationMode),
    //   color: colorDiffuse,
    //   scale: scale,
    //   dstX: dstX,
    //   dstY: dstY,
    //   anchorY: anchorY,
    // );

    // renderSprite(
    //   sprite: spriteHandsLeftWest,
    //   frame: completingAction
    //       ? spriteHandsLeftWest.getFramePercentage(row, actionComplete, animationMode)
    //       : spriteHandsLeftWest.getFrame(row: row, column: animationFrame, mode: animationMode),
    //   color: colorWest,
    //   scale: scale,
    //   dstX: dstX,
    //   dstY: dstY,
    //   anchorY: anchorY,
    // );
    //
    // renderSprite(
    //   sprite: spriteHandsLeftSouth,
    //   frame: completingAction
    //       ? spriteHandsLeftSouth.getFramePercentage(row, actionComplete, animationMode)
    //       : spriteHandsLeftSouth.getFrame(row: row, column: animationFrame, mode: animationMode),
    //   color: colorSouth,
    //   scale: scale,
    //   dstX: dstX,
    //   dstY: dstY,
    //   anchorY: anchorY,
    // );
    //
    // renderSprite(
    //   sprite: spriteHandsRightDiffuse,
    //   frame: completingAction
    //       ? spriteHandsRightDiffuse.getFramePercentage(row, actionComplete, animationMode)
    //       : spriteHandsRightDiffuse.getFrame(row: row, column: animationFrame, mode: animationMode),
    //   color: colorDiffuse,
    //   scale: scale,
    //   dstX: dstX,
    //   dstY: dstY,
    //   anchorY: anchorY,
    // );
    //
    // renderSprite(
    //   sprite: spriteHandsRightWest,
    //   frame: completingAction
    //       ? spriteHandsRightWest.getFramePercentage(row, actionComplete, animationMode)
    //       : spriteHandsRightWest.getFrame(row: row, column: animationFrame, mode: animationMode),
    //   color: colorWest,
    //   scale: scale,
    //   dstX: dstX,
    //   dstY: dstY,
    //   anchorY: anchorY,
    // );
    //
    // renderSprite(
    //   sprite: spriteHandsRightSouth,
    //   frame: completingAction
    //       ? spriteHandsRightSouth.getFramePercentage(row, actionComplete, animationMode)
    //       : spriteHandsRightSouth.getFrame(row: row, column: animationFrame, mode: animationMode),
    //   color: colorSouth,
    //   scale: scale,
    //   dstX: dstX,
    //   dstY: dstY,
    //   anchorY: anchorY,
    // );

    modulate(
      sprite: spriteHeadDiffuse,
      frame: completingAction
          ? spriteHeadDiffuse.getFramePercentage(row, actionComplete, animationMode)
          : spriteHeadDiffuse.getFrame(row: row, column: animationFrame, mode: animationMode),
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
          ? spriteHeadSouth.getFramePercentage(row, actionComplete, animationMode)
          : spriteHeadSouth.getFrame(row: row, column: animationFrame, mode: animationMode),
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
          ? spriteHeadWest.getFramePercentage(row, actionComplete, animationMode)
          : spriteHeadWest.getFrame(row: row, column: animationFrame, mode: animationMode),
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
          ? spriteHairDiffuse.getFramePercentage(row, actionComplete, animationMode)
          : spriteHairDiffuse.getFrame(row: row, column: animationFrame, mode: animationMode),
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
          ? spriteHairSouth.getFramePercentage(row, actionComplete, animationMode)
          : spriteHairSouth.getFrame(row: row, column: animationFrame, mode: animationMode),
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
          ? spriteHairWest.getFramePercentage(row, actionComplete, animationMode)
          : spriteHairWest.getFrame(row: row, column: animationFrame, mode: animationMode),
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
          ? spriteHelmDiffuse.getFramePercentage(row, actionComplete, animationMode)
          : spriteHelmDiffuse.getFrame(row: row, column: animationFrame, mode: animationMode),
      color: colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHelmSouth,
      frame: completingAction
          ? spriteHelmSouth.getFramePercentage(row, actionComplete, animationMode)
          : spriteHelmSouth.getFrame(row: row, column: animationFrame, mode: animationMode),
      color: colorSouth,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    renderSprite(
      sprite: spriteHelmWest,
      frame: completingAction
          ? spriteHelmWest.getFramePercentage(row, actionComplete, animationMode)
          : spriteHelmWest.getFrame(row: row, column: animationFrame, mode: animationMode),
      color: colorWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );
  }

  void renderCharacterShader({
    required Character character,
    required CharacterShader shader,
    double scale = 1.0,
    double anchorY = 0.6,
  }) {

    if (
      (renderBottom && !character.dead) ||
      (!renderBottom && character.dead))
      return;

    final row = character.renderDirection;
    final column = character.animationFrame;
    final characterState = character.state;
    final spriteShadow = shader.shadow.fromCharacterState(characterState);
    final spriteFlat = shader.flat.fromCharacterState(characterState);
    final spriteWest = shader.west.fromCharacterState(characterState);
    final spriteSouth = shader.south.fromCharacterState(characterState);

    final dstX = character.renderX;
    final dstY = character.renderY;
    final render = this.render;

    final colorDiffuse = character.colorDiffuse;
    final animationMode = mapCharacterStateToAnimationMode(characterState);

    render.sprite(
      sprite: spriteShadow,
      frame: spriteShadow.getFrame(row: row, column: column, mode: animationMode),
      color: colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteFlat,
      frame: spriteFlat.getFrame(row: row, column: column, mode: animationMode),
      color: colorDiffuse,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteWest,
      frame: spriteWest.getFrame(row: row, column: column, mode: animationMode),
      color: character.colorNorthWest,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: spriteSouth,
      frame: spriteSouth.getFrame(row: row, column: column, mode: animationMode),
      color: character.colorSouthEast,
      scale: scale,
      dstX: dstX,
      dstY: dstY,
      anchorY: anchorY,
    );
  }
}





