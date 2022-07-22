
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/render/render_projectiles.dart';
import 'package:lemon_engine/render.dart';

void renderCharacterRat(Character character){
  renderPixelRed(character.renderX, character.renderY);

  if (character.state == CharacterState.Idle){
    render(
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: 2680,
      srcY: character.direction * 64,
      srcWidth: 64,
      srcHeight: 64,
      anchorY: 0.66,
      scale: 0.7,
      color: character.renderColor,
    );
  }

  if (character.state == CharacterState.Running){
    render(
      dstX: character.renderX,
      dstY: character.renderY,
      srcX: (character.direction * (4 * 64)) + character.frame * 64,
      srcY: 853,
      srcWidth: 64,
      srcHeight: 64,
      anchorY: 0.66,
      scale: 0.7,
      color: character.renderColor,
    );
  }
}