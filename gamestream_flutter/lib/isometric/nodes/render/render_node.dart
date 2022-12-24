
import 'package:gamestream_flutter/library.dart';

import 'render_node_window.dart';
import 'render_node_wooden_plank.dart';

var previousVisibility = 0;

void renderNodeAt() {
  final currentNodeVisibility = GameRender.currentNodeVisibility;
  if (currentNodeVisibility == Visibility.Invisible) return;

  if (currentNodeVisibility != previousVisibility){
    previousVisibility = currentNodeVisibility;
    Engine.bufferBlendMode = VisibilityBlendModes.fromVisibility(currentNodeVisibility);
  }

  switch (GameRender.currentNodeType) {
    case NodeType.Grass:
      const index_grass = 3;
      const srcX = GameConstants.Sprite_Width_Padded * index_grass;
      renderNodeTemplateShaded(srcX);
      return;
    case NodeType.Brick:
      const index_grass = 2;
      const srcX = GameConstants.Sprite_Width_Padded * index_grass;
      renderNodeTemplateShaded(srcX);
      return;
    case NodeType.Torch:
      RenderNode.renderNodeTorch();
      break;
    case NodeType.Water:
      RenderNode.renderNodeWater();
      break;
    case NodeType.Tree_Bottom:
      Engine.renderSprite(
        image: GameImages.atlas_nodes,
        srcX: AtlasNodeX.Tree_Bottom,
        srcY: AtlasNodeY.Tree_Bottom,
        srcWidth: AtlasNode.Width_Tree_Bottom,
        srcHeight: AtlasNode.Node_Tree_Bottom_Height,
        dstX: GameRender.currentNodeDstX,
        dstY: GameRender.currentNodeDstY,
        color: renderNodeBelowColor,
      );
      break;
    case NodeType.Tree_Top:
      var shift = GameAnimation.treeAnimation[((GameRender.currentNodeRow - GameRender.currentNodeColumn) + GameAnimation.animationFrame) % GameAnimation.treeAnimation.length] * renderNodeWind;
      Engine.renderSprite(
        image: GameImages.atlas_nodes,
        srcX: AtlasNodeX.Tree_Top,
        srcY: AtlasNodeY.Tree_Top,
        srcWidth: AtlasNode.Node_Tree_Top_Width,
        srcHeight: AtlasNode.Node_Tree_Top_Height,
        dstX: GameRender.currentNodeDstX + (shift * 0.5),
        dstY: GameRender.currentNodeDstY,
        color: getRenderLayerColor(-2),
      );
      break;
    case NodeType.Grass_Long:
      switch (GameRender.currentNodeWind) {
        case WindType.Calm:
          RenderNode.renderStandardNodeShaded(
            srcX: AtlasNodeX.Grass_Long,
            srcY: 0,
          );
          return;
        default:
          RenderNode.renderStandardNodeShaded(
              srcX: AtlasNodeX.Grass_Long + ((((GameRender.currentNodeRow - GameRender.currentNodeColumn) + GameAnimation.animationFrameGrass) % 6) * 48), // TODO Expensive Operation
              srcY: 0,
          );
          return;
      }
    case NodeType.Rain_Falling:
      RenderNode.renderStandardNodeShaded(
        srcX: ClientState.srcXRainFalling,
        srcY: 72.0 * ((GameAnimation.animationFrame + GameRender.currentNodeRow + GameRender.currentNodeRow + GameRender.currentNodeColumn) % 6), // TODO Expensive Operation
      );
      return;
    case NodeType.Rain_Landing:
      if (GameQueries.getNodeTypeBelow(GameRender.currentNodeIndex) == NodeType.Water){
        Engine.renderSprite(
          image: GameImages.atlas_nodes,
          srcX: AtlasNode.Node_Rain_Landing_Water_X,
          srcY: 72.0 * ((GameAnimation.animationFrame + GameRender.currentNodeRow + GameRender.currentNodeColumn) % 10), // TODO Expensive Operation
          srcWidth: GameConstants.Sprite_Width,
          srcHeight: GameConstants.Sprite_Height,
          dstX: GameRender.currentNodeDstX,
          dstY: GameRender.currentNodeDstY + GameAnimation.animationFrameWaterHeight + 14,
          anchorY: 0.3,
          color: GameRender.currentNodeColor,
        );
        return;
      }
      RenderNode.renderStandardNodeShaded(
        srcX: ClientState.srcXRainLanding,
        srcY: 72.0 * ((GameAnimation.animationFrame + GameRender.currentNodeRow + GameRender.currentNodeColumn) % 6), // TODO Expensive Operation
      );
      return;
    case NodeType.Concrete:
      renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_8);
      return;
    case NodeType.Road:
      RenderNode.renderStandardNodeShaded(srcX: 768, srcY: 672);
      return;
    case NodeType.Road_2:
      RenderNode.renderStandardNodeShaded(srcX: 768, srcY: 672 + GameConstants.Sprite_Height_Padded);
      return;
    case NodeType.Plain:
      renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_8);
      return;
    case NodeType.Wooden_Plank:
      renderNodeWoodenPlank();
      return;
    case NodeType.Wood:
      const index_grass = 5;
      const srcX = GameConstants.Sprite_Width_Padded * index_grass;
      renderNodeTemplateShaded(srcX);
      break;
    case NodeType.Bau_Haus:
      const index_grass = 6;
      const srcX = GameConstants.Sprite_Width_Padded * index_grass;
      renderNodeTemplateShaded(srcX);
      break;
    case NodeType.Sunflower:
      RenderNode.renderStandardNodeShaded(
          srcX: 1753.0,
          srcY: AtlasNodeY.Sunflower,
      );
      return;
    case NodeType.Soil:
      const index_grass = 7;
      const srcX = GameConstants.Sprite_Width_Padded * index_grass;
      renderNodeTemplateShaded(srcX);
      return;
    case NodeType.Fireplace:
      RenderNode.renderStandardNode(
        srcX: AtlasNode.Campfire_X,
        srcY: AtlasNode.Node_Campfire_Y + ((GameAnimation.animationFrame % 6) * 72),
      );
      return;
    case NodeType.Boulder:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNodeX.Boulder,
        srcY: AtlasNodeY.Boulder,
      );
      return;
    case NodeType.Oven:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNodeX.Oven,
        srcY: AtlasNodeY.Oven,
      );
      return;
    case NodeType.Chimney:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Chimney_X,
        srcY: AtlasNode.Node_Chimney_Y,
      );
      return;
    case NodeType.Window:
      renderNodeWindow();
      break;
    case NodeType.Spawn:
      if (GameState.playMode) return;
      RenderNode.renderStandardNode(
        srcX: AtlasNode.Spawn_X,
        srcY: AtlasNode.Spawn_Y,
      );
      break;
    case NodeType.Spawn_Weapon:
      if (GameState.playMode) return;
      RenderNode.renderStandardNode(
        srcX: AtlasNode.Spawn_Weapon_X,
        srcY: AtlasNode.Spawn_Weapon_Y,
      );
      break;
    case NodeType.Spawn_Player:
      if (GameState.playMode) return;
      RenderNode.renderStandardNode(
        srcX: AtlasNode.Spawn_Player_X,
        srcY: AtlasNode.Spawn_Player_Y,
      );
      break;
    case NodeType.Table:
      RenderNode.renderStandardNode(
        srcX: AtlasNode.Table_X,
        srcY: AtlasNode.Node_Table_Y,
      );
      return;
    case NodeType.Bed_Top:
      RenderNode.renderStandardNode(
        srcX: AtlasNode.X_Bed_Top,
        srcY: AtlasNode.Y_Bed_Top,
      );
      return;
    case NodeType.Bed_Bottom:
      RenderNode.renderStandardNode(
        srcX: AtlasNode.X_Bed_Bottom,
        srcY: AtlasNode.Y_Bed_Bottom,
      );
      return;
    case NodeType.Respawning:
      return;
    default:
      throw Exception('renderNode(index: ${GameRender.currentNodeIndex}, type: ${NodeType.getName(GameRender.currentNodeType)}, orientation: ${NodeOrientation.getName(GameNodes.nodesOrientation[GameRender.currentNodeIndex])}');
  }
}

void renderNodeTemplateShaded(double srcX) {
  switch (GameRender.currentNodeOrientation){
    case NodeOrientation.Solid:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_00,
      );
      return;
    case NodeOrientation.Half_North:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_01,
        offsetX: -8,
        offsetY: -10,
      );
      return;
    case NodeOrientation.Half_South:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_01,
        offsetX: 8,
        offsetY: 6,
      );
      return;
    case NodeOrientation.Half_East:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_02,
        offsetX: 8,
        offsetY: -10,
      );
      return;
    case NodeOrientation.Half_West:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_02,
        offsetX: -8,
        offsetY: -6,
      );
      return;
    case NodeOrientation.Corner_Top:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_03,
      );
      return;
    case NodeOrientation.Corner_Right:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_04,
      );
      return;
    case NodeOrientation.Corner_Bottom:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_05,
      );
      return;
    case NodeOrientation.Corner_Left:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_06,
      );
      return;
    case NodeOrientation.Slope_North:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_07,
      );
      return;
    case NodeOrientation.Slope_East:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_08,
      );
      return;
    case NodeOrientation.Slope_South:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_09,
      );
      return;
    case NodeOrientation.Slope_West:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_10,
      );
      return;
    case NodeOrientation.Slope_Outer_South_West:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_11,
      );
      return;
    case NodeOrientation.Slope_Outer_North_West:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_12,
      );
      return;
    case NodeOrientation.Slope_Outer_North_East:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_13,
      );
      return;
    case NodeOrientation.Slope_Outer_South_East:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_14,
      );
      return;
    case NodeOrientation.Slope_Inner_South_East:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_15,
      );
      return;
    case NodeOrientation.Slope_Inner_North_East :
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_16,
      );
      return;
    case NodeOrientation.Slope_Inner_North_West:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_17,
      );
      return;
    case NodeOrientation.Slope_Inner_South_West:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_18,
      );
      return;
    case NodeOrientation.Radial:
      RenderNode.renderStandardNodeShaded(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_19,
      );
      return;
    case NodeOrientation.Half_Vertical_Top:
      RenderNode.renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_20,
          offsetX: 0,
          offsetY: -12,
      );
      return;
    case NodeOrientation.Half_Vertical_Center:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_20,
        offsetX: 0,
        offsetY: -4,
      );
      return;
    case NodeOrientation.Half_Vertical_Bottom:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_20,
        offsetX: 0,
        offsetY: 4,
      );
      return;
    case NodeOrientation.Column_Top_Left:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_21,
        offsetX: -8,
        offsetY: -12,
      );
      return;
    case NodeOrientation.Column_Top_Center:
      RenderNode.renderNodeShadedOffset(
        srcX: srcX,
        srcY: GameConstants.Sprite_Height_Padded_21,
        offsetX: 0,
        offsetY: -12,
      );
      return;

  }
}



