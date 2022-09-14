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
      srcY: character.allie ? 24 : 8,
      srcWidth: srcWidth,
      srcHeight: srcHeight,
      anchorX: 0,
      color: color,
  );

  render(
      dstX: character.renderX - srcWidthHalf,
      dstY: character.renderY - marginY,
      srcX: srcX,
      srcY: character.allie ? 16 : 0,
      srcWidth: srcWidth * character.health,
      srcHeight: srcHeight,
      anchorX: 0,
      color: color,
  );
}



void renderCharacterBarWeaponRounds({
  required double x,
  required double y,
  required double percentage,
}){
  const srcX = 2400.0;
  const srcWidth = 40.0;
  const srcHeight = 8.0;
  const marginY = 45;
  const srcWidthHalf = srcWidth * 0.5;

  render(
    dstX: x - srcWidthHalf,
    dstY: y - marginY,
    srcX: srcX,
    srcY: 40,
    srcWidth: srcWidth,
    srcHeight: srcHeight,
    anchorX: 0,
  );

  render(
    dstX: x - srcWidthHalf,
    dstY: y - marginY,
    srcX: srcX,
    srcY: 32,
    srcWidth: srcWidth * percentage,
    srcHeight: srcHeight,
    anchorX: 0,
    // color: color,
  );
}
