
import 'package:bleed_common/node_orientation.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';

import 'render_node.dart';
import 'render_standard_node.dart';

void renderNodePlain(){
  switch (nodesOrientation[renderNodeIndex]){
    case NodeOrientation.Solid:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Plain_Solid,
        srcY: 0,
        color: colorShades[nodesShade[renderNodeIndex]],
      );
    case NodeOrientation.Half_North:
      return renderStandardNodeHalfNorth(
        srcX: AtlasSrcX.Node_Plain_Half_Row_X,
        srcY: AtlasSrcX.Node_Plain_Half_Row_Y,
        color: colorShades[nodesShade[renderNodeIndex]],
      );
    case NodeOrientation.Half_East:
      return renderStandardNodeHalfEast(
        srcX: AtlasSrcX.Node_Plain_Half_Column_X,
        srcY: AtlasSrcX.Node_Plain_Half_Column_Y,
        color: colorShades[nodesShade[renderNodeIndex]],
      );
    case NodeOrientation.Half_South:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Plain_Half_Row_X,
        srcY: AtlasSrcX.Node_Plain_Half_Row_Y,
        color: colorShades[nodesShade[renderNodeIndex]],
      );
    case NodeOrientation.Half_West:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Plain_Half_Row_X,
        srcY: AtlasSrcX.Node_Plain_Half_Row_Y,
        color: colorShades[nodesShade[renderNodeIndex]],
      );
    case NodeOrientation.Corner_Top:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Plain_Corner_Top_X,
        srcY: AtlasSrcX.Node_Plain_Corner_Top_Y,
        color: colorShades[nodesShade[renderNodeIndex]],
      );
    case NodeOrientation.Corner_Right:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Plain_Corner_Right_X,
        srcY: AtlasSrcX.Node_Plain_Corner_Right_Y,
        color: colorShades[nodesShade[renderNodeIndex]],
      );
    case NodeOrientation.Corner_Bottom:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Plain_Corner_Bottom_X,
        srcY: AtlasSrcX.Node_Plain_Corner_Bottom_Y,
        color: colorShades[nodesShade[renderNodeIndex]],
      );
    case NodeOrientation.Corner_Left:
      return renderStandardNode(
        srcX: AtlasSrcX.Node_Plain_Corner_Left_X,
        srcY: AtlasSrcX.Node_Plain_Corner_Left_Y,
        color: colorShades[nodesShade[renderNodeIndex]],
      );
  }
}