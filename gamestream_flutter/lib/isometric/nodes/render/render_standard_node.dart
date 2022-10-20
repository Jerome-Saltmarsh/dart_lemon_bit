
import 'package:gamestream_flutter/game_images.dart';
import 'package:gamestream_flutter/game_render.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:lemon_engine/engine.dart';

import 'render_constants.dart';

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
      image: GameImages.nodes,
      srcX: srcX,
      srcY: srcY,
      srcWidth: spriteWidth,
      srcHeight: spriteHeight,
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
    image: GameImages.nodes,
    srcX: srcX,
    srcY: srcY,
    srcWidth: spriteWidth,
    srcHeight: spriteHeight,
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
    image: GameImages.nodes,
    srcX: srcX,
    srcY: srcY,
    srcWidth: spriteWidth,
    srcHeight: spriteHeight,
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
    image: GameImages.nodes,
    srcX: srcX,
    srcY: srcY,
    srcWidth: spriteWidth,
    srcHeight: spriteHeight,
    dstX: GameRender.currentNodeDstX - 17,
    dstY: GameRender.currentNodeDstY - 17,
    anchorY: 0.3,
    color: color,
  );
}

// void renderAdvanced({
//   required double dstX,
//   required double dstY,
//   required double srcX,
//   required double srcY,
//   required double width,
//   required double height,
//   double anchorX = 0.5,
//   double anchorY = 0.5,
//   int color = 1,
// }){
//   GameRender.onscreenNodes++;
//   // _colors[0] = color;
//   // _src[0] = srcX;
//   // _dst[0] = 1;
//   // _src[1] = srcY;
//   // _dst[1] = 0;
//   // _src[2] = srcX + width;
//   // _dst[2] = dstX - width * anchorX;
//   // _src[3] = srcY + spriteHeight;
//   // _dst[3] = dstY - height * anchorY;
//   // Engine.canvas.drawRawAtlas(GameImages.nodes, _dst, _src, _colors, Engine.bufferBlendMode, null, Engine.paint);
//
//   Engine.renderSprite(
//     image: GameImages.nodes,
//     srcX: srcX,
//     srcY: srcY,
//     srcWidth: width,
//     srcHeight: height,
//     dstX: dstX,
//     dstY: dstY,
//     anchorX: anchorX,
//     anchorY: anchorY,
//     color: color,
//   );
// }