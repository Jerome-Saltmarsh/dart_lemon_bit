import 'package:gamestream_flutter/isometric/render/render_character_health_bar.dart';
import 'package:gamestream_flutter/isometric/render/render_character_rat.dart';
import 'package:gamestream_flutter/isometric/render/render_character_slime.dart';
import 'package:gamestream_flutter/isometric/render/render_character_template.dart';
import 'package:gamestream_flutter/isometric/render/src_utils.dart';
import 'package:gamestream_flutter/library.dart';
import 'dart:math';

class RenderCharacter {

  static void renderCharacter(Character character){
    if (!GameQueries.isVisibleV3(character)) return;

    if (character.spawning) {
      if (character.characterType == CharacterType.Rat){
        Engine.renderSprite(
          image: GameImages.gameobjects,
          srcX: 1920,
          srcY: (character.frame % 8) * 43.0,
          dstX: character.renderX,
          dstY: character.renderY,
          srcWidth: 64,
          srcHeight: 43,
          scale: 0.75,
        );
      }
      if (character.characterType == CharacterType.Slime) {
        Engine.renderSprite(
          image: GameImages.gameobjects,
          srcX: 3040,
          srcY: (character.frame % 6) * 48.0,
          dstX: character.renderX,
          dstY: character.renderY,
          srcWidth: 48,
          srcHeight: 48,
          scale: 0.75,
        );
        return;
      }
      Engine.renderSprite(
        image: GameImages.atlasCharacters,
        srcX: 513,
        srcY: (character.frame % 8) * 73.0,
        dstX: character.renderX,
        dstY: character.renderY,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.61,
        scale: 0.75,
      );
      return;
    }

    switch (character.characterType) {
      case CharacterType.Template:
        renderCharacterTemplate(character);
        return;
      case CharacterType.Slime:
        return renderCharacterSlime(character);
      case CharacterType.Rat:
        return renderCharacterRat(character);
      case CharacterType.Zombie:
        return RenderCharacter.renderCharacterZombie(character);
      case CharacterType.Triangle:
        Engine.renderSpriteRotated(
            image: GameImages.atlasCharacters,
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
        throw Exception("Cannot render character type: ${character.characterType}");
    }
  }

  static void renderCharacterDog(Character character){

    if (character.state == CharacterState.Idle){
      Engine.renderSprite(
        image: GameImages.character_dog,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: 0,
        srcY: 64.0 * character.direction,
        srcWidth: 64,
        srcHeight: 64,
        anchorY: 0.66,
        scale: 1,
        color: character.color,
      );
      return;
    }

    if (character.state == CharacterState.Running) {
      const frames = const [4, 5];
      final frame = frames[(character.frame % 2)];
      Engine.renderSprite(
        image: GameImages.character_dog,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: frame * 64.0,
        srcY: 64.0 * character.direction,
        srcWidth: 64,
        srcHeight: 64,
        anchorY: 0.66,
        scale: 1,
        color: character.color,
      );
      return;
    }

    if (character.state == CharacterState.Performing) {
      const frames = const [1, 2];
      var frame = character.frame;
      if (character.frame >= frames.length){
        frame = frames.last;
      } else {
        frame = frames[frame];
      }
      Engine.renderSprite(
        image: GameImages.character_dog,
        dstX: character.renderX,
        dstY: character.renderY,
        srcX: frame * 64.0,
        srcY: 64.0 * character.direction,
        srcWidth: 64,
        srcHeight: 64,
        anchorY: 0.66,
        scale: 1,
        color: character.color,
      );
      return;
    }

  }

  static void renderCharacterZombie(Character character) {
    final shade = GameState.getV3RenderShade(character);
    if (shade < Shade.Dark) renderCharacterHealthBar(character);
    if (character.deadOrDying) return;
    if (character.spawning) return;


    var angle = 0.0;
    var distance = 0.0;

    if (ClientState.torchesIgnited.value && !GameState.outOfBoundsV3(character)){
      // find the nearest torch and move the shadow behind the character
      final characterNodeIndex = GameState.getNodeIndexV3(character);
      final initialSearchIndex = characterNodeIndex - GameState.nodesTotalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
      var torchIndex = -1;

      for (var row = 0; row < 3; row++){
        for (var column = 0; column < 3; column++){
          final searchIndex = initialSearchIndex + (row * GameState.nodesTotalColumns) + column;
          if (GameNodes.nodesType[searchIndex] != NodeType.Torch) continue;
          torchIndex = searchIndex;
          break;
        }
      }

      if (torchIndex != -1) {
        final torchRow = GameState.convertNodeIndexToRow(torchIndex);
        final torchColumn = GameState.convertNodeIndexToColumn(torchIndex);
        final torchPosX = torchRow * Node_Size + Node_Size_Half;
        final torchPosY = torchColumn * Node_Size + Node_Size_Half;
        angle = getAngleBetween(character.x, character.y, torchPosX, torchPosY);
        distance = min(
          GameConfig.Character_Shadow_Distance_Max,
          Engine.calculateDistance(
              character.x,
              character.y,
              torchPosX,
              torchPosY
          ) * GameConfig.Character_Shadow_Distance_Ratio,
        );
      }
    }

    final shadowX = character.x + Engine.calculateAdjacent(angle, distance);
    final shadowY = character.y + Engine.calculateOpposite(angle, distance);
    final shadowZ = character.z;

    Engine.renderSprite(
      image: GameImages.zombie_shadow,
      srcX: getZombieSrcX(character),
      srcY: character.renderDirection * 64,
      srcWidth: 64,
      srcHeight: 64,
      dstX: GameConvert.getRenderX(shadowX, shadowY, shadowZ),
      dstY: GameConvert.getRenderY(shadowX, shadowY, shadowZ),
      anchorY: 0.66,
      scale: 0.7,
      color: character.color,
    );

    Engine.renderSprite(
      image: GameImages.zombie,
      srcX: getZombieSrcX(character),
      srcY: character.renderDirection * 64,
      srcWidth: 64,
      srcHeight: 64,
      dstX: character.renderX,
      dstY: character.renderY,
      anchorY: 0.66,
      scale: 0.7,
      color: character.color,
    );
  }

  static double getZombieSrcX(Character character) {
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
      case CharacterState.Dying:
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
      default:
        throw Exception("Render zombie invalid state ${character.state}");
    }
  }
}