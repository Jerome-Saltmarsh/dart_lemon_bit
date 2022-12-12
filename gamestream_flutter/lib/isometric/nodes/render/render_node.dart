
import 'package:gamestream_flutter/isometric/nodes/render/render_node_wood.dart';
import 'package:gamestream_flutter/library.dart';

import 'render_node_plain.dart';
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
      return renderNodeTypeGrass();
    case NodeType.Brick_2:
      RenderNode.renderNodeTypeBrick();
      return;
    case NodeType.Torch:
      RenderNode.renderNodeTorch();
      break;
    case NodeType.Water:
      RenderNode.renderNodeWater();
      break;
    case NodeType.Tree_Bottom:
      Engine.renderSprite(
        image: GameImages.atlasNodes,
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
        image: GameImages.atlasNodes,
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
          RenderNode.renderStandardNode(
            srcX: AtlasNodeX.Grass_Long,
            srcY: GameConstants.Sprite_Height * renderNodeShade,
          );
          return;
        default:
          RenderNode.renderStandardNode(
              srcX: AtlasNodeX.Grass_Long + ((((GameRender.currentNodeRow - GameRender.currentNodeColumn) + GameAnimation.animationFrameGrass) % 6) * 48),
              srcY: GameConstants.Sprite_Height * renderNodeShade,
          );
          return;
      }
    case NodeType.Rain_Falling:
      RenderNode.renderStandardNodeShaded(
        srcX: ClientState.srcXRainFalling,
        srcY: 72.0 * ((GameAnimation.animationFrame + GameRender.currentNodeRow + GameRender.currentNodeColumn) % 6),
      );
      return;
    case NodeType.Rain_Landing:
      if (GameQueries.getNodeTypeBelow(GameRender.currentNodeIndex) == NodeType.Water){
        Engine.renderSprite(
          image: GameImages.atlasNodes,
          srcX: AtlasNode.Node_Rain_Landing_Water_X,
          srcY: 72.0 * ((GameAnimation.animationFrame + GameRender.currentNodeRow + GameRender.currentNodeColumn) % 10),
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
        srcY: 72.0 * ((GameAnimation.animationFrame + GameRender.currentNodeRow + GameRender.currentNodeColumn) % 6),
      );
      return;
    case NodeType.Stone:
      RenderNode.renderStandardNodeShaded(
          srcX: AtlasNodeX.Stone,
          srcY: AtlasNodeY.Stone,
      );
      return;
    case NodeType.Plain:
      renderNodePlain();
      return;
    case NodeType.Wooden_Plank:
      renderNodeWoodenPlank();
      return;
    case NodeType.Wood_2:
      renderNodeWood();
      break;
    case NodeType.Bau_Haus_2:
      RenderNode.renderNodeBauHaus();
      break;
    case NodeType.Sunflower:
      RenderNode.renderStandardNodeShaded(
          srcX: AtlasNodeX.Sunflower,
          srcY: AtlasNodeY.Sunflower,
      );
      return;
    case NodeType.Soil:
      RenderNode.renderStandardNodeShaded(
        srcX: AtlasNode.Soil_X,
        srcY: AtlasNode.Node_Soil_Y,
      );
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

void renderNodeTypeGrass() {
  switch (GameNodes.nodesOrientation[GameRender.currentNodeIndex]) {
    case NodeOrientation.Solid:
      return RenderNode.renderStandardNode(
          srcX: GameNodes.nodesVariation[GameRender.currentNodeIndex] ? AtlasNodeX.Grass : AtlasNodeX.Grass_Flowers,
          srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_North:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_North,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_East:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_East,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_South:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_South,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_West:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_West,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_Inner_North_East:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_Inner_North_East,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_Inner_South_East:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_Inner_South_East,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_Inner_South_West:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_Inner_South_West,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_Inner_North_West:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_Inner_North_West,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_Outer_North_East:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_Outer_North_East,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_Outer_South_East:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_Outer_South_East,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_Outer_South_West:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_Outer_South_West,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    case NodeOrientation.Slope_Outer_North_West:
      return RenderNode.renderStandardNode(
        srcX: AtlasNode.Node_Grass_Slope_Outer_North_West,
        srcY: GameConstants.Sprite_Height * GameNodes.nodesShade[GameRender.currentNodeIndex],
      );
    default:
      throw Exception(
          'renderNodeTypeGrass(orientation: ${NodeOrientation.getName(GameNodes.nodesOrientation[GameRender.currentNodeIndex])}, shade: ${Shade.getName(GameNodes.nodesShade[GameRender.currentNodeIndex])}'
      );
  }
}

// void renderStandardNodeHalfNorth({
//   required double srcX,
//   required double srcY,
//   int color = 1,
// }){
//
//   colors[renderIndex] = color;
//
//   src[bufferIndex] = srcX;
//   dst[bufferIndex] = 1;
//   bufferIndex++;
//
//   src[bufferIndex] = srcY;
//   dst[bufferIndex] = 0;
//   bufferIndex++;
//
//   src[bufferIndex] = srcX + spriteWidth;
//   dst[bufferIndex] = renderNodeDstX - spriteWidthHalf - 17;
//
//   bufferIndex++;
//   src[bufferIndex] = srcY + spriteHeight;
//   dst[bufferIndex] = renderNodeDstY - spriteHeightThird - 17;
//
//   bufferIndex++;
//   renderIndex++;
//
//   if (bufferIndex < buffers) return;
//   bufferIndex = 0;
//   renderIndex = 0;
//
//   renderAtlas();
// }


// void renderStandardNodeHalfEast({
//   required double srcX,
//   required double srcY,
//   int color = 1,
// }){
//
//   colors[renderIndex] = color;
//
//   src[bufferIndex] = srcX;
//   dst[bufferIndex] = 1;
//   bufferIndex++;
//
//   src[bufferIndex] = srcY;
//   dst[bufferIndex] = 0;
//   bufferIndex++;
//
//   src[bufferIndex] = srcX + spriteWidth;
//   dst[bufferIndex] = renderNodeDstX - spriteWidthHalf + 17;
//
//   bufferIndex++;
//   src[bufferIndex] = srcY + spriteHeight;
//   dst[bufferIndex] = renderNodeDstY - spriteHeightThird - 17;
//
//   bufferIndex++;
//   renderIndex++;
//
//   if (bufferIndex < buffers) return;
//   bufferIndex = 0;
//   renderIndex = 0;
//
//   renderAtlas();
// }



double projectX(int row, int column){
  return (row - column) * Node_Size_Half;
}

double projectY(int row, int column, int z){
  return ((row + column) * Node_Size_Half) - (z * Node_Height);
}

void updateGridAnimation(){
  for (var i = 0; i < GameNodes.nodesTotal; i++){
  }
}

