import 'package:gamestream_flutter/isometric/render/render_character_health_bar.dart';
import 'package:gamestream_flutter/isometric/render/src_utils.dart';
import 'package:gamestream_flutter/library.dart';
import 'dart:math';

import 'package:lemon_math/library.dart';

class RenderCharacter {

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