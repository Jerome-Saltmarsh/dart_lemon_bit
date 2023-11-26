import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:lemon_engine/render.dart';


void renderCharacterHealthBar(Character character){
  const srcX = 2400.0;
  const srcWidth = 40.0;
  const srcHeight = 8.0;
  const marginY = 45;
  const srcWidthHalf = srcWidth * 0.5;
  final color = character.renderColor;

  render(
      dstX: character.renderX - srcWidthHalf,
      dstY: character.renderY - marginY,
      srcX: srcX,
      srcY: srcHeight,
      srcWidth: srcWidth,
      srcHeight: srcHeight,
      anchorX: 0,
      color: color,
  );

  render(
      dstX: character.renderX - srcWidthHalf,
      dstY: character.renderY - marginY,
      srcX: srcX,
      srcY: 0,
      srcWidth: srcWidth * character.health,
      srcHeight: srcHeight,
      anchorX: 0,
      color: color,
  );
}
