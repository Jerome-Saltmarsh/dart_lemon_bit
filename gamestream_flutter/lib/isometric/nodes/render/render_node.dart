
import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/convert_index.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node_bau_haus.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node_wood.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/variables/src_x_rain_falling.dart';
import 'package:gamestream_flutter/isometric/variables/src_x_rain_landing.dart';

import 'render_constants.dart';
import 'render_node_plain.dart';
import 'render_node_torch.dart';
import 'render_node_type_brick.dart';
import 'render_node_window.dart';
import 'render_node_wooden_plank.dart';
import 'render_standard_node.dart';

void renderNodeAt() {
  if (!GameState.nodesVisible[RenderEngine.renderNodeIndex] && GameState.nodesOrientation[RenderEngine.renderNodeIndex] != NodeOrientation.None) {
    if (RenderEngine.renderNodeIndex > nodesArea){
        final nodeBelowIndex = RenderEngine.renderNodeIndex - nodesArea;
        final nodeBelowOrientation = GameState.nodesOrientation[nodeBelowIndex];
        if (nodeBelowOrientation == NodeOrientation.None) {
           return;
        }
        final renderNodeIndexColumn = convertIndexToColumn(RenderEngine.renderNodeIndex);
        final renderNodeIndexRow = convertIndexToRow(RenderEngine.renderNodeIndex);
        final renderNodeIndexZ = convertIndexToZ(RenderEngine.renderNodeIndex);
        final zDiff = (renderNodeIndexZ - RenderEngine.indexShowZ).abs();

        if (renderNodeIndexColumn > RenderEngine.indexShowColumn && renderNodeIndexRow > RenderEngine.indexShowRow){
          if (zDiff > 2 ){
            return;
          }
          var orientation = GameState.nodesOrientation[RenderEngine.renderNodeIndex];
          var srcY = 0.0;
          if (orientation == NodeOrientation.Solid) {
            srcY = 0;
          } else
          if (orientation == NodeOrientation.Slope_North) {
            srcY = spriteHeight_1;
          } else
          if (orientation == NodeOrientation.Slope_East) {
            srcY = spriteHeight_2;
          } else
          if (orientation == NodeOrientation.Slope_South) {
            srcY = spriteHeight_3;
          } else
          if (orientation == NodeOrientation.Slope_West) {
            srcY = spriteHeight_4;
          }
          return renderStandardNode(
            srcX: 8801,
            srcY: srcY,
            color: renderNodeColor,
          );
        }
    }
  }
  switch (RenderEngine.renderNodeType) {
    case NodeType.Grass:
      return renderNodeTypeGrass();
    case NodeType.Brick_2:
      return renderNodeTypeBrick(
        shade: GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeType.Torch:
      renderNodeTorch();
      break;
    case NodeType.Water:
      return renderAdvanced(
        dstX: RenderEngine.renderNodeDstX,
        dstY: RenderEngine.renderNodeDstY + animationFrameWaterHeight + 14,
        srcX: AtlasSrcX.Node_Water_X,
        srcY: AtlasSrcX.Node_Water_Y + (((animationFrameWater + ((RenderEngine.renderNodeRow + RenderEngine.renderNodeColumn) * 3)) % 10) * 72.0),
        width: spriteWidth,
        height: spriteHeight,
        anchorY: 0.3334,
        color: renderNodeColor,
      );
    case NodeType.Tree_Bottom:
      return renderAdvanced(
        dstX: RenderEngine.renderNodeDstX,
        dstY: RenderEngine.renderNodeDstY,
        srcX: AtlasSrcX.Node_Tree_Bottom_X,
        srcY: AtlasSrcX.Node_Tree_Bottom_Y,
        width: AtlasSrcX.Node_Tree_Bottom_Width,
        height: AtlasSrcX.Node_Tree_Bottom_Height,
        anchorY: 0.5,
        color: renderNodeBelowColor,
      );
    case NodeType.Tree_Top:
      var shift = treeAnimation[((RenderEngine.renderNodeRow - RenderEngine.renderNodeColumn) + animationFrame) % treeAnimation.length] * renderNodeWind;
      renderAdvanced(
        dstX: RenderEngine.renderNodeDstX + (shift * 0.5),
        dstY: RenderEngine.renderNodeDstY,
        srcX: AtlasSrcX.Node_Tree_Top_X,
        srcY: AtlasSrcX.Node_Tree_Top_Y,
        width: AtlasSrcX.Node_Tree_Top_Width,
        height: AtlasSrcX.Node_Tree_Top_Height,
        anchorY: 0.5,
        color: getRenderLayerColor(-2),
      );
      return;
    case NodeType.Grass_Long:
      switch (GameState.nodesWind[RenderEngine.renderNodeIndex]) {
        case windIndexCalm:
          renderStandardNode(
            srcX: AtlasSrcX.Node_Grass_Long,
            srcY: spriteHeight * renderNodeShade,
          );
          return;
        default:
          renderStandardNode(
              srcX: AtlasSrcX.Node_Grass_Long + ((((RenderEngine.renderNodeRow - RenderEngine.renderNodeColumn) + animationFrameGrass) % 6) * 48),
              srcY: spriteHeight * renderNodeShade,
          );
          return;
      }
    case NodeType.Rain_Falling:
        renderStandardNodeShaded(
        srcX: srcXRainFalling,
        srcY: 72.0 * ((animationFrame + RenderEngine.renderNodeRow + RenderEngine.renderNodeColumn) % 6),
      );
      return;
    case NodeType.Rain_Landing:
      if (getNodeTypeBelow(RenderEngine.renderNodeIndex) == NodeType.Water){
        renderStandardNodeShaded(
          srcX: AtlasSrcX.Node_Rain_Landing_Water_X,
          srcY: 72.0 * ((animationFrame + RenderEngine.renderNodeRow + RenderEngine.renderNodeColumn) % 10),
        );
        return;
      }
      renderStandardNodeShaded(
        srcX: srcXRainLanding,
        srcY: 72.0 * ((animationFrame + RenderEngine.renderNodeRow + RenderEngine.renderNodeColumn) % 6),
      );
      return;
    case NodeType.Stone:
      renderStandardNodeShaded(
          srcX: AtlasSrcX.Node_Stone,
          srcY: 0,
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
      renderNodeBauHaus();
      break;
    case NodeType.Sunflower:
      renderStandardNodeShaded(
          srcX: AtlasSrcX.Node_Sunflower_X,
          srcY: AtlasSrcX.Node_Sunflower_Y,
      );
      return;
    case NodeType.Soil:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Soil_X,
        srcY: AtlasSrcX.Node_Soil_Y,
      );
      return;
    case NodeType.Fireplace:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Campfire_X,
        srcY: AtlasSrcX.Node_Campfire_Y + ((animationFrame % 6) * 72),
      );
      return;
    case NodeType.Boulder:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Boulder_X,
        srcY: AtlasSrcX.Node_Boulder_Y,
      );
      return;
    case NodeType.Oven:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Oven_X,
        srcY: AtlasSrcX.Node_Oven_Y,
      );
      return;
    case NodeType.Chimney:
      renderStandardNodeShaded(
        srcX: AtlasSrcX.Node_Chimney_X,
        srcY: AtlasSrcX.Node_Chimney_Y,
      );
      return;
    case NodeType.Window:
      renderNodeWindow();
      break;
    case NodeType.Spawn:
      if (playMode) return;
      renderStandardNode(
        srcX: AtlasSrcX.Node_Spawn_X,
        srcY: AtlasSrcX.Node_Spawn_Y,
      );
      break;
    case NodeType.Spawn_Weapon:
      if (playMode) return;
      renderStandardNode(
        srcX: AtlasSrcX.Node_Spawn_X,
        srcY: AtlasSrcX.Node_Spawn_Y,
      );
      break;
    case NodeType.Spawn_Player:
      if (playMode) return;
      renderStandardNode(
        srcX: AtlasSrcX.Node_Spawn_X,
        srcY: AtlasSrcX.Node_Spawn_Y,
      );
      break;
    case NodeType.Table:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Table_X,
        srcY: AtlasSrcX.Node_Table_Y,
      );
      return;
    case NodeType.Bed_Top:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bed_Top_X,
        srcY: AtlasSrcX.Node_Bed_Top_Y,
      );
      return;
    case NodeType.Bed_Bottom:
      renderStandardNode(
        srcX: AtlasSrcX.Node_Bed_Bottom_X,
        srcY: AtlasSrcX.Node_Bed_Bottom_Y,
      );
      return;
    case NodeType.Respawning:
      return;
    default:
      throw Exception('renderNode(index: ${RenderEngine.renderNodeIndex}, type: ${NodeType.getName(RenderEngine.renderNodeType)}, orientation: ${NodeOrientation.getName(GameState.nodesOrientation[RenderEngine.renderNodeIndex])}');
  }
}

void renderNodeTypeGrass() {
  // final renderNodeInFront = renderNodeIndex + nodesArea + nodesArea + nodesTotalColumns + 1;
  //
  // if (renderNodeInFront < nodesTotal){
  //   if (nodesOrientation[renderNodeInFront] == NodeOrientation.Solid){
  //     // return;
  //   }
  // }

  switch (GameState.nodesOrientation[RenderEngine.renderNodeIndex]) {
    case NodeOrientation.Solid:
      return renderStandardNode(
          srcX: GameState.nodesVariation[RenderEngine.renderNodeIndex] ? AtlasSrcX.Node_Grass : AtlasSrcX.Node_Grass_Flowers,
          srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_North:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_North,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_East:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_East,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_South:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_South,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_West,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_Inner_North_East:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_Inner_North_East,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_Inner_South_East:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_Inner_South_East,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_Inner_South_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_Inner_South_West,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_Inner_North_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_Inner_North_West,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_Outer_North_East:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_Outer_North_East,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_Outer_South_East:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_Outer_South_East,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_Outer_South_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_Outer_South_West,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    case NodeOrientation.Slope_Outer_North_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Grass_Slope_Outer_North_West,
        srcY: spriteHeight * GameState.nodesShade[RenderEngine.renderNodeIndex],
      );
    default:
      throw Exception(
          'renderNodeTypeGrass(orientation: ${NodeOrientation.getName(GameState.nodesOrientation[RenderEngine.renderNodeIndex])}, shade: ${Shade.getName(GameState.nodesShade[RenderEngine.renderNodeIndex])}'
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
  return (row - column) * nodeSizeHalf;
}

double projectY(int row, int column, int z){
  return ((row + column) * nodeSizeHalf) - (z * nodeHeight);
}

void updateGridAnimation(){
  for (var i = 0; i < GameState.nodesTotal; i++){
  }
}

