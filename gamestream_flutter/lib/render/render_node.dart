
import 'package:gamestream_flutter/isometric/nodes/render/render_standard_node.dart';
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
}