
import 'package:gamestream_flutter/library.dart';

class RenderNode {

  static final bufferClr = Engine.bufferClr;
  static final bufferSrc = Engine.bufferSrc;
  static final bufferDst = Engine.bufferDst;
  static final atlas = GameImages.atlas_nodes;

  static void renderNodeTorch(){
    if (!ClientState.torchesIgnited.value) {
      Engine.renderSprite(
        image: atlas,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch,
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
        color: GameRender.currentNodeColorTransparentShaded,
      );
      return;
    }
    if (renderNodeWind == WindType.Calm){
      Engine.renderSprite(
        image: atlas,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch), // TODO Optimize
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
        color: GameRender.currentNodeColorTransparentShaded,
      );
      return;
    }
    Engine.renderSprite(
      image: atlas,
      srcX: AtlasNode.X_Torch_Windy,
      srcY: AtlasNode.Y_Torch_Windy + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch), // TODO Optimize
      srcWidth: AtlasNode.Width_Torch,
      srcHeight: AtlasNode.Height_Torch,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
      anchorY: AtlasNodeAnchorY.Torch,
      color: GameRender.currentNodeColorTransparentShaded,
    );
    return;
  }

  static void renderNodeWater() =>
    Engine.renderSprite(
      image: atlas,
      srcX: AtlasNodeX.Water,
      srcY: AtlasNodeY.Water + (((GameAnimation.animationFrameWater + ((GameRender.currentNodeRow + GameRender.currentNodeColumn) * 3)) % 10) * 72.0), // TODO Optimize
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY + GameAnimation.animationFrameWaterHeight + 14,
      anchorY: 0.3334,
      color: renderNodeColor,
    );

  static void renderStandardNode({
    required double srcX,
    required double srcY,
  }){
    GameRender.onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = GameRender.currentNodeVisibility == Visibility.Opaque ? 1 : GameLighting.Transparent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = GameRender.currentNodeDstX - (GameConstants.Sprite_Width_Half);
    bufferDst[f + 3] = GameRender.currentNodeDstY - (GameConstants.Sprite_Height_Third);
    Engine.incrementBufferIndex();
  }

  static void renderStandardNodeShaded({
    required double srcX,
    required double srcY,
  }){
    GameRender.onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = GameRender.currentNodeVisibility == Visibility.Opaque ? GameRender.currentNodeColor : GameLighting.Transparent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = GameRender.currentNodeDstX - (GameConstants.Sprite_Width_Half);
    bufferDst[f + 3] = GameRender.currentNodeDstY - (GameConstants.Sprite_Height_Third);
    Engine.incrementBufferIndex();
  }

  static void renderNodeShadedOffset({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
  }){
    GameRender.onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = GameRender.currentNodeColorTransparentShaded;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = GameRender.currentNodeDstX - (GameConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = GameRender.currentNodeDstY - (GameConstants.Sprite_Height_Third) + offsetY;
    Engine.incrementBufferIndex();
  }


  static void renderStandardNodeHalfEastOld({
    required double srcX,
    required double srcY,
    int color = 1,
  }){
    GameRender.onscreenNodes++;
    Engine.renderSprite(
      image: atlas,
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

  static void renderStandardNodeHalfNorthOld({
    required double srcX,
    required double srcY,
    int color = 1,
  }){
    GameRender.onscreenNodes++;
    Engine.renderSprite(
      image: atlas,
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

  /// HALF

  static void renderNodeTopLeft({
    required double srcX,
    required double srcY,
  }){
    GameRender.onscreenNodes++;
    Engine.renderSprite(
      image: atlas,
      srcX: srcX,
      srcY: srcY,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY + 4,
      anchorY: GameConstants.Sprite_Anchor_Y,
      color: GameRender.currentNodeColorTransparent,
    );
  }
}