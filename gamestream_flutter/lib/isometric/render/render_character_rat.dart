
import 'package:gamestream_flutter/isometric/render/render_projectiles.dart';
import 'package:gamestream_flutter/isometric/render/src_utils.dart';

import '../../library.dart';

void renderCharacterRat(Character character){
  renderPixelRed(character.renderX, character.renderY);

  if (character.state == CharacterState.Running){
    Engine.renderSprite(
      image: GameImages.gameobjects,
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: loop4(animation: const [1, 2, 3, 4], character: character, framesPerDirection: 4),
      srcY: 853,
      srcWidth: 64,
      srcHeight: 64,
      anchorY: 0.66,
      scale: 1,
      color: GameState.getV3NodeBelowShade(character),
    );
  }

  if (character.state == CharacterState.Performing){
    Engine.renderSprite(
      image: GameImages.gameobjects,
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: 2680,
      srcY: character.direction * 64,
      srcWidth: 64,
      srcHeight: 64,
      anchorY: 0.66,
      scale: 1,
      color: GameState.getV3NodeBelowShade(character),
    );
  }

  Engine.renderSprite(
    image: GameImages.gameobjects,
    dstX: character.renderX,
    dstY: character.renderY,
    srcX: 2680,
    srcY: character.direction * 64,
    srcWidth: 64,
    srcHeight: 64,
    anchorY: 0.66,
    scale: 1,
    color: GameState.getV3NodeBelowShade(character),
  );
}