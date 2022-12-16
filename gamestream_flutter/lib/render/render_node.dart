
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
        srcY: AtlasNodeY.Torch + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch),
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
      srcY: AtlasNode.Y_Torch_Windy + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch),
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
      srcY: AtlasNodeY.Water + (((GameAnimation.animationFrameWater + ((GameRender.currentNodeRow + GameRender.currentNodeColumn) * 3)) % 10) * 72.0),
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY + GameAnimation.animationFrameWaterHeight + 14,
      anchorY: 0.3334,
      color: renderNodeColor,
    );

  static void renderNodeTypeBrick() {
    switch (GameRender.currentNodeOrientation) {
      case NodeOrientation.Solid:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Solid,
          srcY: GameConstants.Sprite_Height_Padded * GameRender.currentNodeShade,
        );
      case NodeOrientation.Slope_North:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Slope_Symmetric_North,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Slope_East:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Slope_Symmetric_East,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Slope_South:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Slope_Symmetric_South,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Slope_West:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Slope_Symmetric_West,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Half_North:
        return renderStandardNodeHalfNorthOld(
          srcX: AtlasNodeX.Brick_Half_South,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Half_East:
        return renderStandardNodeHalfEastOld(
          srcX: AtlasNodeX.Brick_Half_West,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Half_South:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Half_South,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Half_West:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Half_West,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Corner_Top:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Corner_Top,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Corner_Right:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Corner_Right,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Corner_Bottom:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Corner_Bottom,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Corner_Left:
        return renderStandardNode(
          srcX: AtlasNodeX.Brick_Corner_Left,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      default:
        throw Exception("renderNodeTypeBrick(orientation: ${NodeOrientation.getName(GameNodes.nodesOrientation[GameRender.currentNodeIndex])}");
    }
  }

  static void renderNodeBauHaus() {
    switch (renderNodeOrientation) {
      case NodeOrientation.Solid:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Solid,
          srcY: AtlasNodeY.Bau_Haus_Solid,
        );
        break;
      case NodeOrientation.Half_North:
        renderStandardNodeHalfNorthOld(
          srcX: AtlasNodeX.Bau_Haus_Half,
          srcY: AtlasNodeY.Bau_Haus_Half_South,
          color: renderNodeColor,
        );
        break;
      case NodeOrientation.Half_East:
        renderStandardNodeHalfEastOld(
          srcX: AtlasNodeX.Bau_Haus_Half,
          srcY: AtlasNodeY.Bau_Haus_Half_West,
          color: renderNodeColor,
        );
        break;
      case NodeOrientation.Half_South:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Half,
          srcY: AtlasNodeY.Bau_Haus_Half_South,
        );
        break;
      case NodeOrientation.Half_West:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Half,
          srcY: AtlasNodeY.Bau_Haus_Half_West,
        );
        break;
      case NodeOrientation.Corner_Top:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Corner,
          srcY: AtlasNodeY.Bau_Haus_Corner_Top,
        );
        break;
      case NodeOrientation.Corner_Right:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Corner,
          srcY: AtlasNodeY.Bau_Haus_Corner_Right,
        );
        break;
      case NodeOrientation.Corner_Bottom:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Corner,
          srcY: AtlasNodeY.Bau_Haus_Corner_Bottom,
        );
        break;
      case NodeOrientation.Corner_Left:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Corner,
          srcY: AtlasNodeY.Bau_Haus_Corner_Left,
        );
        break;
      case NodeOrientation.Slope_North:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Slope,
          srcY: AtlasNodeY.Bau_Haus_Slope_Symmetric_North,
        );
        break;
      case NodeOrientation.Slope_East:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Slope,
          srcY: AtlasNodeY.Bau_Haus_Slope_Symmetric_East,
        );
        break;
      case NodeOrientation.Slope_South:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Slope,
          srcY: AtlasNodeY.Bau_Haus_Slope_Symmetric_South,
        );
        break;
      case NodeOrientation.Slope_West:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Slope,
          srcY: AtlasNodeY.Bau_Haus_Slope_Symmetric_West,
        );
        break;
      case NodeOrientation.Slope_Inner_North_East:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Slope,
          srcY: AtlasNodeY.Bau_Haus_Slope_Inner_North_East,
        );
        break;
      case NodeOrientation.Slope_Inner_South_East:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Slope,
          srcY: AtlasNodeY.Bau_Haus_Slope_Inner_South_East,
        );
        break;
      case NodeOrientation.Slope_Inner_South_West:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Slope,
          srcY: AtlasNodeY.Bau_Haus_Slope_Inner_South_West,
        );
        break;
      case NodeOrientation.Slope_Inner_North_West:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Bau_Haus_Slope,
          srcY: AtlasNodeY.Bau_Haus_Slope_Inner_North_West,
        );
        break;
    }
  }

  static void renderStandardNode({
    required double srcX,
    required double srcY,
  }){
    GameRender.onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = GameRender.currentNodeVisibility == Visibility.Opaque ? 1 : GameConstants.Transparent;
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
    bufferClr[Engine.bufferIndex] = GameRender.currentNodeVisibility == Visibility.Opaque ? GameRender.currentNodeColor : GameConstants.Transparent;
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

  static void renderStandardNodeHalfEast({
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
      dstX: GameRender.currentNodeDstX + 8,
      dstY: GameRender.currentNodeDstY - 8 + Half_Height_Adj,
      anchorY: GameConstants.Sprite_Anchor_Y,
      color: color,
    );
  }

  static void renderStandardNodeHalfWest({
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
      dstX: GameRender.currentNodeDstX - 8,
      dstY: GameRender.currentNodeDstY + 8 + Half_Height_Adj,
      anchorY: GameConstants.Sprite_Anchor_Y,
      color: color,
    );
  }

  static const Half_Height_Adj = -2.0;

  static void renderStandardNodeHalfNorth({
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
      dstX: GameRender.currentNodeDstX - 8,
      dstY: GameRender.currentNodeDstY - 8 + Half_Height_Adj,
      anchorY: GameConstants.Sprite_Anchor_Y,
      color: color,
    );
  }

  static void renderStandardNodeHalfSouth({
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
      dstX: GameRender.currentNodeDstX + 8,
      dstY: GameRender.currentNodeDstY + 8 + Half_Height_Adj,
      anchorY: GameConstants.Sprite_Anchor_Y,
      color: color,
    );
  }

}