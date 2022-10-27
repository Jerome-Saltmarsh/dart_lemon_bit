
import 'package:gamestream_flutter/library.dart';

// final _src = Float32List(4);
// final _dst = () {
//   final bytes = Float32List(4);
//   bytes[0] = 1;
//   bytes[1] = 0;
//   return bytes;
// }();
// final _colors = Int32List(1);

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
    anchorY: 0.3,
    color: GameState.colorShades[GameState.nodesShade[GameRender.currentNodeIndex]],
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
    anchorY: 0.3,
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
    anchorY: 0.3,
    color: color,
  );
}
