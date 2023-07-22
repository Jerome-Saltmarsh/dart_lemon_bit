import 'dart:math';

import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/extensions/render_character_template.dart';
import 'package:gamestream_flutter/library.dart';

class RendererCharacters extends IsometricRenderer {
  late IsometricCharacter character;

  RendererCharacters(super.scene);

  @override
  void renderFunction() => renderCurrentCharacter();

  void updateFunction() {
    final totalCharacters = gamestream.isometric.server.totalCharacters;
    final characters = gamestream.isometric.server.characters;

    while (index < totalCharacters){
      character = characters[index];
      order = character.sortOrder;
      if (scene.isPerceptiblePosition(character))
        break;
      index++;
    }
  }

  @override
  int getTotal() => gamestream.isometric.server.totalCharacters;

  void renderCurrentCharacter(){

    if (!character.allie && gamestream.isometric.options.renderHealthBarEnemies) {
      renderer.renderCharacterHealthBar(character);
    }

    if (character.allie && gamestream.isometric.options.renderHealthBarAllies) {
      renderer.renderCharacterHealthBar(character);
    }

    if (character.spawning) {
      if (character.characterType == CharacterType.Rat){
        gamestream.engine.renderSprite(
          image: Images.atlas_gameobjects,
          srcX: 1920,
          srcY: (character.animationFrame % 8) * 43.0,
          dstX: character.renderX,
          dstY: character.renderY,
          srcWidth: 64,
          srcHeight: 43,
          scale: 0.75,
        );
      }
      if (character.characterType == CharacterType.Slime) {
        gamestream.engine.renderSprite(
          image: Images.atlas_gameobjects,
          srcX: 3040,
          srcY: (character.animationFrame % 6) * 48.0,
          dstX: character.renderX,
          dstY: character.renderY,
          srcWidth: 48,
          srcHeight: 48,
          scale: 0.75,
        );
        return;
      }
      gamestream.engine.renderSprite(
        image: Images.atlas_characters,
        srcX: 513,
        srcY: (character.animationFrame % 8) * 73.0,
        dstX: character.renderX,
        dstY: character.renderY,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.61,
        scale: 0.75,
      );
      return; // character spawning
    }

    switch (character.characterType) {
      case CharacterType.Template:
        renderCharacterTemplate(character);
        break;
      case CharacterType.Zombie:
        renderCharacterZombie(character);
        break;
      case CharacterType.Slime:
        // renderCharacterSlime(character);
        break;
      case CharacterType.Rat:
        renderCharacterRat(character);
        break;
      case CharacterType.Triangle:
        gamestream.engine.renderSpriteRotated(
          image: Images.atlas_characters,
          srcX: 0,
          srcY: 512,
          srcWidth: 32,
          srcHeight: 32,
          dstX: character.renderX,
          dstY: character.renderY,
          rotation: character.angle,
        );
        return;
      case CharacterType.Dog:
        renderCharacterDog(character);
        break;
      default:
        throw Exception('Cannot render character type: ${character.characterType}');
    }
  }


  void renderCharacterDog(IsometricCharacter character){
    const Src_Size = 80.0;
    const Anchor_Y = 0.66;

    if (character.state == CharacterState.Idle){
      gamestream.engine.renderSprite(
        image: Images.character_dog,
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
      gamestream.engine.renderSprite(
        image: Images.character_dog,
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

    if (character.state == CharacterState.Performing) {
      const frames = const [1, 2];
      var frame = character.animationFrame;
      if (character.animationFrame >= frames.length){
        frame = frames.last;
      } else {
        frame = frames[frame];
      }
      gamestream.engine.renderSprite(
        image: Images.character_dog,
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

    if (character.state == CharacterState.Hurt) {
      gamestream.engine.renderSprite(
        image: Images.character_dog,
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
      gamestream.isometric.renderer.renderStarsV3(character);
      gamestream.engine.renderSprite(
        image: Images.character_dog,
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

  void renderCharacterZombie(IsometricCharacter character) {
    if (character.dead) return;
    if (character.spawning) return;

    var angle = 0.0;
    var dist = 0.0;
    // final nodes = gamestream.isometric.scene;

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

    gamestream.engine.renderSprite(
      image: Images.zombie_shadow,
      srcX: getZombieSrcX(character),
      srcY: character.renderDirection * 64,
      srcWidth: 64,
      srcHeight: 64,
      dstX: IsometricRender.getRenderX(shadowX, shadowY, shadowZ),
      dstY: IsometricRender.getRenderY(shadowX, shadowY, shadowZ),
      anchorY: 0.66,
      scale: 0.7,
      color: character.color,
    );

    gamestream.engine.renderSprite(
      image: Images.zombie,
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

  double getZombieSrcX(IsometricCharacter character) {
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
      case CharacterState.Performing:
        return animate(
          animation: const [7, 7, 8, 8],
          character: character,
          framesPerDirection: framesPerDirection,
        );
      case CharacterState.Stunned:
        gamestream.isometric.renderer.renderStarsV3(character);

        return single(
            frame: 1,
            direction: character.direction,
            framesPerDirection: framesPerDirection
        );
      default:
        throw Exception('Render zombie invalid state ${character.state}');
    }
  }

  void renderCharacterRat(IsometricCharacter character){
    if (character.state == CharacterState.Running){
      gamestream.engine.renderSprite(
        image: Images.atlas_gameobjects,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: loop4(animation: const [1, 2, 3, 4], character: character, framesPerDirection: 4),
        srcY: 853,
        srcWidth: 64,
        srcHeight: 64,
        anchorY: 0.66,
        scale: 1,
        color: gamestream.isometric.scene.getRenderColorPosition(character),
      );
    }

    if (character.state == CharacterState.Performing){
      gamestream.engine.renderSprite(
        image: Images.atlas_gameobjects,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: 2680,
        srcY: character.direction * 64,
        srcWidth: 64,
        srcHeight: 64,
        anchorY: 0.66,
        scale: 1,
        color: gamestream.isometric.scene.getRenderColorPosition(character),
      );
    }

    gamestream.engine.renderSprite(
      image: Images.atlas_gameobjects,
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: 2680,
      srcY: character.direction * 64,
      srcWidth: 64,
      srcHeight: 64,
      anchorY: 0.66,
      scale: 1,
      color: gamestream.isometric.scene.getRenderColorPosition(character),
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
    required IsometricCharacter character,
    required int framesPerDirection,
    double size = 64,
  }) => (character.renderDirection * framesPerDirection * size) +
        ((animation[character.animationFrame % 4] - 1) * size);

  double animate({
    required List<int> animation,
    required IsometricCharacter character,
    required int framesPerDirection,
    double size = 64.0
  }) {
    final animationFrame = min(character.animationFrame, animation.length - 1);
    final frame = animation[animationFrame] - 1;
    return (character.renderDirection * framesPerDirection * size) + (frame * size);
  }

}
