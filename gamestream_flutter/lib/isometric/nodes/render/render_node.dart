
import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/node_size.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/convert_index.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node_bau_haus.dart';
import 'package:gamestream_flutter/isometric/nodes/render/render_node_wood.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/render/render_torch.dart';
import 'package:gamestream_flutter/isometric/variables/src_x_rain_falling.dart';
import 'package:gamestream_flutter/isometric/variables/src_x_rain_landing.dart';
import 'package:gamestream_flutter/isometric/watches/raining.dart';
import 'package:gamestream_flutter/isometric/watches/torches_ignited.dart';
import 'package:lemon_engine/actions/render_atlas.dart';
import 'package:lemon_engine/render.dart';

import 'render_constants.dart';
import 'render_node_plain.dart';
import 'render_node_type_brick.dart';
import 'render_node_wooden_plank.dart';
import 'render_standard_node.dart';

/// remove objects from the render layer to reduce garbage collection
void renderNodeAt(){
  if (!nodesVisible[renderNodeIndex] && nodesOrientation[renderNodeIndex] != NodeOrientation.None) {
    if (renderNodeIndex > nodesArea){
        final nodeBelowIndex = renderNodeIndex - nodesArea;
        final nodeBelowOrientation = nodesOrientation[nodeBelowIndex];
        if (nodeBelowOrientation == NodeOrientation.None) {
           return;
        }
        final renderNodeIndexColumn = convertIndexToColumn(renderNodeIndex);
        final renderNodeIndexRow = convertIndexToRow(renderNodeIndex);
        if (renderNodeIndexColumn > indexShowColumn && renderNodeIndexRow > indexShowRow){
          // final renderNodeIndexOrientation = nodesOrientation[renderNodeIndex];
          return renderStandardNode(
            srcX: 8801,
            srcY: 0,
            color: nodesShade[nodesShade[renderNodeIndex]],
          );
        }
    }
    // return;
  }

  onscreenNodes++;
  final shade = nodesShade[renderNodeIndex];
  final color = colorShades[shade];

  switch (renderNodeType) {
    case NodeType.Grass:
      return renderNodeTypeGrass(
          shade: shade,
      );
    case NodeType.Brick_2:
      return renderNodeTypeBrick(
        shade: shade,
      );
    case NodeType.Torch:
      if (!torchesIgnited.value) {
        return renderTorchOff(renderNodeDstX, renderNodeDstY);
      }
      if (nodesWind[renderNodeIndex] == Wind.Calm){
        return renderTorchOn(renderNodeDstX, renderNodeDstY);
      }
      return renderTorchOnWindy(renderNodeDstX, renderNodeDstY);
    case NodeType.Water:
      return render(
        dstX: renderNodeDstX,
        dstY: renderNodeDstY + animationFrameWaterHeight + 14,
        srcX: 7976,
        srcY: (((animationFrameWater + ((renderNodeRow + renderNodeColumn) * 3)) % 10) * 72.0),
        srcWidth: spriteWidth,
        srcHeight: spriteHeight,
        anchorY: 0.3334,
        color: color,
      );
    case NodeType.Tree_Bottom:
      return render(
        dstX: renderNodeDstX,
        dstY: renderNodeDstY,
        srcX: 1478,
        srcY: 0,
        srcWidth: 62.0,
        srcHeight: 74.0,
        anchorY: 0.5,
        color: color,
      );
    case NodeType.Tree_Top:
      final f = raining.value ? animationFrame % 4 : -1;
      var shift = treeAnimation[((renderNodeRow - renderNodeColumn) + animationFrame) % treeAnimation.length] * nodesWind[renderNodeIndex];
      final nodeBelowShade = nodesShade[getNodeIndexZRC(renderNodeZ > 0 ? renderNodeZ - 1 : renderNodeZ, renderNodeRow, renderNodeColumn)];

      return render(
        dstX: renderNodeDstX + (shift * 0.5),
        dstY: renderNodeDstY,
        srcX: 1541,
        srcY: 74.0 + (74 * f),
        srcWidth: 62.0,
        srcHeight: 74.0,
        anchorY: 0.5,
        color: colorShades[nodeBelowShade],
      );
    case NodeType.Grass_Long:
      switch (nodesWind[renderNodeIndex]) {
        case windIndexCalm:
          return renderStandardNode(
            srcX: 10118,
            srcY: spriteHeight * nodesShade[renderNodeIndex],
          );
        default:
          return renderStandardNode(
              srcX: 10240 + ((((renderNodeRow - renderNodeColumn) + animationFrameGrass) % 6) * 48),
              srcY: spriteHeight * nodesShade[renderNodeIndex],
          );
      }
    case NodeType.Rain_Falling:
      return render(
        dstX: renderNodeDstX - rainPosition,
        dstY: renderNodeDstY + animationFrameRain,
        srcX: srcXRainFalling,
        srcY: 72.0 * ((animationFrameRain + renderNodeRow + renderNodeColumn) % 6),
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
        color: color,
      );
    case NodeType.Rain_Landing:
      if (gridNodeZRCTypeSafe(renderNodeZ - 1, renderNodeRow, renderNodeColumn) == NodeType.Water){
        return render(
          dstX: renderNodeDstX,
          dstY: renderNodeDstY,
          srcX: 9280,
          srcY: 72.0 * ((animationFrameRain + renderNodeRow + renderNodeColumn) % 10),
          srcWidth: 48,
          srcHeight: 72,
          anchorY: 0.3334,
          color: color,
        );
      }
      return render(
        dstX: renderNodeDstX,
        dstY: renderNodeDstY,
        srcX: srcXRainLanding,
        srcY: 72.0 * ((animationFrameRain + renderNodeRow + renderNodeColumn) % 6),
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
        color: color,
      );
    case NodeType.Stone:
      return renderStandardNode(
          srcX: AtlasSrc.Node_Stone,
          srcY: 0,
          color: color,
      );
    case NodeType.Plain:
      return renderNodePlain(
        orientation: nodesOrientation[renderNodeIndex],
        dstX: renderNodeDstX,
        dstY: renderNodeDstY,
        color: color,
      );
    case NodeType.Wooden_Plank:
      return renderNodeWoodenPlank(
        orientation: nodesOrientation[renderNodeIndex],
        dstX: renderNodeDstX,
        dstY: renderNodeDstY,
        color: color,
      );
    case NodeType.Wood_2:
      renderNodeWood(
          orientation: nodesOrientation[renderNodeIndex],
          dstX: renderNodeDstX,
          dstY: renderNodeDstY,
          color: color,
      );
      break;
    case NodeType.Bau_Haus_2:
      renderNodeBauHaus(
        orientation: nodesOrientation[renderNodeIndex],
        dstX: renderNodeDstX,
        dstY: renderNodeDstY,
        color: color,
      );
      break;
    case NodeType.Sunflower:
      return renderStandardNode(
          srcX: AtlasSrc.Node_Sunflower,
          srcY: 0,
          color: color,
      );
    case NodeType.Soil:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Soil,
        srcY: 0,
        color: color,
      );
    case NodeType.Fireplace:
      return render(
        dstX: renderNodeDstX,
        dstY: renderNodeDstY,
        srcX: 6469,
        srcY: ((animationFrameTorch % 6) * 72),
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case NodeType.Boulder:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Boulder,
        srcY: 0,
        color: color,
      );
    case NodeType.Oven:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Oven,
        srcY: 0,
        color: color,
      );
    case NodeType.Chimney:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Chimney,
        srcY: 0,
        color: color,
      );
    case NodeType.Window:
      switch(nodesOrientation[renderNodeIndex]){
        case NodeOrientation.Half_North:
          return renderStandardNodeHalfNorth(
            srcX: AtlasSrc.Node_Window,
            srcY: spriteHeight,
            color: color,
          );
        case NodeOrientation.Half_East:
          return renderStandardNodeHalfEast(
            srcX: AtlasSrc.Node_Window,
            srcY: 0,
            color: color,
          );
        case NodeOrientation.Half_South:
          return renderStandardNode(
            srcX: AtlasSrc.Node_Window,
            srcY: spriteHeight,
            color: color,
          );
        case NodeOrientation.Half_West:
          return renderStandardNode(
            srcX: AtlasSrc.Node_Window,
            srcY: 0,
            color: color,
          );
      }
      break;
    case NodeType.Spawn:
      if (playMode) return;
      renderStandardNode(
        srcX: AtlasSrc.Node_Spawn,
        srcY: 0,
      );
      break;
    case NodeType.Spawn_Weapon:
      if (playMode) return;
      renderStandardNode(
        srcX: AtlasSrc.Node_Spawn,
        srcY: 0,
      );
      break;
    case NodeType.Spawn_Player:
      if (playMode) return;
      renderStandardNode(
        srcX: AtlasSrc.Node_Spawn,
        srcY: 0,
      );
      break;
    case NodeType.Respawning:
      return;
    case NodeType.Table:
      renderStandardNode(
        srcX: AtlasSrc.Node_Table,
        srcY: 0,
      );
      return;
    case NodeType.Bed_Top:
      renderStandardNode(
        srcX: AtlasSrc.Node_Bed_Top,
        srcY: 0,
      );
      return;
    case NodeType.Bed_Bottom:
      renderStandardNode(
        srcX: AtlasSrc.Node_Bed_Bottom,
        srcY: 0,
      );
      return;
    default:
      throw Exception('renderNode(index: $renderNodeIndex, type: ${NodeType.getName(renderNodeType)}, orientation: ${NodeOrientation.getName(nodesOrientation[renderNodeIndex])}');
  }
}

void renderNodeTypeGrass({
  // required double x,
  // required double y,
  // required int orientation,
  required int shade,
}) {
  switch (nodesOrientation[renderNodeIndex]) {
    case NodeOrientation.Solid:
      return renderStandardNode(
          srcX: nodesVariation[renderNodeIndex] ? AtlasSrc.Node_Grass : AtlasSrc.Node_Grass_Flowers,
          srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_North:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_North,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_East:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_East,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_South:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_South,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_West:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_West,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_Inner_North_East:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_Inner_North_East,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_Inner_South_East:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_Inner_South_East,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_Inner_South_West:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_Inner_South_West,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_Inner_North_West:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_Inner_North_West,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_Outer_North_East:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_Outer_North_East,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_Outer_South_East:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_Outer_South_East,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_Outer_South_West:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_Outer_South_West,
        srcY: spriteHeight * shade,
      );
    case NodeOrientation.Slope_Outer_North_West:
      return renderStandardNode(
        srcX: AtlasSrc.Node_Grass_Slope_Outer_North_West,
        srcY: spriteHeight * shade,
      );
    default:
      throw Exception('renderNodeTypeGrass(orientation: ${NodeOrientation.getName(nodesOrientation[renderNodeIndex])}, shade: ${Shade.getName(shade)}');
  }
}

void renderStandardNodeHalfNorth({
  required double srcX,
  required double srcY,
  int color = 1,
}){

  colors[renderIndex] = color;

  src[bufferIndex] = srcX;
  dst[bufferIndex] = 1;
  bufferIndex++;

  src[bufferIndex] = srcY;
  dst[bufferIndex] = 0;
  bufferIndex++;

  src[bufferIndex] = srcX + spriteWidth;
  dst[bufferIndex] = renderNodeDstX - spriteWidthHalf - 17;

  bufferIndex++;
  src[bufferIndex] = srcY + spriteHeight;
  dst[bufferIndex] = renderNodeDstY - spriteHeightThird - 17;

  bufferIndex++;
  renderIndex++;

  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;

  renderAtlas();
}


void renderStandardNodeHalfEast({
  required double srcX,
  required double srcY,
  int color = 1,
}){

  colors[renderIndex] = color;

  src[bufferIndex] = srcX;
  dst[bufferIndex] = 1;
  bufferIndex++;

  src[bufferIndex] = srcY;
  dst[bufferIndex] = 0;
  bufferIndex++;

  src[bufferIndex] = srcX + spriteWidth;
  dst[bufferIndex] = renderNodeDstX - spriteWidthHalf + 17;

  bufferIndex++;
  src[bufferIndex] = srcY + spriteHeight;
  dst[bufferIndex] = renderNodeDstY - spriteHeightThird - 17;

  bufferIndex++;
  renderIndex++;

  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;

  renderAtlas();
}



double projectX(int row, int column){
  return (row - column) * nodeSizeHalf;
}

double projectY(int row, int column, int z){
  return ((row + column) * nodeSizeHalf) - (z * nodeHeight);
}

void updateGridAnimation(){
  for (var i = 0; i < nodesTotal; i++){
  }
}

