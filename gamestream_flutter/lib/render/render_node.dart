
import 'package:gamestream_flutter/library.dart';

class RenderNode {
  static void renderNodeTorch(){
    if (!GameState.torchesIgnited.value) {
      Engine.renderSprite(
        image: GameImages.atlasNodes,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch,
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
      );
      return;
    }
    if (renderNodeWind == Wind.Calm){
      Engine.renderSprite(
        image: GameImages.atlasNodes,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch),
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
      );
      return;
    }
    Engine.renderSprite(
      image: GameImages.atlasNodes,
      srcX: AtlasNode.X_Torch_Windy,
      srcY: AtlasNode.Y_Torch_Windy + AtlasNode.Height_Torch + (((GameRender.currentNodeRow + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch),
      srcWidth: AtlasNode.Width_Torch,
      srcHeight: AtlasNode.Height_Torch,
      dstX: GameRender.currentNodeDstX,
      dstY: GameRender.currentNodeDstY,
      anchorY: AtlasNodeAnchorY.Torch,
    );
    return;
  }

  static void renderNodeWater() =>
    Engine.renderSprite(
      image: GameImages.atlasNodes,
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
        return renderStandardNodeHalfNorth(
          srcX: AtlasNodeX.Brick_Half_South,
          srcY: GameConstants.Sprite_Height * GameRender.currentNodeShade,
        );
      case NodeOrientation.Half_East:
        return renderStandardNodeHalfEast(
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
        throw Exception("renderNodeTypeBrick(orientation: ${NodeOrientation.getName(GameState.nodesOrientation[GameRender.currentNodeIndex])}");
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
        renderStandardNodeHalfNorth(
          srcX: AtlasNode.Node_Bau_Haus_Half_South_X,
          srcY: AtlasNode.Node_Bau_Haus_Half_South_Y,
          color: renderNodeColor,
        );
        break;
      case NodeOrientation.Half_East:
        renderStandardNodeHalfEast(
          srcX: AtlasNode.Node_Bau_Haus_Half_West_X,
          srcY: AtlasNode.Node_Bau_Haus_Half_West_Y,
          color: renderNodeColor,
        );
        break;
      case NodeOrientation.Half_South:
        renderStandardNode(
          srcX: AtlasNode.Node_Bau_Haus_Half_South_X,
          srcY: AtlasNode.Node_Bau_Haus_Half_South_Y,
        );
        break;
      case NodeOrientation.Half_West:
        renderStandardNode(
          srcX: AtlasNode.Node_Bau_Haus_Half_South_X,
          srcY: AtlasNode.Node_Bau_Haus_Half_South_Y,
        );
        break;
      case NodeOrientation.Corner_Top:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Corner_Top_X,
          srcY: AtlasNode.Node_Bau_Haus_Corner_Top_Y,
        );
        break;
      case NodeOrientation.Corner_Right:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Corner_Right_X,
          srcY: AtlasNode.Node_Bau_Haus_Corner_Right_Y,
        );
        break;
      case NodeOrientation.Corner_Bottom:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Corner_Bottom_X,
          srcY: AtlasNode.Node_Bau_Haus_Corner_Bottom_Y,
        );
        break;
      case NodeOrientation.Corner_Left:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Corner_Left_X,
          srcY: AtlasNode.Node_Bau_Haus_Corner_Left_Y,
        );
        break;
      case NodeOrientation.Slope_North:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Slope_North_X,
          srcY: AtlasNode.Node_Bau_Haus_Slope_North_Y,
        );
        break;
      case NodeOrientation.Slope_East:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Slope_East_X,
          srcY: AtlasNode.Node_Bau_Haus_Slope_East_Y,
        );
        break;
      case NodeOrientation.Slope_South:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Slope_South_X,
          srcY: AtlasNode.Node_Bau_Haus_Slope_South_Y,
        );
        break;
      case NodeOrientation.Slope_West:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Slope_West_X,
          srcY: AtlasNode.Node_Bau_Haus_Slope_West_Y,
        );
        break;
      case NodeOrientation.Slope_Inner_North_East:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Slope_Inner_North_East_X,
          srcY: AtlasNode.Node_Bau_Haus_Slope_Inner_North_East_Y,
        );
        break;
      case NodeOrientation.Slope_Inner_South_East:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Slope_Inner_South_East_X,
          srcY: AtlasNode.Node_Bau_Haus_Slope_Inner_South_East_Y,
        );
        break;
      case NodeOrientation.Slope_Inner_South_West:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Slope_Inner_South_West_X,
          srcY: AtlasNode.Node_Bau_Haus_Slope_Inner_South_West_Y,
        );
        break;
      case NodeOrientation.Slope_Inner_North_West:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Bau_Haus_Slope_Inner_North_West_X,
          srcY: AtlasNode.Node_Bau_Haus_Slope_Inner_North_West_Y,
        );
        break;
    }
  }

  static void renderStandardNode({
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

  static void renderStandardNodeShaded({
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

  static void renderStandardNodeHalfEast({
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

  static void renderStandardNodeHalfNorth({
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
}