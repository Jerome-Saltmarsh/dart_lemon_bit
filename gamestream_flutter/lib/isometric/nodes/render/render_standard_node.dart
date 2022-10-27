
import 'package:gamestream_flutter/library.dart';

void renderStandardNode({
  required double srcX,
  required double srcY,
}){
  GameRender.onscreenNodes++;
  Engine.renderSprite(
      image: GameImages.atlasNodes,
      srcX: srcX,
      srcY: srcY,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
      anchorY: 0.3,
  );
}

void renderStandardNodeShaded({
  required double srcX,
  required double srcY,
}){
  Engine.renderSprite(
    image: GameImages.atlasNodes,
    srcX: srcX,
    srcY: srcY,
    srcWidth: GameConstants.Sprite_Width,
    srcHeight: GameConstants.Sprite_Height,
    dstX: GameRender.currentNodeDstX,
    dstY: GameRender.currentNodeDstY,
    anchorY: GameConstants.Sprite_Anchor_Y,
    color: GameRender.currentNodeColor,
  );
}

void renderStandardNodeHalfEast({
  required double srcX,
  required double srcY,
  int color = 1,
}){
  GameRender.onscreenNodes++;
  Engine.renderSprite(
    image: GameImages.atlasNodes,
    srcX: srcX,
    srcY: srcY,
    srcWidth: GameConstants.Sprite_Width,
    srcHeight: GameConstants.Sprite_Height,
    dstX: GameRender.currentNodeDstX + 17,
    dstY: GameRender.currentNodeDstY - 17,
    anchorY: GameConstants.Sprite_Anchor_Y,
    color: color,
  );
}

void renderStandardNodeHalfNorth({
  required double srcX,
  required double srcY,
  int color = 1,
}){
  GameRender.onscreenNodes++;
  Engine.renderSprite(
    image: GameImages.atlasNodes,
    srcX: srcX,
    srcY: srcY,
    srcWidth: GameConstants.Sprite_Width,
    srcHeight: GameConstants.Sprite_Height,
    dstX: GameRender.currentNodeDstX - 17,
    dstY: GameRender.currentNodeDstY - 17,
    anchorY: GameConstants.Sprite_Anchor_Y,
    color: color,
  );
}
